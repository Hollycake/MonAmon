%> @file find_all_coverings_len.m
%> @brief Find all coverings of user--defined length for BoolM
%>
%> @param BoolM Boolean matrix [m, n] 
%> @param cov_len Positive integer for length of coverings to search
%>
%> @retval Coverings Matrix [num_cov, cov_len] of coverings 

function [Coverings] = find_all_coverings_len(BoolM, cov_len, cov2del)
  [m,n] = size(BoolM);
  
  Coverings = false(m,n);
  num_covs = 0;
  
  j = nchoosek(1:n, cov_len);
  i = repmat((1:size(j,1))', 1, size(j,2));
  inds2check = logical(full(sparse(i(:),j(:),1,size(i,1),n)));  
  
  %del_len = sum(cov2del,2);
  for i = 1:size(cov2del,1)
    is_eq = ~all(inds2check(:,logical(cov2del(i,:))),2);
    inds2check = inds2check(is_eq,:);
    %is_eq = bsxfun(@and, inds2check, cov2del(i,:));
    %inds2check = inds2check(sum(is_eq,2) ~= del_len(i),:);    
  end
      
  for i = 1:size(inds2check,1)
    T = inds2check(i,:);
    if all( any(BoolM(:,T), 2) )
      num_covs = num_covs + 1;
      Coverings(num_covs,T) = true;
    end    
  end

  if isequal(Coverings, false(1,n))
    Coverings = [];
    disp('No coverings were found');
    return;
  end
  
  Coverings = Coverings(1:num_covs, :);
end