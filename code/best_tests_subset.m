function [Subset_scores, Set, margins] = best_tests_subset(Train_d, Train_y, Test_d, tests_set, miss_val)

  num_classes = length(unique(Train_y));  
  Subset_scores = zeros(size(Test_d,1),num_classes);    
  Set = cell(1,num_classes);
  margins = cell(num_classes,1);
  
  %% Make validation sample
  [train_inds, valid_inds] = sampling_strat_2parts(Train_y, 0.8); 
  Valid_d = Train_d(valid_inds,:);
  Valid_y = Train_y(valid_inds);
  Train_d = Train_d(train_inds,:);
  Train_y = Train_y(train_inds);        
  
  for k = 1:num_classes    
    %% Divide data into K,NotK classes
    Train_K    = Train_d(Train_y == k,:);                          
    Valid_K    = Valid_d(Valid_y == k,:);
    Valid_NotK = Valid_d(Valid_y ~= k,:);        
    
    %% Form Set
    add2set = false(size(tests_set{k},1),1);
    
    for test_it = 1:size(tests_set{k},1)
      % Compute margin
      mean4K = mean(scores_for_K(Valid_K, Train_K, tests_set{k}(test_it,:), miss_val));  
      mean4NotK = mean(scores_for_K(Valid_NotK, Train_K, tests_set{k}(test_it,:), miss_val));
      margins{k}(test_it) = mean4K - mean4NotK;
      % Add to Set if margin > 0
      if margins{k}(test_it) > 0
        add2set(test_it) = true;
      end
    end    
    
    Set{k} = tests_set{k}(add2set,:);
    
    %% Compute scores
    if size(Set{k},1) == 0        
      fprintf('best_tests_subset: Bad decision\n');
    else
      Subset_scores(:,k) = scores_for_K(Test_d, Train_K, Set{k}, miss_val);
    end
  end      
end