function experiments = init_res_struct_loo(num_obj, num_classes)

  experiments.prc  = zeros(num_obj, 2+num_classes);
  experiments.num  = zeros(num_obj, 2*num_classes+1);   
  experiments.time = zeros(1,num_obj);
  experiments.set  = cell(1,num_obj);
  experiments.Scores = zeros(num_obj, num_classes);
  
end