Contents of this directory
- test-summaries contains the summary of each test. Specifically, for each test the `slug,sha,test_name,module_path,summarized_test_result,num_runs,num_pass,num_error,num_fail`
- per-module-order contains for each module the `test_class_order_md5sum,num_test_class,module_path,slug,sha`. This information is meant to help easily see whether any orders are the same or not for the modules we ran.
- md5-to-class-order contains for each module and `test_class_order_md5sum` the actual test class order that was run. E.g., if a module is said to have X number of `test_class_order_md5sum` from per-module-order, then there would be X number of files in md5-to-class-order where each file is the actual test class order that created the md5sum

You can download the per-test results from the following (the zip file is about 300MB).
http://mir.cs.illinois.edu/winglam/personal/combined_per-test-results.zip

The combined_per-test-results.zip contains for each test the `test_name,test_result,time_to_run_test,run_num,machine_id,test_class_order_md5sum,num_test_class,module_path,slug,sha`. When unzipped the contents occupy about 7.6GB.
