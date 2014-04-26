function [data, num_classes, missed_val] = import_file_txt(file_name)
% Imports data from the txt file
  
  file = fopen( file_name );
  
  num_features =  fscanf( file, '%d', 1 );
  num_objects =  fscanf( file, '%d', 1 );
  num_classes =  fscanf( file, '%d', 1 );
  
  ind_class = zeros( num_objects, 1 );
  data = zeros( num_objects, num_features );
  
  for i = 1:num_objects    
    ind_class(i) = fscanf( file, '%d', 1 );       
    raw_data = fscanf( file, '%f, ', num_features )';    
    data( i, : ) = raw_data;    
  end
  
  data = [data ind_class];
  
  fclose(file);  
  
  missed_val = -1;
end