function Scores = compute_score4K(Train_d, Train_y_bin, Test_d, U_set, weights, mode)
   
  Scores = zeros(size(Test_d,1),1);  
  
  % Select subset of Train of class K
  if mode == 1
    Train_K = Train_d(Train_y_bin == 1, :);    
  else
    Train_K = Train_d(Train_y_bin == 0, :);
  end  
  
  % Sum all votes of chosen sets of EC   
  for i = 1:length(U_set)
    Scores = Scores + weights(i) * compute_votes4K(Train_K, Test_d, U_set{i}, mode);      
  end      
   
  % Normilize score
  Scores = Scores ./ size(Train_K,1) ./ length(U_set);

end