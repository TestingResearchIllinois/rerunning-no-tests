# Usage: python parse_test_method_order.py ../all_tests_combined/per-test-results/blah delight.nashornsandbox.TestMemoryLimit.test_no_abuse

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
    pass_orders = {}
    fail_orders = {}
    with open(filepath) as fp:
        for cnt, line in enumerate(fp):
            if line.strip() == "":
                continue
            test, result, time, run_num, machine_id, run_order, tc_num, mod, slug, sha = split_line(line.strip())

            if ftest == test:
                if result == "pass":
                    add_to_dict(pass_orders, test, (machine_id,run_num))
                else:
                    add_to_dict(fail_orders, test, (machine_id,run_num))
            add_to_dict(dicta, (machine_id,run_num), test)
    return (dicta, pass_orders, fail_orders)

def summarize_test_results(roundpath):
    (dicta, pass_orders, fail_orders) = read_per_test_result_file(roundpath[1], roundpath[2])
    for test in pass_orders.keys():
        print str.format("Passing orders for {}: ", test)
        po = pass_orders[test]
        for o in set(tuple(dicta[i]) for i in po):
            print str.format("  {}", o)
    for test in fail_orders.keys():
        print str.format("Failing orders for {}: ", test)
        po = fail_orders[test]
        for o in set(tuple(dicta[i]) for i in po):
            print str.format("  {}", o)

    with open("Output.txt", "w") as text_file:
        for (machine_id,run_num) in dicta.keys():
            text_file.write(str.format("{},{},{}\n", machine_id, run_num, tuple(dicta[(machine_id,run_num)])))

def read_test_order_file(filepath):
    dicta = {}
    tc_order = {}
    tc_info ={}
    with open(filepath) as fp:
        for cnt, line in enumerate(fp):
            if line.strip() == "":
                continue
            test, result, time, run_num, machine_id, run_order, tc_num, mod, slug, sha = split_line(line.strip())
            tc = test[:test.rfind('.')]
            add_to_dict(dicta, (machine_id,run_num, tc), test)
            add_to_dict(tc_order, tc, (machine_id,run_num, tc))
            tc_info[tc] = (slug, sha, mod)
    return (dicta, tc_order, tc_info)

def summarize_all_test_method_order(roundpath):
    (dicta, tc_order, tc_info) = read_test_order_file(roundpath[1])
    for tc in tc_order.keys():
        (slug,sha, mod) = tc_info[tc]
        all_orders = [dicta[i] for i in tc_order[tc]]
        uniq_orders = set(tuple(i) for i in all_orders)
        print str.format("{},{},{},{},{}", slug, sha, mod, tc, len(uniq_orders))
        with open(str.format("{}-method-orders.txt", tc), "w") as text_file:
            text_file.write(str.format("================{}\n", tc))
            for order in uniq_orders:
                text_file.write(str.format("  {} : {}\n", order, len(order)))

if __name__ == '__main__':
    if len(sys.argv) == 3:
        summarize_test_results(sys.argv)
    else:
        summarize_all_test_method_order(sys.argv)
