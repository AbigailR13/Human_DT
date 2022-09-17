

function [percent_correct,preds,classes,score] = DT_SVM_test_model(file_name,control,model_num,mdl_control,scale)
    
    load(file_name,'testing');

    data = testing(:,1:4);
    classes = testing(:,6);

    % load SVM model
    load(strcat('SVM_test_',model_num,'_model_',mdl_control,'_pemh',scale,'.mat'));
    
    % predict states and get scores
    [label,score] = predict(SVMModel,data);
    
    
    % make labels doubles
    preds = zeros(size(label));
    for i = 1:size(label)
        preds(i) = str2double(label{i});
    end
    
    % get num correctly labeled states
    num_correct = sum(preds == classes);
    total = size(preds,1);
    % get percent correctly labeled states
    percent_correct = (num_correct)/total;

end
