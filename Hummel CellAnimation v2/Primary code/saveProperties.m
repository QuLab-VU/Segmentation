function output_args=saveProperties(input_args)
% Usage
% This module is used to save the tracks and ancestry records spreadsheets.
% Input Structure Members
% CellsAncestry – Matrix containing the ancestry records for the cells in the time-lapse movie.
% ProlXlsFile – The desired file name for the spreadsheet containing the ancestry records.
% ShapesXlsFile – The desired file name for the spreadsheet containing the tracks and shape parameters data.
% Tracks – The tracks matrix to be processed.
% TracksLayout – Matrix describing the order of the columns in the tracks matrix.
% Output Structure Members
% None.


saved_data=input_args.SaveData.Value;
column_names= 'Area';
save(input_args.FileName.Value,'saved_data');


output_args=[];

%end saveAncestrySpreadsheets
end
