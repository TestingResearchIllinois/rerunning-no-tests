Contents of this directory
- flake-rates contains the data and scripts we used for RQ1 (Overall failure rate and burst length)
- flake-rate-per-test-order contains the data and scripts we used for RQ2 (Effect of class order on failure rate and burst length)
- isoVtsoRate contains the data and scripts we used for RQ3 (Reproducing TSO failures with ISO)
- multi-flaky-test-failures contains the data and scripts we used for RQ4 (Frequency of TSRs affected by flaky tests)
- module-info-filtered.csv and module-mapping-filtered.csv are files used by some of the scripts in the subdirectories
- readPerTestData.R is a helper script to answer RQs 1,2,3 regarding burst length. Before running the script, please make sure to have the relevant dependencies installed (e.g., build dependencies for R packages, curl, svglite, Cairo). To run the script, we used R version 3.6.3 with the following purposefully installed (e.g., apt install) on the machine: libssl-dev, libxml2-dev, libfontconfig1-dev, libcurl4-openssl-dev, and libcairo2-dev. This script also requires the test result data to be downloaded and decompressed at paths relative to the script (please see the ```list.files``` in the script for more information). Specifically, the script uses the following:
  - ```tso-per-test-results``` is obtained from [here](http://mir.cs.illinois.edu/winglam/publications/2020/LamETAL20ISSRE/tso-per-test-results.zip). Note that the zip file is about 281MB zipped and 6.9GB unzipped.
  - ```iso-per-test-results``` is obtained from [here](http://mir.cs.illinois.edu/winglam/publications/2020/LamETAL20ISSRE/iso-per-test-results.zip). Note that the zip file is about 2.6MB zipped and 113MB unzipped.
