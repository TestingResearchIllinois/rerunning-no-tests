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
allAzureDetailDataFlakies <- group_by(test_name) %>% filter(any(result=="pass") & (any(result="error") | any(result="failure")))

# average number of consecutive test failures for each order
# allAzureDetailData %>% filter(sum()) %>% group_by(machine_id,slug,module_path) %>%
#   group_map(split,cumsum(c(TRUE, diff(x) != 1)))

# average number of consecutive test failures for each order and module

# average number of consecutive test failures for each order and test
# - boxplot?