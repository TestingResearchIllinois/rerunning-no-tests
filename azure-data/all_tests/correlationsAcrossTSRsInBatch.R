getCrossTSRStats <- function(inputData,groupingCriteria){
	return(inputData %>%
	       filter(test_result=="error" | test_result=="failure") %>%
	       group_by_at(groupingCriteria) %>%
	       arrange(run_num) %>%
	       summarize(roundsStr=paste0(run_num,collapse=" ")) %>%
	       rowwise() %>%
	       mutate(rounds=lapply(str_split(roundsStr," "),as.integer)) %>%
	       mutate(maxConsecFail=ifelse(length(rounds)>1,
						  max(lengths(split(unlist(rounds),cumsum(c(TRUE,diff(unlist(rounds)) > 1))))),
	 				   	  1)) %>%
	       mutate(avgFailDist=ifelse(sum(sapply(rounds,length))>1,mean(diff(unlist(rounds))),NA)) %>%
	       mutate(medFailDist=ifelse(length(rounds)>1,median(diff(unlist(rounds))),NA))
	       ) # return
}

createCDFPlot <- function(inputData,variable,xlab,ylab){
	return(ggplot(inputData, aes(eval(as.name(variable)))) + 
  	       stat_ecdf(geom = "step",size=1.2) + 
  	       theme_bw() + 
  	       theme(text = element_text(size=14)) +
  	       scale_y_continuous(limits=c(0,1), labels=percent) +
  	       labs(y=ylab, x=xlab)
	       ) #return
}

# average number of consecutive test failures for each order and test
allAzureFlakiesPerTest <- getCrossTSRStats(allAzureFlakies,c("machine_id","slug","module_path","test_class_order_md5sum","test_name"))
consecutiveFlakesECDF <- createCDFPlot(allAzureFlakiesPerTest,"maxConsecFail","Number of Consecutive Test Failures","Cumulative Fraction of Flaky Tests Identified across 100 Repetitions")
ggsave(plot=consecutiveFlakesECDF,"testFlakeClustersAcrossRepetitions.svg",width=5.5,scale=1.1)

# average number of consecutive test failures for each order and module
allAzureFlakiesPerModule <- getCrossTSRStats(allAzureFlakies,c("machine_id","slug","module_path","test_class_order_md5sum"))
moduleConsecutiveFlakesECDF <- createCDFPlot(allAzureFlakiesPerModule,"maxConsecFail","Number of Consecutive Test Failures","Cumulative Fraction of Flaky Tests Identified across 100 Repetitions")
ggsave(plot=moduleConsecutiveFlakesECDF,"moduleFlakeClustersAcrossRepetitions.svg",width=5.5,scale=1.1)

# average number of consecutive test failures for each order
allAzureFlakiesPerOrder <- getCrossTSRStats(allAzureFlakies,c("test_class_order_md5sum"))
consecutiveFlakesECDF <- createCDFPlot(allAzureFlakiesPerOrder,"maxConsecFail","Number of Consecutive Test Failures","Cumulative Fraction of Flaky Tests Identified across 100 Repetitions")
ggsave(plot=consecutiveFlakesECDF,"orderFlakeClustersAcrossRepetitions.svg",width=5.5,scale=1.1)

