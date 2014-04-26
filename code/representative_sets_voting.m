function Scores = representative_sets_voting(Train_d, Train_y, Test_d)

  num_classes = length(unique(Train_y));
  Scores = zeros(size(Test_d,1),num_classes);
  
  for k = 1:num_classes    
    % Divide data into K, NotK classes
    K    = Train_d(Train_y == k, :);
    NotK = Train_d(Train_y ~= k, :);             
    Scores(:,k) = Classify_ALG(K,NotK,Test_d);
  end
end