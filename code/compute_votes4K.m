function sumv = compute_votes4K(Train, Test, U, mode)

  % mark that feature values that the same in Nabor   
  w_train = Train(:, U(:,1)) == repmat(U(:,2)', size(Train,1), 1);
  w_test  = Test (:, U(:,1)) == repmat(U(:,2)', size(Test,1), 1);

  size_w_train = size(w_train,1);
  size_w_test = size(w_test,1);
  
  w_train = repmat(w_train, size_w_test, 1);  
  w_test = reshape(repmat(w_test, 1, size_w_train)', size(w_test, 2), size_w_train*size_w_test)';
    
  switch mode
    case 1
      sumv = all(w_test >= w_train, 2); %<<<<<MONOTONIC
    case 2      
      sumv = ones( size(w_test,1), 1 ) -  all(w_test >= w_train, 2);%<<<<<REAL ANTIMONOTONIC
  end
    
  sumv = reshape(sumv, size(Train,1), size(Test,1));
   
  sumv = sum(sumv,1)'; %<<<<<<<<<<ANTIMONOTONIC MONOTONIC  
end