# Chameleon Cloud test results

There is one CSV file for each project in the all_tests directory. Each CSV file has a header. **I recommend looking at those to avoid any inconsistencies if we change the format.** Right now it's:
```
project,test_name,summarized_test_result,num_runs,num_pass,num_error,num_fail
```
At the time of writing, this is the format for the Azure test CSVs as well.