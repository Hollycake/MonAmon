function [inds_1, inds_2] = sampling_strat_2parts(y, first_part)

  class_labels = unique(y);
  num_classes  = length(class_labels);
  inds_1 = [];
  inds_2 = [];    
  
  for k = 1:num_classes
    % Find indexes of objects of class k
    k_inds = find(y == class_labels(k));
    % Permute them
    k_inds = k_inds(randperm(length(k_inds)));
    % Find how many objects should add to the first part
    thresh = floor(length(k_inds)*first_part);
    
    inds_1 = [inds_1; k_inds(1:thresh)];
    inds_2 = [inds_2; k_inds(thresh+1:end)];
  end

end