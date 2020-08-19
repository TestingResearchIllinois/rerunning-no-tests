# projmodule-name-macros.tex
i=1; for f in $(cat module-info.csv ); do s=$(echo $f | cut -d, -f1 | cut -d'/' -f4-); mod=$(echo $f | cut -d, -f4); echo "\\Def{${s}=${mod}_name}{M${i}}"; i=$((i+1)); done 

i=1; for f in $(cat module-info.csv ); do s=$(echo $f | cut -d, -f1 | cut -d'/' -f4-); mod=$(echo $f | cut -d, -f4); echo "\\Def{${s}=${mod}_name}{M${i}}"; i=$((i+1)); done 

i=1; for f in $(cat module-info.csv ); do g=$(echo $f | cut -d, -f1 ); s=$(echo $g | cut -d'/' -f4-); mod=$(echo $f | cut -d, -f4); t=$(echo $f | cut -d, -f3);  fi=$( find all_tests_combined/per-module-order/ -name "*${t}-*" ); oc=$(cat $fi | wc -l); cc=$(head -1 $fi | cut -d, -f2);  tc=$(echo $f | cut -d, -f5); so=$( grep $g all_tests_combined/test-summaries/flaky.csv | grep ,$mod, | wc -l); iso=$(grep $g isolation/test-summaries/flaky-surefire-combined-found.csv | grep ,$mod, | wc -l); niso=$(grep $g isolation/test-summaries/flaky-surefire-combined-not-found.csv | grep ,$mod, | wc -l); if [[ "$((so+iso+niso))" != "0" ]]; then echo "\\Def{${s}=${mod}_name}{M${i}}"; i=$((i+1)); fi done 


# module-mapping-filtered.csv 
i=1; for f in $(cat module-info-filtered.csv ); do g=$(echo $f | cut -d, -f1 ); s=$(echo $g | cut -d'/' -f4-); mod=$(echo $f | cut -d, -f4); t=$(echo $f | cut -d, -f3);  fi=$( find all_tests_combined/per-module-order/ -name "*${t}-*" ); oc=$(cat $fi | wc -l); cc=$(head -1 $fi | cut -d, -f2);  tc=$(echo $f | cut -d, -f5); so=$( grep $g all_tests_combined/test-summaries/flaky.csv | grep ,$mod, | wc -l); iso=$(grep $g isolation/test-summaries/flaky-surefire-combined-found.csv | grep ,$mod, | wc -l); niso=$(grep $g isolation/test-summaries/flaky-surefire-combined-not-found.csv | grep ,$mod, | wc -l); slug=$(echo $f | cut -d, -f1);  if [[ "$((so+iso+niso))" != "0" ]]; then echo "$slug,$mod,\\Use{${s}=${mod}_name},M${i}"; i=$((i+1)); fi done > module-mapping-filtered.csv 

# module-info-filtered.csv
Removes the following since we cannot control the order of their test classes
spotify.helios-aebf68d=com.spotify.helios.testing.HeliosSoloDeploymentTest.testUndeployLeftoverJobs-results.csv
apache.hbase-801fc05=org.apache.hadoop.hbase.procedure2.TestProcedureSkipPersistence.test-results.csv (splits tests into two parts; latter part only runs if first part has no failures)

# filtering isolation flaky tests
winglam2@upcrc5:/scratch/winglam2/rerunning-no-tests/azure-data/isolation/test-summaries$ for f in $( cut -d, -f1,2,4 ../../module-info-filtered.csv); do h=$(echo $f | cut -d, -f1,2); m=$(echo $f | cut -d, -f3);  grep $h, flaky-surefire-combined-found.csv | grep ,$m,; done > flaky-surefire-combined-found-filtered.csv 

# module-stats.tex
trao=0; tfio=0; tiso=0; ttmc=0; ttcc=0; ttoc=0; for f in $(cat module-info.csv ); do g=$(echo $f | cut -d, -f1 ); s=$(echo $g | cut -d'/' -f4-); mod=$(echo $f | cut -d, -f4); t=$(echo $f | cut -d, -f3);  fi=$( find all_tests/per-module-order/ -name "*${t}*" ); oc=$(cat $fi | wc -l); cc=$(head -1 $fi | cut -d, -f2);  tc=$(echo $f | cut -d, -f5); rao=$( grep $g all_tests/test-summaries/flaky.csv | grep ,$mod, | wc -l); fio=$( grep $g all_tests_fixed_order/test-summaries/flaky.csv | grep ,$mod, | wc -l); iso=$(grep $g isolation/test-summaries/all.csv | grep ,flaky, | grep ,$mod, | wc -l); echo "\\Use{${s}=${mod}_name} & ${s} & ${tc} & ${cc} & ${oc} & $rao & $fio & $iso \\\\";  trao=$((trao+rao)); tfio=$((tfio+fio)); tiso=$((tiso+iso)); ttmc=$((ttmc+tc)); ttcc=$((ttcc+cc)); ttoc=$((ttoc+oc)); done ; echo "\hline \\multicolumn{2}{|l||}{\textbf{Total}} & \\textbf{${ttmc}} & \\textbf{${ttcc}} & \\textbf{${ttoc}} & \\textbf{${trao}} & \\textbf{${tfio}} & \\textbf{${tiso}} \\\\"

# contains isolation only column
tso=0; tiso=0; ttmc=0; ttcc=0; ttoc=0; tniso=0; for f in $(cat module-info-filtered.csv ); do g=$(echo $f | cut -d, -f1 ); s=$(echo $g | cut -d'/' -f4-); mod=$(echo $f | cut -d, -f4); t=$(echo $f | cut -d, -f3);  fi=$( find all_tests_combined/per-module-order/ -name "*${t}-*" ); oc=$(cat $fi | wc -l); cc=$(head -1 $fi | cut -d, -f2);  tc=$(echo $f | cut -d, -f5); so=$( grep $g all_tests_combined/test-summaries/flaky.csv | grep ,$mod, | wc -l); iso=$(grep $g isolation/test-summaries/flaky-surefire-combined-found.csv | grep ,$mod, | wc -l); niso=$(grep $g isolation/test-summaries/flaky-surefire-combined-not-found.csv | grep ,$mod, | wc -l); if [[ "$((so+iso+niso))" != "0" ]]; then echo "\\Use{${s}=${mod}_name} & ${s} & ${tc} & ${cc} & ${oc} & $so & $iso & $niso \\\\";  tso=$((tso+so)); tniso=$((tniso+niso)); tiso=$((tiso+iso)); ttmc=$((ttmc+tc)); ttcc=$((ttcc+cc)); ttoc=$((ttoc+oc)); fi done ; echo "\hline \\multicolumn{2}{|l||}{\textbf{Total}} & \\textbf{${ttmc}} & \\textbf{${ttcc}} & \\textbf{${ttoc}} & \\textbf{${tso}} & \\textbf{${tiso}} & \\textbf{${tniso}} \\\\"

# no isolation only
tso=0; tiso=0; ttmc=0; ttcc=0; ttoc=0; tniso=0; for f in $(cat module-info-filtered.csv ); do g=$(echo $f | cut -d, -f1 ); s=$(echo $g | cut -d'/' -f4-); mod=$(echo $f | cut -d, -f4); t=$(echo $f | cut -d, -f3);  fi=$( find all_tests_combined/per-module-order/ -name "*${t}-*" ); oc=$(cat $fi | wc -l); cc=$(head -1 $fi | cut -d, -f2);  tc=$(echo $f | cut -d, -f5); so=$( grep $g all_tests_combined/test-summaries/flaky.csv | grep ,$mod, | wc -l); iso=$(grep $g isolation/test-summaries/flaky.csv | grep ,$mod, | wc -l); niso=$(grep $g isolation/test-summaries/flaky.csv | grep ,$mod, | wc -l); if [[ "$((so+iso+niso))" != "0" ]]; then echo "\\Use{${s}=${mod}_name} & ${s} & ${tc} & ${cc} & ${oc} & $so & $iso \\\\";  tso=$((tso+so)); tniso=$((tniso+niso)); tiso=$((tiso+iso)); ttmc=$((ttmc+tc)); ttcc=$((ttcc+cc)); ttoc=$((ttoc+oc)); fi done ; echo "\hline \\multicolumn{2}{|l||}{\textbf{Total}} & \\textbf{${ttmc}} & \\textbf{${ttcc}} & \\textbf{${ttoc}} & \\textbf{${tso}} & \\textbf{${tiso}} \\\\"

# generate per-module-order/
rm -rf ../per-module-order; mkdir ../per-module-order; for f in $(ls *-results.csv); do cut -d, -f6,7,8,9,10 $f | sort -u > ../per-module-order/$f; done

# generate scatter plot
egrep ",failure,|,error," *-results.csv > failure-runs.csv
for f in $(cat ../test-summaries/flaky.csv ); do t=$(echo $f | cut -d, -f3); grep $t, failure-runs.csv; done | cut -d, -f1,2,4 > filtered-failure-runs.csv
for f in $(cut -d, -f1 filtered-failure-runs.csv | sort -u); do ct=$(echo $f | cut -d':' -f2); for g in $(grep $f, filtered-failure-runs.csv | cut -d, -f3 | sort -u ); do c=$(grep $f, filtered-failure-runs.csv | grep ,${g}$ | wc -l ); echo $ct,$g,$c; done done > failure-per-run.csv
python /scratch/winglam2/nondex-get-first-sha/scripts/python-scripts/parse_failure_per_run.py failure-per-run.csv > failure-per-run-dense.csv 


# outlier table
for f in $(cat sheet8.csv); do s=$(echo $f | cut -d, -f1); m=$(echo $f | cut -d, -f4); r=$(echo $f | cut -d, -f5- | sed -e 's/\%/\\%/g' | sed -e 's/,/ \& /g' ); t=$(echo $f | cut -d, -f3 | rev | cut -d'.' -f1,2 | rev | sed -e 's/\_/\\_/g' ); map=$(grep $s,$m, module-mapping-filtered.csv | cut -d, -f3); echo "$map & $t & $r"; done


# module-info-filtered.csv
Removes the following since we cannot control the order of their test classes
apereo.java-cas-client-574b74f=org.jasig.cas.client.validation.AssertionImplTests.testAssertionValidity-results.csv
spotify.helios-aebf68d=com.spotify.helios.testing.HeliosSoloDeploymentTest.testUndeployLeftoverJobs-results.csv
apache.hbase-801fc05=org.apache.hadoop.hbase.procedure2.TestProcedureSkipPersistence.test-results.csv (splits tests into two parts; latter part only runs if first part has no failures)

X knightliao.disconf-2ac5c82=com.baidu.disconf.client.test.DisconfMgrTestCase.demo-results.csv
X zalando.riptide-8277e11=org.zalando.riptide.failsafe.RetryAfterDelayFunctionTest.shouldRetryOnDemandWithDynamicDelay-results.csv (parallelizes test runs)

# flake rate per module
for f in $(tail -n +2 all-test-info.csv | cut -d, -f1,4 | sort -u); do high=0; min=5000; sum=0; c=0; s=$(echo $f | cut -d, -f1); m=$(echo $f | cut -d, -f2);  for g in $(grep "^$s," all-test-info.csv | grep ,$m,); do c=$(( c + 1)); pass=$(echo $g | cut -d, -f6);  high=$(( high < pass ? pass : high )); min=$(( min < pass ? min : pass )); sum=$(( sum + (4000 - pass) )); done; low=$(printf %.1f $(echo "((4000 - $high) / 4000) * 100" | bc -l)); max=$(printf %.1f $(echo "((4000 - $min) / 4000) * 100" | bc -l)); all=$(printf %.1f $(echo "($sum / 4000) * 100" | bc -l)); map=$(grep "^$f," ../module-mapping-filtered.csv | cut -d, -f3); tv=$(grep "$map" ../multi-flaky-test-failures/tsr-rates.csv | cut -d, -f2); tsr=$(printf %.1f $(echo "$tv * 100" | bc -l)); if (( $(echo "$all > 100.0" | bc -l) )); then all="100.0"; fi;  echo "$map & $tsr & $max & $all \\\\";  done | sort -u

# runtimes of compiling and running tests
rm -rf runtimes.csv; for f in $(find -maxdepth 3 -name "*_output.out" ); do root=$(echo $f | rev | cut -d'/' -f2- | rev ); err="$root/stderr.txt"; errd=$(date -r $err +"%s"); fd=$(date -r $f +"%s"); m=$(echo $f | cut -d'/' -f2); cp=$(pwd | rev | cut -d'/' -f1 | rev );  diff=$((fd-errd)); echo $cp,$m,$fd,$errd,$diff >> runtimes.csv; done 

winglam2@upcrc5:/scratch/winglam2/rerunning-no-tests/azure-data/rq-data$ for f in $(cut -d, -f2 flake-rate-per-test-order/flaky-rate-per-test-order-full.csv | sort -u ); do grep $f /scratch/winglam2/azure-scripts/src/iso-runtimes.csv | cut -d, -f5 ; done  | paste -sd+ | bc -ql

winglam2@upcrc5:/scratch/winglam2/rerunning-no-tests/azure-data/rq-data$ for f in $(cut -d, -f3 module-info-filtered.csv ); do grep $f /scratch/winglam2/azure-scripts/src/tso-runtimes.csv | cut -d, -f5 ; done  | paste -sd+ | bc -ql

# RQ2
python flaky-rate-per-test-order.py ../all_tests_combined/test-summaries/flaky-filtered-prefix.csv ../all_tests_combined/per-test-results/ ../rq-data/module-mapping-filtered.csv  ../all_tests_combined/md5-to-class-order/ > flaky-rate-per-test-order.csv

# RQ4
python multi-flaky-test-failures.py ../all_tests_combined/test-summaries/flaky-filtered-prefix.csv ../all_tests_combined/per-test-results/ ../rq-data/module-mapping-filtered.csv > all-multi-flaky-test-failures.csv
