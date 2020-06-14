Contents of this directory
- flake-rates contains the data and scripts we used for RQ1 (Overall failure rate and burst length)
- flake-rate-per-test-order contains the data and scripts we used for RQ2 (Effect of class order on failure rate and burst length)
- isoVtsoRate contains the data and scripts we used for RQ3 (Reproducing TSO failures with ISO)
- multi-flaky-test-failures contains the data and scripts we used for RQ4 (Frequency of TSRs affected by flaky tests)
- module-info-filtered.csv and module-mapping-filtered.csv are files used by some of the scripts in the subdirectories
- bursts.R contains analysis scripts to partially answer RQs 1,2,3. It requires the full test result data to be downloaded and decompressed at paths relative to the script (please see the list.files instructions in the script). Before running the script, please make sure to have dependencies installed (e.g., libcurl-dev) and preprocessed the result CSV files using the preprocess_per-test-results.sh script in this directory.