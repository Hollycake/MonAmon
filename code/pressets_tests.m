fid = fopen(file_with_names);

NET.addAssembly('microsoft.office.interop.excel');
app = Microsoft.Office.Interop.Excel.ApplicationClass;
books = app.Workbooks;
newWB = books.Add;
app.Visible = true;

% Create a new sheet:
sheets = newWB.Worksheets;
newSheet = sheets.Item(1);

% newSheet is a System.__ComObject because sheets.Item can return different types, such as a Chart or a Worksheet. To make the sheet a Worksheet, use the command:
newWS = Microsoft.Office.Interop.Excel.Worksheet(newSheet);

tline = fgetl(fid);
i = 1;

used_algs = [false(1,16),true];
%used_algs = [true, false(1,13),true(1,2),false];

while ischar(tline)
disp(tline)
eval([tline(1:end-4), '_exp = LOOcv(''', path, '\', tline, ''',used_algs, 3);']);
%eval([tline(1:end-4), '_res4_irred_exp = QFoldscv(''', path, '\', tline, ''',used_algs, 4);']);
%Write some data to a range of cells:
i_str = num2str(i);
newRange = newWS.Range(['B', i_str]);
newRange.Value2 = tline(1:end-4);
newRange = newWS.Range(['C', i_str, ':D', i_str]);
newRange.Value2 = NET.convertArray(eval([tline(1:end-4), '_exp.reprsets_exp.prc_mean(1:2)/100']));
%newRange.Value2 = NET.convertArray(eval([tline(1:end-4), '_res4_irred_exp.mgatboo_exp.prc_mean(1:2)/100']));
newRange = newWS.Range(['E', i_str]);
newRange.Value2 = NET.convertArray(eval([tline(1:end-4), '_exp.reprsets_exp.time_mean']));

% newRange = newWS.Range(['G', i_str, ':H', i_str]);
% newRange.Value2 = NET.convertArray(eval([tline(1:end-4), '_res4_irred_exp.amgatboo_exp.prc_mean(1:2)/100']));
% newRange = newWS.Range(['I', i_str]);
% newRange.Value2 = NET.convertArray(eval([tline(1:end-4), '_res4_irred_exp.amgatboo_exp.time_mean']));
i = i+1;
tline = fgetl(fid);
end

fclose(fid);

% If this is a new spreadsheet, use the SaveAs method:
newWB.SaveAs('Reprsets_tests.xlsx');
   
% Close and quit:
newWB.Close;
app.Quit;
