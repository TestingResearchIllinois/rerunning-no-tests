Contents of this directory
- idf_found_per_rounds-summary.csv contains the summary of each test ignoring round types. Specifically, for each test the `test_name,summarized_test_result,num_runs,num_pass,num_error,num_fail`
- idf_found_per_rounds-summary.csv contains the summary of each test per round type. Specifically, for each test the `test_name,round_type,summarized_test_result,num_runs,num_pass,num_error,num_fail`
- per-test-results.csv contains for each test the `test_name,test_result,time_to_run_test,run_num,round_type`.

Compared to the azure-data, the following should be noted for the iDFlakies data:
- time_to_run_test is the time to run the entire module and not per test. Such data is unfortunately not easily available
- All results are assumed to be from the same machine since we do not have the data for which machines any particular run was from
- There are no isolation runs, all the data is from running the entire test suite
- All failures or errors are just treated as failures
