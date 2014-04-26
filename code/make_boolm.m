function [BoolM, Nabor]= make_boolm(K1, K2, flag_delete_rare_ec, varargin)  
  
  n = size(K1, 2); % Number of features
  m_k = size(K1,1); % Number of objects from class K1
  m_notk = size(K2,1); % Number of objects from class K2
  
  %% Set optional parameters
  missed_val = [];
  Nabor = [];
  
  if ~isempty(varargin)        
    for i = 1:2:length(varargin)
      switch varargin{i}
        case 'missed_val'           
          missed_val = varargin{i+1};                        
        case 'Nabor'
          Nabor = varargin{i+1};  
      end
    end        
  end
    
  %% Form Nabor if user not specified it
  if isempty(Nabor)
    % Select all unique values of features from K 
    % Nabor = { [ number of feature, value ] } 
    Nabor = [reshape(repmat(1:n, m_k, 1), n*m_k, 1),  K1(:)];  
    Nabor = unique(Nabor, 'rows');
  end  
  
  %% If it is needed delete from Nabor EC with missed value
  if ~isempty(missed_val)
    Nabor = Nabor( Nabor( :, 2 ) ~= missed_val, : );  
  end
  
  %% Form bool matrix
  BoolM = [];    
  Tmp1 = zeros(m_k, size(Nabor,1));
  
  % Set 1 if value from Nabor is in the description of object from K
  for i = 1:m_k 
    k_obj = K1(i, Nabor(:,1));      
    Tmp1(i, :) = (Nabor(:,2)' == k_obj);       
  end
  
  for i = 1:m_notk
    notk_obj = K2(i, Nabor(:,1));
    BoolM = [BoolM; repmat(Nabor(:,2)' ~= notk_obj, m_k, 1) & Tmp1];
  end
  
  %% If it is needed delete rare EC      
  if flag_delete_rare_ec   
    ind_freq_EC =  sum(BoolM,1) >= m_notk ; % EC is in >= 1 objects of K  
    BoolM = BoolM( :, ind_freq_EC );  
    Nabor = Nabor( ind_freq_EC, : );  
    BoolM = BoolM( any( BoolM, 2 ), : ); % Delete null-rows  
  end
end