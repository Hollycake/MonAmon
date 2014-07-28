options.used_algs = [false(1,19), true];
options.max_rank = 3;
options.max_num_it = 1;
options.verbose = false;
options.epsilon = 0.1;
options.test_len = 1;

dorovskih_loo = LOOcv('../dorovskih_disc2.tab', options);
fprintf('\naccuracy | mean_accuracy | accuracy_class_1 | accuracy_class_2\n');
fprintf('%8.2f |%14.2f | %16.2f | %16.2f\n', dorovskih_loo.mganfrs.prc_mean);

