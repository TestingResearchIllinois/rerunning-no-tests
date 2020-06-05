# Usage: python flaky-rate-per-test-order.py ../all_tests_combined/test-summaries/flaky-filtered-prefix.csv ../all_tests_combined/per-test-results/ ../module-mapping-filtered.csv  ../all_tests_combined/md5-to-class-order/ > flaky-rate-per-test-order.csv

import json
import os
import sys
from shutil import copy2
import operator
import glob

def split_line(line) :
    result = line.split(",")
    return (result[0],result[1],result[2],result[3],result[4],result[5],result[6],result[7],result[8],result[9])

def add_to_dict(dicta, v, val):
    if v in dicta.keys(): 
        result = dicta[v]
    else: 
        result = []
    if val != "":
        result.append(val)
    dicta[v] = result

def read_per_test_result_file(filepath, ftest):
    dicta = {}
    with open(filepath) as fp:
        for cnt, line in enumerate(fp):
            if line.strip() == "":
                continue
            test, result, time, run_num, machine_id, run_order, tc_num, mod, slug, sha = split_line(line.strip())

            if ftest != test:
                continue
            if (test,run_order) in dicta.keys():
                (crun_num, cpass_num, cerror_num, cfail_num) = dicta[(test,run_order)]
            else:
                crun_num = cpass_num = cerror_num = cfail_num = 0
            crun_num += 1
            if result == "pass":
                cpass_num += 1
            elif result == "failure":
                cfail_num += 1
            elif result == "error":
                cerror_num += 1
            dicta[(test,run_order)] = (crun_num, cpass_num, cerror_num, cfail_num)
    return dicta

def read_summary_file(filepath):
    dicta = {}
    with open(filepath) as fp:
        for cnt, line in enumerate(fp):
            if line.strip() == "":
                continue
            file_slug, sha, test, mod, result, num_run, num_pass, num_error, num_fail = line.strip().split(",")
            file_name, slug = file_slug.split(":", 1)
            dicta[test] = (file_name, slug, sha, mod)
    return dicta

def read_module_file(filepath):
    dicta = {}
    with open(filepath) as fp:
        for cnt, line in enumerate(fp):
            if line.strip() == "":
                continue
            slug, mod_path, macro, mod_id = line.strip().split(",")
            dicta[(slug,mod_path)] = (macro, mod_id)
    return dicta

def read_order_files(filepath, md5, test):
    classlist = list()
    files = glob.glob(os.path.join(filepath, str.format("*{}*", md5)))
    if len(files) != 1:
        raise ValueError(str.format("Multiple order files found for {} matching md5sum: {}", test, files))
    fullclass = test[:test.rfind('.')]
    testclassidx = -1
    with open(files[0]) as fp:
        for cnt, line in enumerate(fp):
            if line.strip() == "":
                continue
            if fullclass == line.strip():
                testclassidx = cnt
            classlist.append(line.strip())
    return (classlist, testclassidx)

def summarize_test_results(roundpath):
    test_info = read_summary_file(roundpath[1])
    per_test_result_path = roundpath[2]
    module_info = read_module_file(roundpath[3])
    order_files = roundpath[4]
    print "Module_ID,Test_name,Order_ID,Order_Flake_rate,Num_runs,Num_pass,Num_fail,Num_error,Absolute_position,Num_test_class"
    for test in test_info.keys():
        (file_name, slug, sha, mod) = test_info[test]
        results_file = str.format("{}-results.csv", file_name[:file_name.rfind('-')])
        results_file_path = os.path.join(per_test_result_path, results_file)
        if os.path.isfile(results_file_path):
            test_order_results = read_per_test_result_file(results_file_path, test)
            for (test,run_order) in test_order_results.keys():
                (crun_num, cpass_num, cerror_num, cfail_num) = test_order_results[(test,run_order)]
                (classlist, testclassidx) = read_order_files(order_files, run_order, test)

                print str.format("{},{},{},{},{},{},{},{},{},{}", module_info[(slug,mod)][0], test, run_order, round((cerror_num + cfail_num) / (crun_num * 1.0),4), crun_num, cpass_num, cerror_num, cfail_num, testclassidx, len(classlist))
        else:
            raise ValueError(str.format("Cannot find results file: {}", results_file_path))


if __name__ == '__main__':
    summarize_test_results(sys.argv)
