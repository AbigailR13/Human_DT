
close all
clear

% assign trials
test_nums_all{1} = ["23"];
test_nums_all{2} = ["24"];
test_nums_all{3} = ["25"];
test_nums_all{4} = ["26"];

% split data into training and testing and get SVM model from training data
DT_SVM_get_model(test_nums_all);

