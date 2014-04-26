%> @file create_comparisons_matrix.m
%> @brief Make comparisons matrix from given K and NotK objects
%> 
%> @param K Matrix [m_k, n] of train objects from class K 
%> @param NotK Matrix [m_notk, n] of train objects from class NotK 
%>
%> @retval CompM Comparisons matrix [m_k * m_nk, n]
%> [(S'_1, S''_1); ...; (S'_1, S''_{m_nk};, ..., (S'_{m_k}, S''_1); ...; (S'_{m_k}, S''_{m_nk})]

function CompM = create_comparisons_matrix(K, NotK)

    [m_k, n] = size(K);
    m_nk = size(NotK,1);
    
    K_rep = reshape(repmat(K', m_nk, 1), n, m_k*m_nk)';
    NotK_rep = repmat(NotK, m_k, 1);

    CompM = K_rep ~= NotK_rep;
end
