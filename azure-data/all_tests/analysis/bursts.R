getCrossTSRStats <- function(inputData,groupingCriteria){
	return(inputData %>%
	       filter(test_result=="error" | test_result=="failure") %>%
	       group_by_at(groupingCriteria) %>%
	       arrange(run_num) %>%
	       summarize(roundsStr=paste0(run_num,collapse=" ")) %>%
	       rowwise() %>%
	       mutate(rounds=lapply(str_split(roundsStr," "),as.integer)) %>%
	       mutate(rounds=list(unique(unlist(rounds)))) %>%
	       mutate(maxConsecFail=ifelse(length(rounds)>1,
						  max(lengths(split(unlist(rounds),cumsum(c(TRUE,diff(unlist(rounds)) > 1))))),
	 				   	  1)) %>%
	       mutate(failDist=list(diff(unlist(rounds))))
	       ) # return
}

createCDFPlot <- function(inputData,variable,xlab,ylab){
	return(ggplot(inputData, aes(eval(as.name(variable)))) + 
  	       stat_ecdf(geom = "step",size=1.2) + 
  	       theme_bw() + 
  	       theme(text = element_text(size=20)) +
  	       scale_y_continuous(limits=c(0,1), labels=percent) +
  	       labs(y=ylab, x=xlab)
	       ) #return
}

createScatterPlot <- function(inputData,x.in,y.in,xlab,ylab){
	return(ggplot(inputData, aes(x=eval(as.name(x.in)),y=eval(as.name(y.in)))) + 
  	       geom_point(na.rm=T) + 
  	       theme_bw() + 
  	       theme(text = element_text(size=14)) +
  	       #scale_y_continuous(limits=c(0,1), labels=percent) +
  	       labs(y=ylab, x=xlab)
	       ) #return
}

# maximum number of consecutive test failures for each order and test
# allAzureFlakiesPerTest <- getCrossTSRStats(allAzureFlakies,c("machine_id","slug","module_path","test_class_order_md5sum","test_name"))
# consecutiveFlakesECDF <- createCDFPlot(allAzureFlakiesPerTest,"maxConsecFail","Number of Consecutive Test Failures","Cumulative Fraction of Flaky Tests Identified across 100 Repetitions")
# ggsave(plot=consecutiveFlakesECDF,"testFlakeClustersAcrossRepetitions.svg",width=5.5,scale=1.1)

# maximum number of consecutive test failures for each order and module
# allAzureFlakiesPerModule <- getCrossTSRStats(allAzureFlakies,c("machine_id","slug","module_path","test_class_order_md5sum"))
# moduleConsecutiveFlakesECDF <- createCDFPlot(allAzureFlakiesPerModule,"maxConsecFail","Number of Consecutive Test Failures","Cumulative Fraction of Flaky Tests Identified across 100 Repetitions")
# ggsave(plot=moduleConsecutiveFlakesECDF,"moduleFlakeClustersAcrossRepetitions.svg",width=5.5,scale=1.1)

# maximum number of consecutive test failures for each order
# allAzureFlakiesPerOrder <- getCrossTSRStats(allAzureFlakies,c("test_class_order_md5sum"))
# consecutiveFlakesECDF <- createCDFPlot(allAzureFlakiesPerOrder,"maxConsecFail","Number of Consecutive Test Failures","Cumulative Fraction of Flaky Tests Identified across 100 Repetitions")
# ggsave(plot=consecutiveFlakesECDF,"orderFlakeClustersAcrossRepetitions.svg",width=5.5,scale=1.1)

# allAzureFlakiesResults <- allAzureFlakies %>% rowwise() %>% mutate(test_result=recode(test_result,"pass"=0,"error"=1,"failure"=1))

# allAzureFlakiesResults <- allAzureFlakiesResults %>% group_by(machine_id,slug,module_path,test_class_order_md5sum,test_result) %>% summarize(logit.p=coef(summary(glm(test_result ~ run_num,data=.,family=binomial(logit))))[2,4])

# RQ1 - Flake rates

# overallFailRateISO <- allAzureFlakiesISO %>% group_by(test_name) %>% summarize(rate=(n()-sum(test_result=="pass"))/n())
# overallFailRateTS <- allAzureFlakies %>% group_by(test_name) %>% summarize(rate=(n()-sum(test_result=="pass"))/n())


# RQ1 - Max Bursts

allAzureFlakiesBurstsPerTest <- getCrossTSRStats(allAzureFlakies,c("test_name","machine_id","slug","module_path","test_class_order_md5sum"))
allAzureFlakiesBurstsPerOrder <- allAzureFlakiesBurstsPerTest %>% group_by(test_name,test_class_order_md5sum) %>% summarize(maxConsecFail=max(maxConsecFail))
allAzureFlakiesBurstsPerTest <- allAzureFlakiesBurstsPerTest %>% group_by(test_name) %>% summarize(maxConsecFail=max(maxConsecFail))

TSOMaxBurstsECDF <- ggplot(allAzureFlakiesBurstsPerTest, aes(x=maxConsecFail)) + 
  	       stat_ecdf(geom = "step",size=1.2) + 
  	       theme_bw() + 
  	       theme(text = element_text(size=20)) +
  	       scale_y_continuous(limits=c(0,1), labels=percent) +
	       scale_x_continuous(breaks=c(0,5,10,seq(20,100,20)),minor_breaks=c(seq(30,90,20))) +
  	       labs(y="Cumulative Fraction Across Tests", x="Test Failure Burst Length")
#	       scale_color_discrete(name="",breaks=c("ISO","TSO"),labels=c("ISO","TSO")) +
 # 	       scale_linetype_discrete(name="",breaks=c("ISO","TSO"),labels=c("ISO","TSO"))
ggsave(plot=TSOMaxBurstsECDF,file="TSOBurstsByTest.svg")

allAzureFlakiesBurstsPerTestISO <- getCrossTSRStats(allAzureFlakiesISO,c("test_name","machine_id","slug","module_path","test_class_order_md5sum"))
allAzureFlakiesBurstsPerTestISO <- allAzureFlakiesBurstsPerTestISO %>% group_by(test_name) %>% summarize(maxConsecFail=max(maxConsecFail))
combinedMaxBursts <- full_join(allAzureFlakiesBurstsPerTest %>% select(test_name,TSO=maxConsecFail),allAzureFlakiesBurstsPerTestISO %>% select(test_name,ISO=maxConsecFail))
combinedMaxBurstsTransformed <- gather(combinedMaxBursts,howRun,maxBurst,2:3)

combinedMaxBurstsECDF <- ggplot(combinedMaxBurstsTransformed, aes(x=maxBurst,group=howRun,linetype=howRun,color=howRun)) + 
  	       stat_ecdf(geom = "step",size=1.2) + 
  	       theme_bw() + 
  	       theme(text = element_text(size=20),legend.position = "top",legend.key.width=unit(1,"cm")) +
  	       scale_y_continuous(limits=c(0,1), labels=percent) +
  	       labs(y="Cumulative Fraction Across Tests", x="Test Failure Burst Length") +
	       scale_color_discrete(name="",breaks=c("ISO","TSO"),labels=c("ISO","TSO")) +
  	       scale_linetype_discrete(name="",breaks=c("ISO","TSO"),labels=c("ISO","TSO"))
ggsave(plot=combinedMaxBurstsECDF,file="burstsByTest.svg")

# first TSO plateau
ecdf((combinedMaxBurstsTransformed %>% filter(howRun=="TSO"))$maxBurst)(6)

# ISO exceeds TSO here
ecdf((combinedMaxBurstsTransformed %>% filter(howRun=="TSO"))$maxBurst)(10)

combinedMaxBurstsInner <- inner_join(allAzureFlakiesBurstsPerTest %>% select(test_name,TSO=maxConsecFail),allAzureFlakiesBurstsPerTestISO %>% select(test_name,ISO=maxConsecFail))
combinedMaxBurstsTransformedInner <- gather(combinedMaxBurstsInner,howRun,maxBurst,2:3)

combinedMaxBurstsECDFInner <- ggplot(combinedMaxBurstsTransformedInner, aes(x=maxBurst,group=howRun,linetype=howRun,color=howRun)) + 
  	       stat_ecdf(geom = "step",size=1.2) + 
  	       theme_bw() + 
  	       theme(text = element_text(size=20),legend.position = "top",legend.key.width=unit(1,"cm")) +
  	       scale_y_continuous(limits=c(0,1), labels=percent) +
	       scale_x_continuous(breaks=c(0,5,10,seq(20,100,20)),minor_breaks=c(seq(30,90,20))) +	       
  	       labs(y="Cumulative Fraction Across Tests", x="Test Failure Burst Length") +
	       scale_color_discrete(name="",breaks=c("ISO","TSO"),labels=c("ISO","TSO")) +
  	       scale_linetype_discrete(name="",breaks=c("ISO","TSO"),labels=c("ISO","TSO"))
ggsave(plot=combinedMaxBurstsECDFInner,file="burstsByTestInner.svg")

# RQ4 -- Hypothesis tests

TSOFailRates <- allAzureFlakies %>% group_by(test_name) %>% summarize(failRateTSO=(1-sum(test_result=="pass")/n()))
ISOFailRates <- allAzureFlakiesISO %>% group_by(test_name) %>% summarize(failRateISO=(1-sum(test_result=="pass")/n()))
combinedFailRates <- full_join(TSOFailRates,ISOFailRates,by="test_name") %>% replace_na(list(failRateTSO=0,failRateISO=0))
wilcox.test(combinedFailRates$failRateTSO,combinedFailRates$failRateISO,paired=T,alternative="two.sided")
ks.test(combinedFailRates$failRateTSO,combinedFailRates$failRateISO,alternative="two.sided")