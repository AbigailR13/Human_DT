

close all
clear

% file where testing data matrix is stored
file_name = 'DT_testing_data.mat';

% input data into human DT
[percent_correct,physiological_states,qofo] = Human_DT(file_name);

percent_correct




