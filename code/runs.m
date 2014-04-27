      options.num2stripe = 27;
      options.max_rank = 3;
      options.num_it = 10;
      options.verbose = false;
      
manelis2_10s27_loo = LOOcv('../Data/All/manelis2.tab', options);
botwinklbl_10s27_loo = LOOcv('../Data/Discretized/botwinklbl_disc2.tab', options);

disp('../Data/Discretized/ech_r_disc2.tab');
ech_r_10s27_loo = LOOcv('../Data/Discretized/ech_r_disc2.tab', options);
disp('../Data/All/Hep_r.tab');
hep_r_10s27_loo = LOOcv('../Data/All/Hep_r.tab', options);
disp('../Data/Discretized/stupenexper1_disc2.tab');
stupenexper_10s27_loo = LOOcv('../Data/Discretized/stupenexper1_disc2.tab', options);
options.num2stripe = 23;
disp('../Data/Discretized/stupenexper1_disc2.tab');
stupenexper_10s23_loo = LOOcv('../Data/Discretized/stupenexper1_disc2.tab', options);
options.num2stripe = 27;
disp('../Data/All/echu.tab');
echu_10s27_loo = LOOcv('../Data/All/echu.tab', options);

disp('manelis3.tab');
manelis3_10s27_loo = LOOcv('../Data/All/manelis3.tab', options);
disp('melanoma_disc2.tab');
melanoma_10s27_loo = LOOcv('../Data/Discretized/melanoma_disc2.tab', options);
disp('Pnevmo_r_disc2.tab');
options.num2stripe = 23;
pnevmo_r_10s23_loo = LOOcv('../Data/Discretized/Pnevmo_r_disc2.tab', options);
options.num2stripe = 27;
pnevmo_r_10s27_loo = LOOcv('../Data/Discretized/Pnevmo_r_disc2.tab', options);
disp('SARComa_disc2.tab');
sarcoma_10s27_loo = LOOcv('../Data/Discretized/SARComa_disc2.tab', options);
disp('manelis4.tab');
manelis4_10s27_loo = LOOcv('../Data/All/manelis4.tab', options);

disp('Hea_r_disc2.tab');
Hea_r_3s27_loo = LOOcv('../Data/Discretized/Hea_r_disc2.tab', options);

ech_r_5s10_loo = LOOcv('C:\Users\asus\Documents\MATLAB\Data\Discretized\ech_r_disc2.tab', options);