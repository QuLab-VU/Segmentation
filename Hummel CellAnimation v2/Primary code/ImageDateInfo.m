% To generate the dates for when the images were acquired. The MATLAB
% function only works with the "Date Modified" so you need to use the
% original images and not a copy.
%
Source = 2; % Options are 1 = BD Pathway or 2 = CellaVista
ImageFolder = '~/Dropbox/Stain Images for Analysis/20121109 A375 Series/24hr/';
% ImageFolder = '~/Documents/Test Images/';
OutputFolder = ImageFolder;

% Use the Start and End Image inputs for BD Pathway
StartImage = 1;
EndImage = 10;

ImageDate = [];
FormatSpreadsheet = [];

if Source == 1
NameBase = 'DsRed - Confocal - n';
ImageExtension='.tif';
NumberFormat='%06d';
for i = StartImage:EndImage
    Name = [NameBase num2str(i,NumberFormat) ImageExtension];
    Image = imfinfo([ImageFolder Name]);
    ImageTime = Image.FileModDate;
    formatin = 'yyyymmddHHMMSS';
    ConvertImageTime = datestr(ImageTime, formatin);
    FormatSpreadsheet_new = struct('ImageNumber',1, 'ImageDate',2);
    FormatSpreadsheet_new.ImageNumber=i;
    FormatSpreadsheet_new.ImageDate=ConvertImageTime;
    FormatSpreadsheet = vertcat(FormatSpreadsheet, FormatSpreadsheet_new);
end

else Source == 2
CVOutputFile = '1.txt';
CVOutputFile = fileread([ImageFolder CVOutputFile]);
Pattern = '[0-9_]+-?[0-9_]+-[A-Z_]+[0-9_]+-[A-Z_]+[0-9_]+.tiff';
D = regexp(CVOutputFile, Pattern, 'match');
V = rot90(D);
J = flipud(V); 
count = length(J);
for i = 1:count
    Name1 = char(J(i,:));
    Image = imfinfo([ImageFolder Name1]);
    ImageTime = Image.FileModDate;
    formatin = 'yyyymmddHHMMSS';
    ConvertImageTime = datestr(ImageTime, formatin);
    Well = regexp(J{i}, '(?<=[0-9_]+-)[0-9_]+','match');
    Well = char(Well);
    FormatSpreadsheet_new = struct('ImageNumber',1, 'ImageDate',2);
    FormatSpreadsheet_new.ImageNumber=Well;
    FormatSpreadsheet_new.ImageDate=ConvertImageTime;
    FormatSpreadsheet = vertcat(FormatSpreadsheet, FormatSpreadsheet_new);
end  
    
end

FormatSpreadsheet = struct2dataset(FormatSpreadsheet);
DataFileName='ImageDateInfo';
Type2='.csv';
export(FormatSpreadsheet, 'File', [OutputFolder DataFileName Type2],'Delimiter',',');