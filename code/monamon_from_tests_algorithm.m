function [Scores, res_set] = monamon_from_tests_algorithm(Train_d, Train_y, Test_d, tests_set, miss_val, mode)

  num_classes = length(unique(Train_y));  
  Scores = zeros(size(Test_d,1),num_classes);  
  n = size(Train_d,2);  
  res_set = cell(1,num_classes);
  
  %Check tests_set
  for k = 1:num_classes
    if size(tests_set{k},1) == 0
      fprintf('monamon_from_tests_algorithm: empty test set\n');
      return
    end
  end
  
  for k = 1:num_classes
    % Divide data into K,NotK classes
    K    = Train_d(Train_y == k, :);
    NotK = Train_d(Train_y ~= k, :);
    % Compute comparisons matrix
    CompM = create_comparisons_matrix(K, NotK);          
    
    m_k = size(K,1);
    m_nk = size(NotK,1);        
    
    if mode == 1
      m1 = m_k;
      m2 = m_nk;
      class = K; 
    else
      m1 = m_nk;
      m2 = m_k;
      class = NotK; 
    end
    % Make Nabor    
    set_mask = any(reshape(CompM, m2, m1*n),1);   
    set_mask_cell = num2cell(reshape(set_mask, m1, n),1);
    col_rep = repmat(1:n,m1,1);    
    set_all_ec = num2cell([col_rep;class],1);
    set_all_ec = cellfun(@(x) reshape(x,m1,2), set_all_ec, 'UniformOutput', false);
    set_all_ec = cellfun(@(x, mask) unique(x(mask,:),'rows'), set_all_ec, set_mask_cell, 'UniformOutput', false);
    set_all_ec = cellfun(@(x) x(x(:,2)~=miss_val,:), set_all_ec, 'UniformOutput', false);
    
    k_tests = tests_set{k}; 
    
    for t_it = 1:size(k_tests,1)
       res_set{k}{t_it} = cell2mat(set_all_ec(k_tests(t_it,:))');        
    end               
    
    % Compute scores of belonging to class K
    weights = ones(1,length(res_set{k}));
    Scores(:,k) = compute_score4K(Train_d, Train_y == k, Test_d, res_set{k}, weights, mode);       
  end 
end