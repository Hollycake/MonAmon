%> @file monamon_ga_2.m
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

function [Scores, Set] = monamon_ga_2(Train_d, Train_y, Test_d, tests_set, miss_val, mode)

  num_classes = length(unique(Train_y));  
  Scores = zeros(size(Test_d,1),num_classes);    
  Set = cell(1,num_classes);  
  
  %Check tests_set
  for k = 1:num_classes
    if size(tests_set{k},1) == 0
      fprintf('monamon_ga_2: empty test set\n');
      return
    end
  end
  
  % Make validation sample
  [train_inds, valid_inds] = sampling_strat_2parts(Train_y, 0.85); 
  Valid_d = Train_d(valid_inds,:);
  Valid_y = Train_y(valid_inds);
  Train_d = Train_d(train_inds,:);
  Train_y = Train_y(train_inds);
  
  for k = 1:num_classes    
    % Find indexes of columns that are in any test from "tests_set"
    cols = find(any(tests_set{k},1));
    cols = unique(cols);
    
    % Divide data from columns with indexes "cols" into K, NotK classes
    K    = Train_d(Train_y == k, cols);
    NotK = Train_d(Train_y ~= k, cols);             
 
    % Create appropriate bool matrix
    if mode == 1
      K1 = K; 
      K2 = NotK;            
    else
      K1 = NotK;
      K2 = K;
    end        
    [BoolM, Nabor]= make_boolm(K1, K2, true, 'missed_val', miss_val);   
    
    % Run GA
    %w = ones(1,size(BoolM,2)) / size(BoolM,2);
    %options.FitnessFunction = @(x)x * w';    
    Train_eq = K1(:, Nabor(:,1)) == repmat(Nabor(:,2)', size(K1,1), 1);
    Valid_K = Valid_d(Valid_y == k, cols);
    Valid_NotK = Valid_d(Valid_y ~= k, cols);
    Valid_K_eq = Valid_K(:, Nabor(:,1)) == repmat(Nabor(:,2)', size(Valid_K,1), 1);
    Valid_NotK_eq = Valid_NotK(:, Nabor(:,1)) == repmat(Nabor(:,2)', size(Valid_NotK,1), 1);    
    
    % Some shit for computing votes
    s_size.train = size(Train_eq,1);
    s_size.valid_K = size(Valid_K_eq,1);
    s_size.valid_NotK = size(Valid_NotK_eq,1);
    num_ec = size(Nabor,1);
    
    w_train_1 = repmat(Train_eq, s_size.valid_K, 1);
    w_train_2 = repmat(Train_eq, s_size.valid_NotK, 1);
    w_valid_K = reshape(repmat(Valid_K_eq, 1, s_size.train)',...
                        num_ec, s_size.train * s_size.valid_K)';
    w_valid_NotK = reshape(repmat(Valid_NotK_eq, 1, s_size.train)',...
                           num_ec, s_size.train * s_size.valid_NotK)';
    
    comp_w_K = w_valid_K >= w_train_1;
    comp_w_NotK = w_valid_NotK >= w_train_2;            
    
    options.FitnessFunction = ...
      @(SetU) find_weights_ga_2(comp_w_K, comp_w_NotK, s_size, SetU, mode);
    options.InstanceCount = 100;
    
    Pop = scp_ga(logical(BoolM), options);      
    
    % Add to Nabor real indexes of columns
    for col_it = 1:length(cols)      
      Nabor(Nabor(:,1) == col_it,1) = cols(col_it);
    end
    
    % Transform results
    Pop_l = logical(Pop);
    for U_it = 1:size(Pop,1)
      Set{k}{U_it} = Nabor(Pop_l(U_it,:),:);
    end
      
    % Compute scores of belonging to class K
    weights = ones(1,length(Set{k}));
    Scores(:,k) = compute_score4K(Train_d, Train_y == k, Test_d, Set{k}, weights, mode);       
  end 
end

function weights = find_weights_ga_2(comp_w_K, comp_w_NotK, s_size, SetU, mode)   
       
    numU = size(SetU,1);
    RightVotes4K = zeros(numU,1);
    WrongVotes4K = zeros(numU,1);
    
    for U_it = 1:numU      
      U = SetU(U_it,:);
      RightVotes4K(U_it) = ...
        sum(compute_votes4K_ga_2(comp_w_K(:,U), s_size.train, s_size.valid_K, mode));
      WrongVotes4K(U_it) = ...
        sum(compute_votes4K_ga_2(comp_w_NotK(:,U), s_size.train, s_size.valid_NotK, mode));
    end
    
    weights = WrongVotes4K / s_size.valid_NotK...
              - RightVotes4K / s_size.valid_K;
    
end

function sumv = compute_votes4K_ga_2(comp_w_U, s_train, s_valid, mode)

  switch mode
    case 1
      % Monotonic
      sumv = all(comp_w_U, 2);
    case 2 
      % Antimonotonic
      sumv = ones(size(comp_w_U,1),1) - all(comp_w_U,2);
  end
    
  sumv = sum(reshape(sumv, s_train, s_valid),1)';     
end