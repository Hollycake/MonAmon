function EC_set = construct_local_basis(K1, K2, EC_set, options)

  EC1_set = construct_all1rank_basis(K1,options.miss_val);
  w_k1 = make_ECin_mat(K1, EC1_set);
  w_k2 = make_ECin_mat(K2, EC1_set);
  
  Nabor = zeros(size(EC1_set.H,1),2);
  [~, Nabor(:,1)] = find(EC1_set.H);
  Nabor(:,2) = EC1_set.sigma(EC1_set.H);
  
  stripes_inds = cut_stripes(size(Nabor,1),options.num_stripes);
  num_stripes = length(stripes_inds);
  
  %EC_set.H     = [];
  %EC_set.sigma = [];
  
  n = size(K1,2);
  
  for stripe = 1:num_stripes
    cols = stripes_inds{stripe};
    [H_s, sigma_s] = recfindECs(Nabor(cols,:), w_k1(:,cols), w_k2(:,cols),...
                                0, 1, options.max_depth);
    if isempty(H_s)
      continue
    end
    
    H     = false(length(H_s),n);
    sigma = zeros(length(H_s),n);
    
    for i = 1:length(H_s)
       H    (i,H_s{i}) = true;
       sigma(i,H_s{i}) = sigma_s{i};
    end    
    
    EC_set.H     = [EC_set.H;     H];
    EC_set.sigma = [EC_set.sigma; sigma];
  end
  
  H_sigma = unique([EC_set.H, EC_set.sigma], 'rows');
  EC_set.H     = logical(H_sigma(:,1:n));
  EC_set.sigma = H_sigma(:,n+1:end);
end

function [H, sigma] = recfindECs(Nabor, w_k1, w_k2, prev_crit_val, depth, max_depth)

  H     = [];
  sigma = [];  
  
  %% Find best component to add
  crit_vals     = sum((w_k1/size(w_k1,1)).^0.5,1) - sum((w_k2/size(w_k2,1)).^0.5,1);
  max_crit_val  = max(crit_vals);
  
  %% Stop if there are no good components to add
  if (max_crit_val < prev_crit_val)
    return
  end
  
  ind_init_comps = find(crit_vals == max_crit_val);
  num_init_comps = length(ind_init_comps);         
  
  res_it = 1;
  
  for init_comp_it = 1:num_init_comps

    ind_comp = ind_init_comps(init_comp_it);            
        
%     %% Stop if no objects from K1 are covered
%     if sum(w_k1(:,ind_comp)) == 0
%       continue
%     end

    %% Stop if p/n is less than 60%/40%
    if sum(w_k1(:,ind_comp)) / sum(w_k2(:,ind_comp)) < 1.5
      continue
    end
    
%     %% Stop if max number of components was added
%     % Stop if all objects from K2 are not covered //% Stop if all objects from K1 are covered
%     w_k2_i = w_k2(w_k2(:,ind_comp),:); %w_k1_i = w_k1(~w_k1(:,ind_comp),:);
     
    %if isempty(w_k1_i) || depth == max_depth
%     if isempty(w_k2_i) || depth == max_depth
    if depth == max_depth
      H{res_it}     = Nabor(ind_comp,1);
      sigma{res_it} = Nabor(ind_comp,2);
      res_it = res_it + 1;
      continue   
    end

    %% Go deeper!
    ind_comps_i = (Nabor(:,1) ~= Nabor(ind_comp,1));
    %ind_comps_i = setdiff(1:size(Nabor,1),Nabor(ind_comp,1));

    w_k1_i = w_k1(:,ind_comps_i) .* repmat(w_k1(:,ind_comp),1,sum(ind_comps_i));
    w_k2_i = w_k2(:,ind_comps_i) .* repmat(w_k2(:,ind_comp),1,sum(ind_comps_i));
    
    [H_ii, sigma_ii] = recfindECs(Nabor(ind_comps_i,:), w_k1_i, w_k2_i, ...
                                  max_crit_val, depth+1, max_depth);

%     [H_ii, sigma_ii] = recfindECs(Nabor(ind_comps_i,:), ...
%                                   w_k1(:,ind_comps_i), w_k2_i(:,ind_comps_i), ...
%                                   depth+1, max_depth);
%     [H_ii, sigma_ii] = recfindECs(Nabor(ind_comps_i,:), ...
%                                 w_k1_i(:,ind_comps_i), w_k2(:,ind_comps_i), ...
%                                 depth+1, max_depth);
                            
    %% Add new ECs
    if isempty(H_ii)
      H{res_it}     = Nabor(ind_comp,1);
      sigma{res_it} = Nabor(ind_comp,2);
      res_it = res_it + 1;
      continue
    end
        
    for i = 0:length(H_ii)-1
      H{res_it+i}     = [Nabor(ind_comp,1), H_ii{i+1}];
      sigma{res_it+i} = [Nabor(ind_comp,2), sigma_ii{i+1}];
    end
    res_it = res_it + length(H_ii);

  end
end