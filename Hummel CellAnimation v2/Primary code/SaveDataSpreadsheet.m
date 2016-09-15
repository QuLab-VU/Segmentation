function output_args=savedataformat(input_args)
% Usage
% The module is used to save the Cell IDs, Area, and raw Intensity so that
% the user can integrate the Intensity over the area.

ImageFolder=input_args.ImageFolder.Value;
Cell_ID=input_args.ObjectsLabel.Value;
Cell_Area=input_args.ObjectsArea.Value;
Cell_Intensity=input_args.ObjectsIntensity.Value;

Cell_ID = unique(Cell_ID);
Cell_ID(Cell_ID==0) = [];

FormatSpreadsheet = struct('CellIDCol', 1, 'AreaCol',2,'IntensityCol',3);

FormatSpreadsheet.CellIDCol=Cell_ID;
FormatSpreadsheet.AreaCol=Cell_Area;
FormatSpreadsheet.StainIntensityCol=Cell_Intensity;

column_names= 'CellID,Area,Intensity';
FormatSpreadsheet = struct2dataset(FormatSpreadsheet);
export(FormatSpreadsheet, 'File', [ImageFolder 'ImageProperties.csv'],'Delimiter',',');

output_args=[];

%end savedataformat
end
