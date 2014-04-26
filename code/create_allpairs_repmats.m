%> @file create_allpairs_repmats.m
%> @brief Make repeated matrixes from two given for all pairs comparison
%> @param A Matrix [m1, n] 
%> @param B Matrix [m2, n] 
%>
%> @retval A_rep Special repeated [m_1 * m_2, n]
%> A_rep = [A_rep(1,:); ...; A_rep(1,:); ...; A_rep(m1,:); ...; A_rep(m1,:)]
%>          <----------- m2 ---------->       <------------ m2 ----------->
%> @retval B_rep Special repeated [m_1 * m_2, n]
%> B_rep = [B; ...; B]
%>          <---m1-->

function [A_rep,B_rep] = create_allpairs_repmats(A, B)

    [m1, n] = size(A);
    m2 = size(B,1);
    
    A_rep = reshape(repmat(A', m2, 1), n, m1*m2)';
    B_rep = repmat(B, m1, 1);
end
