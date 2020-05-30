Each file in this directory corresponds to a module.

Within each file the format of the contents are:
`slug,sha,test_name,module_path,summarized_test_result,num_runs,num_pass,num_error,num_fail`

A `summarized_test_result` is pass, error, or failure if all of its runs pass, error, or fail (respectively). The `summarized_test_result` is flaky if it has inconsistent results.

The following modules are known to have less than 2000 runs. They have less than 2000 runs because their tests hang sometimes and do not finish their runs.
- spotify.helios-aebf68d=com.spotify.helios.testing.HeliosSoloDeploymentTest.testUndeployLeftoverJobs-summary.csv
- undertow-io.undertow-d0efffa=io.undertow.websockets.jsr.test.JsrWebSocketServer07Test.testErrorHandling-summary.csv

The following modules use Maven version <2.7 and their test orders are therefore not guaranteed to be the same. These -results.csv are in the per-test-results directory/zip.
- apereo.java-cas-client-574b74f=org.jasig.cas.client.validation.AssertionImplTests.testAssertionValidity-results.csv
- espertechinc.esper-590fa9c=com.espertech.esper.example.rfidassetzone.TestLRMovingSimMain.testSim-results.csv
- knightliao.disconf-2ac5c82=com.baidu.disconf.client.test.DisconfMgrTestCase.demo-results.csv

The following modules are confirmed to have more than one test order that was run
- apereo.java-cas-client-574b74f=org.jasig.cas.client.validation.AssertionImplTests.testAssertionValidity-results.csv
- knightliao.disconf-2ac5c82=com.baidu.disconf.client.test.DisconfMgrTestCase.demo-results.csv
- spotify.helios-aebf68d=com.spotify.helios.testing.HeliosSoloDeploymentTest.testUndeployLeftoverJobs-results.csv
- apache.hbase-801fc05=org.apache.hadoop.hbase.procedure2.TestProcedureSkipPersistence.test-results.csv (splits tests into two parts; latter part only runs if first part has no failures)
- zalando.riptide-8277e11=org.zalando.riptide.failsafe.RetryAfterDelayFunctionTest.shouldRetryOnDemandWithDynamicDelay-results.csv (parallelizes test runs)
