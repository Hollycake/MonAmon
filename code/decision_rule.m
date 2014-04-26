function [Classification, num_denial] = decision_rule( ScoreForClasses )

    [~, Classification] = max( ScoreForClasses, [], 2);

    num_denial = sum(sum( bsxfun( @(x,y) abs(x-y)<eps, ScoreForClasses, max( ScoreForClasses, [], 2) ), 2 ) > 1 ) ;
    %num_denial = sum(sum( bsxfun( @eq, ScoreForClasses, max( ScoreForClasses, [], 2) ), 2 ) > 1 ) ;
end