function sum_exp = compute_results(ind_exp)

    sum_exp.ind = ind_exp;
        
    tf_vals = ind_exp(:,1:end-1);
    num_classes = size(tf_vals,2) / 2;
    num_folds = size(tf_vals,1);
    num_obj = sum(tf_vals(:));
    
    R1 = sum(tf_vals(:,2*(1:num_classes)-1),2) ./ sum(tf_vals,2);
    
    R1_class = zeros(num_folds,num_classes);
    
    for k = 1:num_classes
        R1_class(:,k) = tf_vals(:,2*k-1) ./ (tf_vals(:,2*k-1) + tf_vals(:,2*k));
    end
    
    R2 = mean(R1_class,2);
    
    sum_exp.rates = [R1, R2];
    sum_exp.rates_mean = mean(sum_exp.rates,1);
    sum_exp.num_denials = sum(ind_exp(:,end));
    sum_exp.prc_denials = sum_exp.num_denials / num_obj;
end