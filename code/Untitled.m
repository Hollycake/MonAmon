figure;
y = [test_exp_2_loo.prc_mean(1), test_exp_3_loo.prc_mean(1), ...
      test_exp_4_loo.prc_mean(1),test_exp_5_loo.prc_mean(1)];
plot(2:5, y, 'LineWidth',2.5); hold on

y = [mon_exp_2_loo.prc_mean(1), mon_exp_3_loo.prc_mean(1), ...
      mon_exp_4_loo.prc_mean(1),mon_exp_5_loo.prc_mean(1)];
plot(2:5, y, 'g', 'LineWidth',2.5); 

y = [amon_exp_2_loo.prc_mean(1), amon_exp_3_loo.prc_mean(1), ...
      amon_exp_4_loo.prc_mean(1),amon_exp_5_loo.prc_mean(1)];
plot(2:5, y, 'r', 'LineWidth',2.5);

xlabel('max test length');
ylabel('R1');
legend('TEST', 'MOH', 'AMOH', 'Location','SouthEast');

%==============================================
figure;
y = [test_exp_2_loo.prc_mean(2), test_exp_3_loo.prc_mean(2), ...
      test_exp_4_loo.prc_mean(2),test_exp_5_loo.prc_mean(2)];
plot(2:5, y, 'LineWidth',2.5); hold on

y = [mon_exp_2_loo.prc_mean(2), mon_exp_3_loo.prc_mean(2), ...
      mon_exp_4_loo.prc_mean(2),mon_exp_5_loo.prc_mean(2)];
plot(2:5, y, 'g', 'LineWidth',2.5); 

y = [amon_exp_2_loo.prc_mean(2), amon_exp_3_loo.prc_mean(2), ...
      amon_exp_4_loo.prc_mean(2),amon_exp_5_loo.prc_mean(2)];
plot(2:5, y, 'r', 'LineWidth',2.5);

xlabel('max test length');
ylabel('R2');
legend('TEST', 'MOH', 'AMOH', 'Location','SouthEast');