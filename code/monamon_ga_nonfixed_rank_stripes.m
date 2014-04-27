%> @file monamon_ga_nonfixed_rank_stripes.m
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
    
function [Scores, Set, Hist, it_inds] = monamon_ga_nonfixed_rank_stripes(Train_d, Train_y, Test_d, Test_y, options)

  num_classes = length(unique(Train_y)); 
  
  %% Make validation sample
  if isfield(options,'it_inds')
    it_inds = options.it_inds;
    train_inds = options.it_inds.train; 
    valid_inds = options.it_inds.valid;
  else
    [train_inds, valid_inds] = sampling_strat_2parts(Train_y, 0.85);
    it_inds.train = train_inds;
    it_inds.valid = valid_inds;
  end
  
  Valid_d = Train_d(valid_inds,:);
  Valid_y = Train_y(valid_inds);
  Train_d = Train_d(train_inds,:);
  Train_y = Train_y(train_inds);
  
  max_num_it = options.max_num_it;
  
%   Set = cell(1,num_it);
  
%   if options.verbose
%     v_obj_ind = 1:length(Valid_y);
%     v_obj_ind_k1 = v_obj_ind(Valid_y == 1);
%     v_obj_ind_k2 = v_obj_ind(Valid_y == 2);
%     v_obj_ind_k3 = v_obj_ind(Valid_y == 3);
%     v_obj_ind_k4 = v_obj_ind(Valid_y == 4);
%     v_obj_ind_k5 = v_obj_ind(Valid_y == 5);
%   end
  
  for it = 1:max_num_it
    [Hist.Scores_test(:,:,it), Hist.Scores_valid(:,:,it), Set{it}] = monamon_ga_nonfixed_rank_stripe_step(Train_d, Train_y, Valid_d, Valid_y, Test_d, options);
    Scores = sum(Hist.Scores_test(:,:,1:it),3) / it;
    Scores_valid = sum(Hist.Scores_valid(:,:,1:it),3) / it;
    
    %% Compute margins
    Hist.Margins_test(it) = Scores(Test_y) - max(Scores(setdiff(1:num_classes,Test_y)));
    
    Hist.Margins_val{it} = zeros(length(Valid_y),1);    
    
    val_start = 1;
    for k = 1:num_classes
       v_obj_ind_k = (Valid_y == k);       
       Hist.Margins_val{it}(val_start:val_start+sum(v_obj_ind_k)-1) = Scores_valid(v_obj_ind_k,k) - max(Scores_valid(v_obj_ind_k,setdiff(1:num_classes,k)));
       val_start = val_start + sum(v_obj_ind_k);              
    end
    
    %% Show margins if verbose
    if options.verbose
      figure(it);
      clf;    
      subplot(2,1,1);
      for k = 1:num_classes        
        v_obj_ind_k = find(Valid_y == k);  
        
        switch k
          case 1
            marker = 'o';
            color = 'r';
          case 2
            marker = '+';
            color = 'b';
          case 3
            marker = '^';
            color = 'g';
          case 4
            marker = 'x';
            color = 'k';
          case 5
            marker = 'd';
            color = 'c';
        end
                
        hold on;
        scatter(v_obj_ind_k, Hist.Margins_val{it}(v_obj_ind_k), marker, color);                  
      end
      
      hold on;
      plot([1,length(Valid_y)],[0 0], 'm-.'); 
      
      subplot(2,1,2);
      switch Test_y
        case 1
          marker = 'o';
          color = 'r';
        case 2
          marker = '+';
          color = 'b';
        case 3
          marker = '^';
          color = 'g';
        case 4
          marker = 'x';
          color = 'k';
        case 5
          marker = 'd';
          color = 'c';
      end
      plot(1:it, Hist.Margins_test, [color,'-',marker]); 
      hold on;
      plot([1,it],[0 0], 'm-.');
    end
    
    %% Check if we have denialls at first iteration
    if (it == 1) && any(~any(Scores_valid,2))
      continue;
    end
          
    %% Classify
    [~, val_prc] = classify(Scores_valid, Valid_y);
    
    %% Stop if 100% accuracy on valid sample
    if val_prc == 100
      break;
    end    
    
    %%
    if (it > 1) && all(Hist.Margins_val{it} - Hist.Margins_val{it-1} < options.epsilon)
      break;
    end
      
  end
    
end

function [Scores_test, Scores_valid, Set] = monamon_ga_nonfixed_rank_stripe_step(Train_d, Train_y, Valid_d, Valid_y, Test_d, options)

  num_classes = length(unique(Train_y));  
  Scores_test  = zeros(size(Test_d,1),num_classes);
  Scores_valid = zeros(size(Valid_d,1),num_classes);
  Set = cell(1,num_classes);  
    
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
    
    while 1
      EC_set_1rank = construct_all1rank_basis(K1,options.miss_val);
      [BoolM_1r,EC_set_1rank] = make_boolm_nfrank(K1, K2, EC_set_1rank);
      obj2save = any(BoolM_1r,2);
      if ~all(obj2save)        
        obj2save_k1 = all(reshape(obj2save,size(K2,1),size(K1,1)),1);   
        obj2save_k2 = all(reshape(obj2save,size(K2,1),size(K1,1)),2);
        if sum(obj2save_k1)/size(K1,1) > sum(obj2save_k2)/size(K2,1)
          K1 = K1(obj2save_k1,:);
        else
          K2 = K2(obj2save_k2,:);
        end
        %EC_set_1rank = construct_all1rank_basis(K1,options.miss_val);
      else
        break
      end
    end
    
    options.num2stripe = 2*ceil(log2(size(BoolM_1r,1)))+3;
   
%     [BoolM, EC_set] = make_boolm_nfrank(K1, K2, EC_set_1rank);
    num_1rank = size(EC_set_1rank.H,1);
    
    inds_pool = 1:num_1rank;
    stripe_inds = false(1,num_1rank);
    
    num2stripe = min(options.num2stripe,length(inds_pool));
    for i = 1:num2stripe
      if isempty(inds_pool)
        break
      else
        j = randi(length(inds_pool),1);
        stripe_inds(inds_pool(j)) = true;      
        inds_pool(j) = [];        
      end
    end
    
    num_attempts = 3;
    for attempt = 1:num_attempts
      if all(any(BoolM_1r(:,stripe_inds),2))
        Set{k}.num2stripe = sum(stripe_inds);
        break
      end
      %fprintf('Attempt %d of %d\n',attempt,num_attempts);
      
      if attempt == num_attempts
        obj2save = any(BoolM_1r(:,stripe_inds),2);
        obj2save_k1 = all(reshape(obj2save,size(K2,1),size(K1,1)),1);
        obj2save_k2 = all(reshape(obj2save,size(K2,1),size(K1,1)),2);
        part_save_k1 = sum(obj2save_k1)/size(K1,1);
        part_save_k2 = sum(obj2save_k2)/size(K2,1);

        if part_save_k1 > part_save_k2
          K1 = K1(obj2save_k1,:);
        else
          K2 = K2(obj2save_k2,:);
        end        
        Set{k}.num2stripe = sum(stripe_inds);
        break;
      end
      
      if ~isempty(inds_pool)
        j = randi(length(inds_pool),1);
        stripe_inds(inds_pool(j)) = true;
        inds_pool(j) = [];
      end
    end

    EC_set = construct_stripe_basis(EC_set_1rank.H(stripe_inds,:), EC_set_1rank.sigma(stripe_inds,:), options.max_rank);      
    %% Make bool matrix
    [BoolM, EC_set] = make_boolm_nfrank(K1, K2, EC_set);

    if ~all(any(BoolM,2))
      disp('BoolM has not covered rows');
    end
    
    Set{k}.num2stripe = sum(stripe_inds);    
          
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
    [Pop, Set{k}.ga_scores] = scp_ga(logical(BoolM), gaoptions);      
       
    %% Transform results
    Set{k}.population = logical(Pop);
    Set{k}.H          = EC_set.H;
    Set{k}.sigma      = EC_set.sigma;          

    %% Compute scores of belonging to class K
    weights = ones(1,size(Set{k}.population,1));
    Scores_test(:,k)  = compute_score4K_nfrank(K1, Test_d,  Set{k}, weights, options.mode);
    Scores_valid(:,k) = compute_score4K_nfrank(K1, Valid_d, Set{k}, weights, options.mode);
  
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