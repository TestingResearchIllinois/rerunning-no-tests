# script to create Figure fig:tso-flakiness-rate

library(ggplot2)
library(scales)

plot.data=read.table(file="no-outlier-simplified.csv",sep=',',header=TRUE)
plot.data[,2] <- as.numeric(gsub("%", "",plot.data[,2]))/100
plot.data[,3] <- as.numeric(gsub("%", "",plot.data[,3]))/100

scatterplot <- ggplot(plot.data,aes(x=TSO_flake_rate,y=ISO_flake_rate)) +
	       theme_bw() +
	       theme(text=element_text(size=15),panel.grid.minor=element_blank()) +
	       geom_point(shape=1,size=2) +
	       scale_x_continuous(name="Failure Rate in Test Suite",labels=scales::percent_format(accuracy=1),breaks=c(.01,.02,.03),limits=c(0,.03)) +
	       scale_y_continuous(name="Failure Rate in Isolation",labels=scales::percent_format(accuracy=1),breaks=c(.01,.02,.03),limits=c(0,.03))
ggsave(plot=scatterplot,filename="RateTSOtests.svg",width=3.5,height=3.5)