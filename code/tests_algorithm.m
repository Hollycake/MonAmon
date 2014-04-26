function [Scores, tests] = tests_algorithm(Train, y_train, Test, max_test_len, miss_val)
  
  num_classes = length(unique(y_train));  
  Scores = zeros(size(Test,1),num_classes);  
  tests.lens = 1:max_test_len;  
  tests.stat = zeros(length(tests.lens), num_classes);
  tests.set = cell(1,num_classes);
  
  for k = 1:num_classes
    % Divide data into K,NotK classes
    K    = Train(y_train == k, :);
    NotK = Train(y_train ~= k, :);
    % Compute comparisons matrix
    CompM = create_comparisons_matrix(K, NotK);          
    
    for len_it = 1:max_test_len   
      % Find all coverings with defined length
      new_tests = find_all_coverings_len(CompM, len_it, tests.set{k});
      tests.stat(len_it,k) = size(new_tests, 1);
      tests.set{k} = [tests.set{k}; new_tests];            
    end
    tests.set{k} = logical(tests.set{k});
    % Compute scores of belonging to class K
    Scores(:,k) = scores_for_K(Test, K, tests.set{k}, miss_val);         
  end
  
end