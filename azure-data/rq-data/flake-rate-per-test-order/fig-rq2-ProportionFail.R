#script to produce figure fig:rq2:ProportionFail

library(ggplot2)
library(scales)

tests=read.table(file="flaky-rate-per-test-order-simplified.csv",sep=',',header=TRUE)
X=split(tests,tests$Test_name)

#removing tests with one or two orderings
Ordering.Count.Per.Test=sapply(X, dim)[1,]
#get tests with one or two orderings only:
which(as.numeric(Ordering.Count.Per.Test)==1)
# [1] 14 27 28 29 34 85
which(as.numeric(Ordering.Count.Per.Test)==2)
#[1] 2 3 5
X=X[-c(2,3,5,14,27,28,29,34,85)]
#n=98

# obtaining the proportion of total orders per test

FailOrderingCount.per.softwareTest=rep(0,length(X))
for (i in 1:length(X)){
    FailOrderingCount.per.softwareTest[i]=sum(X[[i]]$Order_Flake_rate!=0)/length(X[[i]]$Order_Flake_rate)
}

plotData <- data.frame(FailOrderingCount.per.softwareTest)
colnames(plotData) <- c("data")

propFailBP <- ggplot(plotData,aes(y=data)) +
	      stat_boxplot(geom='errorbar',width=0.33) +
	      geom_boxplot(width=.5) +
	      theme_bw() +
	      theme(panel.grid.major.y = element_blank(),
	      	    panel.grid.minor.y = element_blank(),
	            axis.line = element_line(colour = "black"),
		    axis.title=element_blank(),
		    axis.ticks.y=element_blank(),
		    axis.text.y=element_blank(),
		    text = element_text(size=30)) +
	      scale_y_continuous(labels=scales::percent,limits=c(0,1),
				 breaks=seq(0,10,2)/10) +
	      scale_x_continuous(expand=expansion(add=.15)) +
	      coord_flip()
ggsave(plot=propFailBP,file="ProportionFail.svg",height=1.5,width=10)