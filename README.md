Contents of this directory
- azure-data contains the results from running the iDFlakies dataset with Surefire on Azure
- idf-data contains the results from running iDFlakies for our ICST 2019 paper. These results were collected on a variety of machines including Tao's server
- chameleon-data MISSING description -- is it same format as azure-data?

Here are some example queries one could find from the dataset:

(1) whether a test was found flaky by IDF, Azure test suite, and Azure isolation:

cut -f1 -d, idf_data/idf_found_all_rounds-summary.csv >/tmp/idf_flaky # wc -l /tmp/idf_flaky # 188
grep ,flaky, azure-data/all_tests/test-summaries/all.csv | cut -f1 -d, >/tmp/azure_all_flaky # wc -l /tmp/azure_all_flaky # 121
grep ,flaky, azure-data/isolation/test-summaries/all.csv | cut -f1 -d, >/tmp/azure_iso_flaky # wc -l /tmp/azure_iso_flaky # 61
sort -u /tmp/{idf_flaky,azure_all_flaky,azure_iso_flaky} >/tmp/flaky_tests # wc -l /tmp/flaky_tests # 251
# idf_flaky=($(cut -f1 -d, idf_data/idf_found_all_rounds-summary.csv)) # echo "${#idf_flaky[@]}" # 188
# azure_all_flaky=($(grep ,flaky, azure-data/all_tests/test-summaries/all.csv | cut -f1 -d,)) # echo "${#azure_all_flaky[@]}" # 121
# azure_iso_flaky=($(grep ,flaky, azure-data/isolation/test-summaries/all.csv | cut -f1 -d,)) # echo "${#azure_iso_flaky[@]}" # 61
# flaky_tests=($(shuf -e "${idf_flaky[@]}" "${azure_all_flaky[@]}" "${azure_iso_flaky[@]}" | sort -u)) # echo "${#flaky_tests[@]}" # 251

echo test,idf_flaky,azure_all_flaky,azure_iso_flaky
for t in $(cat /tmp/flaky_tests); do
   echo $t,$(grep -q "^$t$" /tmp/idf_flaky && echo flaky),$(grep -q "^$t$" /tmp/azure_all_flaky && echo flaky),$(grep -q "^$t$" /tmp/azure_iso_flaky && echo flaky)
done # | column -t -s ,

(2) how many times it was run and didn't pass for IDF, Azure test suite, and Azure isolation:

function not_pass() {
  line=$(grep "^$1," $2)
  [[ -z $line ]] && echo n/a,n/a && return
  echo === $line === >/dev/tty
  echo $(echo $line | cut -f3 -d,),$(( $(echo $line | cut -f5 -d,) + $(echo $line | cut -f6 -d,) ))
}
echo test,idf_run,idf_not_pass,azure_all_run,azure_all_not_pass,azure_iso_run,azure_iso_not_pass
for t in $(cat /tmp/flaky_tests); do
   echo $t,$(not_pass $t idf_data/idf_found_all_rounds-summary.csv),$(not_pass $t azure-data/all_tests/test-summaries/all.csv),$(not_pass $t azure-data/isolation/test-summaries/all.csv)
done # | column -t -s ,

################ here is one problem: when IDF says "not pass", do we know if it's OD or NOD situation? maybe we should not compare not_pass_ratio between IDF and Azure

(3) in what runs it didn't pass for IDF, Azure test suite, and Azure isolation?

# Darko didn't follow up how to analyze the following zips/CSVs (in the order of IDF, Azure test suite, and Azure isolation):
https://github.com/TestingResearchIllinois/rerunning-no-tests/blob/master/idf_data/per-test-results.csv
http://mir.cs.illinois.edu/winglam/personal/per-test-results.zip
https://github.com/TestingResearchIllinois/rerunning-no-tests/blob/master/azure-data/isolation/per-test-results.zip
