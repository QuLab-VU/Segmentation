function output_args=savedataformatfucci(input_args)
% Usage
% The module is used to save the Cell IDs, Area, and raw Intensity so that
% the user can integrate the Intensity over the area.
global functions_list;

ImageFolder=input_args.ImageFolder.Value;
Cell_ID=input_args.ObjectsLabel.Value;
Cell_Area=input_args.ObjectsArea.Value;
Cell_Intensity=input_args.ObjectsIntensity.Value;
Cell_FucciIntensity=input_args.ObjectsIntensityFucci.Value;
Cell_NucleiIntensity=input_args.ObjectsIntensityNuclei.Value;

Cell_ID = unique(Cell_ID);
Cell_ID(Cell_ID==0) = [];

ExperimentDate = repmat(strcat(input_args.ExperimentDate.Value),[size(Cell_ID,1),1]);
WellName = repmat(input_args.WellName.Value,[size(Cell_ID),1]);
Time = repmat(input_args.Time.Value,[size(Cell_ID),1]);
CellType = repmat(input_args.CellType.Value,[size(Cell_ID),1]);
Drug = repmat(input_args.Drug.Value,[size(Cell_ID),1]);
Concentration = repmat(input_args.Concentration.Value,[size(Cell_ID),1]);

FormatSpreadsheet = struct('ExperimentDate',1, 'WellName',2, 'Time',3, 'CellType',4, 'Drug',5, ...
    'Concentration',6, 'CellID', 7, 'Area',8, 'One_Intensity',9, 'Two_Intensity',10, 'Three_Intensity',11);

FormatSpreadsheet.ExperimentDate=ExperimentDate;
FormatSpreadsheet.WellName=WellName;
FormatSpreadsheet.Time=Time;
FormatSpreadsheet.CellType=CellType;
FormatSpreadsheet.Drug=Drug;
FormatSpreadsheet.Concentration=Concentration;
FormatSpreadsheet.CellID=Cell_ID;
FormatSpreadsheet.Area=Cell_Area;
FormatSpreadsheet.One_Intensity=Cell_NucleiIntensity;
FormatSpreadsheet.Two_Intensity=Cell_Intensity;
FormatSpreadsheet.Three_Intensity=Cell_FucciIntensity;

% column_names= 'Experiment, Well, Time, Cell_Type, Drug, Concentration, CellID, Area, One_Intensity,Two_Intensity,Three_Intensity';
FormatSpreadsheet = struct2dataset(FormatSpreadsheet);
export(FormatSpreadsheet, 'File', [ImageFolder 'ImageProperties.csv'],'Delimiter',',');

output_args=[];

%end savedataformat
end
