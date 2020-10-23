library(stringr)

# make sure per test input data has been read in

if(!exists("getCrossTSRStats",mode="function")) {
    wd <- normalizePath(".")
    setwd(str_match(wd,"(.*/rq-data)")[[1]])
    source("readPerTestData.R")
    setwd(wd)
}

# RQ3: Max burst length ECDF for ISO vs. TSO

allAzureFlakiesBurstsPerTest <- getCrossTSRStats(allAzureFlakies,c("test_name","machine_id","slug","module_path","test_class_order_md5sum"))
allAzureFlakiesBurstsPerTest <- allAzureFlakiesBurstsPerTest %>%
			     	ungroup() %>%
			     	group_by(test_name) %>%
				summarize(maxConsecFail=max(maxConsecFail)) 

allAzureFlakiesBurstsPerTestISO <- getCrossTSRStats(allAzureFlakiesISO,c("test_name","machine_id","slug","module_path","test_class_order_md5sum"))
allAzureFlakiesBurstsPerTestISO <- allAzureFlakiesBurstsPerTestISO %>%
				   ungroup() %>%
				   group_by(test_name) %>%
				   summarize(maxConsecFail=max(maxConsecFail))

combinedMaxBursts <- inner_join(allAzureFlakiesBurstsPerTest %>% ungroup() %>% select(test_name,TSO=maxConsecFail),
		     		allAzureFlakiesBurstsPerTestISO %>% ungroup() %>% select(test_name,ISO=maxConsecFail))

combinedMaxBurstsTransformed <- gather(combinedMaxBursts,howRun,maxBurst,TSO:ISO)

combinedMaxBurstsTransformed$howRun <- factor(combinedMaxBurstsTransformed$howRun,levels=rev(levels(factor(combinedMaxBurstsTransformed$howRun))))

combinedMaxBurstsECDF <- ggplot(combinedMaxBurstsTransformed, aes(x=maxBurst,group=howRun,color=howRun)) +
  	       stat_ecdf(geom = "step",size=1) +
  	       theme_bw() + 
  	       theme(text = element_text(size=15),
	       	     legend.position=c(0.65,0.2),
		     legend.key.width=unit(1,"cm")) +
  	       scale_y_continuous(limits=c(0,1), labels=percent) +
	       scale_x_continuous(breaks=c(0,5,10,seq(20,100,20)),minor_breaks=c(seq(30,90,20))) +
  	       labs(y="Cumulative Fraction Across Tests", x="Maximal Test Failure Burst Length",color="Test Run Configuration") +
	       scale_color_grey(name="Test Run Configuration",breaks=c("TSO","ISO"),labels=c("TSO","ISO"),end=0.7) +
ggsave(file="ISO_TSOBurstsByTest.svg",width=5,height=4.3)
