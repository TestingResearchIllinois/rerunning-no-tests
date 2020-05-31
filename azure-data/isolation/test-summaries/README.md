Contents of this directory
- all.csv contains the summary of each test running 2000 times in isolation. Specifically, for each test the `slug,sha,test_name,module_path,summarized_test_result,num_runs,num_pass,num_error,num_fail`

A `summarized_test_result` is pass, error, or failure if all of its runs pass, error, or fail (respectively). The `summarized_test_result` is flaky if it has inconsistent results.

The following tests are known to have less than 2000 runs. 
- `https://github.com/spotify/helios,aebf68dcbdf9d3850478e8bddd2c478fa5fa282a,com.spotify.helios.testing.JobNamePrefixTest.testJobNamePrefix` (hangs)
- `https://github.com/TooTallNate/Java-WebSocket,fa3909c391195178ccf5a92d4ac342a30ae247c8,org.java_websocket.misc.OpeningHandshakeRejectionTest.org.java_websocket.misc.OpeningHandshakeRejectionTest` (issue with surefire outputting class name when failure is in setups)
- `https://github.com/undertow-io/undertow,d0efffad5d2034bb07525cac9b299dac72c3045d,io.undertow.websockets.jsr.test.extension.JsrWebsocketExtensionTestCase.testLongTextMessage` (issue with test being run twice when it fails)
