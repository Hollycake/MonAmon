function [prc_unique_all, prc_unique_each] = compute_prc_unique(Mat)

%   Cell = num2cell(Mat,1);
%   num_u = cellfun(@length, cellfun(@unique, Cell, 'UniformOutput', false))';
  
  num_u = zeros(1,size(Mat,2));
  for i = 1:size(Mat,2)
   num_u(i) = length(unique(Mat(:,i)));
  end
  
  prc_unique_each = num_u / size(Mat,1);
  prc_unique_all = mean(prc_unique_each);  

end