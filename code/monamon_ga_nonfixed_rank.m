%> @file monamon_ga_nonfixed_rank.m
%> @brief Apply (anti)monotonic algorithm with EC of nonfixed rank using GA.
%> Initial set of EC is formed from "good" EC.
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
%> Set{k}.population --- logical matrix [num_U,  num_EC]
%> Set{k}.H          --- logical matrix [num_EC, num_features]
%> Set{k}.sigma      --- double  matrix [num_EC, num_features]
    
function [Scores, Set] = monamon_ga_nonfixed_rank(Train_d, Train_y, Test_d, options)

  num_classes = length(unique(Train_y));  
  Scores = zeros(size(Test_d,1),num_classes);    
  Set = cell(1,num_classes);  
    
  %% Make validation sample
  if isfield(options,'it_inds')
    train_inds = options.it_inds.train; 
    valid_inds = options.it_inds.valid;
  else
    [train_inds, valid_inds] = sampling_strat_2parts(Train_y, 0.85); 
  end
  
  Valid_d = Train_d(valid_inds,:);
  Valid_y = Train_y(valid_inds);
  Train_d = Train_d(train_inds,:);
  Train_y = Train_y(train_inds);
  
  for k = 1:num_classes    
      
    %% Divide data into K,NotK classes
    K    = Train_d(Train_y == k,:);
    NotK = Train_d(Train_y ~= k,:);             
 
    %% Create appropriate bool matrix
    if options.mode == 1
      K1 = K; 
      K2 = NotK;            
    else
      K1 = NotK;
      K2 = K;
    end        
    
    EC_set.H     = [];
    EC_set.sigma = [];    
    
    counter = 1;
    while counter < 30
      %% Make local basis    
      %EC_set = construct_local_basis(K1, K2, EC_set, options);    
      EC_set = construct_all1rank_basis(K1,options.miss_val);
    
      %% Make bool matrix
      [BoolM, EC_set] = make_boolm_nfrank(K1, K2, EC_set);    
    
      if ~all(any(BoolM,2))
        %fprintf('Iteration %d: there are null rows in bool matrix\n', counter);
      else
        break
      end
      
      counter = counter + 1;
    end
    
    if counter == 30
       continue         
    end
    
    %% Make [num_obj, num_ec] matrixes of B(H,\sigma)(S)
    Train_eq      = make_ECin_mat(K1, EC_set);
    Valid_K_eq    = make_ECin_mat(Valid_d(Valid_y == k,:), EC_set);
    Valid_NotK_eq = make_ECin_mat(Valid_d(Valid_y ~= k,:), EC_set);
   
    %% Some shit for computing votes
    s_size.train = size(Train_eq,1);
    s_size.valid_K = size(Valid_K_eq,1);
    s_size.valid_NotK = size(Valid_NotK_eq,1);

    [w_valid_K,    w_train_1] = create_allpairs_repmats(Valid_K_eq,   Train_eq);
    [w_valid_NotK, w_train_2] = create_allpairs_repmats(Valid_NotK_eq,Train_eq);
   
    comp_w_K = w_valid_K >= w_train_1;
    comp_w_NotK = w_valid_NotK >= w_train_2;            
    
    %% Define fitness function
    gaoptions.FitnessFunction = ...
      @(SetU) find_weights_ga_0(comp_w_K, comp_w_NotK, s_size, SetU, options.mode);
    
    %% Run GA
    gaoptions.InstanceCount = 100;
    Pop = scp_ga(logical(BoolM), gaoptions);      
        
    %% Transform results
    Set{k}.population = logical(Pop);
    Set{k}.H          = EC_set.H;
    Set{k}.sigma      = EC_set.sigma;
    
    %% Compute scores of belonging to class K
    weights = ones(1,size(Set{k}.population,1));
    Scores(:,k) = compute_score4K_nfrank(K1, Test_d, Set{k}, weights, options.mode);
  end 
end

function sumv = compute_votes4K_nfrank(Train, Test, U, mode)

  w_test =  make_ECin_mat(Test,  U);
  w_train = make_ECin_mat(Train, U);
  [w_test_rep, w_train_rep] = create_allpairs_repmats(w_test, w_train);
    
  switch mode
    case 1 % MON
      sumv = all(w_test_rep >= w_train_rep, 2);
    case 2 % AMON     
      sumv = ones(size(w_test_rep,1),1) - all(w_test_rep >= w_train_rep,2);
  end
    
  sumv = reshape(sumv, size(Train,1), size(Test,1));   
  sumv = sum(sumv,1)'; 
end

function Scores = compute_score4K_nfrank(Train_d, Test_d, U_set, weights, mode)
   
  Scores = zeros(size(Test_d,1),1);  
  num_U = size(U_set.population,1);
    
  % Sum all votes of chosen sets of EC   
  for i = 1:num_U
    ec_mask = U_set.population(i,:);
    U_i.H     = U_set.H(ec_mask,:);
    U_i.sigma = U_set.sigma(ec_mask,:);
    Scores = Scores + weights(i) * compute_votes4K_nfrank(Train_d, Test_d, U_i, mode);      
  end      
   
  % Normilize score
  Scores = Scores ./ size(Train_d,1) ./ num_U;
end

function weights = find_weights_ga_0(comp_w_K, comp_w_NotK, s_size, SetU, mode)   
       
    numU = size(SetU,1);
    RightVotes4K = zeros(numU,1);
    WrongVotes4K = zeros(numU,1);
    
    for U_it = 1:numU      
      U = SetU(U_it,:);
      RightVotes4K(U_it) = ...
        sum(compute_votes4K_ga_0(comp_w_K(:,U), s_size.train, s_size.valid_K, mode));
      WrongVotes4K(U_it) = ...
        sum(compute_votes4K_ga_0(comp_w_NotK(:,U), s_size.train, s_size.valid_NotK, mode));
    end
    
    weights = WrongVotes4K / s_size.valid_NotK...
            - RightVotes4K / s_size.valid_K;
    
end

function sumv = compute_votes4K_ga_0(comp_w_U, s_train, s_valid, mode)

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