

close all
clear

% trials for testing data
data{1} = ["24"];
data{2} = ["25"];

% input data into human DT
[percent_correct,physiological_states,qofm] = Human_DT(data);

percent_correct




