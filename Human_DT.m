

function [percent_correct,physiological_states,qofo,qofo_c,qofo_i] = Human_DT(file_name)

    % training sets used
    model_num = "23242526";
    
    scale = '';
        
    % store predicted physiological states
    physiological_states = [];
    % percent_correct keeps count of correctly labeled states
    percent_correct = 0;
    % count keeps count of total states labeled
    count = 0;
    

    % get prediction from model
    [percent_correct_1,preds,classes,score_2] = DT_SVM_test_model(file_name,1,model_num,"1",scale);
    
    score = zeros(size(score_2,1),1);

    for i = 1:size(score_2)
        score(i) = score_2(i,preds(i));
    end

    % store physiological states
    physiological_states = [physiological_states;preds];
    percent_correct = percent_correct + percent_correct_1;
    count = count + 1;   
    
    qofo = zeros(size(score));
    for i = 1:size(score,1)
        x1 = score(i);
        % quality-of-output distribution
        qofo(i) = 0.2055*atan(15*(x1-0.89))+0.789;
    end
    
    % quality-of-output metrics for all correctly and incorrectly labeled
    % physiological states
    qofo_c = [];
    qofo_i = [];
    for i = 1:size(score,1)
        x1 = score(i);
        qofo1 = 0.2055*atan(15*(x1-0.89))+0.789;
        if classes(i) == preds(i)
            qofo_c = [qofo_c;qofo1];
        else
            qofo_i = [qofo_i;qofo1];
        end
    end

    % percent of correctly labeled states
    percent_correct = percent_correct/count;

end
