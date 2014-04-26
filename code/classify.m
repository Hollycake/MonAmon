function [res_num, res_prc] = classify(Scores, y_true)
    
    %Result is a vector [#right_classified_of class1, #wrong_classified_of class1, ..., #right_classified_of class_last, #wrong_classified_of class_last, #denials]

    % Apply decision rule
    [Classification, num_denial] = decision_rule(Scores);
    
    % Get numbers of right and wrong classified objects for every class
    num_classes = size(Scores,2);
    num_right_class   = zeros(1,num_classes);
    num_wrong_class = zeros(1,num_classes);
    
    for class_number = 1:num_classes
        num_right_class(class_number) = sum( (y_true == Classification) & (y_true == class_number) );
        num_wrong_class(class_number) = sum( (y_true ~= Classification) & (y_true == class_number) );
    end
    
    how_class = [num_right_class; num_wrong_class];       
    res_num    = [how_class(:)', num_denial];    
        
    R1 = sum(num_right_class) / sum(how_class(:)) * 100;
    R_class = num_right_class ./ (num_right_class + num_wrong_class) * 100;
    R2 = mean(R_class);
    res_prc = [R1, R2, R_class];
end