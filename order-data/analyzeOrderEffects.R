library(dplyr)
library(stringr)
library(openssl)

# make sure per test input data has been read in

if(!exists("allAzureFlakies")) {
    wd <- normalizePath(".")
    setwd(paste0(str_match(wd,"(.*/rerunning-no-tests)")[[1]],"/azure-data/rq-data"))
    source("readPerTestDataTSO.R")
    setwd(wd)
}

# read names of tests that are identical to their class names

doNotExtractClassName <- read.csv("flakyTestNamesThatEqualClassNames.csv",stringsAsFactors=F)

# get some per class info that's easiest integrated when processing order data below

uniqueTestNames <- as.data.frame(allAzureDetailData %>%
				 ungroup() %>%
				 distinct(test_name))

testClasses <- uniqueTestNames %>%
	       mutate(test_class=ifelse(test_name %in% doNotExtractClassName$test_class,test_name,str_match(test_name,"(.+)\\.[^\\.]+$")[,2]))

testsPerClass <- as.data.frame(allAzureDetailData %>%
				 ungroup() %>%
				 distinct(test_name)) %>%
		 mutate(test_class=ifelse(test_name %in% doNotExtractClassName$test_class,test_name,str_match(test_name,"(.+)\\.[^\\.]+$")[,2])) %>%
	         group_by(test_class) %>%
	         summarize(number_tests_in_class=n())

# make sure order data has been read in

if(!exists("orderData")) {
    wd <- normalizePath(".")
    setwd(str_match(wd,"(.*/order-data)")[[1]])
    source("readOrderData.R")
    setwd(wd)
}

allAzureDetailDataOrders <- allAzureFlakies %>%
			    ungroup() %>%
			    left_join(testClasses,by=c("test_name"))

allAzureDetailDataOrders <- allAzureDetailDataOrders %>%
			    group_by(machine_id,slug,run_num,test_class_order_md5sum,module_path,test_class) %>%
			    mutate(test_method_order=paste0(test_name,collapse=","),method_position=row_number()) %>%
			    ungroup()

allAzureDetailDataOrders <- allAzureDetailDataOrders %>%
			    left_join(orderData,by=c("slug","module_path","test_class","test_class_order_md5sum")) %>%
			    mutate(total_positions=total_tests_in_module,absolute_position=tests_before+method_position,relative_position=absolute_position/total_positions) %>%
			    group_by(slug,module_path,test_name) %>%
			    mutate(max_exec_position=max(absolute_position)) %>%
			    ungroup() %>%
			    mutate(relative_exec_position=absolute_position/max_exec_position)

ordersPlot <- ggplot(allAzureDetailDataOrders %>% filter(test_result!="pass") %>% group_by(test_name) %>% mutate(fail_count=n(),different_positions=n_distinct(absolute_position)) %>% ungroup() %>% filter(fail_count>1 & different_positions>1),
	             aes(x=relative_position, y=str_trunc(test_name,width=15,side="left"))) +
	      geom_point() +
	      facet_wrap(c("slug","module_path"),nrow=5,scales="free_y") +
	      labs(x="Relative Position of Failing Tests in Test Suite Execution",y="Test Name")

ggsave(filename="failPosScatterplot.svg",plot=ordersPlot,width=22,height=9)

# uniqueOrdersPerClass <- as.data.frame(allAzureDetailDataOrders %>%
# 		     		      distinct(test_class,test_method_order))

# uniqueOrdersPerClass <- uniqueOrdersPerClass %>%
# 		     	mutate(test_method_order_md5sum=md5(test_method_order))

# allAzureDetailDataOrders <- allAzureDetailDataOrders %>%
# 			    left_join(uniqueOrdersPerClass,by=c("test_class","test_method_order"))

