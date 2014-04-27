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

function res = LOOcv(filename, options)  
  % Leave One Out tests

  %% Output parametres
  %
  % 'inderiments' --- matrix with rows [#right_classified_of class_1, #wrong_classified_of class_1, ..., #right_classified_of class_l, #wrong_classified_of class_l, #denials]               
  
  used_algs = options.used_algs;
  test_len = options.test_len;
  
  %% Prepare data
  [Data, num_classes, miss_val] = import_data(filename); 
  X = Data(:,1:end-1);
  y = Data(:,end);  

  %% Prepare structures for results
  num_obj = size(X,1);
  res = init_all_res_struct_loo(num_obj, num_classes, used_algs);  
  
  %% Run algorithms
  for obj2out = 1:num_obj
    
    fprintf('obj2out = %d\n', obj2out);
    
    %% Set Train and Control sets        
    Train_d = X(setdiff(1:num_obj, obj2out),:);
    Train_y = y(setdiff(1:num_obj, obj2out));
    Test_d  = X(obj2out,:); 
    Test_y  = y(obj2out);
           
    if used_algs(1)
      %% Test algorithm
      %fprintf('Test algorithm is running...\n');
      tic;
      [res.t.Scores(obj2out,:), res.t.set{obj2out}] = ...
          tests_algorithm(Train_d, Train_y, Test_d, test_len, miss_val);      
      res.t.time(obj2out) = toc;
    end
    
    if used_algs(2)
      %% Best tests subset
      %fprintf('Best tests algorithm is running...\n');
      tic;
      [res.tb.Scores(obj2out,:), res.tb.set{obj2out}] = ...
          best_tests_subset(Train_d, Train_y, Test_d, res.t.set{obj2out}.set, miss_val);      
      res.tb.time(obj2out) = toc;
    end
    
    if used_algs(3)
      %% MON from tests
      %fprintf('MON from tests algorithm is running...\n');
      tic;
      [res.mt.Scores(obj2out,:), res.mt.set{obj2out}] = ...              
          monamon_from_tests_algorithm(Train_d, Train_y, Test_d, res.t.set{obj2out}.set, miss_val, 1);        
      res.mt.time(obj2out) = toc;
    end
    
    if used_algs(4)
      %% AMON from test
      %fprintf('AMON from tests algorithm is running...\n');
      tic;
      [res.amt.Scores(obj2out,:), res.amt.set{obj2out}] = ...        
          monamon_from_tests_algorithm(Train_d, Train_y, Test_d, res.t.set{obj2out}.set, miss_val, 2);        
      res.amt.time(obj2out) = toc;    
    end
    
    if used_algs(5)
      %% MON from best tests subset
      %fprintf('MON from best tests subset algorithm is running...\n');
      tic;
      [res.mtb.Scores(obj2out,:), res.mtb.set{obj2out}] = ...                      
          monamon_from_tests_algorithm(Train_d, Train_y, Test_d, res.tb.set{obj2out}, miss_val, 1);
      res.mtb.time(obj2out) = toc;
    end
    
    if used_algs(6)
      %% AMON from best tests subset
      %fprintf('AMON from best tests subset algorithm is running...\n');
      tic;
      [res.amtb.Scores(obj2out,:), res.amtb.set{obj2out}] = ...                
          monamon_from_tests_algorithm(Train_d, Train_y, Test_d, res.tb.set{obj2out}, miss_val, 2);
      res.amtb.time(obj2out) = toc;    
    end
    
    if used_algs(7)
      %% MON GA from tests
      %fprintf('MON GA from tests algorithm is running...\n');
      tic;
      [res.mgat.Scores(obj2out,:), res.mgat.set{obj2out}] = ...        
          monamon_ga_2(Train_d, Train_y, Test_d, res.t.set{obj2out}.set, miss_val, 1);        
      res.mgat.time(obj2out) = toc;
    end
    
    if used_algs(8)
      %% AMON GA from tests
      %fprintf('AMON GA from tests algorithm is running...\n');
      tic;
      [res.amgat.Scores(obj2out,:), res.amgat.set{obj2out}] = ...        
          monamon_ga_2(Train_d, Train_y, Test_d, res.t.set{obj2out}.set, miss_val, 2);        
      res.amgat.time(obj2out) = toc;   
    end
    
    if used_algs(9)
      %% MON GA from best tests subset
      %fprintf('MON GA from best tests subset algorithm is running...\n');
      tic;
      [res.mgatb.Scores(obj2out,:), res.mgatb.set{obj2out}] = ...                
          monamon_ga_2(Train_d, Train_y, Test_d, res.tb.set{obj2out}, miss_val, 1);
      res.mgatb.time(obj2out) = toc;
    end
    
    if used_algs(10)    
      %% AMON GA from best tests subset
      %fprintf('AMON GA from best tests subset algorithm is running...\n');
      tic;
      [res.amgatb.Scores(obj2out,:), res.amgatb.set{obj2out}] = ...                
          monamon_ga_2(Train_d, Train_y, Test_d, res.tb.set{obj2out}, miss_val, 2);
      res.amgatb.time(obj2out) = toc;   
    end
    
    if used_algs(11)
      %% MON GA
      %fprintf('MON GA algorithm is running...\n');
      tic;
      [res.mga.Scores(obj2out,:), res.mga.set{obj2out}] = ...
          monamon_ga_0(Train_d, Train_y, Test_d, miss_val, 1);      
      res.mga.time(obj2out) = toc;
    end
    
    if used_algs(12)
      %% AMON GA
      %fprintf('AMON GA algorithm is running...\n');
      tic;
      [res.amga.Scores(obj2out,:), res.amga.set{obj2out}] = ...
          monamon_ga_0(Train_d, Train_y, Test_d, miss_val, 2);      
      res.amga.time(obj2out) = toc;   
    end
    
    if used_algs(13)
      %% MON GA from tests one one
      %fprintf('MON GA from tests one one algorithm is running...\n');
      tic;
      [res.mgat11.Scores(obj2out,:), res.mgat11.set{obj2out}] = ...        
          monamon_ga_oneone(Train_d, Train_y, Test_d, res.t.set{obj2out}.set, miss_val, 1);        
      res.mgat11.time(obj2out) = toc;
    end
    
    if used_algs(14)
      %% AMON GA from tests one one
      %fprintf('AMON GA from tests one one algorithm is running...\n');
      tic;
      [res.amgat11.Scores(obj2out,:), res.amgat11.set{obj2out}] = ...        
          monamon_ga_oneone(Train_d, Train_y, Test_d, res.t.set{obj2out}.set, miss_val, 2);        
      res.amgat11.time(obj2out) = toc;   
    end
        
    if used_algs(15)
      boost_eps = 0.1;
      %% MON GA boost from tests
      %fprintf('MON GA boost from tests algorithm is running...\n');
      tic;      
      [res.mgatboo.Scores(obj2out,:), res.mgatboo.set{obj2out}] = ...        
          monamon_ga_boost(Train_d, Train_y, Test_d, res.t.set{obj2out}.set, boost_eps, miss_val, 1);        
      res.mgatboo.time(obj2out) = toc;
    end
    
    if used_algs(16)
      boost_eps = 0.1;
      %% AMON GA boost from tests
      %fprintf('AMON GA boost from tests algorithm is running...\n');
      tic;
      [res.amgatboo.Scores(obj2out,:), res.amgatboo.set{obj2out}] = ...        
          monamon_ga_boost(Train_d, Train_y, Test_d, res.t.set{obj2out}.set, boost_eps, miss_val, 2);        
      res.amgatboo.time(obj2out) = toc;   
    end
    
    if used_algs(17)      
      %% Representative sets voting
      %fprintf('Representative sets voting...\n');
      tic;
      res.reprsets.Scores(obj2out,:) = ...        
          representative_sets_voting(Train_d, Train_y, Test_d);        
      res.reprsets.time(obj2out) = toc;   
    end
    
    if used_algs(18)      
      %% MON + GA + stripes  
      res.mgastripe.num_stripes = 6;
      tic;
      [res.mgastripe.Scores(obj2out,:), res.mgastripe.set{obj2out}] = ...        
          monamon_ga_stripes(Train_d, Train_y, Test_d, res.mgastripe.num_stripes, miss_val, 1);        
      res.mgastripe.time(obj2out) = toc;   
    end
    
    if used_algs(19)
      %% MON + GA + nonfixed EC rank
      tic;
      options.mode = 1;
      options.miss_val = miss_val;
      [res.mganfr.Scores(obj2out,:), res.mganfr.set{obj2out}] = ...        
          monamon_ga_nonfixed_rank(Train_d, Train_y, Test_d, options);        
      res.mganfr.time(obj2out) = toc; 
    end
    
    if used_algs(20)
      %% MON + GA + nonfixed EC rank
      tic;
      options.mode = 1;
      options.miss_val = miss_val;
%       options.num2stripe = 30;
%       options.max_rank = 3;
%       options.num_it = 5;
%       options.verbose = false;
      [res.mganfrs.Scores(obj2out,:), res.mganfrs.set{obj2out}, res.mganfrs.hist{obj2out}] = ...        
          monamon_ga_nonfixed_rank_stripes(Train_d, Train_y, Test_d, Test_y, options);        
      res.mganfrs.time(obj2out) = toc; 
    end
  end                
  
  %% Classification
  res = classify_all(res, y);

  %% Average results
  res = avg_all_res_struct_loo(res);  
end

function experiments = init_res_struct_loo(num_obj, num_classes)

  experiments.prc  = zeros(num_obj, 2+num_classes);
  experiments.num  = zeros(num_obj, 2*num_classes+1);   
  experiments.time = zeros(1,num_obj);
  experiments.set  = cell(1,num_obj);
  experiments.Scores = zeros(num_obj, num_classes);
  
end

function res = init_all_res_struct_loo(num_obj, num_classes, used_algs)

  res.used_algs = used_algs;
  
  if used_algs(1)
    res.t = init_res_struct_loo(num_obj,num_classes);
  end
  
  if used_algs(2)
    res.tb = init_res_struct_loo(num_obj,num_classes);
  end
  
  if used_algs(3)
    res.mt = init_res_struct_loo(num_obj,num_classes);
  end
  
  if used_algs(4)
    res.amt = init_res_struct_loo(num_obj,num_classes);
  end
  
  if used_algs(5)
    res.mtb = init_res_struct_loo(num_obj,num_classes);
  end
  
  if used_algs(6)
    res.amtb = init_res_struct_loo(num_obj,num_classes);
  end
  
  if used_algs(7)
    res.mgat = init_res_struct_loo(num_obj,num_classes);
  end
  
  if used_algs(8)
    res.amgat = init_res_struct_loo(num_obj,num_classes);
  end
  
  if used_algs(9)
    res.mgatb = init_res_struct_loo(num_obj,num_classes);
  end
  
  if used_algs(10)
    res.amgatb = init_res_struct_loo(num_obj,num_classes);
  end
  
  if used_algs(11)
    res.mga = init_res_struct_loo(num_obj,num_classes);
  end
  
  if used_algs(12)
    res.amga = init_res_struct_loo(num_obj,num_classes);
  end
  
  if used_algs(13)
    res.mgat11 = init_res_struct_loo(num_obj,num_classes);
  end
  
  if used_algs(14)
    res.amgat11 = init_res_struct_loo(num_obj,num_classes);
  end
  
  if used_algs(15)
    res.mgatboo = init_res_struct_loo(num_obj,num_classes);
  end
  
  if used_algs(16)
    res.amgatboo = init_res_struct_loo(num_obj,num_classes);
  end
  
  if used_algs(17)
    res.reprsets = init_res_struct_loo(num_obj,num_classes);
  end
  
  if used_algs(18)
    res.mgastripe = init_res_struct_loo(num_obj,num_classes);
  end
  
  if used_algs(19)
    res.mganfr = init_res_struct_loo(num_obj,num_classes);
  end
  
  if used_algs(20)
    res.mganfrs = init_res_struct_loo(num_obj,num_classes);
  end
end
  
function res = classify_all(res_ent, y)
  
  res = res_ent;

  if res.used_algs(1)
    [res.t.num, res.t.prc] = classify(res_ent.t.Scores, y);
  end
  
  if res.used_algs(2)
    [res.tb.num, res.tb.prc] = classify(res_ent.tb.Scores, y);
  end
  
  if res.used_algs(3)
    [res.mt.num, res.mt.prc] = classify(res_ent.mt.Scores, y);
  end
  
  if res.used_algs(4)
    [res.amt.num, res.amt.prc] = classify(res_ent.amt.Scores, y);
  end
  
  if res.used_algs(5)
    [res.mtb.num, res.mtb.prc] = classify(res_ent.mtb.Scores, y);
  end
  
  if res.used_algs(6)
    [res.amtb.num, res.amtb.prc] = classify(res_ent.amtb.Scores, y);
  end
  
  if res.used_algs(7)
    [res.mgat.num, res.mgat.prc] = classify(res_ent.mgat.Scores, y);
  end
  
  if res.used_algs(8)
    [res.amgat.num, res.amgat.prc] = classify(res_ent.amgat.Scores, y);
  end
  
  if res.used_algs(9)
    [res.mgatb.num, res.mgatb.prc] = classify(res_ent.mgatb.Scores, y);
  end
  
  if res.used_algs(10)
    [res.amgatb.num, res.amgatb.prc] = classify(res_ent.amgatb.Scores, y);
  end
  
  if res.used_algs(11)
    [res.mga.num, res.mga.prc] = classify(res_ent.mga.Scores, y);
  end
  
  if res.used_algs(12)
    [res.amga.num, res.amga.prc] = classify(res_ent.amga.Scores, y);  
  end                        

  if res.used_algs(13)
    [res.mgat11.num, res.mgat11.prc] = classify(res_ent.mgat11.Scores, y);
  end
  
  if res.used_algs(14)
    [res.amgat11.num, res.amgat11.prc] = classify(res_ent.amgat11.Scores, y);
  end
  
  if res.used_algs(15)
    [res.mgatboo.num, res.mgatboo.prc] = classify(res_ent.mgatboo.Scores, y);
  end
  
  if res.used_algs(16)
    [res.amgatboo.num, res.amgatboo.prc] = classify(res_ent.amgatboo.Scores, y);
  end
  
  if res.used_algs(17)
    [res.reprsets.num, res.reprsets.prc] = classify(res_ent.reprsets.Scores, y);
  end
  
  if res.used_algs(18)
    [res.mgastripe.num, res.mgastripe.prc] = classify(res_ent.mgastripe.Scores, y);
  end
  
  if res.used_algs(19)
    [res.mganfr.num, res.mganfr.prc] = classify(res_ent.mganfr.Scores, y);
  end
  
  if res.used_algs(20)
    [res.mganfrs.num, res.mganfrs.prc] = classify(res_ent.mganfrs.Scores, y);
  end
end

function experiments = avg_res_struct_loo(experiments)
  experiments.num_mean  = mean(experiments.num,1);
  experiments.prc_mean  = mean(experiments.prc,1);
  experiments.time_mean = mean(experiments.time);
  experiments.time_all  = sum (experiments.time);
end

function res = avg_all_res_struct_loo(res_ent)
  res = res_ent;

  if res.used_algs(1)
    res.t = avg_res_struct_loo(res_ent.t);
  end
  
  if res.used_algs(2)
    res.tb = avg_res_struct_loo(res_ent.tb);
  end
  
  if res.used_algs(3)
    res.mt = avg_res_struct_loo(res_ent.mt);
  end
  
  if res.used_algs(4)
    res.amt = avg_res_struct_loo(res_ent.amt);
  end
  
  if res.used_algs(5)
    res.mtb = avg_res_struct_loo(res_ent.mtb);
  end
  
  if res.used_algs(6)
    res.amtb = avg_res_struct_loo(res_ent.amtb);
  end
  
  if res.used_algs(7)
    res.mgat = avg_res_struct_loo(res_ent.mgat);
  end
  
  if res.used_algs(8)
    res.amgat = avg_res_struct_loo(res_ent.amgat);
  end
  
  if res.used_algs(9)
    res.mgatb = avg_res_struct_loo(res_ent.mgatb);
  end
  
  if res.used_algs(10)
    res.amgatb = avg_res_struct_loo(res_ent.amgatb);
  end
  
  if res.used_algs(11)
    res.mga = avg_res_struct_loo(res_ent.mga);
  end
  
  if res.used_algs(12)
    res.amga = avg_res_struct_loo(res_ent.amga);
  end     
  
  if res.used_algs(13)
    res.mgat11 = avg_res_struct_loo(res_ent.mgat11);
  end
  
  if res.used_algs(14)
    res.amgat11 = avg_res_struct_loo(res_ent.amgat11);
  end
  
  if res.used_algs(15)
    res.mgatboo = avg_res_struct_loo(res_ent.mgatboo);
  end
  
  if res.used_algs(16)
    res.amgatboo = avg_res_struct_loo(res_ent.amgatboo);
  end
  
  if res.used_algs(17)
    res.reprsets = avg_res_struct_loo(res_ent.reprsets);
  end
  
  if res.used_algs(18)
    res.mgastripe = avg_res_struct_loo(res_ent.mgastripe);
  end
  
  if res.used_algs(19)
    res.mganfr = avg_res_struct_loo(res_ent.mganfr);
  end
  
  if res.used_algs(20)
    res.mganfrs = avg_res_struct_loo(res_ent.mganfrs);
  end
end  