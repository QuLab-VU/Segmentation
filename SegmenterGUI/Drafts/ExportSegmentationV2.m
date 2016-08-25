function [handles] = ExportSegmentation(handles)
%Function for exporting the data after segmentation.
%Cell Events.csv contains each cell's data
%Image Events is a summary of each image segmented
%Handles.mat contains handle to the segmenter and all the parameters
%Processing Parameters.csv contains all the segmentation parameters used

seg_file = dir([handles.expDir filesep 'Segmented/*.mat'])

handles.numCh

totCell = 0;
for i = 1:length(seg_file)
    load([handles.expDir filesep 'Segmented/' seg_file(i).name]);
    if double(CO.cellCount) ~= 0
    	totCell = totCell + double(CO.cellCount);
    else
    	totCell = totCell +1;
    end
end
handles.totIm = length(seg_file)
handles.totCell = totCell

Seg.Nuc_IntperA = zeros(handles.totCell,1);
Seg.NucArea = zeros(handles.totCell,1);
Seg.NucInt = zeros(handles.totCell,1);
Seg.numCytowoutNuc = zeros(handles.totIm,1);
Seg.cellcount = zeros(handles.totIm,1);
Seg.month = zeros(handles.totCell,1);
Seg.day = zeros(handles.totCell,1);
Seg.min = zeros(handles.totCell,1);
Seg.year = zeros(handles.totCell,1);
Seg.hour = zeros(handles.totCell,1);
Seg.RW = cell(handles.totCell,1);
Seg.ImNum = zeros(handles.totCell,1);
Seg.CL = cell(handles.totCell,1);
Seg.class.debris = zeros(handles.totCell,1);
Seg.class.nucleus = zeros(handles.totCell,1);
Seg.class.over = zeros(handles.totCell,1);
Seg.class.under = zeros(handles.totCell,1);
Seg.class.predivision = zeros(handles.totCell,1);
Seg.class.postdivision = zeros(handles.totCell,1);
Seg.class.apoptotic = zeros(handles.totCell,1);
Seg.class.newborn = zeros(handles.totCell,1);
Seg.class.edge = zeros(handles.totCell,1);
Seg.NucBackground = zeros(handles.totIm,1);
Seg.xpos = zeros(handles.totCell,1);
Seg.ypos = zeros(handles.totCell,1);
Seg.RowSingle = cell(handles.totIm,1);
Seg.ColSingle = cell(handles.totIm,1);
Seg.cellId = zeros(handles.totCell,1);
Seg.yearFile= zeros(handles.totIm,1);
Seg.monthFile = zeros(handles.totIm,1);
Seg.dayFile= zeros(handles.totIm,1);
Seg.hourFile= zeros(handles.totIm,1);
Seg.minFile= zeros(handles.totIm,1);
Seg.ImNumSingle = zeros(handles.totIm,1);

for q = 1:handles.numCh
    chnm = ['CH_' num2str(q)]
    Seg.(chnm).IntperA = zeros(handles.totCell,1);
    Seg.(chnm).Intensity = zeros(handles.totCell,1);
    Seg.(chnm).Area = zeros(handles.totCell,1);
    Seg.(chnm).Perimeter = zeros(handles.totCell,1); 
    Seg.(chnm).AtoP = zeros(handles.totCell,1);
    Seg.(chnm).Background = zeros(handles.totIm,1);
end

hf = waitbar(0,'Export Time Estimate:')
cnt = 1;
for i = 1:size(seg_file,1)
    tic
    load([handles.expDir filesep 'Segmented/' seg_file(i).name])
    cnt2 = cnt+double(CO.cellCount)-1;
    if double(CO.cellCount) ~=0
        Seg.year(cnt:cnt2) = repmat(CO.tim.year,double(CO.cellCount),1);
        Seg.month(cnt:cnt2) = repmat(CO.tim.month,double(CO.cellCount),1);
        Seg.day(cnt:cnt2) = repmat(CO.tim.day,double(CO.cellCount),1);
        Seg.hour(cnt:cnt2) = repmat(CO.tim.hr,double(CO.cellCount),1);
        Seg.hourFile(i) = CO.tim.hr;
        Seg.min(cnt:cnt2) =repmat(CO.tim.min,double(CO.cellCount),1);
        Seg.yearFile(i) = CO.tim.year;
        Seg.dayFile(i) = CO.tim.day;
        Seg.monthFile(i) = CO.tim.month;
        Seg.minFile(i) = CO.tim.min;
        Seg.RowSingle{i} = char(seg_file(i).name(1:3));
        Seg.ColSingle{i} = char(seg_file(i).name(5:7));
        idx = strfind(seg_file(i).name,'_');
        Seg.ImNumSingle(i) = str2double(seg_file(i).name(idx(2)+1:strfind(seg_file(i).name,'.')-1));
        Seg.ImNum(cnt:cnt2) = str2double(repmat(seg_file(i).name(idx(2)+1:strfind(seg_file(i).name,'.')-1),double(CO.cellCount),1));
        for k = cnt:cnt2
            Seg.RW{k} = seg_file(i).name(1:3);
            Seg.CL{k} = seg_file(i).name(5:7);
        end
        Seg.NucArea(cnt:cnt2) = CO.Nuc.Area;
        Seg.NucInt(cnt:cnt2) = CO.Nuc.Intensity;
        Seg.Nuc_IntperA(cnt:cnt2) = CO.Nuc.Intensity./CO.Nuc.Area;
        Seg.numCytowoutNuc(i) = CO.numCytowoutNuc;
        Seg.cellcount(i) =double(CO.cellCount);
        Seg.NucBackground(i) = CO.Nuc.Background;
        Seg.class.debris(cnt:cnt2) = CO.class.debris;
        Seg.class.nucleus(cnt:cnt2) = CO.class.nucleus;
        Seg.class.over(cnt:cnt2) = CO.class.over;
        Seg.class.under(cnt:cnt2) = CO.class.under;
        Seg.class.predivision(cnt:cnt2) =  CO.class.predivision;
        Seg.class.postdivision(cnt:cnt2) = CO.class.postdivision;
        Seg.class.apoptotic(cnt:cnt2) =  CO.class.apoptotic;
        Seg.class.newborn(cnt:cnt2) = CO.class.newborn;
        Seg.cellId(cnt:cnt2) = CO.cellId;
        Seg.xpos(cnt:cnt2) = CO.Centroid(:,1);
        Seg.ypos(cnt:cnt2) = CO.Centroid(:,2);
        Seg.class.edge(cnt:cnt2) = CO.class.edge;
        for q = 1:handles.numCh
            chnm = ['CH_' num2str(q)];
            Seg.(chnm).IntperA(cnt:cnt2) = CO.(chnm).Intensity./CO.(chnm).Area;
            Seg.(chnm).Intensity(cnt:cnt2) = CO.(chnm).Intensity;
            Seg.(chnm).Area(cnt:cnt2) = CO.(chnm).Area;
            Seg.(chnm).Perimeter(cnt:cnt2) = CO.(chnm).Perimeter;
            Seg.(chnm).AtoP(cnt:cnt2) = CO.(chnm).Area./CO.(chnm).Perimeter;
            Seg.(chnm).Background(i) = CO.(chnm).Background;
        end
	cnt = cnt2 + 1;
    else
        Seg.year(cnt) = CO.tim.year;
        Seg.month(cnt) = CO.tim.month;
        Seg.day(cnt) = CO.tim.day;
        Seg.min(cnt)=CO.tim.min;
        Seg.hour(cnt) = CO.tim.hr;
        Seg.hourFile(i) =  CO.tim.hr;
        Seg.yearFile(i) = CO.tim.year;
        Seg.dayFile(i) = CO.tim.day;
        Seg.monthFile(i) = CO.tim.month;
        Seg.minFile(i) = CO.tim.min;
        Seg.RowSingle{i} = seg_file(i).name(1:3);
        Seg.ColSingle{i} = seg_file(i).name(5:7);
        idx = strfind(seg_file(i).name,'_');
        Seg.ImNumSingle(i) = str2double(seg_file(i).name(idx(2)+1:strfind(seg_file(i).name,'.')-1));
        Seg.ImNum(cnt) = str2double(repmat(seg_file(i).name(idx(2)+1:strfind(seg_file(i).name,'.')-1),1,1));
        Seg.RW{cnt} = seg_file(i).name(1:3);
        Seg.CL{cnt} = seg_file(i).name(5:7);
        Seg.NucArea(cnt) = 0;
        Seg.NucInt(cnt) = 0;
        Seg.Nuc_IntperA(cnt) = 0;
        Seg.numCytowoutNuc(i) = 0;
        Seg.cellcount(i) = 0;
        Seg.NucBackground(i) = 0;
        Seg.class.debris(cnt) = 0;
        Seg.class.nucleus(cnt) = 0;
        Seg.class.over(cnt) = 0;
        Seg.class.under(cnt) =0;
        Seg.class.predivision(cnt) = 0;
        Seg.class.postdivision(cnt) =0;
        Seg.class.apoptotic(cnt) = 0;
        Seg.class.newborn(cnt) = 0;
        Seg.cellId(cnt) = 0;
        Seg.xpos(cnt) = 0;
        Seg.ypos(cnt) = 0;
        Seg.class.edge(cnt) = 0;
        for q = 1:handles.numCh
            chnm = ['CH_' num2str(q)];
            Seg.(chnm).IntperA(cnt) = 0;
            Seg.(chnm).Intensity(cnt) = 0;
            Seg.(chnm).Area(cnt) = 0;
            Seg.(chnm).Perimeter(cnt) = 0;
            Seg.(chnm).AtoP(cnt) = 0;
            Seg.(chnm).Background(i) = 0;
        end
	cnt = cnt + 1;
    end
    t(i) = toc;
    str = sprintf('Time Estimate:%.2f sec',(size(seg_file,1)-i)*mean(t));
    waitbar(i/size(seg_file,1),hf,str);
end
close(hf)
hf = msgbox('Writing results...')


save([handles.expDir filesep 'Compiled Segmentation Results.mat'],'Seg')
Condition = {'Year','Month','Day','Hour','Min','Row','Col','ImNumber','cellId','Xposition','Yposition','Nuc_IntperA','NucArea','NucInt'};
tempMat = [];
tempMat = array2table([Seg.year,Seg.month,Seg.day,Seg.hour,Seg.min],'VariableNames',{Condition{1:5}}); 
tempMat = [tempMat, cell2table([cellstr(Seg.RW),cellstr(Seg.CL)],'VariableNames',{Condition{6:7}})];
tempMat = [tempMat, array2table([Seg.ImNum,Seg.cellId,Seg.xpos,Seg.ypos,Seg.Nuc_IntperA,Seg.NucArea,Seg.NucInt],'VariableNames',{Condition{8:14}})];
for q = 1:handles.numCh
    chnm = ['CH_' num2str(q)];
    Condition = {Condition{:}, [chnm '_IntperA'],[chnm '_Intensity'],[chnm '_Area'],[chnm '_Perimeter'],[chnm '_AtoP']};
    tempMat = [tempMat, array2table([Seg.(chnm).IntperA,Seg.(chnm).Intensity,Seg.(chnm).Area,Seg.(chnm).Perimeter,Seg.(chnm).AtoP],'VariableNames',{Condition{(q-1)*5+15:q*5+14}})];
end
Condition = {Condition{:},'Class_Nucleus','Class_Debris','Class_Over','Class_Under','Class_Predivision','Class_Postdivision','Class_Newborn','Class_Apoptotic','Class_Edge'};
tempMat = [tempMat, array2table([Seg.class.nucleus,Seg.class.debris,Seg.class.over,Seg.class.under,Seg.class.predivision,Seg.class.postdivision,Seg.class.newborn,Seg.class.apoptotic,Seg.class.edge],'VariableNames',{Condition{(handles.numCh)*5+15:end}})];
writetable(tempMat,[handles.expDir filesep 'Cell Events.csv'])

tempMat = [];
Condition = [];
Condition = {'ImageNumber','Year','Month','Day','Hour','Min','Row','Col','CellCount','NuclearCh_Background'};
tempMat = array2table([Seg.ImNumSingle,Seg.yearFile,Seg.monthFile,Seg.dayFile,Seg.hourFile,Seg.minFile],'VariableNames',{Condition{1:6}}); 
tempMat = [tempMat, cell2table([cellstr(Seg.RowSingle),cellstr(Seg.ColSingle)],'VariableNames',{Condition{7:8}})];
tempMat = [tempMat, array2table([Seg.cellcount,Seg.NucBackground],'VariableNames',{Condition{9:10}})];
for q = 1:handles.numCh
    chnm = ['CH_' num2str(q)];
    Condition = {Condition{:}, [chnm '_Background']};
    tempMat = [tempMat, array2table([Seg.(chnm).Background],'VariableNames',{Condition{end}})];
end
tempMat = [tempMat, array2table(Seg.numCytowoutNuc,'VariableNames',{'NumCytoWoutNuc'})];
writetable(tempMat,[handles.expDir filesep 'Image Events.csv']);

tempMat = [];
ImageParameter = [];
ImageParameter = {'Number_Flourescent_Channels_ex_Nuc','Nuclear_Segmentation_Level','Cytoplasm_Segmentation_Level'...
    'Split_Nuclei','Noise_Filter_Cytoplasm','Noise_Filter_Nucleus','Segmentation_Smoothing_Factor','Cidre_correct_1_is_true',...
    'Correct_by_Background_Sub','Segment_by_Nuclear_Dilation','Nuclear_Dilation_Factor','Segment_Cell_Surface',...
    'Cell_Surface_Dilation_Factor','Clear_Border_Cells','BD_pathway_exp'};
T = array2table([handles.numCh,handles.NucnumLevel,handles.CytonumLevel,handles.NucSegHeight,handles.noise_disk,handles.nuc_noise_disk,...
handles.smoothing_factor,handles.cidrecorrect,handles.background_corr,handles.nuclear_segment,...
handles.nuclear_segment_factor,handles.surface_segment,handles.surface_segment_factor,...
handles.cl_border,handles.bd_pathway],'VariableNames',ImageParameter);
if handles.cidrecorrect
    T.Cidre_Directory = handles.cidreDir;
else
    T.Cidre_Directory = 0;
end
if handles.background_corr
    T.Background_CorrIm_file = handles.CorrIm_file;
else
    T.Background_CorrIm_file = 0;
end
writetable(T,[handles.expDir filesep 'Processing Parameters.csv']);

close(hf)
end
