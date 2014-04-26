function [Scores, Set] = monamon_ga(Train_d, Train_y, Test_d, tests_set, mode)

  num_classes = length(unique(Train_y));  
  Scores = zeros(size(Test_d,1),num_classes);  
  n = size(Train_d,2);  
  Set = cell(1,num_classes);
  
  for k = 1:num_classes
    tests_k = tests_set{k};
    num_tests_k = size(tests_k,1);
    
    for test_it = 1:num_tests_k
        
      % Divide data into K,NotK classes
      K    = Train_d(Train_y == k, tests_k(test_it,:));
      NotK = Train_d(Train_y ~= k, tests_k(test_it,:));             
  
      m_k = size(K,1);
      m_nk = size(NotK,1);        
  
      if mode == 1
        m1 = m_k;
        m2 = m_nk;
        K1 = K; 
        K2 = NotK;
      else
        m1 = m_nk;
        m2 = m_k;
        K1 = NotK;
        K2 = K;
      end
      
      [BoolM, Nabor]= make_boolm(K1, K2, flag_delete_rare_ec, missed_val);
      w = ones(1,size(BoolM,2)) / size(BoolM,2);
      options.FitnessFunction = @(x)x * w';
      options.InstanceCount = 100;
      [Pop, ga_scores] = scp_ga(BoolM, options);
      
      Set{k}{test_it} = 
      
      % Make Nabor    
      set_mask = any(reshape(CompM, m2, m1*n),1);   
      set_mask_cell = num2cell(reshape(set_mask, m1, n),1);
      col_rep = repmat(1:n,m1,1);    
      set_all_ec = num2cell([col_rep;class],1);
      set_all_ec = cellfun(@(x) reshape(x,m1,2), set_all_ec, 'UniformOutput', false);
      set_all_ec = cellfun(@(x, mask) unique(x(mask,:),'rows'), set_all_ec, set_mask_cell, 'UniformOutput', false);
      
      k_tests = tests_set{k}; 
    
      for t_it = 1:size(k_tests,1)
        res_set{k}{t_it} = cell2mat(set_all_ec(k_tests(t_it,:))');        
      end               
    
    end
    
    % Compute scores of belonging to class K
    weights = ones(1,length(res_set{k}));
    Scores(:,k) = compute_score4K(Train_d, Train_y == k, Test_d, res_set{k}, weights, mode);       
  end 
end