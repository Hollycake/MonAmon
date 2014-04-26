function cvt2arrf(list_file_name, list_numobj_file_name, data_dir)

  listfile = fopen(list_file_name, 'r');
  list_numobj_file = fopen(list_numobj_file_name, 'w+');
  
  filename = fgetl(listfile);

  while ischar(filename)    
    dataName = filename(1:end-4);
    filename = [data_dir '\' filename];
    disp(filename);      
    [data, num_classes] = import_data(filename);
    [num_obj, num_feat] = size(data);
    
    % Fill arff list
    fileName = [filename(1:end-4) '.arff'];
    fprintf(list_numobj_file, '%s, %d\r\n', fileName, num_obj);
    
    % Fill attributes names and types
    attributeName = cell(1,num_feat);
    attributeType = cell(1,num_feat);
    
    for f_i = 1:num_feat-1
      attributeName{f_i} = ['X', num2str(f_i)];
      attributeType{f_i} = 'REAL';
    end
    attributeName{end} = 'class';
    class_type = num2str(1:num_classes, '%d,');
    attributeType{end} = ['{' class_type(1:end-1) '}'];           
    
    % Write arff file
    arffwrite(fileName,dataName,attributeName,attributeType,data)
    
    filename = fgetl(listfile);
  end

  fclose(listfile);
  fclose(list_numobj_file);
end