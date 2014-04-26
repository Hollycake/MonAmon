function [Scores, Set] = monamon_ga_1(Train_d, Train_y, Test_d, tests_set, mode)

  num_classes = length(unique(Train_y));  
  Scores = zeros(size(Test_d,1),num_classes);    
  Set = cell(1,num_classes);  
  
  % Make validation sample
  [train_inds, valid_inds] = sampling_strat_2parts(Train_y, 0.85); 
  Valid_d = Train_d(valid_inds,:);
  Valid_y = Train_y(valid_inds);
  Train_d = Train_d(train_inds,:);
  Train_y = Train_y(train_inds);
  
  for k = 1:num_classes    
    cols = find(any(tests_set{k},1));
    cols = unique(cols);
    
    % Divide data into K,NotK classes
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
    [BoolM, Nabor]= make_boolm(K1, K2, true, -1); %%TODO    
    
    % Run GA
    %w = ones(1,size(BoolM,2)) / size(BoolM,2);
    %options.FitnessFunction = @(x)x * w';    
    Train_K_eq = K1(:, Nabor(:,1)) == repmat(Nabor(:,2)', size(K1,1), 1);
    Valid_K = Valid_d(Valid_y == k, cols);
    Valid_NotK = Valid_d(Valid_y ~= k, cols);
    Valid_K_eq = Valid_K(:, Nabor(:,1)) == repmat(Nabor(:,2)', size(Valid_K,1), 1);
    Valid_NotK_eq = Valid_NotK(:, Nabor(:,1)) == repmat(Nabor(:,2)', size(Valid_NotK,1), 1);
    
    options.FitnessFunction = @(SetU) find_weights_ga(Train_K_eq, Valid_K_eq, Valid_NotK_eq, SetU, mode);
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

function weights = find_weights_ga(Train_K_eq, Valid_K_eq, Valid_NotK_eq, SetU, mode)
    % Train - training set of objects, last feature is for class
    % Test - test set of objects, last feature is for class
    % Nabor - set of elementary classifiers (number of feature, value of feature)
    % ug - set of numbers of EC in Nabor, that are in U - set of monotonic EC      
    
    pow_of_test_of_K = size(Valid_K_eq, 1);
    pow_of_test_of_NotK = size(Valid_NotK_eq, 1);
    
    numU = size(SetU,1);
    RightVotes4K = zeros(numU,1);
    WrongVotes4K = zeros(numU,1);
    
    for U_it = 1:numU
      %RightVotes4K(U_it) = sum(compute_votes4K(Train_K, Valid_K, Nabor(SetU(U_it,:),:), mode));
      %WrongVotes4K(U_it) = sum(compute_votes4K(Train_K, Valid_NotK, Nabor(SetU(U_it,:),:), mode));
      RightVotes4K(U_it) = sum(compute_votes4K_ga(Train_K_eq, Valid_K_eq, SetU(U_it,:), mode));
      WrongVotes4K(U_it) = sum(compute_votes4K_ga(Train_K_eq, Valid_NotK_eq, SetU(U_it,:), mode));      
    end
    
    weights = WrongVotes4K / pow_of_test_of_NotK - RightVotes4K / pow_of_test_of_K;
    
end
