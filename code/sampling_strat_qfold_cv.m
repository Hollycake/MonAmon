function [train_inds, test_inds] = sampling_strat_qfold_cv(y, num_folds)

  class_labels = unique(y);
  num_classes  = length(class_labels);
  train_inds = cell(1,num_folds);
  test_inds = cell(1,num_folds);    
  
  for k = 1:num_classes
    % Find indexes of objects of class k
    k_inds = find(y == class_labels(k));
    % Permute them
    k_inds = k_inds(randperm(length(k_inds)));
    % Find how many objects should add to fold
    num2fold = floor(length(k_inds)/num_folds);
    if num2fold == 0
      disp('Not enough objects for such number of folds');
      return;
    end
    
    end_c = 0;
    % Add to folds
    for fold = 1:num_folds
      start_c = end_c + 1;
      if fold == num_folds
        end_c = length(k_inds);
      else
        end_c = end_c + num2fold;
      end
      train_inds{fold} = [train_inds{fold}; k_inds([1:start_c-1,end_c+1:end])];
      test_inds{fold} = [test_inds{fold}; k_inds(start_c:end_c)];      
    end
  end

end