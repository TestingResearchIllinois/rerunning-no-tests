library(tidyverse)
library(stringr)
library(purrr)
library(scales)

# load data

# sourceDir <- getSrcDirectory(function(dummy) {dummy})
# workingdir <- paste0(sourceDir,"/")
# setwd(workingdir)

azureDetailFiles <- list.files(path="../per-test-results",recursive=T,pattern = ".csv$",full.names=T)
azureDetailFilesFiO <- list.files(path="../../all_tests_fixed_order/per-test-results",recursive=T,pattern = ".csv$",full.names=T)
azureDetailFiles <- azureDetailFiles %>% append(azureDetailFilesFiO)
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
azureDetailFilesISO <- list.files(path="../../isolation/per-test-results",recursive=T,pattern = ".csv$",full.names=T)
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
filteredModules <- read.csv("../../module-info-filtered.csv",header=F)
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

