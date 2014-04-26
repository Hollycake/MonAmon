function stripes_inds = cut_stripes(num_features,num_stripes)

  if num_features <= 3
    stripes_inds{1} = 1:num_features;
    return
  end
  
  num2stripe = floor(num_features/num_stripes);
  
  if num2stripe < 3          
    num2stripe = 3;
    num_stripes = ceil(num_features/num2stripe);
  end
  
  perm = randperm(num_features);
  
  stripes_inds = cell(1,num_stripes);
  
  end_c = 0;
  
  for stripe = 1:num_stripes
    start_c = end_c + 1;
    if stripe == num_stripes
      end_c = num_features;
    else
      end_c = end_c + num2stripe;
    end        
    stripes_inds{stripe} = perm(start_c:end_c);
  end
  
end