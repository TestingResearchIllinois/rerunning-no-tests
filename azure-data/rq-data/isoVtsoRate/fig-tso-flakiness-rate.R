# script to create Figure fig:tso-flakiness-rate

pdf(file="./tso-flakiness-rate-box.pdf",width=12,height=12)
plot.data=read.table(file="no-outlier-simplified.csv",sep=',',header=TRUE)
plot.data[,2] <- as.numeric(gsub("%", "",plot.data[,2]))/100
plot.data[,3] <- as.numeric(gsub("%", "",plot.data[,3]))/100
plot(plot.data$TSO_flake_rate,plot.data$ISO_flake_rate,xlab=("Failure rate in test suite"),ylab=("Failure rate in isolation"),cex.lab=1.3,xaxt="n",yaxt="n")
axis(2, at=c(0,.01,.02,.03), labels=paste0(c(0,.01,.02,.03)*100, "%"),tick = FALSE,cex.lab=1,cex.axis=3)
axis(1, at=c(0,.01,.02,.0285), labels=paste0(c(0,.01,.02,.03)*100, "%"),tick = FALSE,cex.lab=1,cex.axis=3)
graphics.off()