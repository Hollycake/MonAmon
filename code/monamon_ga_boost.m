%> @file monamon_ga_boost.m
%> @brief Apply (anti)monotonic algorithm using GA.
%> Initial set of EC is formed from tests_set.
%> Validation sample is used for GA fitness function.
%>
%> @param Train_d Matrix of train objects data
%> @param Train_y Matrix of train objects labels
%> @param Test_d Matrix of test objects data
%> @param tests_set Cell [1, num_classes] of logical matrixes [num_tests, num_features]
%> each row in which representes what columns are in appropriate test
%> @param miss_val Missing value
%> @mode 1 --- monotonic, 2 --- antimonotonic
%>
%> @retval Scores Scores of belonging objects from Test_d to each class
%> @retval Set of correct sets of EC

function [Test_scores, Set] = monamon_ga_boost(Train_d, Train_y, Test_d, tests_set, eps, miss_val, mode)

  num_classes = length(unique(Train_y));  
  Test_scores = zeros(size(Test_d,1),num_classes);    
  Set = cell(1,num_classes);  
  
  fictive_test = Train_d(1,:);
  max_iter = 5;
  Scores = cell(1,num_classes);
  
  %% Check tests_set
  for k = 1:num_classes
    if size(tests_set{k},1) == 0
      fprintf('monamon_ga_2: empty test set\n');
      return
    end
  end       
   
  %% Divide data into K, NotK classes
  classes = cell(1,num_classes);  
  for k = 1:num_classes
    classes{k}.k    = Train_d(Train_y == k,:);
    classes{k}.notk = Train_d(Train_y ~= k,:);
    classes{k}.inds = [find(Train_y == k); find(Train_y ~= k)];
    [~, classes{k}.inds_back] = sort(classes{k}.inds);
    classes{k}.numk    = size(classes{k}.k,1);
    classes{k}.numnotk = size(classes{k}.notk,1);
  end
    
  %% Initiate obj_weights
  obj_weights = cell(1,num_classes);
  for k = 1:num_classes
    obj_weights{k}.k    = ones(classes{k}.numk,1) / classes{k}.numk;
    obj_weights{k}.notk = ones(classes{k}.numnotk,1) / classes{k}.numnotk;        
  end
  
  obj_weights_hist = cell(1, max_iter);
  
  %% Mark all tests as active
  active_tests_inds = cell(1,num_classes);
  for k = 1:num_classes
    active_tests_inds{k} = true(1,size(tests_set{k},1));
  end      
  
  for it = 1:max_iter
          
    %% Find best test using margins
    [best_tests, active_tests_inds] = find_best_tests(classes, obj_weights, tests_set, active_tests_inds, miss_val);
    %% GA for best test    
%    [~, Set_it] = monamon_ga_2(Train_d, Train_y, fictive_test, best_tests, miss_val, mode) ;       
    [~, Set_it] = monamon_ga_oneone(Train_d, Train_y, fictive_test, best_tests, miss_val, mode) ;       
    %% Find best new EC sets Set
    if it == 1
      only_pos_margins = false;
    else 
      only_pos_margins = true;
    end
    [Set_it_best, Scores_it_best] = find_best_ec_sets(classes, obj_weights, Set_it, mode, only_pos_margins);
    %% Add best new EC sets
    for k = 1:num_classes
      Set{k} = [Set{k}, Set_it_best{k}];
      Scores{k} = [Scores{k}, Scores_it_best{k}];
    end    
    %% Recompute objects weights
    obj_weights = compute_object_weights(classes, Train_y, Scores);
    obj_weights_hist{it} = obj_weights;    
    %% Check stop criterion
    if is_no_active_test(active_tests_inds)
      break;
    end    
    if it>1 && is_no_sign_weight_change(obj_weights_hist, eps)
      break;
    end              
  end 
  
  %% Compute scores of belonging to class K
  for k = 1:num_classes
    Test_scores(:,k) = compute_score4K(Train_d, Train_y == k, Test_d, Set{k}, ones(1,length(Set{k})), mode);
  end
end

function res = is_no_active_test(active_tests_inds)
  res = all(cell2mat(cellfun(@(x) ~any(x), active_tests_inds, 'UniformOutput', false)));
end

function res = is_no_sign_weight_change(obj_weights_hist, eps)
  res = true;  
  num_classes = length(obj_weights_hist{end});
  for k = 1:num_classes
    res = res | (all(abs(obj_weights_hist{end}{k}.k - obj_weights_hist{end-1}{k}.k) < eps) &...
        all(abs(obj_weights_hist{end}{k}.k - obj_weights_hist{end-1}{k}.k) < eps));             
  end
end

function active_tests_set = form_active_tests_set(tests_set, active_tests_inds)

  num_classes = length(tests_set);
  active_tests_set = cell(1,num_classes);
  
  for k = 1:num_classes
    active_tests_set{k} = tests_set{k}(active_tests_inds{k},:);      
  end
end

function [best_tests, active_tests_inds] = find_best_tests(classes, obj_weights, tests_set_ent, active_tests_inds, miss_val)
  % find best test using margins  
  
  % Form active tests set  
  tests_set = form_active_tests_set(tests_set_ent, active_tests_inds);
    
  num_classes = length(classes);
  best_tests = cell(1,num_classes);
  
  for k = 1:num_classes
    num_tests_k = size(tests_set{k},1);
    margins = zeros(1, num_tests_k);
        
    for test_it = 1:num_tests_k
      % Compute margin
      % M_t = mean_{S_i \in K}(w_i * test_score_t(S_i)) - mean_{S_i \in NotK}(w_i * test_score_t(S_i))      
      mean4K = mean(obj_weights{k}.k .* scores_for_K(classes{k}.k, classes{k}.k, tests_set{k}(test_it,:), miss_val));             
      mean4NotK = mean(obj_weights{k}.notk .* scores_for_K(classes{k}.notk, classes{k}.k, tests_set{k}(test_it,:), miss_val));
      margins(test_it) = mean4K - mean4NotK;
    end
    
    [~, best_test_ind] = max(margins);
    best_tests{k} = tests_set{k}(best_test_ind,:);
    
    % Deactivate best test
    active_tests_inds{k}(best_test_ind) = false;
  end
end    

function [best_U_sets, best_scores] = find_best_ec_sets(classes, obj_weights, U_set, mode, only_pos_margins)

  num2add = 3;
  
  num_classes = length(classes);
  best_U_sets = cell(1,num_classes);  
  best_scores = cell(1,num_classes);
  Scores = cell(1,num_classes);
  
  for k = 1:num_classes
    Test_d = [classes{k}.k; classes{k}.notk];     
  
    if mode == 1
      K1 = classes{k}.k;    
    else
      K1 = classes{k}.notk;    
    end  
  
    % Sum all votes of chosen sets of EC   
    for u_it = 1:length(U_set{k})
      Scores{k}.all(:,u_it) = compute_votes4K(K1, Test_d, U_set{k}{u_it}, mode);    
    end      
  
    % Normilize score
    Scores{k}.all = Scores{k}.all ./ size(K1,1);

    num_k       = classes{k}.numk;
    num_notk    = classes{k}.numnotk;
    Scores{k}.k    = Scores{k}.all(1:num_k,:);
    Scores{k}.notk = Scores{k}.all(num_k+1:end,:);
            
    % Compute margin
    % M_t = mean_{S_i \in K}(w_i * score_t(S_i)) - mean_{S_i \in NotK}(w_i * score_t(S_i))
    mean4K    = obj_weights{k}.k' * Scores{k}.k / num_k;
    mean4NotK = obj_weights{k}.notk' * Scores{k}.notk / num_notk;
    margins = mean4K - mean4NotK;  
    
    [~,sort_inds] = sort(margins, 'descend');  
    num2add = min(num2add,length(U_set{k}));
    
    if only_pos_margins
      pos_ind = find(margins > 0);
      best_inds = intersect(sort_inds(1:num2add),pos_ind);
    else
      best_inds = sort_inds(1:num2add);
    end
    
    best_U_sets{k} = U_set{k}(best_inds);
    best_scores{k} = Scores{k}.all(:,best_inds);    
  end
  
end

function obj_weights = compute_object_weights(classes, y, Scores_each)
        
  Scores = cell2mat(cellfun(@(x) mean(x,2), Scores_each, 'UniformOutput', false));  
  [num_obj, num_classes] = size(Scores);
  
  for k = 1:num_classes
    Scores(:,k) = Scores(classes{k}.inds_back,k);
  end

  margins = zeros(num_obj,1);
  for i = 1:num_obj
    margins(i) = Scores(i,y(i)) - max(Scores(i,setdiff(1:num_classes,y(i))));      
  end
  
  obj_weights = cell(1,num_classes);
  for k = 1:num_classes
    margins_perm = margins(classes{k}.inds);
    obj_weights{k}.k = margins_perm(1:classes{k}.numk) / classes{k}.numk;
    obj_weights{k}.notk = margins_perm(classes{k}.numk+1:end) / classes{k}.numnotk;
  end
end