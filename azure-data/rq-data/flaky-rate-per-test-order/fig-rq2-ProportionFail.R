#script to produce figure fig:rq2:ProportionFail

tests=read.table(file="~/Downloads/flaky-rate-per-test-order-simplified.txt",sep=',',header=TRUE)
X=split(tests,tests$Test_name)

# obtaining the proportion of total orders per test with at least one failure
# eliminating tests with one ordering

FailOrderingCount.per.softwareTest=rep(0,length(X))
for (i in 1:length(X)){
  if(dim(X[[i]])[1]==1){
    FailOrderingCount.per.softwareTest[i]=NA
  }
  else {
    FailOrderingCount.per.softwareTest[i]=sum(X[[i]]$Order_Flake_rate!=0)/length(X[[i]]$Order_Flake_rate)
  }
}

boxplot(FailOrderingCount.per.softwareTest,main=("Proportion of Orderings with >1 Failure, by Test (n=101)"), ylab=("Proportion"))
