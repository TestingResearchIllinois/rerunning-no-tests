library(stringr)

# make sure per test input data has been read in

if(!exists("getCrossTSRStats",mode="function")) {
    wd <- normalizePath(".")
    setwd(str_match(wd,"(.*/rq-data)")[[1]])
    source("readPerTestData.R")
    setwd(wd)
}

# RQ1: ECDF for maximal burst lengths per test in TSO

allAzureFlakiesBurstsPerTest <- getCrossTSRStats(allAzureFlakies,c("test_name","machine_id","slug","module_path","test_class_order_md5sum"))
allAzureFlakiesBurstsPerTest <- allAzureFlakiesBurstsPerTest %>%
			     	group_by(test_name) %>%
				summarize(maxConsecFail=max(maxConsecFail))

TSOMaxBurstsECDF <- ggplot(allAzureFlakiesBurstsPerTest, aes(x=maxConsecFail)) + 
  	       stat_ecdf(geom = "step",size=1.2) + 
  	       theme_bw() + 
  	       theme(text = element_text(size=15),legend.position=c(0.7,0.2)) +
  	       scale_y_continuous(limits=c(0,1), labels=percent) +
	       scale_x_continuous(breaks=c(0,5,10,seq(20,100,20)),minor_breaks=c(seq(30,90,20))) +
  	       labs(y="Cumulative Fraction Across Tests", x="Maximal Test Failure Burst Length")
ggsave(plot=TSOMaxBurstsECDF,file="TSOBurstsByTest.svg",width=5,height=4.3)

