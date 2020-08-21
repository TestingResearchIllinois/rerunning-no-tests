if (!require("tidyverse")) install.packages("tidyverse",dependencies=T)
if (!require("stringr")) install.packages("stringr",dependencies=T)
if (!require("purrr")) install.packages("purrr",dependencies=T)
if (!require("scales")) install.packages("scales",dependencies=T)
if (!require("svglite")) install.packages("svglite",dependencies=T)

library(tidyverse)
library(stringr)
library(purrr)
library(scales)

# read in test suite execution data

azureDetailFiles <- list.files(path="./per-test-results",recursive=T,pattern = ".csv$",full.names=T)
azureDetailData <- list()
for (f in azureDetailFiles){
  frameName <- str_match(f,"(.+).csv")
  azureDetailData[[frameName[2]]] <- read.csv(f,
                                        na.strings = "",
                                        quote = "\"",
                                        colClasses=c("character","character","numeric","numeric","character","character","numeric","character","character"),
                                        stringsAsFactors = F)
}
allAzureDetailData <- bind_rows(azureDetailData) %>%
		   mutate(slug=str_replace(slug,"https://github.com/([^/]+)/([^/]+)","\\1.\\2"))

# read in isolation run data

azureDetailFilesISO <- list.files(path="./isolation/per-test-results",recursive=T,pattern = ".csv$",full.names=T)
azureDetailDataISO <- list()
for (f in azureDetailFilesISO){
  frameName <- str_match(f,"(.+).csv")
  azureDetailDataISO[[frameName[2]]] <- read.csv(f,
                                        na.strings = "",
                                        quote = "\"",
                                        colClasses=c("character","character","numeric","numeric","character","character","numeric","character","character"),
                                        stringsAsFactors = F)
}
allAzureDetailDataISO <- bind_rows(azureDetailDataISO) %>%
		   mutate(slug=str_replace(slug,"https://github.com/([^/]+)/([^/]+)","\\1.\\2"))

# remove filtered modules

filteredModules <- read.csv("module-info-filtered.csv",header=F)
colnames(filteredModules) <- c('slug','sha','some_test_name','module_path','some_number')
filteredModules <- filteredModules %>%
		select(slug,module_path) %>%
		mutate(slug=str_replace(slug,"https://github.com/([^/]+)/([^/]+)","\\1.\\2"))
allAzureDetailData <- semi_join(allAzureDetailData,filteredModules,by=c("slug","module_path"))
# allAzureDetailDataISO <- semi_join(allAzureDetailDataISO,filteredModules,by=c("slug","module_path"))

# only flakies

allAzureFlakies <- allAzureDetailData %>%
		group_by(test_name) %>%
		filter(any(test_result=="pass") & (any(test_result=="error") | any(test_result=="failure"))) %>% ungroup()

allAzureFlakiesISO <- allAzureDetailDataISO %>%
		 group_by(test_name) %>%
		 filter(any(test_result=="pass") & (any(test_result=="error") | any(test_result=="failure"))) %>% ungroup()

# Function definitions

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
	       ) # return
}

# RQ1 - Flake rates

overallFailRateISO <- allAzureFlakiesISO %>% group_by(test_name) %>% summarize(rate=(n()-sum(test_result=="pass"))/n())
overallFailRateTS <- allAzureFlakies %>% group_by(test_name) %>% summarize(rate=(n()-sum(test_result=="pass"))/n())

# RQ1 - Max Bursts

# allAzureFlakiesBurstsPerTest <- getCrossTSRStats(allAzureFlakies,c("test_name","machine_id","slug","module_path","test_class_order_md5sum"))
# allAzureFlakiesBurstsPerOrder <- allAzureFlakiesBurstsPerTest %>% group_by(test_name,test_class_order_md5sum) %>% summarize(maxConsecFail=max(maxConsecFail))
# allAzureFlakiesBurstsPerTest <- allAzureFlakiesBurstsPerTest %>% group_by(test_name) %>% summarize(maxConsecFail=max(maxConsecFail))

# TSOMaxBurstsECDF <- ggplot(allAzureFlakiesBurstsPerTest, aes(x=maxConsecFail)) + 
#   	       stat_ecdf(geom = "step",size=1.2) + 
#   	       theme_bw() + 
#   	       theme(text = element_text(size=20)) +
#   	       scale_y_continuous(limits=c(0,1), labels=percent) +
# 	       scale_x_continuous(breaks=c(0,5,10,seq(20,100,20)),minor_breaks=c(seq(30,90,20))) +
#   	       labs(y="Cumulative Fraction Across Tests", x="Test Failure Burst Length")
# ggsave(plot=TSOMaxBurstsECDF,file="TSOBurstsByTest.svg")

allAzureFlakiesBurstsPerTestISO <- getCrossTSRStats(allAzureFlakiesISO,c("test_name","machine_id","slug","module_path","test_class_order_md5sum"))
allAzureFlakiesBurstsPerTestISO <- allAzureFlakiesBurstsPerTestISO %>% group_by(test_name) %>% summarize(maxConsecFail=max(maxConsecFail))
combinedMaxBursts <- full_join(allAzureFlakiesBurstsPerTest %>% select(test_name,TSO=maxConsecFail),allAzureFlakiesBurstsPerTestISO %>% select(test_name,ISO=maxConsecFail))
combinedMaxBurstsTransformed <- gather(combinedMaxBursts,howRun,maxBurst,2:3)

combinedMaxBurstsInner <- inner_join(allAzureFlakiesBurstsPerTest %>% select(test_name,TSO=maxConsecFail),allAzureFlakiesBurstsPerTestISO %>% select(test_name,ISO=maxConsecFail))
combinedMaxBurstsTransformedInner <- gather(combinedMaxBurstsInner,howRun,maxBurst,TSO:ISO)

combinedMaxBurstsECDFInner <- ggplot(combinedMaxBurstsTransformedInner, aes(x=maxBurst,group=howRun,shape=howRun,color=howRun)) + 
  	       stat_ecdf(geom = "step",size=1) +
  	       theme_bw() + 
  	       theme(text = element_text(size=15),legend.position = c(.65,.2),legend.key.width=unit(1,"cm")) +
  	       scale_y_continuous(limits=c(0,1), labels=percent) +
	       scale_x_continuous(breaks=c(0,5,10,seq(20,100,20)),minor_breaks=c(seq(30,90,20))) +	       
  	       labs(y="Cumulative Fraction Across Tests", x="Maximal Test Failure Burst Length",color="Test Run Configuration") +
	       #scale_color_discrete(name="",breaks=c("ISO","TSO"),labels=c("ISO","TSO")) +
	       scale_color_grey(name="",breaks=c("TSO","ISO"),labels=c("TSO","ISO"),end=0.7) +
  	       scale_shape_manual(name="",values=0:1,breaks=c("TSO","ISO"),labels=c("TSO","ISO"))
ggsave(plot=combinedMaxBurstsECDFInner,file="burstsByTestCombined.svg")

# RQ3 -- Hypothesis tests

TSOFailRates <- allAzureFlakies %>% group_by(test_name) %>% summarize(TSO=(1-sum(test_result=="pass")/n()))
ISOFailRates <- allAzureFlakiesISO %>% group_by(test_name) %>% summarize(ISO=(1-sum(test_result=="pass")/n()))
combinedFailRates <- full_join(TSOFailRates,ISOFailRates,by="test_name") %>% replace_na(list(TSO=0,ISO=0))
wilcox.test(combinedFailRates$TSO,combinedFailRates$ISO,paired=T,alternative="two.sided")
ks.test(combinedFailRates$TSO,combinedFailRates$ISO,alternative="two.sided")

# RQ3 -- Fail rate ECDF

#combinedFailRatesTransformed <- combinedFailRates %>% gather(howRun,failRate,2:3)
#combinedFailRatesECDF <- ggplot(combinedFailRatesTransformed, aes(x=failRate,group=howRun,linetype=howRun,color=howRun)) + 
  	       # stat_ecdf(geom = "step",size=1.2) + 
  	       # theme_bw() + 
  	       # theme(text = element_text(size=20),legend.position = "top",legend.key.width=unit(1,"cm")) +
  	       # scale_y_continuous(limits=c(0,1), labels=percent) +
  	       # labs(y="Cumulative Fraction Across Tests", x="Test Failure Rate") +
	       # scale_color_discrete(name="",breaks=c("ISO","TSO"),labels=c("ISO","TSO")) +
  	       # scale_linetype_discrete(name="",breaks=c("ISO","TSO"),labels=c("ISO","TSO"))
#ggsave(plot=combinedFailRatesECDF,file="FailRatesByTest.svg")

# RQ2 -- Burst lengths

allAzureFlakiesBurstsPerTest <- getCrossTSRStats(allAzureFlakies,c("test_name","machine_id","slug","module_path","test_class_order_md5sum"))
allAzureFlakiesBurstsPerOrder <- allAzureFlakiesBurstsPerTest %>% group_by(test_name,test_class_order_md5sum) %>% summarize(maxConsecFail=max(maxConsecFail),.groups="keep")

# Manually checked that allAzureFlakiesBurstsPerOrder does NOT contain the tests filtered for the per order fail rate discussion

# these are summary statistics on the spread of maxBursts across different orders for each test, this should give 84 tests
orderDifferences <- allAzureFlakiesBurstsPerOrder %>% ungroup(test_class_order_md5sum) %>% filter(n()>1) %>% summarize(minMaxBurst=min(maxConsecFail),medMaxBurst=median(maxConsecFail),avgMaxBurst=mean(maxConsecFail),maxMaxBurst=max(maxConsecFail))

# tests that only fail in one order
singleOrderFails <- allAzureFlakiesBurstsPerOrder %>% ungroup(test_class_order_md5sum) %>% filter(n()==1) %>% distinct(test_name)

# orders for which the tests that fail in only one order were run
allAzureDetailData %>% filter(test_name %in% singleOrderFails$test_name) %>% group_by(test_name) %>% summarize(orders=n_distinct(test_class_order_md5sum))

# RQ3: Max burst length ECDF for ISO vs. TSO

# allAzureFlakiesBurstsPerTestISO <- getCrossTSRStats(allAzureFlakiesISO,c("test_name","machine_id","slug","module_path","test_class_order_md5sum"))
# allAzureFlakiesBurstsPerTestISO <- allAzureFlakiesBurstsPerTestISO %>% group_by(test_name) %>% summarize(maxConsecFail=max(maxConsecFail))
# combinedMaxBursts <- full_join(allAzureFlakiesBurstsPerTest %>% select(test_name,TSO=maxConsecFail),allAzureFlakiesBurstsPerTestISO %>% select(test_name,ISO=maxConsecFail))
# combinedMaxBurstsTransformed <- gather(combinedMaxBursts,howRun,maxBurst,2:3)

# combinedMaxBurstsInner <- inner_join(allAzureFlakiesBurstsPerTest %>% select(test_name,TSO=maxConsecFail),allAzureFlakiesBurstsPerTestISO %>% select(test_name,ISO=maxConsecFail))
# combinedMaxBurstsTransformedInner <- gather(combinedMaxBurstsInner,howRun,maxBurst,TSO:ISO)

# combinedMaxBurstsTransformedInner$howRun <- factor(combinedMaxBurstsTransformedInner$howRun,levels=rev(levels(factor(combinedMaxBurstsTransformedInner$howRun))))

# combinedblahMaxBurstsECDF <- ggplot(combinedMaxBurstsTransformedInner, aes(x=maxBurst,group=howRun,color=howRun)) +
#   	       stat_ecdf(geom = "step",size=1) +
#   	       theme_bw() + 
#   	       theme(text = element_text(size=15),legend.position=c(0.65,0.2),legend.key.width=unit(1,"cm")) +
#   	       scale_y_continuous(limits=c(0,1), labels=percent) +
# 	       scale_x_continuous(breaks=c(0,5,10,seq(20,100,20)),minor_breaks=c(seq(30,90,20))) +
#   	       labs(y="Cumulative Fraction Across Tests", x="Maximal Test Failure Burst Length",color="Test Run Configuration") +
# 	       #scale_color_discrete(name="",breaks=c("TSO","ISO"),labels=c("TSO","ISO")) +
# 	       scale_color_grey(name="Test Run Configuration",breaks=c("TSO","ISO"),labels=c("TSO","ISO"),end=0.7) +
# #  	       scale_shape_manual(name="",values=0:1,breaks=c("TSO","ISO"),labels=c("TSO","ISO"))
# ggsave(plot=combinedblahMaxBurstsECDF,file="ISO_TSOBurstsByTest.svg",width=5,height=4.3)

# combinedFailRatesTransformed$howRun <- factor(combinedFailRatesTransformed$howRun,levels=rev(levels(factor(combinedFailRatesTransformed$howRun))))

# Figure that integrates the TSO max burst length CDF (RQ1) with a CDF for average failure rates (RQ1)
# overallFailRateTS <- allAzureFlakies %>% group_by(test_name) %>% summarize(rate=(n()-sum(test_result=="pass"))/n())
# allAzureFlakiesOrderFailRates <- allAzureFlakies %>% group_by(test_name,machine_id,test_class_order_md5sum) %>% summarize(orderRate=sum(test_result != "pass")/n())
# TSOMaxBurstsECDF <- ggplot() + 
#   	       stat_ecdf(geom = "step",size=1,aes(x=allAzureFlakiesBurstsPerTest$maxConsecFail,color="black")) +
# 	       stat_ecdf(geom = "step",size=1,aes(x=allAzureFlakiesOrderFailRates$orderRate*100,color="grey")) +
#   	       theme_bw() + 
#   	       theme(text = element_text(size=15),axis.line.x.top=element_line(color="grey"),axis.title.x.top=element_text(color="grey"),axis.line.x.bottom=element_line(color="black"),axis.text.x.bottom=element_text(color="black"),axis.text.x.top=element_text(color="grey"),axis.ticks.x.top=element_line(color="grey"),legend.position=c(0.7,0.2)) +
#   	       scale_y_continuous(limits=c(0,1), labels=percent) +
# 	       scale_x_continuous(breaks=c(0,5,10,seq(20,100,20)),minor_breaks=c(seq(30,90,20)),sec.axis=sec_axis(~./2,name="Failure Rate [%]")) +
# #	       scale_color_manual("",values=c("black","grey"),labels=c("Max. Burst Length","Failure Rate"),breaks=c("Max. Burst Length","Failure Rate")) +
# 	       scale_color_identity(name="Metric",breaks=c("black","grey"),labels=c("Max. Burst Length","Failure Rate"),guide = "legend") + 
#   	       labs(y="Cumulative Fraction Across Tests", x="Maximal Test Failure Burst Length",color="Metric")
# ggsave(plot=TSOMaxBurstsECDF,file="TSORatesAndBurstsByTest.svg",height=4.3,width=5)

# RQ1: ECDF for max burst lengths per test in TSO

allAzureFlakiesBurstsPerTest <- getCrossTSRStats(allAzureFlakies,c("test_name","machine_id","slug","module_path","test_class_order_md5sum"))
allAzureFlakiesBurstsPerOrder <- allAzureFlakiesBurstsPerTest %>% group_by(test_name,test_class_order_md5sum) %>% summarize(maxConsecFail=max(maxConsecFail))
allAzureFlakiesBurstsPerTest <- allAzureFlakiesBurstsPerTest %>% group_by(test_name) %>% summarize(maxConsecFail=max(maxConsecFail))

TSOMaxBurstsECDF <- ggplot(allAzureFlakiesBurstsPerTest, aes(x=maxConsecFail)) + 
  	       stat_ecdf(geom = "step",size=1.2) + 
  	       theme_bw() + 
  	       theme(text = element_text(size=15),legend.position=c(0.7,0.2)) +
  	       scale_y_continuous(limits=c(0,1), labels=percent) +
	       scale_x_continuous(breaks=c(0,5,10,seq(20,100,20)),minor_breaks=c(seq(30,90,20))) +
  	       labs(y="Cumulative Fraction Across Tests", x="Maximal Test Failure Burst Length")
ggsave(plot=TSOMaxBurstsECDF,file="TSOBurstsByTest.svg",width=5,height=4.3)