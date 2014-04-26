function [data, num_classes, missed_val] = import_file_tab(filename)
%  Imports data from the tab file
  
  file = fopen(filename);
  num_features = fscanf(file,'%d',1);
  num_classes = fscanf(file,'%d',1);
  class_start = fscanf(file,'%d',num_classes+1);
  missed_val = fscanf(file,'%d',1);    
  
  rawdata = (fscanf(file,'%f',[num_features class_start(end)]))';
  data = rawdata;

  ind_class = zeros(size(data,1),1);
  for i = 1:num_classes
    ind_class(class_start(i)+1:class_start(i+1))=i;
  end
  
  data = [data ind_class];
  
  fclose(file);  
end

