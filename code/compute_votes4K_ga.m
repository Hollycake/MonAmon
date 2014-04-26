function sumv = compute_votes4K_ga(Train_eq, Valid_eq, U, mode)

  % mark that feature values that the same in Nabor   
  %w_train = Train(:, U(:,1)) == repmat(U(:,2)', size(Train,1), 1);
  %w_valid  = Test (:, U(:,1)) == repmat(U(:,2)', size(Test,1), 1);

  w_train = Train_eq(:,U);
  w_valid = Valid_eq(:,U);
  
  size_w_train = size(w_train,1);
  size_w_valid = size(w_valid,1);
  
  w_train = repmat(w_train, size_w_valid, 1);  
  w_valid = reshape(repmat(w_valid, 1, size_w_train)', size(w_valid, 2), size_w_train*size_w_valid)';
    
  switch mode
    case 1
      sumv = all(w_valid >= w_train, 2); %<<<<<MONOTONIC
    case 2      
      sumv = ones( size(w_valid,1), 1 ) -  all(w_valid >= w_train, 2);%<<<<<REAL ANTIMONOTONIC
  end
    
  sumv = reshape(sumv, size(Train_eq,1), size(Valid_eq,1));
   
  sumv = sum(sumv,1)'; %<<<<<<<<<<ANTIMONOTONIC MONOTONIC  
end