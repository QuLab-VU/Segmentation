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
ImageNumber = repmat(input_args.ImageNumber.Value,[size(Cell_ID),1]);

FormatSpreadsheet = struct('ExperimentDate',1, 'WellName',2, 'Time',3, 'CellType',4, 'Drug',5, ...
    'Concentration',6, 'Image',7, 'CellID', 8, 'Area',9, 'One_Intensity',10, 'Two_Intensity',11, 'Three_Intensity',12);

FormatSpreadsheet.ExperimentDate=ExperimentDate;
FormatSpreadsheet.WellName=WellName;
FormatSpreadsheet.Time=Time;
FormatSpreadsheet.CellType=CellType;
FormatSpreadsheet.Drug=Drug;
FormatSpreadsheet.Concentration=Concentration;
FormatSpreadsheet.Image=ImageNumber;
FormatSpreadsheet.CellID=Cell_ID;
FormatSpreadsheet.Area=Cell_Area;
FormatSpreadsheet.One_Intensity=Cell_NucleiIntensity;
FormatSpreadsheet.Two_Intensity=Cell_Intensity;
FormatSpreadsheet.Three_Intensity=Cell_FucciIntensity;

% column_names= 'Experiment, Well, Time, Cell_Type, Drug, Concentration, CellID, Area, One_Intensity,Two_Intensity,Three_Intensity';
FormatSpreadsheet = struct2dataset(FormatSpreadsheet);
DataFileName='ImageProperties';
Type2='.csv';
ImageNumber1=input_args.ImageNumber1.Value;
export(FormatSpreadsheet, 'File', [ImageFolder DataFileName ImageNumber1 Type2],'Delimiter',',');
% export(FormatSpreadsheet, 'File', [ImageFolder 'ImageProperties.csv'],'Delimiter',',');

output_args=[];

%end savedataformat
end
