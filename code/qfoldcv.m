function [t_exp, mt_exp, amt_exp, mga_exp, amga_exp] = qfoldcv(filename, test_len, num_folds)  
  
  % q-fold CV

  %% Output parametres
  %
  % 'ind_experiments' --- matrix with rows [#right_classified_of class_1, #wrong_classified_of class_1, ..., #right_classified_of class_l, #wrong_classified_of class_l, #denials]         
    
  %% Prepare data
  [Data, num_classes ] = import_data(filename); 
  X = Data(:,1:end-1);
  y = Data(:,end);    

  %% Prepare structures for results
  t_exp = init_res_struct_qfolds(num_folds, num_classes);
  mt_exp = init_res_struct_qfolds(num_folds, num_classes);
  amt_exp = init_res_struct_qfolds(num_folds, num_classes);
  mga_exp = init_res_struct_qfolds(num_folds, num_classes);
  amga_exp = init_res_struct_qfolds(num_folds, num_classes);
   
  % Select Train and Control sets  
  [train_inds, test_inds] = sampling_strat_qfold_cv(y, num_folds);  
  
  %% Run algorithms
  for fold = 1:num_folds
    
    fprintf('number of fold = %d\n', fold);
    
    %% Set Train and Control sets        
    Train_d = X(train_inds{fold},:);
    Train_y = y(train_inds{fold});
    Test_d  = X(test_inds{fold},:);
    Test_y  = y(test_inds{fold});
       
    %% Test algorithm  
    %fprintf('Test algorithm is running...\n');
    tic;
    [t_exp.Scores{fold}, t_exp.set{fold}] = ...
        tests_algorithm(Train_d, Train_y, Test_d, test_len);      
    t_exp.time(fold) = toc;
    
    %% MON
    %fprintf('MON from tests algorithm is running...\n');
    tic;
    [mt_exp.Scores{fold}, mt_exp.set{fold}] = ...
        monamon_from_tests_algorithm(Train_d, Train_y, Test_d, t_exp.set{fold}.set, 1);      
    mt_exp.time(fold) = toc;
    
    %% AMON
    %fprintf('AMON from tests algorithm is running...\n');
    tic;
    [amt_exp.Scores{fold}, amt_exp.set{fold}] = ...
        monamon_from_tests_algorithm(Train_d, Train_y, Test_d, t_exp.set{fold}.set, 2);      
    amt_exp.time(fold) = toc;
    
    %% MON GA
    %fprintf('MON GA algorithm is running...\n');
    tic;
    [mga_exp.Scores{fold}, mga_exp.set{fold}] = ...
        monamon_ga_1(Train_d, Train_y, Test_d, t_exp.set{fold}.set, 1);      
    mga_exp.time(fold) = toc;
        
    %% AMON GA
    %fprintf('AMON GA algorithm is running...\n');
    tic;
    [amga_exp.Scores{fold}, amga_exp.set{fold}] = ...
        monamon_ga_1(Train_d, Train_y, Test_d, t_exp.set{fold}.set, 2);      
    amga_exp.time(fold) = toc;
    
    %% Classification
    [t_exp.num(fold,:), t_exp.prc(fold,:)] = classify(t_exp.Scores{fold}, Test_y);
    [mt_exp.num(fold,:), mt_exp.prc(fold,:)] = classify(mt_exp.Scores{fold}, Test_y);
    [amt_exp.num(fold,:), amt_exp.prc(fold,:)] = classify(amt_exp.Scores{fold}, Test_y);    
    [mga_exp.num(fold,:), mga_exp.prc(fold,:)] = classify(mga_exp.Scores{fold}, Test_y);
    [amga_exp.num(fold,:), amga_exp.prc(fold,:)] = classify(amga_exp.Scores{fold}, Test_y);
  end                
  
  %% Average results
  t_exp    = avg_res_struct_qfolds(t_exp);
  mt_exp   = avg_res_struct_qfolds(mt_exp);
  amt_exp  = avg_res_struct_qfolds(amt_exp);
  mga_exp  = avg_res_struct_qfolds(mga_exp);
  amga_exp = avg_res_struct_qfolds(amga_exp);
  
end
 
function exp = init_res_struct_qfolds(num_folds, num_classes)
  exp.prc    = zeros(num_folds, 2+num_classes);
  exp.num    = zeros(num_folds, 2*num_classes+1);   
  exp.time   = zeros(1,num_folds);
  exp.set    = cell(1,num_folds);
  exp.Scores = cell(1, num_folds); 
end

function exp = avg_res_struct_qfolds(exp)
  exp.num_mean  = mean(exp.num,1);
  exp.prc_mean  = mean(exp.prc,1);
  exp.time_mean = mean(exp.time);
end