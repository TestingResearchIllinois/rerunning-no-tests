Contents of this directory
- flake-rates contains the data and scripts we used for RQ1 (Overall failure rate and burst length)
- flake-rate-per-test-order contains the data and scripts we used for RQ2 (Effect of class order on failure rate and burst length)
- isoVtsoRate contains the data and scripts we used for RQ3 (Reproducing TSO failures with ISO)
- multi-flaky-test-failures contains the data and scripts we used for RQ4 (Frequency of TSRs affected by flaky tests)
- module-info-filtered.csv and module-mapping-filtered.csv are files used by some of the scripts in the subdirectories
- bursts.R contains analysis scripts to answer RQs 1,2,3 regarding burst length. Before running the script, please make sure to have the relevant dependencies installed (e.g., build dependencies for R packages, curl, svglite, Cairo). This script requires the test result data to be downloaded and decompressed at paths relative to the script (please see the ```list.files``` in the script for more information). Specifically, the script uses the following:
  - ```../all_tests_combined/per-test-results``` is obtained from [here](https://drive.google.com/file/d/1L_2uycsWzsKLV9fiZH5FdS8HvBElwMgI). Note that the zip file is about 281MB zipped and 6.9GB unzipped.
  - ```../isolation/per-test-results``` is obtained from [here](https://drive.google.com/file/d/17dcCrDyitqQKC6GsHLeeMzQx2fCJDYGw). Note that the zip file is about 2.6MB zipped and 113MB unzipped.
- preprocess_per-test-results.sh used to preprocess the test result CSV files used by the bursts.R script
