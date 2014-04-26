%% Avaliable algorithms:
%  1 -- TEST
%  2 -- BTEST
%  3 -- MON  + TEST
%  4 -- AMON + TEST
%  5 -- MON  + BTEST
%  6 -- AMON + BTEST
%  7 -- MON  + GA + TEST
%  8 -- AMON + GA + TEST
%  9 -- MON  + GA + BTEST
% 10 -- AMON + GA + BTEST
% 11 -- MON  + GA
% 12 -- AMON + GA
% 13 -- MON  + GA + oneone
% 14 -- AMON + GA + oneone
% 15 -- MON  + GA + boost
% 16 -- AMON + GA + boost
% 17 -- ReprSets //представительные наборы длины 3
% 18 -- MON + GA + horizontal stripes
% 19 -- MON + GA + nonfixed EC rank
% 20 -- MON + GA + nonfixed EC rank + vert stripes

function res = QFoldscv(filename, options)  
  % Leave One Out tests

  %% Output parametres
  %
  % 'inderiments' --- matrix with rows [#right_classified_of class_1, #wrong_classified_of class_1, ..., #right_classified_of class_l, #wrong_classified_of class_l, #denials]               
  
  used_algs = options.used_algs;
  test_len  = options.test_len;
  num_folds = options.num_folds;
  
  %% Prepare data
  [Data, num_classes, miss_val] = import_data(filename); 
  X = Data(:,1:end-1);
  y = Data(:,end);  

  %% Prepare structures for results
  num_obj = size(X,1);
  res = init_all_res_struct_qfolds(num_folds, num_classes, used_algs);  
  
  %% Select Train and Control sets
  if isfield(options, 'inds')
    train_inds = options.inds.train;
    test_inds  = options.inds.test;
    res.inds = options.inds;
  else
    [train_inds, test_inds] = sampling_strat_qfold_cv(y, num_folds);
    res.inds.train = train_inds;
    res.inds.test  = test_inds;
  end
  
  %% Run algorithms
  for fold = 1:num_folds
    
    fprintf('number of fold = %d\n', fold);
    
    %% Set Train and Control sets        
    Train_d = X(train_inds{fold},:);
    Train_y = y(train_inds{fold});
    Test_d  = X(test_inds{fold},:);
    Test_y  = y(test_inds{fold});
           
    if used_algs(1)
      %% Test algorithm
      %fprintf('Test algorithm is running...\n');
      tic;
      [res.t.Scores{fold}, res.t.set{fold}] = ...
          tests_algorithm(Train_d, Train_y, Test_d, test_len, miss_val);      
      res.t.time(fold) = toc;
    end
    
    if used_algs(2)
      %% Best tests subset
      %fprintf('Best tests algorithm is running...\n');
      tic;
      [res.tb.Scores{fold}, res.tb.set{fold}] = ...
          best_tests_subset(Train_d, Train_y, Test_d, res.t.set{fold}.set, miss_val);      
      res.tb.time(fold) = toc;
    end
    
    if used_algs(3)
      %% MON from tests
      %fprintf('MON from tests algorithm is running...\n');
      tic;
      [res.mt.Scores{fold}, res.mt.set{fold}] = ...              
          monamon_from_tests_algorithm(Train_d, Train_y, Test_d, res.t.set{fold}.set, miss_val, 1);        
      res.mt.time(fold) = toc;
    end
    
    if used_algs(4)
      %% AMON from test
      %fprintf('AMON from tests algorithm is running...\n');
      tic;
      [res.amt.Scores{fold}, res.amt.set{fold}] = ...        
          monamon_from_tests_algorithm(Train_d, Train_y, Test_d, res.t.set{fold}.set, miss_val, 2);        
      res.amt.time(fold) = toc;    
    end
    
    if used_algs(5)
      %% MON from best tests subset
      %fprintf('MON from best tests subset algorithm is running...\n');
      tic;
      [res.mtb.Scores{fold}, res.mtb.set{fold}] = ...                      
          monamon_from_tests_algorithm(Train_d, Train_y, Test_d, res.tb.set{fold}, miss_val, 1);
      res.mtb.time(fold) = toc;
    end
    
    if used_algs(6)
      %% AMON from best tests subset
      %fprintf('AMON from best tests subset algorithm is running...\n');
      tic;
      [res.amtb.Scores{fold}, res.amtb.set{fold}] = ...                
          monamon_from_tests_algorithm(Train_d, Train_y, Test_d, res.tb.set{fold}, miss_val, 2);
      res.amtb.time(fold) = toc;    
    end
    
    if used_algs(7)
      %% MON GA from tests
      %fprintf('MON GA from tests algorithm is running...\n');
      tic;
      [res.mgat.Scores{fold}, res.mgat.set{fold}] = ...        
          monamon_ga_2(Train_d, Train_y, Test_d, res.t.set{fold}.set, miss_val, 1);        
      res.mgat.time(fold) = toc;
    end
    
    if used_algs(8)
      %% AMON GA from tests
      %fprintf('AMON GA from tests algorithm is running...\n');
      tic;
      [res.amgat.Scores{fold}, res.amgat.set{fold}] = ...        
          monamon_ga_2(Train_d, Train_y, Test_d, res.t.set{fold}.set, miss_val, 2);        
      res.amgat.time(fold) = toc;   
    end
    
    if used_algs(9)
      %% MON GA from best tests subset
      %fprintf('MON GA from best tests subset algorithm is running...\n');
      tic;
      [res.mgatb.Scores{fold}, res.mgatb.set{fold}] = ...                
          monamon_ga_2(Train_d, Train_y, Test_d, res.tb.set{fold}, miss_val, 1);
      res.mgatb.time(fold) = toc;
    end
    
    if used_algs(10)    
      %% AMON GA from best tests subset
      %fprintf('AMON GA from best tests subset algorithm is running...\n');
      tic;
      [res.amgatb.Scores{fold}, res.amgatb.set{fold}] = ...                
          monamon_ga_2(Train_d, Train_y, Test_d, res.tb.set{fold}, miss_val, 2);
      res.amgatb.time(fold) = toc;   
    end
    
    if used_algs(11)
      %% MON GA
      %fprintf('MON GA algorithm is running...\n');
      tic;
      [res.mga.Scores{fold}, res.mga.set{fold}] = ...
          monamon_ga_0(Train_d, Train_y, Test_d, miss_val, 1);      
      res.mga.time(fold) = toc;
    end
    
    if used_algs(12)
      %% AMON GA
      %fprintf('AMON GA algorithm is running...\n');
      tic;
      [res.amga.Scores{fold}, res.amga.set{fold}] = ...
          monamon_ga_0(Train_d, Train_y, Test_d, miss_val, 2);      
      res.amga.time(fold) = toc;   
    end
    
    if used_algs(13)
      %% MON GA from tests one one
      %fprintf('MON GA from tests one one algorithm is running...\n');
      tic;
      [res.mgat11.Scores{fold}, res.mgat11.set{fold}] = ...        
          monamon_ga_oneone(Train_d, Train_y, Test_d, res.t.set{fold}.set, miss_val, 1);        
      res.mgat11.time(fold) = toc;
    end
    
    if used_algs(14)
      %% AMON GA from tests one one
      %fprintf('AMON GA from tests one one algorithm is running...\n');
      tic;
      [res.amgat11.Scores{fold}, res.amgat11.set{fold}] = ...        
          monamon_ga_oneone(Train_d, Train_y, Test_d, res.t.set{fold}.set, miss_val, 2);        
      res.amgat11.time(fold) = toc;   
    end
        
    if used_algs(15)
      boost_eps = 0.1;
      %% MON GA boost from tests
      %fprintf('MON GA boost from tests algorithm is running...\n');
      tic;      
      [res.mgatboo.Scores{fold}, res.mgatboo.set{fold}] = ...        
          monamon_ga_boost(Train_d, Train_y, Test_d, res.t.set{fold}.set, boost_eps, miss_val, 1);        
      res.mgatboo.time(fold) = toc;
    end
    
    if used_algs(16)
      boost_eps = 0.000000000000001;
      %% AMON GA boost from tests
      %fprintf('AMON GA boost from tests algorithm is running...\n');
      tic;
      [res.amgatboo.Scores{fold}, res.amgatboo.set{fold}] = ...        
          monamon_ga_boost(Train_d, Train_y, Test_d, res.t.set{fold}.set, boost_eps, miss_val, 2);        
      res.amgatboo.time(fold) = toc;   
    end
    
    if used_algs(17)      
      %% Representative sets voting
      %fprintf('Representative sets voting...\n');
      tic;
      res.reprsets.Scores{fold} = ...        
          representative_sets_voting(Train_d, Train_y, Test_d);        
      res.reprsets.time(fold) = toc;   
    end
    
    if used_algs(18)      
      %% MON + GA + stripes  
      res.mgastripe.num_stripes = 6;
      tic;
      [res.mgastripe.Scores{fold}, res.mgastripe.set{fold}] = ...        
          monamon_ga_stripes(Train_d, Train_y, Test_d, res.mgastripe.num_stripes, miss_val, 1);        
      res.mgastripe.time(fold) = toc;   
    end
    
    if used_algs(19)
      %% MON + GA + nonfixed EC rank
      tic;
      options.mode = 1;
      options.miss_val = miss_val;
      [res.mganfr.Scores{fold}, res.mganfr.set{fold}] = ...        
          monamon_ga_nonfixed_rank(Train_d, Train_y, Test_d, options);        
      res.mganfr.time(fold) = toc; 
    end
    
    if used_algs(20)
      %% MON + GA + nonfixed EC rank
      tic;
      options.mode = 1;
      options.miss_val = miss_val;
%       options.num2stripe = 30;
%       options.max_rank = 3;
%       options.num_it = 3;
%       options.verbose = true;
      if isfield(options, 'infold_inds')
        options.it_inds = options.infold_inds{fold};
      end
      [res.mganfrs.Scores{fold}, res.mganfrs.set{fold}, res.mganfrs.hist{fold}, res.infold_inds{fold}] = ...        
          monamon_ga_nonfixed_rank_stripes(Train_d, Train_y, Test_d, options);        
      res.mganfrs.time(fold) = toc; 
    end
    
    %% Classification
    res = classify4fold(res, fold, Test_y);
    
  end                  

  %% Average results
  res = avg_all_res_struct_qfolds(res);  
end

function exp = init_res_struct_qfolds(num_folds, num_classes)
  exp.prc    = zeros(num_folds, 2+num_classes);
  exp.num    = zeros(num_folds, 2*num_classes+1);   
  exp.time   = zeros(1,num_folds);
  exp.set    = cell(1,num_folds);
  exp.Scores = cell(1, num_folds); 
end

function res = init_all_res_struct_qfolds(num_obj, num_classes, used_algs)

  res.used_algs = used_algs;
  
  if used_algs(1)
    res.t = init_res_struct_qfolds(num_obj,num_classes);
  end
  
  if used_algs(2)
    res.tb = init_res_struct_qfolds(num_obj,num_classes);
  end
  
  if used_algs(3)
    res.mt = init_res_struct_qfolds(num_obj,num_classes);
  end
  
  if used_algs(4)
    res.amt = init_res_struct_qfolds(num_obj,num_classes);
  end
  
  if used_algs(5)
    res.mtb = init_res_struct_qfolds(num_obj,num_classes);
  end
  
  if used_algs(6)
    res.amtb = init_res_struct_qfolds(num_obj,num_classes);
  end
  
  if used_algs(7)
    res.mgat = init_res_struct_qfolds(num_obj,num_classes);
  end
  
  if used_algs(8)
    res.amgat = init_res_struct_qfolds(num_obj,num_classes);
  end
  
  if used_algs(9)
    res.mgatb = init_res_struct_qfolds(num_obj,num_classes);
  end
  
  if used_algs(10)
    res.amgatb = init_res_struct_qfolds(num_obj,num_classes);
  end
  
  if used_algs(11)
    res.mga = init_res_struct_qfolds(num_obj,num_classes);
  end
  
  if used_algs(12)
    res.amga = init_res_struct_qfolds(num_obj,num_classes);
  end
  
  if used_algs(13)
    res.mgat11 = init_res_struct_qfolds(num_obj,num_classes);
  end
  
  if used_algs(14)
    res.amgat11 = init_res_struct_qfolds(num_obj,num_classes);
  end
  
  if used_algs(15)
    res.mgatboo = init_res_struct_qfolds(num_obj,num_classes);
  end
  
  if used_algs(16)
    res.amgatboo = init_res_struct_qfolds(num_obj,num_classes);
  end
  
  if used_algs(17)
    res.reprsets = init_res_struct_qfolds(num_obj,num_classes);
  end
  
  if used_algs(18)
    res.mgastripe = init_res_struct_qfolds(num_obj,num_classes);
  end
  
  if used_algs(19)
    res.mganfr = init_res_struct_qfolds(num_obj,num_classes);
  end
  
  if used_algs(20)
    res.mganfrs = init_res_struct_qfolds(num_obj,num_classes);
  end
end
  
function res = classify4fold(res_ent, fold, y)
  
  res = res_ent;

  if res.used_algs(1)
    [res.t.num(fold,:), res.t.prc(fold,:)] = classify(res_ent.t.Scores{fold}, y);
  end
  
  if res.used_algs(2)
    [res.tb.num(fold,:), res.tb.prc(fold,:)] = classify(res_ent.tb.Scores{fold}, y);
  end
  
  if res.used_algs(3)
    [res.mt.num(fold,:), res.mt.prc(fold,:)] = classify(res_ent.mt.Scores{fold}, y);
  end
  
  if res.used_algs(4)
    [res.amt.num(fold,:), res.amt.prc(fold,:)] = classify(res_ent.amt.Scores{fold}, y);
  end
  
  if res.used_algs(5)
    [res.mtb.num(fold,:), res.mtb.prc(fold,:)] = classify(res_ent.mtb.Scores{fold}, y);
  end
  
  if res.used_algs(6)
    [res.amtb.num(fold,:), res.amtb.prc(fold,:)] = classify(res_ent.amtb.Scores{fold}, y);
  end
  
  if res.used_algs(7)
    [res.mgat.num(fold,:), res.mgat.prc(fold,:)] = classify(res_ent.mgat.Scores{fold}, y);
  end
  
  if res.used_algs(8)
    [res.amgat.num(fold,:), res.amgat.prc(fold,:)] = classify(res_ent.amgat.Scores{fold}, y);
  end
  
  if res.used_algs(9)
    [res.mgatb.num(fold,:), res.mgatb.prc(fold,:)] = classify(res_ent.mgatb.Scores{fold}, y);
  end
  
  if res.used_algs(10)
    [res.amgatb.num(fold,:), res.amgatb.prc(fold,:)] = classify(res_ent.amgatb.Scores{fold}, y);
  end
  
  if res.used_algs(11)
    [res.mga.num(fold,:), res.mga.prc(fold,:)] = classify(res_ent.mga.Scores{fold}, y);
  end
  
  if res.used_algs(12)
    [res.amga.num(fold,:), res.amga.prc(fold,:)] = classify(res_ent.amga.Scores{fold}, y);  
  end                        

  if res.used_algs(13)
    [res.mgat11.num(fold,:), res.mgat11.prc(fold,:)] = classify(res_ent.mgat11.Scores{fold}, y);
  end
  
  if res.used_algs(14)
    [res.amgat11.num(fold,:), res.amgat11.prc(fold,:)] = classify(res_ent.amgat11.Scores{fold}, y);
  end
  
  if res.used_algs(15)
    [res.mgatboo.num(fold,:), res.mgatboo.prc(fold,:)] = classify(res_ent.mgatboo.Scores{fold}, y);
  end
  
  if res.used_algs(16)
    [res.amgatboo.num(fold,:), res.amgatboo.prc(fold,:)] = classify(res_ent.amgatboo.Scores{fold}, y);
  end
  
  if res.used_algs(17)
    [res.reprsets.num(fold,:), res.reprsets.prc(fold,:)] = classify(res_ent.reprsets.Scores{fold}, y);
  end
  
  if res.used_algs(18)
    [res.mgastripe.num(fold,:), res.mgastripe.prc(fold,:)] = classify(res_ent.mgastripe.Scores{fold}, y);
  end
  
  if res.used_algs(19)
    [res.mganfr.num(fold,:), res.mganfr.prc(fold,:)] = classify(res_ent.mganfr.Scores{fold}, y);
  end
  
  if res.used_algs(20)
    [res.mganfrs.num(fold,:), res.mganfrs.prc(fold,:)] = classify(res_ent.mganfrs.Scores{fold}, y);
  end
end

function experiments = avg_res_struct_qfolds(experiments)
  experiments.num_mean  = mean(experiments.num,1);
  experiments.prc_mean  = mean(experiments.prc,1);
  experiments.time_mean = mean(experiments.time);
  experiments.time_all  = sum (experiments.time);
end

function res = avg_all_res_struct_qfolds(res_ent)
  res = res_ent;

  if res.used_algs(1)
    res.t = avg_res_struct_qfolds(res_ent.t);
  end
  
  if res.used_algs(2)
    res.tb = avg_res_struct_qfolds(res_ent.tb);
  end
  
  if res.used_algs(3)
    res.mt = avg_res_struct_qfolds(res_ent.mt);
  end
  
  if res.used_algs(4)
    res.amt = avg_res_struct_qfolds(res_ent.amt);
  end
  
  if res.used_algs(5)
    res.mtb = avg_res_struct_qfolds(res_ent.mtb);
  end
  
  if res.used_algs(6)
    res.amtb = avg_res_struct_qfolds(res_ent.amtb);
  end
  
  if res.used_algs(7)
    res.mgat = avg_res_struct_qfolds(res_ent.mgat);
  end
  
  if res.used_algs(8)
    res.amgat = avg_res_struct_qfolds(res_ent.amgat);
  end
  
  if res.used_algs(9)
    res.mgatb = avg_res_struct_qfolds(res_ent.mgatb);
  end
  
  if res.used_algs(10)
    res.amgatb = avg_res_struct_qfolds(res_ent.amgatb);
  end
  
  if res.used_algs(11)
    res.mga = avg_res_struct_qfolds(res_ent.mga);
  end
  
  if res.used_algs(12)
    res.amga = avg_res_struct_qfolds(res_ent.amga);
  end     
  
  if res.used_algs(13)
    res.mgat11 = avg_res_struct_qfolds(res_ent.mgat11);
  end
  
  if res.used_algs(14)
    res.amgat11 = avg_res_struct_qfolds(res_ent.amgat11);
  end
  
  if res.used_algs(15)
    res.mgatboo = avg_res_struct_qfolds(res_ent.mgatboo);
  end
  
  if res.used_algs(16)
    res.amgatboo = avg_res_struct_qfolds(res_ent.amgatboo);
  end
  
  if res.used_algs(17)
    res.reprsets = avg_res_struct_qfolds(res_ent.reprsets);
  end
  
  if res.used_algs(18)
    res.mgastripe = avg_res_struct_qfolds(res_ent.mgastripe);
  end
  
  if res.used_algs(19)
    res.mganfr = avg_res_struct_qfolds(res_ent.mganfr);
  end
  
  if res.used_algs(20)
    res.mganfrs = avg_res_struct_qfolds(res_ent.mganfrs);
  end
end  