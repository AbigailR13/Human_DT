

function [percent_correct,physiological_states,qofm] = Human_DT(data)

    % training sets used
    model_num = "2326";
    
    scale = '';
    
    % load ranges of scores and percent correct in those ranges (distribution of quality-of-output metric) 
    load('qofm_distribution2326.mat',"distribution");
    score_opts = distribution(1,:);
    percent = distribution(2,:);
    max_range = score_opts(end);
    step = score_opts(2) - score_opts(1);
    
    % store predicted physiological states
    physiological_states = [];
    % scores_2 stores all the scores
    scores_2 = [];
    % scores stores all scores for incorrectly labeled states
    scores = [];
    % scores_1 stores all scores for correctly labeled states
    scores_1 = [];
    % percent_correct keeps count of correctly labeled states
    percent_correct = 0;
    % count keeps count of total states labeled
    count = 0;
    
    % predict states for data from all testing trials
    for k = 1:size(data,2)
        % get prediction from model
        [percent_correct_1,preds,classes,score] = DT_SVM_test_model(data{k},1,model_num,"1",scale);
        
        % store scores
        scores_2 = [scores_2;score];
        % store physiological states
        physiological_states = [physiological_states;preds];
        percent_correct = percent_correct + percent_correct_1;
        count = count + 1;
        
        % separate scores for correctly and incorrectly labeled states
        for i = 1:size(classes,2)
            if abs(score(i,1)) >= max_range
                if preds(i) == classes(i)
                    scores_1 = [scores_1,abs(score(i,1))];
                else
                    scores = [scores,abs(score(i,1))];
                end
            else
                for j = 1:size(score_opts,2)
                    if abs(score(i,1)) < (step * j)
                        if preds(i) == classes(i)
                            scores_1 = [scores_1,abs(score(i,1))];
                        else
                            scores = [scores,abs(score(i,1))];
                        end
                        break
                    end
                end
            end
        end
    end
    
    % store probability of physiological state for incorrectly labeled
    % states
    incorrect = size(scores);
    for i = 1:size(scores,2)
        if abs(scores(i)) >= max_range
            incorrect(i) = percent(end); 
        else
            for j = 1:size(score_opts,2)
                if abs(scores(i)) < (step * j)
                    incorrect(i) = percent(j);
                    break
                end
            end
        end
    end
    % store probability of physiological state for correctly labeled
    % states
    correct_1 = size(scores_1);
    for i = 1:size(scores_1,2)
        if abs(scores_1(i)) >= max_range
            correct_1(i) = percent(end); 
        else
            for j = 1:size(score_opts,2)
                if abs(scores_1(i)) < (step * j)
                    correct_1(i) = percent(j);
                    break
                end
            end
        end
    end

    % store probability that state is correctly labeled for all labeled
    % states
    qofm = zeros(size(scores_2,1),1);
    for i = 1:size(scores_2,1)
        if abs(scores_2(i)) >= max_range
            qofm(i) = percent(end); 
        else
            for j = 1:size(score_opts,2)
                if abs(scores_2(i)) < (step * j)
                    qofm(i) = percent(j);
                    break
                end
            end
        end
    end
    
    % percent of correctly labeled states
    percent_correct = percent_correct/count;

end