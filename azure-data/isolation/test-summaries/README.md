Contents of this directory
- all.csv contains the summary of each test running 2000 times in isolation. Specifically, for each test the test_name,summarized_test_result,num_runs,num_pass,num_error,num_fail

A summarized_test_result is pass, error, or failure if all of its runs pass, error, or fail (respectively). The summarized_test_result is flaky if it has inconsistent results.

The following modules are known to have less than 2000 runs. Wing is looking into getting these up to 2000.
- org.apache.dubbo.remoting.transport.netty.ClientReconnectTest.testReconnectWarnLog,pass,1000,1000,0,0
- net.redpipe.templating.freemarker.ApiTest.checkMail,pass,500,500,0,0
- net.redpipe.templating.freemarker.ApiTest.checkTemplateNegociationSingleHtml,pass,600,600,0,0
- net.redpipe.templating.freemarker.ApiTest.checkTemplateNegociationText,pass,700,700,0,0
- com.spotify.helios.testing.HealthCheckTest.test,pass,700,700,0,0
- com.spotify.helios.testing.JobNamePrefixTest.testJobNamePrefix,pass,400,400,0,0
- retrofit2.adapter.rxjava2.CancelDisposeTest.cancelDoesNotDispose,pass,1100,1100,0,0
- retrofit2.adapter.rxjava.CancelDisposeTest.cancelDoesNotDispose,pass,900,900,0,0
- retrofit2.adapter.rxjava2.CompletableThrowingTest.bodyThrowingInOnErrorDeliveredToPlugin,pass,1000,1000,0,0
- retrofit2.adapter.rxjava.CompletableThrowingTest.bodyThrowingInOnErrorDeliveredToPlugin,pass,1000,1000,0,0
- retrofit2.adapter.rxjava2.CompletableThrowingTest.throwingInOnCompleteDeliveredToPlugin,pass,1000,1000,0,0
- retrofit2.adapter.rxjava.CompletableThrowingTest.throwingInOnCompleteDeliveredToPlugin,pass,1000,1000,0,0
- retrofit2.adapter.rxjava2.ObservableThrowingTest.responseThrowingInOnCompleteDeliveredToPlugin,pass,1300,1300,0,0
- retrofit2.adapter.rxjava.ObservableThrowingTest.responseThrowingInOnCompleteDeliveredToPlugin,pass,700,700,0,0
- retrofit2.adapter.rxjava2.SingleThrowingTest.bodyThrowingInOnSuccessDeliveredToPlugin,pass,1000,1000,0,0
- retrofit2.adapter.rxjava.SingleThrowingTest.bodyThrowingInOnSuccessDeliveredToPlugin,pass,1000,1000,0,0
- retrofit2.adapter.rxjava.SingleThrowingTest.responseThrowingInOnSuccessDeliveredToPlugin,pass,1400,1400,0,0
- retrofit2.adapter.rxjava2.SingleThrowingTest.responseThrowingInOnSuccessDeliveredToPlugin,pass,600,600,0,0
