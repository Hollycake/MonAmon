function res_experiments = avg_res_struct(experiments)
  res_experiments.num_mean  = mean(experiments.num,1);
  res_experiments.prc_mean  = mean(experiments.prc,1);
  res_experiments.time_mean = mean(experiments.time);
  res_experiments.time_all  = sum (experiments.time);
end