#script to produce figure fig:rq2:ProportionFail

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

pdf(file="./ProportionFail.pdf",width=8,height=4)
boxplot(FailOrderingCount.per.softwareTest, width=1, xlab=("Proportion of Orderings with >1 Failure per Test"),ylim=c(0,1),horizontal=TRUE,cex.lab=1.5,cex.axis=1,xaxt="n")
axis(1, at=c(0,.1,.2,.3,.4,.5,.6,.7,.8,.9,1), labels=paste0(c(0,.1,.2,.3,.4,.5,.6,.7,.8,.9,1)*100, "%"),cex.lab=1.4,cex.axis=1.1)
graphics.off()

