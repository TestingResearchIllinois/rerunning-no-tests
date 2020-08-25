library(stringr)

# make sure per test input data has been read in

if(!exists("getCrossTSRStats",mode="function")) {
    wd <- normalizePath(".")
    setwd(str_match(wd,"(.*/rq-data)")[[1]])
    source("readPerTestData.R")
    setwd(wd)
}

# RQ2 -- Burst lengths

allAzureFlakiesBurstsPerTest <- getCrossTSRStats(allAzureFlakies,c("test_name","machine_id","slug","module_path","test_class_order_md5sum"))

allAzureFlakiesBurstsPerOrder <- allAzureFlakiesBurstsPerTest %>%
			      	 group_by(test_name,test_class_order_md5sum) %>%
				 summarize(maxConsecFail=max(maxConsecFail),.groups="keep")

# these are summary statistics on the spread of maxBursts across different orders for each test, this should give 84 tests
orderDifferences <- allAzureFlakiesBurstsPerOrder %>%
		    ungroup(test_class_order_md5sum) %>%
		    filter(n()>1) %>%
		    summarize(minMaxBurst=min(maxConsecFail),medMaxBurst=median(maxConsecFail),avgMaxBurst=mean(maxConsecFail),maxMaxBurst=max(maxConsecFail))

cat("Smallest and largest maximal burst length observed across test execution orders:\n")
print(distinct(orderDifferences %>% select(minMaxBurst,maxMaxBurst) %>% group_by(minMaxBurst,maxMaxBurst) %>% arrange(.by_group=T)))