function [data, num_classes, missed_val] = import_data(filename)

  if isequal(filename(end-2:end), 'tab')
    [data, num_classes, missed_val] = import_file_tab(filename);
    return
  end
  
  if isequal(filename(end-2:end), 'txt')
    [data, num_classes, missed_val] = import_file_txt(filename);
    return
  end
    
  fprintf('Error: unknown file format\n');
end