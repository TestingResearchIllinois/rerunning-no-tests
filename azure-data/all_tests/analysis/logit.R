allAzureFlakiesResults <- allAzureFlakies %>% rowwise() %>% mutate(test_result=recode(test_result,"pass"=0,"error"=1,"failure"=1))

# allAzureFlakiesResults <- allAzureFlakiesResults %>% group_by(machine_id,slug,module_path,test_class_order_md5sum,test_name) %>% group_modify(~ as.data.frame(coef(summary(glm(.x$test_result ~ .x$run_num,data=.x,family=binomial(logit))))[2,4]))

allAzureFlakiesResultsModels <- allAzureFlakiesResults %>% group_by(machine_id,slug,module_path,test_class_order_md5sum,test_name) %>% group_modify(~ as.data.frame(glm(.x$test_result ~ .x$run_num,data=.x,family=binomial(logit))))