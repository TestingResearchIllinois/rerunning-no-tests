library(tidyverse)
library(stringr)
library(purrr)
library(scales)

# load data

sourceDir <- getSrcDirectory(function(dummy) {dummy})
workingdir <- paste0(sourceDir,"/")
setwd(workingdir)

azureDetailFiles <- list.files(path="per-test-results",recursive=T,pattern = ".csv$")
azureDetailFilesFiO <- list.files(path="../all_tests_fixed_order/per-test-results",recursive=T,pattern = ".csv$")
azureDetailFiles <- azureDetailFiles %>% append(azureDetailFilesFiO)
azureDetailData <- list()
for (f in azureDetailFiles){
  frameName <- str_match(f,"(.+).csv")
  azureDetailData[[frameName[2]]] <- read.csv(paste0(paste0(workingdir,"per-test-results/"),f),
                                        na.strings = "",
                                        quote = "\"",
                                        colClasses=c("character","character","numeric","numeric","character","character","numeric","character"),
                                        stringsAsFactors = F)
}
allAzureDetailData <- bind_rows(azureDetailData) %>% mutate(slug=str_replace(slug,"https://github.com/([^/]+)/([^/]+)","\\1.\\2"))

# only flakies
allAzureFlakies <- allAzureDetailData %>% group_by(test_name) %>% filter(any(test_result=="pass") & (any(test_result=="error") | any(test_result=="failure"))) %>% ungroup()

allAzureFlakies <- as.data.frame(allAzureFlakies)