#script to produce figure fig:rq2:AverageFlakeRatePerTest

tests=read.table(file="flaky-rate-per-test-order-simplified.csv",sep=',',header=TRUE)
X=split(tests,tests$Test_name)

#average flake rate for 107 tests
# mean for each test:
mean.rate.per.softwareTest=rep(0,length(X))
for (i in 1:length(X)){
  mean.rate.per.softwareTest[i]=mean(X[[i]]$Order_Flake_rate)
}
pdf(file="./AverageFlakeRatePerTest.pdf",width=8,height=6)
barplot(sort(mean.rate.per.softwareTest,decreasing=TRUE),ylab="Average Failure Rate",xlab="Test",ylim=c(0,.5),ytick=c(0,.1,.2,.3,.4,.5),cex.lab=1.3,cex.axis=1.4)
graphics.off()
