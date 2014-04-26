function ExportToExcel( A )

NET.addAssembly('microsoft.office.interop.excel');
app = Microsoft.Office.Interop.Excel.ApplicationClass;
books = app.Workbooks;
newWB = books.Add;
app.Visible = true;

%Create a new sheet:
sheets = newWB.Worksheets;
newSheet = sheets.Item(1);

%newSheet is a System.__ComObject because sheets.Item can return different types, such as a Chart or a Worksheet. To make the sheet a Worksheet, use the command:
newWS = Microsoft.Office.Interop.Excel.Worksheet(newSheet);

%convert to .NET array
excelArray = NET.convertArray(A);

%Write some data to a range of cells:
newRange = newWS.Range('A1');
newRange.Value2 = 'Data from Location A';
newRange = newWS.Range('A3:K60');
newRange.Value2 = excelArray;

%Modify cell format and name the worksheet:
newWS.Name = 'Test Data';

%If this is a new spreadsheet, use the SaveAs method:
newWB.SaveAs('mySpreadsheet.xlsx');

%Close and quit:
newWB.Close;
app.Quit;

end