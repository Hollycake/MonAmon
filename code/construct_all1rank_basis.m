function EC_set = construct_all1rank_basis(K1,miss_val)

  [m,n] = size(K1);
  Nabor = [reshape(repmat(1:n, m, 1), n*m, 1),  K1(:)];  
  Nabor = unique(Nabor, 'rows');
  Nabor = Nabor(Nabor(:,2) ~= miss_val,:);
  
  num_ec = size(Nabor,1);
  EC_set.H     = false(num_ec,n);
  EC_set.sigma = zeros(num_ec,n);
  
  for i = 1:num_ec
    j = Nabor(i,1);    
    EC_set.H(i,j)     = true;
    EC_set.sigma(i,j) = Nabor(i,2);
  end
end