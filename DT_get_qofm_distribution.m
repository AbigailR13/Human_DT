

function DT_get_qofm_distribution(data, model_num)
   
    scale = '';
    
    % step size for score groups for quality-of-output metrics
    step = 0.1;
    % options for ranges of scores
    max_range = 1.;
    score_opts = 0.6:step:max_range;
    % store number correctly labeled states for each range
    correct = zeros(size(score_opts));
    % store total number of states for each range
    total = zeros(size(score_opts));
        
    % predict states for data from all testing trials
    for k = 1:size(data,2)
        [percent_correct_1,preds,classes,score] = DT_SVM_test_model(data{k},1,model_num,"1",scale);
                
        for i = 1:size(score,1)
            score(i,1) = score(i,preds(i));
        end
        score = score(:,1);

        % separate scores (posterior probabilities) for correctly and incorrectly labeled states
        for i = 1:size(score,1)
            if abs(score(i,1)) > max_range
                total(end) = total(end) + 1;
                if preds(i) == classes(i)
                    correct(end) = correct(end) + 1;
                end
            else
                for j = 1:size(score_opts,2)
                    if score(i) <= score_opts(j)
                        total(j) = total(j) + 1;
                        if preds(i) == classes(i)
                            correct(j) = correct(j) + 1;
                        end
                        break
                    end
                end
            end
        end
    end
    
    % if the count for a range is 0 make it 1 to avoid Nans
    for i = 1:size(total,2)
        if total(i) == 0
            total(i) = 1;
        end
    end

    % get distribution and ranges for distribution
    percent = correct./total;
    distribution = [score_opts;percent];

    % save distribution
    save(strcat("qofm_distribution",model_num,".mat"),"distribution");
    
end
