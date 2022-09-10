
close all
clear

% assign trials for training data
test_nums_all{1} = ["23"];
test_nums_all{2} = ["26"];

% get SVM model from training data (test_nums_all)
DT_SVM_get_model(test_nums_all);

