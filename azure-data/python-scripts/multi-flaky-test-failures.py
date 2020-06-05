# Usage: python multi-flaky-test-failures.py ../all_tests_combined/test-summaries/flaky-filtered-prefix.csv ../all_tests_combined/per-test-results/ ../module-mapping-filtered.csv

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

def read_per_test_result_file(filepath, ftest, dicta, module_dict, module_info):
    with open(filepath) as fp:
        for cnt, line in enumerate(fp):
            if line.strip() == "":
                continue
            test, result, time, run_num, machine_id, run_order, tc_num, mod, slug, sha = split_line(line.strip())

            if ftest != test:
                continue
            if result == "failure" or result == "error":
                add_to_dict(dicta, (run_order,machine_id,run_num), test)
                module_dict[(run_order,machine_id,run_num)] = module_info

def read_summary_file(filepath):
#apache.incubator-dubbo-737f7a7=org.apache.dubbo.rpc.protocol.dubbo.DubboLazyConnectTest.testSticky1-summary.csv:https://github.com/apache/incubator-dubbo,737f7a7ea67832d7f17517326fb2491d0a086dd7,org.apache.dubbo.rpc.protocol.dubbo.telnet.ListTelnetHandlerTest.testListService,./dubbo-rpc/dubbo-rpc-dubbo,flaky,4000,3991,9,0
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
# https://github.com/alibaba/fastjson,.,\Use{alibaba/fastjson=._name},M1
    dicta = {}
    with open(filepath) as fp:
        for cnt, line in enumerate(fp):
            if line.strip() == "":
                continue
            slug, mod_path, macro, mod_id = line.strip().split(",")
            dicta[(slug,mod_path)] = (macro, mod_id)
    return dicta

def summarize_test_results(roundpath):
    test_info = read_summary_file(roundpath[1])
    per_test_result_path = roundpath[2]
    module_info = read_module_file(roundpath[3])
    print "module_id,batch_id,order_id,tsrnum(1-100),set_of_test_that_fail"
    test_order_results = {}
    order_to_module = {}
    for test in test_info.keys():
        (file_name, slug, sha, mod) = test_info[test]
        results_file = str.format("{}-results.csv", file_name[:file_name.rfind('-')])
        results_file_path = os.path.join(per_test_result_path, results_file)
        if os.path.isfile(results_file_path):
            read_per_test_result_file(results_file_path, test, test_order_results,order_to_module,  module_info[(slug,mod)][0])
        else:
            raise ValueError(str.format("Cannot find results file: {}", results_file_path))

    for (run_order,machine_id,run_num) in test_order_results.keys():
        test_list = test_order_results[(run_order,machine_id,run_num)]
        test_list.sort()
        print str.format("{},{},{},{},{}", order_to_module[(run_order,machine_id,run_num)], machine_id, run_order, run_num, ';'.join(test_list))

if __name__ == '__main__':
    summarize_test_results(sys.argv)
