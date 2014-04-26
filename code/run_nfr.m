function res = run_nfr(file_name)

options.used_algs = [false(1,18), true];
options.max_depth = 3;
options.num_stripes = 10;
options.test_len = 1;
 
%num2stripe = floor(num_features/num_stripes);
fprintf('Iteration %d: %s\n', 1, file_name);
res.res1 = LOOcv(file_name, options);
fprintf('Iteration %d: %s\n', 2, file_name);
res.res2 = LOOcv(file_name, options);
fprintf('Iteration %d: %s\n', 3, file_name);
res.res3 = LOOcv(file_name, options);
fprintf('Iteration %d: %s\n', 4, file_name);
res.res4 = LOOcv(file_name, options);
fprintf('Iteration %d: %s\n', 5, file_name);
res.res5 = LOOcv(file_name, options);

A = [res.res1.mganfr.prc_mean; res.res2.mganfr.prc_mean; res.res3.mganfr.prc_mean; res.res4.mganfr.prc_mean; res.res5.mganfr.prc_mean] / 100;
A = A(:,1:2);

B = [res.res1.mganfr.time_mean;res.res2.mganfr.time_mean;res.res3.mganfr.time_mean;res.res4.mganfr.time_mean;res.res5.mganfr.time_mean];

ExportToExcel([A,B]);

end