%> @file scores_for_K.m
%> @brief Find Test algorithm class K scores for set of objects to recognize
%>
%> @param Rec Matrix [m_r, n] of objects to recognize 
%> @param K Matrix [m_k, n] of train objects from class K 
%> @param TestsSet Matrix [num_tests, test_len] of tests 
%>
%> @retval KScores Scores of belonging object from Ret to class K

function Kscores = scores_for_K(Rec, K, TestsSet, miss_val)
    
    [m_r, n] = size(Rec);
    m_k = size(K,1);
    num_tests = size(TestsSet, 1);
    %num_not_misses = sum(K ~= miss_val,1);
    
    Kscores = zeros(1, m_r);
    
    Rec(Rec == miss_val) = 100500;
    Rec_rep = reshape(repmat(Rec', m_k, 1), n, m_r*m_k)';
    K_rep = repmat(K, m_r, 1);
    
    for i = 1:num_tests
        T = TestsSet(i,:);
        Kscores = Kscores + sum(reshape( all(Rec_rep(:,T) == K_rep(:,T), 2), m_k, m_r), 1);        
    end
    
    Kscores = Kscores' / num_tests / m_k;
    %Kscores = Kscores' / num_tests ./ num_not_misses;
end