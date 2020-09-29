if (!require("tidyverse")) install.packages("tidyverse",dependencies=T)
if (!require("stringr")) install.packages("stringr",dependencies=T)
if (!require("purrr")) install.packages("purrr",dependencies=T)
if (!require("scales")) install.packages("scales",dependencies=T)
if (!require("svglite")) install.packages("svglite",dependencies=T)

library(tidyverse)
library(stringr)
library(purrr)
library(scales)

# read in test execution data

azureDetailFiles <- list.files(path="tso-per-test-results",recursive=T,pattern = ".csv$",full.names=T)
azureDetailData <- list()
for (f in azureDetailFiles){
  frameName <- str_match(f,"(.+).csv")
  azureDetailData[[frameName[2]]] <- read.csv(f,
                                        na.strings = "",
                                        quote = "\"",
                                        colClasses=c("character","character","numeric","numeric","character","character","numeric","character","character"),
                                        stringsAsFactors = F,
					header=F)
  colnames(azureDetailData[[frameName[2]]]) <- c("test_name","test_result","time_to_run_test","run_num","machine_id","test_class_order_md5sum","num_test_class","module_path","slug","sha")
}
allAzureDetailData <- bind_rows(azureDetailData) %>%
		   mutate(slug=str_replace(slug,"https://github.com/([^/]+)/([^/]+)","\\1.\\2"))

# read in isolation run data

azureDetailFilesISO <- list.files(path="iso-per-test-results",recursive=T,pattern = ".csv$",full.names=T)
azureDetailDataISO <- list()
for (f in azureDetailFilesISO){
  frameName <- str_match(f,"(.+).csv")
  azureDetailDataISO[[frameName[2]]] <- read.csv(f,
                                        na.strings = "",
                                        quote = "\"",
                                        colClasses=c("character","character","numeric","numeric","character","character","numeric","character","character"),
                                        stringsAsFactors = F,
					header=F)
  colnames(azureDetailDataISO[[frameName[2]]]) <- c("test_name","test_result","time_to_run_test","run_num","machine_id","test_class_order_md5sum","num_test_class","module_path","slug","sha")
}
allAzureDetailDataISO <- bind_rows(azureDetailDataISO) %>%
		   mutate(slug=str_replace(slug,"https://github.com/([^/]+)/([^/]+)","\\1.\\2"))

# remove filtered modules

filteredModules <- read.csv("module-info-filtered.csv",header=F)
colnames(filteredModules) <- c("slug","sha","some_test_name","module_path","some_number")
filteredModules <- filteredModules %>%
		select(slug,module_path) %>%
		mutate(slug=str_replace(slug,"https://github.com/([^/]+)/([^/]+)","\\1.\\2"))
allAzureDetailData <- semi_join(allAzureDetailData,filteredModules,by=c("slug","module_path"))

# only flakies

allAzureFlakies <- allAzureDetailData %>%
		group_by(test_name) %>%
		filter(any(test_result=="pass") & (any(test_result=="error") | any(test_result=="failure"))) %>% ungroup()

allAzureFlakiesISO <- allAzureDetailDataISO %>%
		 group_by(test_name) %>%
		 filter(any(test_result=="pass") & (any(test_result=="error") | any(test_result=="failure"))) %>% ungroup()

# helper function to extract the maximal number of consecutive failures

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