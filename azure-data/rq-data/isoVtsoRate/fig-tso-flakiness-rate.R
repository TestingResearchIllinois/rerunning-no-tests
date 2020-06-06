# script to create Figure fig:tso-flakiness-rate

plot.data=read.table(file="~/Downloads/no-outlier-simplified.txt",sep=',',header=TRUE)
plot.data[,2] <- as.numeric(gsub("%", "",plot.data[,2]))/100
plot.data[,3] <- as.numeric(gsub("%", "",plot.data[,3]))/100
plot(plot.data$TSO_flake_rate,plot.data$ISO_flake_rate,xlab=("Flakiness rate in test suite"),ylab=("Flakiness rate in isolation"),main="Flakiness rate of all TSO tests (n=82)")