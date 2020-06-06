Contents of this directory
- all_tests contains the results from running the entire test suite in random test class orders
- all_tests_fixed_order contains the results from running the entire test suite in reverse alphabetical test class order
- all_tests_combined contains the combined results from running the entire test suite in reverse alphabetical test class order and in random test class orders
- isolation contains the results from running each test in isolation. Note that we run isolation only for the flaky tests that all_tests random order, all_tests fixed order, or iDFlakies found. That is, we do _not_ run every test in isolation, only those that we know of to be flaky from some runs of the entire test suite.
- module-info.csv contains for each module used in our study `slug,sha,some_test_in_module,module_path,test_count`

To obtain the mvn-test logs and XML files for specific tests, the relevant locations are the following on our upcrc5 machine.
- all_tests results are from: `/scratch/winglam2/azure-scripts/src/all_tests_results/random_orders`
- all_tests_fixed_order are from: `/scratch/winglam2/azure-scripts/src/all_tests_results/fixed_order`
- all_tests_combined are from the directories listed for all_tests_fixed_order and all_tests results
- isolation results are from: `/scratch/winglam2/azure-scripts/src/isolation-results`
