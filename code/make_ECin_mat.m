function w_mat = make_ECin_mat(mat, EC_set)

  [m,n] = size(mat);
  num_ec = size(EC_set.H,1);
  w_mat = false(m,num_ec);
  
  H_rep     = permute(reshape(repmat(EC_set.H,     1, m)', n, m, num_ec),[2 1 3]);
  sigma_rep = permute(reshape(repmat(EC_set.sigma, 1, m)', n, m, num_ec),[2 1 3]);
  
  for ec_it = 1:num_ec
    w_mat(:,ec_it) = all( mat .* H_rep(:,:,ec_it) == sigma_rep(:,:,ec_it),2);      
  end
end