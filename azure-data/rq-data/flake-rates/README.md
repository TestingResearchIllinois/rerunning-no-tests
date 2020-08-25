Contents of this directory
- summarize-flake-rate-per-module.sh contains the bash script we use to generate Table 1
- per-module-order contains for each module the unique test class orderings that we observed from our test suite runs
- iso-flake-rate.csv contains the flake rate for isolation runs
- tso-flake-rate.csv contains the flake rate for test suite runs
- TSOburstLengthsECDF.R contains the script to generate Figure 3 in the paper.

Within each *-flake-rate.csv the format of the contents are:
`slug,sha,test_name,module_path,summarized_test_result,num_runs,num_pass,num_error,num_fail`

A `summarized_test_result` is pass, error, or failure if all of its runs pass, error, or fail (respectively). The `summarized_test_result` is flaky if it has inconsistent results.
