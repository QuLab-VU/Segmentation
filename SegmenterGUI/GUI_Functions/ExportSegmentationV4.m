function [handles] = ExportSegmentationV4(handles)
%Function for exporting the data after segmentation.
%Cell Events.csv contains each cell's data
%Image Events is a summary of each image segmented
%Handles.mat contains handle to the segmenter and all the parameters
%Processing Parameters.csv contains all the segmentation parameters used

seg_file = dir([handles.expDir filesep 'Segmented/*.mat']);
fid = fopen([handles.expDir filesep 'Segmented/NumDetect_Im.txt'], 'r');
if fid < 0
    error('Cannot open file with cell count'); 
end
data = textscan(fid,'%s %d %s %d','delimiter','\t');
handles.totCell = double(data{2});
handles.totIm = double(data{4});

%Preallocate the structure holding all the information Seg
%File Parameters
Seg.FileName            = cell(handles.totCell,1);
Seg.FileNameSingle      = cell(handles.totIm,1);
Seg.numCytowoutNuc      = zeros(handles.totIm,1);
Seg.cellcount           = zeros(handles.totIm,1);
Seg.month               = zeros(handles.totCell,1);
Seg.day                 = zeros(handles.totCell,1);
Seg.min                 = zeros(handles.totCell,1);
Seg.year                = zeros(handles.totCell,1);
Seg.hour                = zeros(handles.totCell,1);
Seg.RW                  = cell(handles.totCell,1);
Seg.CL                  = cell(handles.totCell,1);
Seg.ImNum               = zeros(handles.totCell,1);
Seg.RowSingle           = cell(handles.totIm,1);
Seg.ColSingle           = cell(handles.totIm,1);
Seg.cellId              = zeros(handles.totCell,1);
Seg.yearFile            = zeros(handles.totIm,1);
Seg.monthFile           = zeros(handles.totIm,1);
Seg.dayFile             = zeros(handles.totIm,1);
Seg.hourFile            = zeros(handles.totIm,1);
Seg.minFile             = zeros(handles.totIm,1);
Seg.ImNumSingle         = zeros(handles.totIm,1);
%Classification probabilities
Seg.class.nucleus       = zeros(handles.totCell,1);
Seg.class.apoptotic     = zeros(handles.totCell,1);
Seg.class.mitotic       = zeros(handles.totCell,1);
Seg.class.Edge          = zeros(handles.totCell,1);
Seg.class.debris        = zeros(handles.totCell,1);
        
%Nuclear properties
Seg.Nuc.Area                = zeros(handles.totCell,1);
Seg.Nuc.Perimeter           = zeros(handles.totCell,1);
Seg.Nuc.Solidity            = zeros(handles.totCell,1);
Seg.Nuc.EulerNumber         = zeros(handles.totCell,1);
Seg.Nuc.ConvexArea          = zeros(handles.totCell,1);
Seg.Nuc.EquivDiameter       = zeros(handles.totCell,1);
Seg.Nuc.MajorAxisLength     = zeros(handles.totCell,1);
Seg.Nuc.MinorAxisLength     = zeros(handles.totCell,1);
Seg.Nuc.Circularity         = zeros(handles.totCell,1);
Seg.Nuc.Hu_mom1             = zeros(handles.totCell,1);
Seg.Nuc.Hu_mom2             = zeros(handles.totCell,1);
Seg.Nuc.Hu_mom3             = zeros(handles.totCell,1);
Seg.Nuc.Hu_mom4             = zeros(handles.totCell,1);
Seg.Nuc.Hu_mom5             = zeros(handles.totCell,1);
Seg.Nuc.Hu_mom6             = zeros(handles.totCell,1);
Seg.Nuc.Hu_mom7             = zeros(handles.totCell,1);
Seg.Nuc.Extension           = zeros(handles.totCell,1);
Seg.Nuc.Dispersion          = zeros(handles.totCell,1);
Seg.Nuc.Elongation          = zeros(handles.totCell,1);
Seg.Nuc.Mean_Pixel_Dist     = zeros(handles.totCell,1);
Seg.Nuc.Max_Pixel_Dist      = zeros(handles.totCell,1);
Seg.Nuc.Min_Pixel_Dist      = zeros(handles.totCell,1);
Seg.Nuc.Std_Pixel_Dist      = zeros(handles.totCell,1);
Seg.Nuc.Mean_Intensity      = zeros(handles.totCell,1);
Seg.Nuc.Min_Intensity       = zeros(handles.totCell,1);
Seg.Nuc.Max_Intensity       = zeros(handles.totCell,1);
Seg.Nuc.Std_Intensity       = zeros(handles.totCell,1);
Seg.Nuc.Mean_Gradient_Full  = zeros(handles.totCell,1);
Seg.Nuc.Min_Gradient_Full   = zeros(handles.totCell,1);
Seg.Nuc.Max_Gradient_Full   = zeros(handles.totCell,1);
Seg.Nuc.Std_Gradient_Full   = zeros(handles.totCell,1);
Seg.xpos                    = zeros(handles.totCell,1);
Seg.ypos                    = zeros(handles.totCell,1);
Seg.NucBackground          = zeros(handles.totIm,1);
Seg.Nuc.Mean_Dist_to_closest_objs = zeros(handles.totCell,1);

%Cytoplasm shape based properties
Seg.Cyto.Area             = zeros(handles.totCell,1);
Seg.Cyto.Perimeter        = zeros(handles.totCell,1); 
Seg.Cyto.Circularity      = zeros(handles.totCell,1);
Seg.Cyto.Hu_mom1          = zeros(handles.totCell,1);
Seg.Cyto.Hu_mom2          = zeros(handles.totCell,1);
Seg.Cyto.Hu_mom3          = zeros(handles.totCell,1);
Seg.Cyto.Hu_mom4          = zeros(handles.totCell,1);
Seg.Cyto.Hu_mom5          = zeros(handles.totCell,1);
Seg.Cyto.Hu_mom6          = zeros(handles.totCell,1);
Seg.Cyto.Hu_mom7          = zeros(handles.totCell,1);
Seg.Cyto.Extension        = zeros(handles.totCell,1);
Seg.Cyto.Dispersion       = zeros(handles.totCell,1);
Seg.Cyto.Elongation       = zeros(handles.totCell,1);

%Properties for each cell in each channel
for q = 1:handles.numCh
    chnm = ['CH_' num2str(q)];
    Seg.(chnm).Background       = zeros(handles.totIm,1);
    Seg.(chnm).Intensity        = zeros(handles.totCell,1);
    Seg.(chnm).Mean_Pixel_Dist  = zeros(handles.totCell,1);
    Seg.(chnm).Max_Pixel_Dist   = zeros(handles.totCell,1);
    Seg.(chnm).Min_Pixel_Dist   = zeros(handles.totCell,1);
    Seg.(chnm).Std_Pixel_Dist   = zeros(handles.totCell,1);
    Seg.(chnm).Mean_Intensity   = zeros(handles.totCell,1);
    Seg.(chnm).Min_Intensity    = zeros(handles.totCell,1);
    Seg.(chnm).Max_Intensity    = zeros(handles.totCell,1);
    Seg.(chnm).Std_Intensity    = zeros(handles.totCell,1);
    Seg.(chnm).Mean_Gradient_Full   = zeros(handles.totCell,1);
    Seg.(chnm).Min_Gradient_Full    = zeros(handles.totCell,1);
    Seg.(chnm).Max_Gradient_Full    = zeros(handles.totCell,1);
    Seg.(chnm).Std_Gradient_Full    = zeros(handles.totCell,1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Begin Exporting by loading each file and saving the contents
hf = waitbar(0,'Export Time Estimate:');
cnt = 1;
for i = 1:size(seg_file,1)
    tic
    load([handles.expDir filesep 'Segmented/' seg_file(i).name])
    cnt2 = cnt+double(CO.cellCount)-1;
    if cnt2>243030
        i
        size(seg_file,1)
        error('Stop')
    end
    if double(CO.cellCount) ~=0
        Seg.FileNameSingle{i}           = char(CO.filename);
        Seg.year(cnt:cnt2)              = repmat(CO.tim.year,double(CO.cellCount),1);
        Seg.month(cnt:cnt2)             = repmat(CO.tim.month,double(CO.cellCount),1);
        Seg.day(cnt:cnt2)               = repmat(CO.tim.day,double(CO.cellCount),1);
        Seg.hour(cnt:cnt2)              = repmat(CO.tim.hr,double(CO.cellCount),1);
        Seg.hourFile(i)                 = CO.tim.hr;
        Seg.min(cnt:cnt2)               = repmat(CO.tim.min,double(CO.cellCount),1);
        Seg.yearFile(i)                 = CO.tim.year;
        Seg.dayFile(i)                  = CO.tim.day;
        Seg.monthFile(i)                = CO.tim.month;
        Seg.minFile(i)                  = CO.tim.min;
        Seg.RowSingle{i}                = char(CO.rw);
        Seg.ColSingle{i}                = char(CO.cl);
        Seg.numCytowoutNuc(i)           = CO.numCytowoutNuc;
        Seg.cellcount(i)                = double(CO.cellCount);
        Seg.cellId(cnt:cnt2)            = CO.cellId;
        Seg.ImNumSingle(i)              = i;
        Seg.ImNum(cnt:cnt2)             = repmat(i,double(CO.cellCount),1);
        for k = cnt:cnt2
            Seg.FileName{k}     = CO.filename;
            Seg.RW{k}           = CO.rw;
            Seg.CL{k}           = CO.cl;
        end
        %Position
        Seg.xpos(cnt:cnt2)                  = CO.Centroid(:,1);
        Seg.ypos(cnt:cnt2)                  = CO.Centroid(:,2);
        %Nuclear parameters
        Seg.Nuc.Area(cnt:cnt2)              = CO.Nuc.Area;
        Seg.Nuc.Perimeter(cnt:cnt2)         = CO.Nuc.Perimeter;
        Seg.Nuc.Solidity(cnt:cnt2)          = CO.Nuc.Solidity;
        Seg.Nuc.EulerNumber(cnt:cnt2)       = CO.Nuc.EulerNumber;
        Seg.Nuc.ConvexArea(cnt:cnt2)        = CO.Nuc.ConvexArea;
        Seg.Nuc.EquivDiameter(cnt:cnt2)     = CO.Nuc.EquivDiameter;
        Seg.Nuc.MajorAxisLength(cnt:cnt2)   = CO.Nuc.MajorAxisLength;
        Seg.Nuc.MinorAxisLength(cnt:cnt2)   = CO.Nuc.MinorAxisLength;
        Seg.NucBackground(i)               = CO.NucBackground;
        Seg.Nuc.Circularity(cnt:cnt2)       = CO.Nuc.Circularity;
        Seg.Nuc.Hu_mom1(cnt:cnt2)           = CO.Nuc.Hu_mom1;
        Seg.Nuc.Hu_mom2(cnt:cnt2)           = CO.Nuc.Hu_mom2;
        Seg.Nuc.Hu_mom3(cnt:cnt2)           = CO.Nuc.Hu_mom3;
        Seg.Nuc.Hu_mom4(cnt:cnt2)           = CO.Nuc.Hu_mom4;
        Seg.Nuc.Hu_mom5(cnt:cnt2)           = CO.Nuc.Hu_mom5;
        Seg.Nuc.Hu_mom6(cnt:cnt2)           = CO.Nuc.Hu_mom6;
        Seg.Nuc.Hu_mom7(cnt:cnt2)           = CO.Nuc.Hu_mom7;
        Seg.Nuc.Extension(cnt:cnt2)         = CO.Nuc.Extension;
        Seg.Nuc.Dispersion(cnt:cnt2)        = CO.Nuc.Dispersion;
        Seg.Nuc.Elongation(cnt:cnt2)        = CO.Nuc.Elongation;
        Seg.Nuc.Mean_Pixel_Dist(cnt:cnt2)   = CO.Nuc.Mean_Pixel_Dist;
        Seg.Nuc.Max_Pixel_Dist(cnt:cnt2)    = CO.Nuc.Max_Pixel_Dist;
        Seg.Nuc.Min_Pixel_Dist(cnt:cnt2)    = CO.Nuc.Min_Pixel_Dist;
        Seg.Nuc.Std_Pixel_Dist(cnt:cnt2)    = CO.Nuc.Std_Pixel_Dist;
        Seg.Nuc.Mean_Intensity(cnt:cnt2)    = CO.Nuc.Mean_Intensity;
        Seg.Nuc.Min_Intensity(cnt:cnt2)     = CO.Nuc.Min_Intensity;
        Seg.Nuc.Max_Intensity(cnt:cnt2)     = CO.Nuc.Max_Intensity;
        Seg.Nuc.Std_Intensity(cnt:cnt2)     = CO.Nuc.Std_Intensity;
        Seg.Nuc.Mean_Gradient_Full(cnt:cnt2)= CO.Nuc.Mean_Gradient_Full;
        Seg.Nuc.Min_Gradient_Full(cnt:cnt2) = CO.Nuc.Min_Gradient_Full;
        Seg.Nuc.Max_Gradient_Full(cnt:cnt2) = CO.Nuc.Max_Gradient_Full;
        Seg.Nuc.Std_Gradient_Full(cnt:cnt2) = CO.Nuc.Std_Gradient_Full;
        Seg.Nuc.Mean_Dist_to_closest_objs(cnt:cnt2) = CO.Nuc.Mean_Dist_to_closest_objs;
        %Classification
        Seg.class.nucleus(cnt:cnt2)         = CO.class.nucleus;
        Seg.class.apoptotic(cnt:cnt2)       = CO.class.apoptotic;
        Seg.class.mitotic(cnt:cnt2)         = CO.class.mitotic;
        Seg.class.Edge(cnt:cnt2)            = CO.class.Edge;
        Seg.class.debris(cnt:cnt2)          = CO.class.debris;
        
        for q = 1:handles.numCh
            chnm = ['CH_' num2str(q)];
            if q == 1
                Seg.Cyto.Area(cnt:cnt2)         = CO.Cyto.Area;
                Seg.Cyto.Perimeter(cnt:cnt2)    = CO.Cyto.Perimeter;
                Seg.Cyto.Circularity(cnt:cnt2)  = CO.Cyto.Circularity;
                Seg.Cyto.Hu_mom1(cnt:cnt2)      = CO.Cyto.Hu_mom1;
                Seg.Cyto.Hu_mom2(cnt:cnt2)      = CO.Cyto.Hu_mom2;
                Seg.Cyto.Hu_mom3(cnt:cnt2)      = CO.Cyto.Hu_mom3;
                Seg.Cyto.Hu_mom4(cnt:cnt2)      = CO.Cyto.Hu_mom4;
                Seg.Cyto.Hu_mom5(cnt:cnt2)      = CO.Cyto.Hu_mom5;
                Seg.Cyto.Hu_mom6(cnt:cnt2)      = CO.Cyto.Hu_mom6;
                Seg.Cyto.Hu_mom7(cnt:cnt2)      = CO.Cyto.Hu_mom7;
                Seg.Cyto.Extension(cnt:cnt2)    = CO.Cyto.Extension;
                Seg.Cyto.Dispersion(cnt:cnt2)   = CO.Cyto.Dispersion;
                Seg.Cyto.Elongation(cnt:cnt2)   = CO.Cyto.Elongation;
            end
            Seg.(chnm).Background(i)            = CO.(chnm).Background;
            Seg.(chnm).Mean_Pixel_Dist(cnt:cnt2)= CO.(chnm).Mean_Pixel_Dist;
            Seg.(chnm).Max_Pixel_Dist(cnt:cnt2) = CO.(chnm).Max_Pixel_Dist;
            Seg.(chnm).Min_Pixel_Dist(cnt:cnt2) = CO.(chnm).Min_Pixel_Dist;
            Seg.(chnm).Std_Pixel_Dist(cnt:cnt2) = CO.(chnm).Std_Pixel_Dist;
            Seg.(chnm).Mean_Intensity(cnt:cnt2) = CO.(chnm).Mean_Intensity;
            Seg.(chnm).Min_Intensity(cnt:cnt2)  = CO.(chnm).Min_Intensity;
            Seg.(chnm).Max_Intensity(cnt:cnt2)  = CO.(chnm).Max_Intensity;
            Seg.(chnm).Std_Intensity(cnt:cnt2)  = CO.(chnm).Std_Intensity;
            Seg.(chnm).Mean_Gradient_Full(cnt:cnt2) = CO.(chnm).Mean_Gradient_Full;
            Seg.(chnm).Min_Gradient_Full(cnt:cnt2)  = CO.(chnm).Min_Gradient_Full;
            Seg.(chnm).Max_Gradient_Full(cnt:cnt2)  = CO.(chnm).Max_Gradient_Full;
            Seg.(chnm).Std_Gradient_Full(cnt:cnt2)  = CO.(chnm).Std_Gradient_Full;
        end
	cnt = cnt2 + 1;
    else %If the segmented image is empty
        Seg.FileNameSingle{i}           = char(CO.filename);
        Seg.year(cnt)                   = CO.tim.year;
        Seg.month(cnt)                  = CO.tim.month;
        Seg.day(cnt)                    = CO.tim.day;
        Seg.hour(cnt)                   = CO.tim.hr;
        Seg.hourFile(i)                 = CO.tim.hr;
        Seg.min(cnt)                    = CO.tim.min;
        Seg.yearFile(i)                 = CO.tim.year;
        Seg.dayFile(i)                  = CO.tim.day;
        Seg.monthFile(i)                = CO.tim.month;
        Seg.minFile(i)                  = CO.tim.min;
        Seg.RowSingle{i}                = char(seg_file(i).name(1:3));
        Seg.ColSingle{i}                = char(seg_file(i).name(5:7));
        Seg.numCytowoutNuc(i)           = CO.numCytowoutNuc;
        Seg.cellcount(i)                = double(CO.cellCount);
        Seg.cellId(cnt)                 = 0;
        idx                             = strfind(seg_file(i).name,'_');
        Seg.ImNumSingle(i)              = str2double(seg_file(i).name(idx(2)+1:strfind(seg_file(i).name,'.')-1));
        Seg.ImNum(cnt)                  = str2double(seg_file(i).name(idx(2)+1:strfind(seg_file(i).name,'.')-1));
        Seg.FileName{cnt}               = CO.filename;
        Seg.RW{cnt}                     = CO.rw;
        Seg.CL{cnt}                     = CO.cl;
        %Position
        Seg.xpos(cnt)                  = 0;
        Seg.ypos(cnt)                  = 0;
        %Nuclear parameters
        Seg.Nuc.Area(cnt)              = 0;
        Seg.Nuc.Perimeter(cnt)         = 0;
        Seg.Nuc.Solidity(cnt)          = 0;
        Seg.Nuc.EulerNumber(cnt)       = 0;
        Seg.Nuc.ConvexArea(cnt)        = 0;
        Seg.Nuc.EquivDiameter(cnt)     = 0;
        Seg.Nuc.MajorAxisLength(cnt)   = 0;
        Seg.Nuc.MinorAxisLength(cnt)   = 0;
        Seg.NucBackground(i)          = 0;
        Seg.Nuc.Circularity(cnt)       = 0;
        Seg.Nuc.Hu_mom1(cnt)           = 0;
        Seg.Nuc.Hu_mom2(cnt)           = 0;
        Seg.Nuc.Hu_mom3(cnt)           = 0;
        Seg.Nuc.Hu_mom4(cnt)           = 0;
        Seg.Nuc.Hu_mom5(cnt)           = 0;
        Seg.Nuc.Hu_mom6(cnt)           = 0;
        Seg.Nuc.Hu_mom7(cnt)           = 0;
        Seg.Nuc.Extension(cnt)         = 0;
        Seg.Nuc.Dispersion(cnt)        = 0;
        Seg.Nuc.Elongation(cnt)        = 0;
        Seg.Nuc.Mean_Pixel_Dist(cnt)   = 0;
        Seg.Nuc.Max_Pixel_Dist(cnt)    = 0;
        Seg.Nuc.Min_Pixel_Dist(cnt)    = 0;
        Seg.Nuc.Std_Pixel_Dist(cnt)    = 0;
        Seg.Nuc.Mean_Intensity(cnt)    = 0;
        Seg.Nuc.Min_Intensity(cnt)     = 0;
        Seg.Nuc.Max_Intensity(cnt)     = 0;
        Seg.Nuc.Std_Intensity(cnt)     = 0;
        Seg.Nuc.Mean_Gradient_Full(cnt)= 0;
        Seg.Nuc.Min_Gradient_Full(cnt) = 0;
        Seg.Nuc.Max_Gradient_Full(cnt) = 0;
        Seg.Nuc.Std_Gradient_Full(cnt) = 0;
        Seg.Nuc.Mean_Dist_to_closest_objs(cnt) = 0;
        %Classification
        Seg.class.nucleus(cnt)         = 0;
        Seg.class.apoptotic(cnt)       = 0;
        Seg.class.mitotic(cnt)         = 0;
        Seg.class.Edge(cnt)            = 0;
        Seg.class.debris(cnt)          = 0;
        
        for q = 1:handles.numCh
            chnm = ['CH_' num2str(q)];
            if q == 1
                Seg.Cyto.Area(cnt)         = 0;
                Seg.Cyto.Perimeter(cnt)    = 0;
                Seg.Cyto.AtoP(cnt)         = 0;
                Seg.Cyto.Circularity(cnt)  = 0;
                Seg.Cyto.Hu_mom1(cnt)      = 0;
                Seg.Cyto.Hu_mom2(cnt)      = 0;
                Seg.Cyto.Hu_mom3(cnt)      = 0;
                Seg.Cyto.Hu_mom4(cnt)      = 0;
                Seg.Cyto.Hu_mom5(cnt)      = 0;
                Seg.Cyto.Hu_mom6(cnt)      = 0;
                Seg.Cyto.Hu_mom7(cnt)      = 0;
                Seg.Cyto.Extension(cnt)    = 0;
                Seg.Cyto.Dispersion(cnt)   = 0;
                Seg.Cyto.Elongation(cnt)   = 0;
            end
            Seg.(chnm).Background(i)       = 0;
            Seg.(chnm).Mean_Pixel_Dist(cnt)= 0;
            Seg.(chnm).Max_Pixel_Dist(cnt) = 0;
            Seg.(chnm).Min_Pixel_Dist(cnt) = 0;
            Seg.(chnm).Std_Pixel_Dist(cnt) = 0;
            Seg.(chnm).Mean_Intensity(cnt) = 0;
            Seg.(chnm).Min_Intensity(cnt)  = 0;
            Seg.(chnm).Max_Intensity(cnt)  = 0;
            Seg.(chnm).Std_Intensity(cnt)  = 0;
            Seg.(chnm).Mean_Gradient_Full(cnt) = 0;
            Seg.(chnm).Min_Gradient_Full(cnt)  = 0;
            Seg.(chnm).Max_Gradient_Full(cnt)  = 0;
            Seg.(chnm).Std_Gradient_Full(cnt)  = 0;
        end
        cnt = cnt + 1;
    end
    t(i) = toc;
    str = sprintf('Time Estimate:%.2f sec',(size(seg_file,1)-i)*mean(t));
    waitbar(i/size(seg_file,1),hf,str);
end
close(hf)
hf = msgbox('Writing results...');
child = get(hf,'Children');
delete(child(1)) 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Save the results in three separate files
%The first is a matrix with individual cell events saved as a CSV
%The second is the image events, which details cell count and the
%background for each image also as a csv
%Third is the .mat file with all this infomation saved.

Condition = {'FileName','Year','Month','Day','Hour','Min','Row','Col','ImNumber','cellId','X_position','Y_position','Nuc_Area','Nuc_Perimeter',...
    'Nuc_Circularity','Nuc_Hu_mom1','Nuc_Hu_mom2','Nuc_Hu_mom3','Nuc_Hu_mom4','Nuc_Hu_mom5','Nuc_Hu_mom6','Nuc_Hu_mom7','Extension','Dispersion','Elongation',...
    'Nuc_Mean_Dist_to_closest_objs','Nuc_Mean_Pixel_Dist','Nuc_Max_Pixel_Dist','Nuc_Min_Pixel_Dist','Nuc_Std_Pixel_Dist','Nuc_Mean_Intensity','Nuc_Min_Intensity',...
    'Nuc_Max_Intensity','Nuc_Std_Intensity','Nuc_Mean_Gradient_Full','Nuc_Min_Gradient_Full','Nuc_Max_Gradient_Full','Nuc_Std_Gradient_Full',...
    'Nuc_ConvexArea','Nuc_Solidity','Nuc_MajorAxisLength','Nuc_MinorAxisLength','Nuc_EquivDiameter','Nuc_EulerNumber'};
tempMat_CellEvent = cell2table(Seg.FileName,'VariableNames',{Condition{1}});
tempMat_CellEvent = [tempMat_CellEvent, array2table([Seg.year,Seg.month,Seg.day,Seg.hour,Seg.min],'VariableNames',{Condition{2:6}})]; 
tempMat_CellEvent = [tempMat_CellEvent, cell2table([Seg.RW,Seg.CL],'VariableNames',{Condition{7:8}})];
tempMat_CellEvent = [tempMat_CellEvent, array2table([Seg.ImNum,Seg.cellId,Seg.xpos,Seg.ypos,Seg.Nuc.Area,Seg.Nuc.Perimeter],'VariableNames',{Condition{9:14}})];

tempMat_CellEvent = [tempMat_CellEvent, array2table([Seg.Nuc.Circularity,Seg.Nuc.Hu_mom1,Seg.Nuc.Hu_mom2,Seg.Nuc.Hu_mom3,Seg.Nuc.Hu_mom4,...
    Seg.Nuc.Hu_mom5,Seg.Nuc.Hu_mom6,Seg.Nuc.Hu_mom7,Seg.Nuc.Extension,Seg.Nuc.Dispersion,Seg.Nuc.Elongation,...
    Seg.Nuc.Mean_Dist_to_closest_objs,Seg.Nuc.Mean_Pixel_Dist,Seg.Nuc.Max_Pixel_Dist,Seg.Nuc.Min_Pixel_Dist,...
    Seg.Nuc.Std_Pixel_Dist,Seg.Nuc.Mean_Intensity,Seg.Nuc.Min_Intensity,Seg.Nuc.Max_Intensity,Seg.Nuc.Std_Intensity,...
    Seg.Nuc.Mean_Gradient_Full,Seg.Nuc.Min_Gradient_Full,Seg.Nuc.Max_Gradient_Full,Seg.Nuc.Std_Gradient_Full,...
    Seg.Nuc.ConvexArea,Seg.Nuc.Solidity,Seg.Nuc.MajorAxisLength,Seg.Nuc.MinorAxisLength,Seg.Nuc.EquivDiameter,Seg.Nuc.EulerNumber],...
    'VariableNames',...
    {Condition{15:end}})];
temp = array2table([Seg.Cyto.Area, Seg.Cyto.Perimeter, Seg.Cyto.Circularity, Seg.Cyto.Extension, Seg.Cyto.Dispersion, Seg.Cyto.Elongation,...
    Seg.Cyto.Hu_mom1, Seg.Cyto.Hu_mom2, Seg.Cyto.Hu_mom3, Seg.Cyto.Hu_mom4, Seg.Cyto.Hu_mom5, Seg.Cyto.Hu_mom6, Seg.Cyto.Hu_mom7],...
    'VariableNames',{'Cyto_Area','Cyto_Perimeter','Cyto_Circularity','Cyto_Extension','Cyto_Dispersion','Cyto_Elongation',...
    'Cyto_Hu_mom1','Cyto_Hu_mom2','Cyto_Hu_mom3','Cyto_Hu_mom4','Cyto_Hu_mom5','Cyto_Hu_mom6','Cyto_Hu_mom7'});
tempMat_CellEvent = [tempMat_CellEvent, array2table([Seg.Cyto.Area, Seg.Cyto.Perimeter, Seg.Cyto.Circularity, Seg.Cyto.Extension, Seg.Cyto.Dispersion, Seg.Cyto.Elongation,...
    Seg.Cyto.Hu_mom1, Seg.Cyto.Hu_mom2, Seg.Cyto.Hu_mom3, Seg.Cyto.Hu_mom4, Seg.Cyto.Hu_mom5, Seg.Cyto.Hu_mom6, Seg.Cyto.Hu_mom7],...
    'VariableNames',{'Cyto_Area','Cyto_Perimeter','Cyto_Circularity','Cyto_Extension','Cyto_Dispersion','Cyto_Elongation',...
    'Cyto_Hu_mom1','Cyto_Hu_mom2','Cyto_Hu_mom3','Cyto_Hu_mom4','Cyto_Hu_mom5','Cyto_Hu_mom6','Cyto_Hu_mom7'})];

for q = 1:handles.numCh
    chnm = ['CH_' num2str(q)];
    Condition = {[chnm '_Mean_Pixel_Dist'],[chnm '_Max_Pixel_Dist'],[chnm '_Min_Pixel_Dist'],[chnm '_Std_Pixel_Dist'],...
        [chnm '_Mean_Intensity'],[chnm '_Min_Intensity'],[chnm '_Max_Intensity'],[chnm '_Std_Intensity'],...
        [chnm '_Mean_Gradient_Full'],[chnm '_Min_Gradient_Full'],[chnm '_Max_Gradient_Full'],[chnm '_Std_Gradient_Full']};
    tempMat_CellEvent = [tempMat_CellEvent, array2table([Seg.(chnm).Mean_Pixel_Dist,Seg.(chnm).Max_Pixel_Dist,Seg.(chnm).Min_Pixel_Dist,Seg.(chnm).Std_Pixel_Dist,...
        Seg.(chnm).Mean_Intensity,Seg.(chnm).Min_Intensity,Seg.(chnm).Max_Intensity,Seg.(chnm).Std_Intensity,...
        Seg.(chnm).Mean_Gradient_Full,Seg.(chnm).Min_Gradient_Full,Seg.(chnm).Max_Gradient_Full,Seg.(chnm).Std_Gradient_Full],'VariableNames',Condition)];
end

Condition = {'Class_Nucleus','Class_Debris','Class_Mitotic','Class_Apoptotic','Class_Edge'};
tempMat_CellEvent = [tempMat_CellEvent, array2table([Seg.class.nucleus,Seg.class.debris,Seg.class.mitotic,Seg.class.apoptotic,Seg.class.Edge],'VariableNames',Condition)];
writetable(tempMat_CellEvent,[handles.expDir filesep 'Cell Events.csv'])

Condition = {'FileName','ImageNumber','Year','Month','Day','Hour','Min','Row','Col','CellCount','Nuc_Background'};
tempMat_ImEvents = cell2table(cellstr(Seg.FileNameSingle),'VariableNames',Condition(1));
tempMat_ImEvents = [tempMat_ImEvents, array2table([Seg.ImNumSingle,Seg.yearFile,Seg.monthFile,Seg.dayFile,Seg.hourFile,Seg.minFile],'VariableNames',{Condition{2:7}})]; 
tempMat_ImEvents = [tempMat_ImEvents, cell2table([cellstr(Seg.RowSingle),cellstr(Seg.ColSingle)],'VariableNames',{Condition{8:9}})];
tempMat_ImEvents = [tempMat_ImEvents, array2table([Seg.cellcount,Seg.NucBackground],'VariableNames',{Condition{10:11}})];
for q = 1:handles.numCh
    chnm = ['CH_' num2str(q)];
    tempMat_ImEvents = [tempMat_ImEvents, array2table([Seg.(chnm).Background],'VariableNames', {[chnm '_Background']})];
end
tempMat_ImEvents = [tempMat_ImEvents, array2table(Seg.numCytowoutNuc,'VariableNames',{'NumCytoWoutNuc'})];
writetable(tempMat_ImEvents,[handles.expDir filesep 'Image Events.csv']);

ImageParameter = {'Number_Flourescent_Channels_ex_Nuc','Nuclear_Segmentation_Level','Cytoplasm_Segmentation_Level'...
    'Split_Nuclei','Noise_Filter_Cytoplasm','Noise_Filter_Nucleus','Segmentation_Smoothing_Factor','Cidre_correct_1_is_true',...
    'Correct_by_Background_Sub','Segment_by_Nuclear_Dilation','Nuclear_Dilation_Factor','Segment_Cell_Surface',...
    'Cell_Surface_Dilation_Factor','Clear_Border_Cells','BD_pathway_exp'};
tempMat_SegParameters = array2table([handles.numCh,handles.NucnumLevel,handles.CytonumLevel,handles.NucSegHeight,handles.noise_disk,handles.nuc_noise_disk,...
handles.smoothing_factor,handles.cidrecorrect,handles.background_corr,handles.nuclear_segment,...
handles.nuclear_segment_factor,handles.surface_segment,handles.surface_segment_factor,...
handles.cl_border,handles.bd_pathway],'VariableNames',ImageParameter);
if handles.cidrecorrect
    tempMat_SegParameters.Cidre_Directory = handles.cidreDir;
else
    tempMat_SegParameters.Cidre_Directory = 0;
end
if handles.background_corr
    tempMat_SegParameters.Background_CorrIm_file = handles.CorrIm_file;
else
    tempMat_SegParameters.Background_CorrIm_file = 0;
end
writetable(tempMat_SegParameters,[handles.expDir filesep 'Processing Parameters.csv']);

save([handles.expDir filesep 'Compiled Segmentation Results.mat'],'Seg','tempMat_SegParameters','tempMat_ImEvents','tempMat_CellEvent','handles')

close(hf)
end
