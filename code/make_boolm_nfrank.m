function [BoolM, EC_set] = make_boolm_nfrank(K1, K2, EC_set)

  w_k1 =  make_ECin_mat(K1,EC_set);
  w_k2 = ~make_ECin_mat(K2,EC_set);
  
  [w_k1_rep, w_k2_rep] = create_allpairs_repmats(w_k1,w_k2);
  
  BoolM = w_k1_rep .* w_k2_rep;
  
  %% Delete rare EC  
  ind_freq_EC =  sum(BoolM,1) >= size(K2,1); % EC is in >= 1 objects of K
  EC_set.H     = EC_set.H    (ind_freq_EC,:);
  EC_set.sigma = EC_set.sigma(ind_freq_EC,:);
  BoolM = BoolM(:,ind_freq_EC);
  
  %% Delete null cols
  ind_notnull = any(BoolM,1);
  EC_set.H     = EC_set.H    (ind_notnull,:);
  EC_set.sigma = EC_set.sigma(ind_notnull,:);
  BoolM = BoolM(:,ind_notnull);
    
end