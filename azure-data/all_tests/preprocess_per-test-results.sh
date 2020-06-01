#!/bin/zsh

# include header in CSV files and remove last column (for better load times; sha is not needed for now)
find -path ./per-test-results/\*.csv -print0 | xargs -0 -n1 -P4 -I{} sed -i '1i test_name,test_result,time_to_run_test,run_num,machine_id,test_class_order_md5sum,num_test_class,module_path,slug,sha; s/,[^,]+$//' {}
