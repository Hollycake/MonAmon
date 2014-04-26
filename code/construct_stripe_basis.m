function EC_set = construct_stripe_basis(H_r1, sigma_r1, max_rank)    

%   ind_cols = any(H_r1,1);
%   n = sum(ind_cols);
%   D = (0:2^n-1)';
%   B = rem(floor(D*pow2(-(n-1):0)),2);   
%   H = B(sum(B,2)<=max_rank,:);
%   
%   EC_set.H = zeros(size(H,1)-1,size(H_r1,2));
%   EC_set.H(:,ind_cols) = H(2:end,:);
%   
%   sigma_vals_rep = repmat(sum(sigma_r1,1),size(EC_set.H,1),1);
%   EC_set.sigma = sigma_vals_rep .* EC_set.H;

  HS = [H_r1, sigma_r1];
  res_all = HS;
  res_it = HS;
  
  for i = 1:max_rank-1
    [res_rep,HS_rep] = create_allpairs_repmats(res_it, HS);
    res_it = res_rep + HS_rep;
    res_all = [res_all; res_it];
  end
   
  res_all = unique(res_all,'rows');
  n = size(H_r1,2);
  rows2save = all(res_all(:,1:n) <= 1, 2);
  
  EC_set.H = res_all(rows2save,1:n);
  EC_set.sigma = res_all(rows2save,n+1:end);
  
end