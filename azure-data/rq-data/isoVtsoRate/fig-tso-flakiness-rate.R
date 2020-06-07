# script to create Figure fig:tso-flakiness-rate

plot.data=read.table(file="~/Downloads/no-outlier-simplified.txt",sep=',',header=TRUE)
plot.data[,2] <- as.numeric(gsub("%", "",plot.data[,2]))/100
plot.data[,3] <- as.numeric(gsub("%", "",plot.data[,3]))/100
plot(plot.data$TSO_flake_rate,plot.data$ISO_flake_rate,xlab=("Failure rate in test suite"),ylab=("Failure rate in isolation"),cex.lab=1.5,xaxt="n",yaxt="n")
axis(2, at=c(0,.01,.02,.03), labels=paste0(c(0,.01,.02,.03)*100, "%"),tick = FALSE,cex.lab=5,cex.axis=1.5)
axis(1, at=c(0,.01,.02,.0285), labels=paste0(c(0,.01,.02,.03)*100, "%"),tick = FALSE,cex.lab=3,cex.axis=1.5)
