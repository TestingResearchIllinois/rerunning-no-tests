Contents of this directory:
- 188_idf_nods.csv contains the NO flaky tests found by iDFlakies (idf). Each line is `github_link,sha,module,test_name,found_in_which_dataset`
- 309_nods.csv contains the NO flaky tests found by iDFlakies and from running Surefire on Azure (soa). Each line is `github_link,sha,module,test_name,found_in_which_dataset`. Note that the names of the tests are not unique across rows
- 48_did_compile_soa_mods.csv contains the modules that we successfully compiled and ran Surefire on Azure
- 63-mod-overview.csv compares the number of flaky tests found by idf and soa. Each line is `project,sha,module,did_compile_soa,idf_found,soa_found,idf_only,soa_only,idf_and_soa`

Note that instead of NOT_RUN for the following module, it is actually currently running.
- https://github.com/alibaba/fastjson,e05e9c5e4be580691cc55a59f3256595393203a1,fastjson,NOT_RUN,2,0,2,0,0
