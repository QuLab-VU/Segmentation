function [] = assayCellCounting ()
% COUNTS CELLS FROM BD PATHWAY IMAGE STACKS
% This is a stand alone assay and does not require any additional folders
% or files to run. The assay will iterate through the specified start frame
% through the frame count.  
%
% DESCRIPTION OF INPUTS
% ImageFolder: Path to where the images are located
% ImageFolesRoot: The principle name of the images
% ImageExtension: type of image
% StartFrme: The first image the user wants cells to be counted
% FrameCount: The last frame number

WellName = 'D03'

OutputFolder='/Volumes/Al/CellAnimOutput/2013-01-17 CellAnim Output/';
FolderName= '/Volumes/Rufus/Data/2013-01-11_001/Well ';
ImageFolder=[ FolderName WellName '/']

ImageFilesRoot='DsRed - Confocal - n';
ImageExtension='.tif';
StartFrame=0;
FrameCount=64;

TimeFrame=1;
FrameStep=1;
NumberFormat='%06d';

% % User input data regarding the experiment
% ExperimentDate = '20121216';
% Time = '24';
% CellType = 'A375';
% Drug = 'PLX-4720';
% Concentration = '8';

% Information required to process the images
IntegerClass='uint8';
ClearBorder=true;
ClearBorderDist=0;
Strel='disk';
StrelSize= 15;
BrightnessThresholdPct=1.15;
ClearBorder_intensity=false;
IntensityThresholdPct=0.10;
MinObjectArea=200;
FormatSpreadsheet = [];

% Start of the Iteration
x = StartFrame;
iteration = FrameCount;
for i = x:iteration
    ImageFileBase=[ImageFolder ImageFilesRoot];
    ImageName=[ImageFileBase num2str(i,NumberFormat) ImageExtension];


%% Read the image into the script
image_name=ImageName;
img_channel='r';
img_to_proc=imread(image_name);
switch img_channel
    case 'r'
        img_to_proc=img_to_proc(:,:,1);
    case 'g'
        img_to_proc=img_to_proc(:,:,2);
    case 'b'
        img_to_proc=img_to_proc(:,:,3);
end
Image=img_to_proc;

%% Normalize the image
int_class=IntegerClass;
max_val=double(intmax(int_class));
img_raw=Image;
img_dbl=floor(double((img_raw-min(img_raw(:))))*max_val./double(max(img_raw(:))-min(img_raw(:))));
switch(int_class)
    case 'uint8'
       Image=uint8(img_dbl);
    case 'uint16'
       Image=uint16(img_dbl);
    otherwise
        Image=[];
end

%% Threshold the Image

avg_filter=fspecial(Strel,StrelSize);
img_avg=imfilter(Image,avg_filter,'replicate');
img_bw=Image>(BrightnessThresholdPct*img_avg);
if (ClearBorder)
    clear_border_dist=ClearBorderDist;
    if (clear_border_dist>1)
        img_bw(1:clear_border_dist-1,1:end)=1;
        img_bw(end-clear_border_dist+1:end,1:end)=1;
        img_bw(1:end,1:clear_border_dist-1)=1;
        img_bw(1:end,end-clear_border_dist+1:end)=1;
    end
    Image=imclearborder(img_bw);
else
    Image=img_bw;
end

%% Clear Border Intensity

max_pixel=max(Image(:));
min_pixel=min(Image(:));
brightnessPct=IntensityThresholdPct;
threshold_intensity=brightnessPct*double(max_pixel-min_pixel)+min_pixel;
img_bw=Image>threshold_intensity;
% img_bw=im2bw(img_to_proc,brightnessPct*graythresh(img_to_proc));
clear_border_dist=ClearBorderDist;
if (ClearBorder_intensity)
    if (clear_border_dist>1)
        img_bw(1:clear_border_dist-1,1:end)=1;
        img_bw(end-clear_border_dist+1:end,1:end)=1;
        img_bw(1:end,1:clear_border_dist-1)=1;
        img_bw(1:end,end-clear_border_dist+1:end)=1;
    end
    Image=imclearborder(img_bw);
else
    Image=img_bw;
end

%% Clear small objects based on preset indicated above

Image=bwareaopen(Image,MinObjectArea);

%%
LabelMatrix=bwlabeln(Image);

nucl_lbl=LabelMatrix;
nucl_ids_left = unique(nucl_lbl);
% nucl_idx=ismember(nucl_lbl)

%% Saving Data to Spreadsheet
Cell_ID = length(nucl_ids_left)


WellName2 = repmat(WellName,[size(Cell_ID),1]);
ImageNumber = repmat(i,[size(Cell_ID),1]);

% ExperimentDate = repmat(strcat(ExperimentDate),[size(Cell_ID,1),1]);
% Time = repmat(Time,[size(Cell_ID),1]);
% CellType = repmat(CellType,[size(Cell_ID),1]);
% Drug = repmat(Drug,[size(Cell_ID),1]);
% Concentration = repmat(Concentration,[size(Cell_ID),1]);


% FormatSpreadsheet = struct('ExperimentDate',1, 'WellName',2, 'Time',3, 'CellType',4, 'Drug',5, ...
%     'Concentration',6, 'Image',7, 'CellID',8);

FormatSpreadsheet_new = struct('WellName',1, 'Image',2, 'Cell_Count',3);

% FormatSpreadsheet.ExperimentDate=ExperimentDate;
FormatSpreadsheet_new.WellName=WellName2;
% FormatSpreadsheet.Time=Time;
% FormatSpreadsheet.CellType=CellType;
% FormatSpreadsheet.Drug=Drug;
% FormatSpreadsheet.Concentration=Concentration;
FormatSpreadsheet_new.Image=ImageNumber;
FormatSpreadsheet_new.Cell_Count=Cell_ID;

% FormatSpreadsheet = [FormatSpreadsheet, FormatSpreadsheet];

% i = i + FrameStep;

% FormatSpreadsheet = [FormatSpreadsheet; FormatSpreadsheet_new];
FormatSpreadsheet = vertcat(FormatSpreadsheet, FormatSpreadsheet_new);

end

FormatSpreadsheet = struct2dataset(FormatSpreadsheet);
DataFileName='CellCount';
Type2='.csv';
export(FormatSpreadsheet, 'File', [OutputFolder DataFileName WellName Type2],'Delimiter',',');


end