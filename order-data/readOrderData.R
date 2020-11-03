if (!require("tidyverse")) install.packages("tidyverse",dependencies=T)
if (!require("stringr")) install.packages("stringr",dependencies=T)
if (!require("purrr")) install.packages("purrr",dependencies=T)
if (!require("scales")) install.packages("scales",dependencies=T)
if (!require("svglite")) install.packages("svglite",dependencies=T)

library(tidyverse)
library(stringr)
library(purrr)
library(scales)

if(!exists("testsPerClass")){
	stop("test count per class data missing")
}

# read module-to-representative-test mapping

moduleMapping <- read.csv("../azure-data/module-info-all.csv",header=F)
colnames(moduleMapping) <- c("slug","sha","test","module_path","num_tests")
moduleMapping <- moduleMapping %>%
	      	 mutate(slug=str_to_lower(str_replace(slug,"https://github.com/([^/]+)/([^/]+)","\\1.\\2")))

modulesFiltered <- read.csv("../azure-data/module-info-filtered.csv",header=F)
colnames(modulesFiltered) <- c("slug","sha","test","module_path","num_tests")
modulesFiltered <- modulesFiltered %>%
	      	   mutate(slug=str_to_lower(str_replace(slug,"https://github.com/([^/]+)/([^/]+)","\\1.\\2")))

# read in test class order data

orderFiles <- list.files(path="md5-to-class-order",recursive=T,pattern = ".txt$",full.names=T)
orderData <- data.frame()
undetectedTestClasses <- data.frame()
for (f in orderFiles){
    f.slug <- str_match(basename(f),"^(.+)-[^-]+=")[,2]
    f.module <- as.character(moduleMapping %>% filter(test==str_match(basename(f),"=([^-]+)-")[,2]) %>% select(module_path))
    if(! paste(f.slug,f.module) %in% paste(modulesFiltered$slug,modulesFiltered$module_path)){
    	print(sprintf("skipping %s",paste(f.slug,f.module)))
        next
    }
    f.numTests <- as.numeric(moduleMapping %>% filter(test==str_match(basename(f),"=([^-]+)-")[,2]) %>% select(num_tests))
    f.orderHash <- str_match(basename(f),"-([^-]+)-order.txt")[,2]
    f.classes <- read.csv(f,header=F,stringsAsFactors=F)
    colnames(f.classes) <- c("test_class")
    f.classesFound <- f.classes %>%
    	      	 tibble::rowid_to_column("class_position") %>%
		 left_join(testsPerClass,by="test_class") %>% 
		 add_column(slug=f.slug,test_class_order_md5sum=f.orderHash) %>%
		 mutate(num_classes=max(class_position),module_path=f.module,tests_before=ifelse(class_position==1,0,cumsum(number_tests_in_class)-number_tests_in_class),total_tests_in_module=f.numTests)
    # f.classesNotFound <- f.classes %>%
    # 	      	 tibble::rowid_to_column("class_position") %>%
    # 		 anti_join(testsPerClass,by="test_class") %>% 
    # 		 add_column(slug=f.slug,test_class_order_md5sum=f.orderHash) %>%
    # 		 mutate(num_classes=max(class_position),module_path=f.module,total_tests_in_module=f.numTests)
    orderData <- rbind(orderData,f.classesFound)
#    undetectedTestClasses <- rbind(undetectedTestClasses,f.classesNotFound)
}

