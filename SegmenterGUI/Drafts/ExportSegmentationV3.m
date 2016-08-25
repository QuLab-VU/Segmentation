function [handles] = ExportSegmentationV3(handles)
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

Seg.FileName = zeros(handles.totCell,1);
Seg.FileNameSingle = zeros(handles.totIm,1):
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
Seg.class.apoptotic = zeros(handles.totCell,1);
Seg.class.mitotic = zeros(handles.totCell,1);
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

Seg.Circularity  = zeros(handles.totCell,1);
Seg.Hu_mom1 = zeros(handles.totCell,1);
Seg.Hu_mom2 = zeros(handles.totCell,1);
Seg.Hu_mom3 = zeros(handles.totCell,1);
Seg.Hu_mom4 = zeros(handles.totCell,1);
Seg.Hu_mom5 = zeros(handles.totCell,1);
Seg.Hu_mom6 = zeros(handles.totCell,1);
Seg.Hu_mom7 = zeros(handles.totCell,1);
Seg.Extension = zeros(handles.totCell,1);
Seg.Dispersion =zeros(handles.totCell,1);
Seg.Elongation =zeros(handles.totCell,1);
Seg.Mean_Dist_to_closest_objs = zeros(handles.totCell,1);
Seg.Mean_Pixel_Dist = zeros(handles.totCell,1);
Seg.Max_Pixel_Dist = zeros(handles.totCell,1);
Seg.Min_Pixel_Dist = zeros(handles.totCell,1);
Seg.Std_Pixel_Dist = zeros(handles.totCell,1);
Seg.Min_Intensity = zeros(handles.totCell,1);
Seg.Max_Intensity = zeros(handles.totCell,1);
Seg.Std_Intensity = zeros(handles.totCell,1);
Seg.Mean_Gradient_Full = zeros(handles.totCell,1);
Seg.Min_Gradient_Full = zeros(handles.totCell,1);
Seg.Max_Gradient_Full = zeros(handles.totCell,1);
Seg.Std_Gradient_Full = zeros(handles.totCell,1);


for q = 1:handles.numCh
    chnm = ['CH_' num2str(q)]
    Seg.(chnm).IntperA = zeros(handles.totCell,1);
    Seg.(chnm).Intensity = zeros(handles.totCell,1);
    Seg.(chnm).Area = zeros(handles.totCell,1);
    Seg.(chnm).Perimeter = zeros(handles.totCell,1); 
    Seg.(chnm).AtoP = zeros(handles.totCell,1);
    Seg.(chnm).Background = zeros(handles.totIm,1);
    
    Seg.(chnm).Circularity  = zeros(handles.totCell,1);
    Seg.(chnm).Hu_mom1 = zeros(handles.totCell,1);
    Seg.(chnm).Hu_mom2 = zeros(handles.totCell,1);
    Seg.(chnm).Hu_mom3 = zeros(handles.totCell,1);
    Seg.(chnm).Hu_mom4 = zeros(handles.totCell,1);
    Seg.(chnm).Hu_mom5 = zeros(handles.totCell,1);
    Seg.(chnm).Hu_mom6 = zeros(handles.totCell,1);
    Seg.(chnm).Hu_mom7 = zeros(handles.totCell,1);
    Seg.(chnm).Extension = zeros(handles.totCell,1);
    Seg.(chnm).Dispersion =zeros(handles.totCell,1);
    Seg.(chnm).Elongation =zeros(handles.totCell,1);
    Seg.(chnm).Mean_Dist_to_closest_objs = zeros(handles.totCell,1);
    Seg.(chnm).Mean_Pixel_Dist = zeros(handles.totCell,1);
    Seg.(chnm).Max_Pixel_Dist = zeros(handles.totCell,1);
    Seg.(chnm).Min_Pixel_Dist = zeros(handles.totCell,1);
    Seg.(chnm).Std_Pixel_Dist = zeros(handles.totCell,1);
    Seg.(chnm).Min_Intensity = zeros(handles.totCell,1);
    Seg.(chnm).Max_Intensity = zeros(handles.totCell,1);
    Seg.(chnm).Std_Intensity = zeros(handles.totCell,1);
    Seg.(chnm).Mean_Gradient_Full = zeros(handles.totCell,1);
    Seg.(chnm).Min_Gradient_Full = zeros(handles.totCell,1);
    Seg.(chnm).Max_Gradient_Full = zeros(handles.totCell,1);
    Seg.(chnm).Std_Gradient_Full = zeros(handles.totCell,1);
end

hf = waitbar(0,'Export Time Estimate:')
cnt = 1;
for i = 1:size(seg_file,1)
    tic
    load([handles.expDir filesep 'Segmented/' seg_file(i).name])
    cnt2 = cnt+double(CO.cellCount)-1;
    if double(CO.cellCount) ~=0
        Seg.FileName(cnt:cnt2) = repmat(CO.filename,double(CO.cellCount),1);
        Seg.FileNameSingle{i} = char(CO.filename);
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
        Seg.ImNum(cnt:cnt2) = repmat(str2double(seg_file(i).name(idx(2)+1:strfind(seg_file(i).name,'.')-1)),double(CO.cellCount),1);
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
        Seg.class.apoptotic(cnt:cnt2) =  CO.class.apoptotic;
        Seg.class.mitotic(cnt:cnt2) = CO.class.mitotic;
        Seg.cellId(cnt:cnt2) = CO.cellId;
        Seg.xpos(cnt:cnt2) = CO.Centroid(:,1);
        Seg.ypos(cnt:cnt2) = CO.Centroid(:,2);
        Seg.class.edge(cnt:cnt2) = CO.class.edge;
        
        Seg.Circularity(cnt:cnt2)  =CO.Nuc.Circularity;
        Seg.Hu_mom1(cnt:cnt2) =CO.Nuc.Hu_mom1;
        Seg.Hu_mom2(cnt:cnt2) =CO.Nuc.Hu_mom2;
        Seg.Hu_mom3(cnt:cnt2) =CO.Nuc.Hu_mom3;
        Seg.Hu_mom4(cnt:cnt2) =CO.Nuc.Hu_mom4;
        Seg.Hu_mom5(cnt:cnt2) =CO.Nuc.Hu_mom5;
        Seg.Hu_mom6(cnt:cnt2) =CO.Nuc.Hu_mom6;
        Seg.Hu_mom7(cnt:cnt2)=CO.Nuc.Hu_mom7;
        Seg.Extension(cnt:cnt2) = CO.Nuc.Extension;
        Seg.Dispersion(cnt:cnt2) = CO.Nuc.Dispersion;
        Seg.Elongation(cnt:cnt2) = CO.Nuc.Elongation;
        Seg.Mean_Dist_to_closest_objs(cnt:cnt2) =CO.Nuc.Mean_Dist_to_closest_objs;
        Seg.Mean_Pixel_Dist(cnt:cnt2)=CO.Nuc.Mean_Pixel_Dist;
        Seg.Max_Pixel_Dist(cnt:cnt2) =CO.Nuc.Max_Pixel_Dist;
        Seg.Min_Pixel_Dist(cnt:cnt2)=CO.Nuc.Min_Pixel_Dist;
        Seg.Std_Pixel_Dist(cnt:cnt2) =CO.Nuc.Std_Pixel_Dist;
        Seg.Min_Intensity(cnt:cnt2) =CO.Nuc.Min_Intensity;
        Seg.Max_Intensity(cnt:cnt2) =CO.Nuc.Max_Intensity;
        Seg.Std_Intensity(cnt:cnt2) =CO.Nuc.Std_Intensity;
        Seg.Mean_Gradient_Full(cnt:cnt2)=CO.Nuc.Mean_Gradient_Full;
        Seg.Min_Gradient_Full(cnt:cnt2)=CO.Nuc.Min_Gradient_Full;
        Seg.Max_Gradient_Full(cnt:cnt2) =CO.Nuc.Max_Gradient_Full;
        Seg.Std_Gradient_Full(cnt:cnt2)=CO.Nuc.Std_Gradient_Full;


        for q = 1:handles.numCh
            chnm = ['CH_' num2str(q)];
            Seg.(chnm).IntperA(cnt:cnt2) = CO.(chnm).Intensity./CO.(chnm).Area;
            Seg.(chnm).Intensity(cnt:cnt2) = CO.(chnm).Intensity;
            Seg.(chnm).Area(cnt:cnt2) = CO.(chnm).Area;
            Seg.(chnm).Perimeter(cnt:cnt2) = CO.(chnm).Perimeter;
            Seg.(chnm).AtoP(cnt:cnt2) = CO.(chnm).Area./CO.(chnm).Perimeter;
            Seg.(chnm).Background(i) = CO.(chnm).Background;
            
            Seg.(chnm).Circularity(cnt:cnt2)  =CO.(chnm).Circularity;
            Seg.(chnm).Hu_mom1(cnt:cnt2) =CO.(chnm).Hu_mom1;
            Seg.(chnm).Hu_mom2(cnt:cnt2) =CO.(chnm).Hu_mom2;
            Seg.(chnm).Hu_mom3(cnt:cnt2) =CO.(chnm).Hu_mom3;
            Seg.(chnm).Hu_mom4(cnt:cnt2) =CO.(chnm).Hu_mom4;
            Seg.(chnm).Hu_mom5(cnt:cnt2) =CO.(chnm).Hu_mom5;
            Seg.(chnm).Hu_mom6(cnt:cnt2) =CO.(chnm).Hu_mom6;
            Seg.(chnm).Hu_mom7(cnt:cnt2)=CO.(chnm).Hu_mom7;
            Seg.(chnm).Extension(cnt:cnt2) = CO.(chnm).Extension;
            Seg.(chnm).Dispersion(cnt:cnt2) = CO.(chnm).Dispersion;
            Seg.(chnm).Elongation(cnt:cnt2) = CO.(chnm).Elongation;
            
            Seg.(chnm).Mean_Dist_to_closest_objs(cnt:cnt2) =CO.(chnm).Mean_Dist_to_closest_objs;
            Seg.(chnm).Mean_Pixel_Dist(cnt:cnt2)=CO.(chnm).Mean_Pixel_Dist;
            Seg.(chnm).Max_Pixel_Dist(cnt:cnt2) =CO.(chnm).Max_Pixel_Dist;
            Seg.(chnm).Min_Pixel_Dist(cnt:cnt2)=CO.(chnm).Min_Pixel_Dist;
            Seg.(chnm).Std_Pixel_Dist(cnt:cnt2) =CO.(chnm).Std_Pixel_Dist;
            Seg.(chnm).Min_Intensity(cnt:cnt2) =CO.(chnm).Min_Intensity;
            Seg.(chnm).Max_Intensity(cnt:cnt2) =CO.(chnm).Max_Intensity;
            Seg.(chnm).Std_Intensity(cnt:cnt2) =CO.(chnm).Std_Intensity;
            Seg.(chnm).Mean_Gradient_Full(cnt:cnt2)=CO.(chnm).Mean_Gradient_Full;
            Seg.(chnm).Min_Gradient_Full(cnt:cnt2)=CO.(chnm).Min_Gradient_Full;
            Seg.(chnm).Max_Gradient_Full(cnt:cnt2) =CO.(chnm).Max_Gradient_Full;
            Seg.(chnm).Std_Gradient_Full(cnt:cnt2)=CO.(chnm).Std_Gradient_Full;
        end
	cnt = cnt2 + 1;
    else
        Seg.FileName{cnt} = CO.filename;
        Seg.FileNameSingle{i} = CO.filename;
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
        Seg.class.apoptotic(cnt) = 0;
        Seg.class.mitotic(cnt) = 0;
        Seg.cellId(cnt) = 0;
        Seg.xpos(cnt) = 0;
        Seg.ypos(cnt) = 0;
        Seg.class.edge(cnt) = 0;
        
        Seg.Circularity(cnt)  =0;
        Seg.Hu_mom1(cnt) =0;
        Seg.Hu_mom2(cnt) =0;
        Seg.Hu_mom3(cnt) =0;
        Seg.Hu_mom4(cnt) =0;
        Seg.Hu_mom5(cnt) =0;
        Seg.Hu_mom6(cnt) =0;
        Seg.Hu_mom7(cnt)=0;
        Seg.Extension(cnt) = 0;
        Seg.Dispersion(cnt) = 0;
        Seg.Elongation(cnt) = 0;
        
        Seg.Mean_Dist_to_closest_objs(cnt) =0;
        Seg.Mean_Pixel_Dist(cnt)=0;
        Seg.Max_Pixel_Dist(cnt) =0;
        Seg.Min_Pixel_Dist(cnt)=0;
        Seg.Std_Pixel_Dist(cnt) =0;
        Seg.Min_Intensity(cnt) =0;
        Seg.Max_Intensity(cnt) =0;
        Seg.Std_Intensity(cnt) =0;
        Seg.Mean_Gradient_Full(cnt)=0;
        Seg.Min_Gradient_Full(cnt)=0;
        Seg.Max_Gradient_Full(cnt) =0;
        Seg.Std_Gradient_Full(cnt)=0;
        
        for q = 1:handles.numCh
            chnm = ['CH_' num2str(q)];
            Seg.(chnm).IntperA(cnt) = 0;
            Seg.(chnm).Intensity(cnt) = 0;
            Seg.(chnm).Area(cnt) = 0;
            Seg.(chnm).Perimeter(cnt) = 0;
            Seg.(chnm).AtoP(cnt) = 0;
            Seg.(chnm).Background(i) = 0;
         
            Seg.(chnm).Circularity(cnt)  =0;
            Seg.(chnm).Hu_mom1(cnt) =0;
            Seg.(chnm).Hu_mom2(cnt) =0;
            Seg.(chnm).Hu_mom3(cnt) =0;
            Seg.(chnm).Hu_mom4(cnt) =0;
            Seg.(chnm).Hu_mom5(cnt) =0;
            Seg.(chnm).Hu_mom6(cnt) =0;
            Seg.(chnm).Hu_mom7(cnt)=0;
            Seg.(chnm).Extension(cnt) = 0;
            Seg.(chnm).Dispersion(cnt) = 0;
            Seg.(chnm).Elongation(cnt) = 0;
            Seg.(chnm).Mean_Dist_to_closest_objs(cnt) =0;
            Seg.(chnm).Mean_Pixel_Dist(cnt)=0;
            Seg.(chnm).Max_Pixel_Dist(cnt) =0;
            Seg.(chnm).Min_Pixel_Dist(cnt)=0;
            Seg.(chnm).Std_Pixel_Dist(cnt) =0;
            Seg.(chnm).Min_Intensity(cnt) =0;
            Seg.(chnm).Max_Intensity(cnt) =0;
            Seg.(chnm).Std_Intensity(cnt) =0;
            Seg.(chnm).Mean_Gradient_Full(cnt)=0;
            Seg.(chnm).Min_Gradient_Full(cnt)=0;
            Seg.(chnm).Max_Gradient_Full(cnt) =0;
            Seg.(chnm).Std_Gradient_Full(cnt)=0;
        end
	cnt = cnt + 1;
    end
    t(i) = toc;
    str = sprintf('Time Estimate:%.2f sec',(size(seg_file,1)-i)*mean(t));
    waitbar(i/size(seg_file,1),hf,str);
end
close(hf)
hf = msgbox('Writing results...');


save([handles.expDir filesep 'Compiled Segmentation Results.mat'],'Seg')
Condition = {'Year','Month','Day','Hour','Min','Row','Col','ImNumber','cellId','Xposition','Yposition','Nuc_IntperA','NucArea','NucInt'};
tempMat = [];
tempMat = array2table([Seg.year,Seg.month,Seg.day,Seg.hour,Seg.min],'VariableNames',{Condition{1:5}}); 
tempMat = [tempMat, cell2table([cellstr(Seg.RW),cellstr(Seg.CL)],'VariableNames',{Condition{6:7}})];
tempMat = [tempMat, array2table([Seg.ImNum,Seg.cellId,Seg.xpos,Seg.ypos,Seg.Nuc_IntperA,Seg.NucArea,Seg.NucInt],'VariableNames',{Condition{8:14}})];
tempMat = [tempMat, array2table([Seg.Circularity,Seg.Hu_mom1,Seg.Hu_mom2,Seg.Hu_mom3,Seg.Hu_mom4,Seg.Hu_mom5,Seg.Hu_mom6,...
    Seg.Hu_mom7,Seg.Extension,Seg.Dispersion,Seg.Elongation,Seg.Mean_Dist_to_closest_objs,Seg.Mean_Pixel_Dist,Seg.Max_Pixel_Dist,Seg.Min_Pixel_Dist,Seg.Std_Pixel_Dist,Seg.Min_Intensity,...
    Seg.Max_Intensity,Seg.Std_Intensity,Seg.Mean_Gradient_Full,Seg.Min_Gradient_Full,Seg.Max_Gradient_Full,Seg.Std_Gradient_Full],'VariableNames',...
    {'Nuc_Circularity','Nuc_Hu_mom1','Nuc_Hu_mom2','Nuc_Hu_mom3','Nuc_Hu_mom4','Nuc_Hu_mom5','Nuc_Hu_mom6','Nuc_Hu_mom7','Extension','Dispersion','Elongation',...
    'Nuc_Mean_Dist_to_closest_objs','Nuc_Mean_Pixel_Dist','Nuc_Max_Pixel_Dist','Nuc_Min_Pixel_Dist','Nuc_Std_Pixel_Dist','Nuc_Min_Intensity','Nuc_Max_Intensity','Nuc_Std_Intensity',...
    'Nuc_Mean_Gradient_Full','Nuc_Min_Gradient_Full','Nuc_Max_Gradient_Full','Nuc_Std_Gradient_Full'})];
        
for q = 1:handles.numCh
    chnm = ['CH_' num2str(q)];
    Condition = {Condition{:}, [chnm '_IntperA'],[chnm '_Intensity'],[chnm '_Area'],[chnm '_Perimeter'],[chnm '_AtoP']};
    tempMat = [tempMat, array2table([Seg.(chnm).IntperA,Seg.(chnm).Intensity,Seg.(chnm).Area,Seg.(chnm).Perimeter,Seg.(chnm).AtoP],'VariableNames',{Condition{(q-1)*5+15:q*5+14}})];
    
    SegCond =  {[chnm '_Circularity'],[chnm '_Hu_mom1'],[chnm '_Hu_mom2'],[chnm '_Hu_mom3'],[chnm '_Hu_mom4'],[chnm '_Hu_mom5'],[chnm '_Hu_mom6'],[chnm '_Hu_mom7'],...
    [chnm '_Extension'],[chnm '_Dispersion'],[chnm '_Elongation'],[chnm '_Mean_Dist_to_closest_objs'],...
    [chnm '_Mean_Pixel_Dist'],[chnm '_Max_Pixel_Dist'],[chnm '_Min_Pixel_Dist'],[chnm '_Std_Pixel_Dist'],[chnm '_Min_Intensity'],[chnm '_Max_Intensity'],[chnm '_Std_Intensity'],...
    [chnm '_Mean_Gradient_Full'],[chnm '_Min_Gradient_Full'],[chnm '_Max_Gradient_Full'],[chnm '_Std_Gradient_Full']};

    tempMat = [tempMat, array2table([Seg.(chnm).Circularity,Seg.(chnm).Hu_mom1,Seg.(chnm).Hu_mom2,Seg.(chnm).Hu_mom3,Seg.(chnm).Hu_mom4,Seg.(chnm).Hu_mom5,Seg.(chnm).Hu_mom6,...
    Seg.(chnm).Hu_mom7,Seg.(chnm).Extension,Seg.(chnm).Dispersion,Seg.(chnm).Elongation,Seg.(chnm).Mean_Dist_to_closest_objs,Seg.(chnm).Mean_Pixel_Dist,Seg.(chnm).Max_Pixel_Dist,Seg.(chnm).Min_Pixel_Dist,Seg.(chnm).Std_Pixel_Dist,Seg.(chnm).Min_Intensity,...
    Seg.(chnm).Max_Intensity,Seg.(chnm).Std_Intensity,Seg.(chnm).Mean_Gradient_Full,Seg.(chnm).Min_Gradient_Full,Seg.(chnm).Max_Gradient_Full,Seg.(chnm).Std_Gradient_Full],'VariableNames',SegCond)];  
end

Condition = {Condition{:},'Class_Nucleus','Class_Debris','Class_Over','Class_Under','Class_Predivision','Class_Postdivision','Class_Newborn','Class_Apoptotic','Class_Edge'};
tempMat = [tempMat, array2table([Seg.class.nucleus,Seg.class.debris,Seg.class.over,Seg.class.under,Seg.class.predivision,Seg.class.postdivision,Seg.class.mitotic,Seg.class.apoptotic,Seg.class.edge],'VariableNames',{Condition{(handles.numCh)*5+15:end}})];
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
