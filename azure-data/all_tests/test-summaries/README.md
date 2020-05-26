Each file in this directory corresponds to a module.

Within each file the format of the contents are:
test_name,summarized_test_result,num_runs,num_pass,num_error,num_fail

A summarized_test_result is pass, error, or failure if all of its runs pass, error, or fail (respectively). The summarized_test_result is flaky if it has inconsistent results.

The following modules are known to have less than 2000 runs. Wing is looking into getting these up to 2000.
- fromage.redpipe-0aff891=net.redpipe.templating.freemarker.ApiTest.checkMail-summary.csv
- openpojo.openpojo-9badbcc=com.openpojo.issues.issue112.IssueTest.shouldNotFail-summary.csv
- spotify.helios-aebf68d=com.spotify.helios.testing.HeliosSoloDeploymentTest.testUndeployLeftoverJobs-summary.csv
- square.retrofit-ae28c3d=retrofit2.adapter.rxjava.CancelDisposeTest.cancelDoesNotDispose-summary.csv
- undertow-io.undertow-d0efffa=io.undertow.websockets.jsr.test.JsrWebSocketServer07Test.testErrorHandling-summary.csv
