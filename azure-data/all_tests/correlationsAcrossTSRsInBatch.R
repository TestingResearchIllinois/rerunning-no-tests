library(tidyverse)
library(stringr)
library(purrr)

# load data

sourceDir <- getSrcDirectory(function(dummy) {dummy})
workingdir <- paste0(sourceDir,"/")
setwd(workingdir)

azureDetailFiles <- list.files(path="per-test-results",recursive=T,pattern = ".csv$")
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
allAzureFlakies <- allAzureDetailData %>% group_by(test_name) %>% filter(any(test_result=="pass") & (any(test_result=="error") | any(test_result=="failure")))

# average number of consecutive test failures for each order
allAzureFlakies %>%
	filter(test_result=="error" | test_result=="failure") %>%
	group_by(machine_id,slug,module_path,test_name) %>%
	arrange(run_num) %>%
	summarize(rounds=paste0(run_num,collapse=" ")) %>%
	mutate(rounds=lapply(str_split(rounds," "),as.integer)) %>%
	mutate(rounds=max(lengths(split(unlist(rounds),cumsum(c(TRUE,diff(unlist(rounds)) != 1))))))

# average number of consecutive test failures for each order and module

# average number of consecutive test failures for each order and test
# - boxplot?