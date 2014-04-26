%> @file monamon_ga_0.m
%> @brief Apply (anti)monotonic algorithm using GA.
%> Initial set of EC is formed from all possible EC.
%> Validation sample is used for GA fitness function.
%>
%> @param Train_d Matrix of train objects data
%> @param Train_y Matrix of train objects labels
%> @param Test_d Matrix of test objects data
%> @param miss_val Missing value
%> @mode 1 --- monotonic, 2 --- antimonotonic
%>
%> @retval Scores Scores of belonging objects from Test_d to each class
%> @retval Set of correct sets of EC

function [Scores, Set] = monamon_ga_stripes(Train_d, Train_y, Test_d, num_stripes, miss_val, mode)

  num_classes = length(unique(Train_y));  
  Scores = zeros(size(Test_d,1),num_classes);    
  Set = cell(1,num_stripes);  
    
  %% Make validation sample
  %[train_inds, valid_inds] = sampling_strat_2parts(Train_y, 0.85); 
  %Valid_d = Train_d(valid_inds,:);
  %Valid_y = Train_y(valid_inds);
%   Train_d = Train_d(train_inds,:);
%   Train_y = Train_y(train_inds);
  
  stripes_inds = sampling_strat_stripes(Train_y, num_stripes);
  
  for stripe = 1:num_stripes
    %disp(stripe);
    %% Set Train and Control sets        
    sTrain_d = Train_d(stripes_inds{stripe},:);
    sTrain_y = Train_y(stripes_inds{stripe});
    
    %% 
    [res.Scores{stripe}, Set{stripe}] = ...
      monamon_ga_0(sTrain_d, sTrain_y, Test_d, miss_val, mode);      
    Scores = Scores + res.Scores{stripe};
  end
  
  Scores = Scores / num_stripes;
end

function [stripes_inds] = sampling_strat_stripes(y, num_stripes)

  class_labels = unique(y);
  num_classes  = length(class_labels);  
  stripes_inds = cell(1,num_stripes);    
  
  for k = 1:num_classes
    % Find indexes of objects of class k
    k_inds = find(y == class_labels(k));
    % Permute them
    k_inds = k_inds(randperm(length(k_inds)));
    % Find how many objects should add to fold
    num2stripe = floor(length(k_inds)/num_stripes);
    if num2stripe == 0
      disp('Not enough objects for such number of stripes');
      return;
    end
    
    end_c = 0;
    % Add to folds
    for stripe = 1:num_stripes
      start_c = end_c + 1;
      if stripe == num_stripes
        end_c = length(k_inds);
      else
        end_c = end_c + num2stripe;
      end      
      stripes_inds{stripe} = [stripes_inds{stripe}; k_inds(start_c:end_c)];      
    end
  end

end