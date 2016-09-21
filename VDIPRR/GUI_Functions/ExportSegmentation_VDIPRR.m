function [handles] = ExportSegmentation_VDIPRR(handles)
%Function for exporting the data after segmentation.
%Cell Events.csv contains each cell's data
%Image Events is a summary of each image segmented
%Handles.mat contains handle to the segmenter and all the parameters
%Processing Parameters.csv contains all the segmentation parameters used
    
%Open resulting segmentation
seg_file = dir([handles.expDir filesep 'Segmented' filesep '*.mat']);
%Open a text file that was written as the segmentation was being run that
%counted the number of cells in each image to allow for preallocating the
%total number of cells
fid = fopen([handles.expDir filesep 'Segmented' filesep 'NumDetect_Im.txt'], 'r');
if fid < 0
    error('Cannot open file with cell count'); 
end
data = textscan(fid,'%s %d %s %d','delimiter','\t');
handles.totCell = double(data{2});
handles.totIm = double(data{4});
mkdir([handles.expDir filesep 'Results']);

%Reorder the files. Necessary because of matlabs strange numbering scheme
to_order = [];
for j = 1:length(seg_file)
        temp_id = strfind(seg_file(j).name,'.');
        to_order(end+1) = str2double(seg_file(j).name(1:temp_id-1));
end
[~, reorder_id] = sort(to_order,'ascend');
seg_file = seg_file(reorder_id);

%Creaste the two tables
for i = 1:length(seg_file)
    load([handles.expDir filesep 'Segmented' filesep seg_file(i).name])
    if i == 1
        T_CellData  = struct2table(CO.CData);
        T_ImData    = struct2table(CO.ImData);
    else
        T_CellData = [T_CellData; struct2table(CO.CData)];
        T_ImData   = [T_ImData; struct2table(CO.ImData)];
    end
end

%Count FUCCI+ cells using a gaussian mixed model
GM = fitgmdist(T_CellData.CytoInt,2);
class = cluster(GM,T_CellData.CytoInt);
[~, id] = max(GM.mu);
T_CellData.FUCCI_pos = zeros(size(T_CellData,1),1);
T_CellData.FUCCI_pos(class==id) = 1;
T_ImData.FUCCIcnt = zeros(size(T_ImData,1),1);
[images, ~, ilx] = unique(T_CellData.ImName);
for i = 1:length(images)
    cnt = 1;
    while 1
        bool = strcmp(T_ImData.ImName(cnt,:),char(images{i}));
        if bool
            break;
        end
        cnt = cnt + 1;
    end
    T_ImData.FUCCIcnt(cnt) = sum(ilx==i & T_CellData.FUCCI_pos);
end
% 
% % %Make 2 quick plots
%  h = figure()
%  plot(1:size(T_ImData,1),T_ImData.FUCCIcnt)
%  hold on
%  plot(1:size(T_ImData,1),T_ImData.cellCount)
%  xlabel('pseudo-time');ylabel('Raw Count')
%  set(gca,'fontsize',18)
%  saveas(gcf,[handles.expDir filesep 'Results' filesep 'CellCountPlot.png'])
%  x = log(T_CellData.CytoInt);
%  [F1,XI1] = ksdensity(x(class==1));
%  [F2,XI2] = ksdensity(x(class==2));
%  plot(XI1,F1,XI2,F2,'linewidth',4)
%  xlabel('log(FUCCI mean intensity)')
% 
% cellMat = table2array(T_CellData(:,[1:24,28:38]));
% cellMat(find(isinf(cellMat)))=0;
% [COEFF, SCORE] = pca(cellMat);
% mappedX = fast_tsne(cellMat,2,30);
% figure()
% plot(mappedX(:,1),mappedX(:,2),'.')

%Write tables
writetable(T_CellData,[handles.expDir filesep 'Results' filesep  'Cell_Events.csv'])
writetable(T_ImData, [handles.expDir filesep 'Results' filesep 'Image_Events.csv'])


ImageParameter = {'Nuclear_Segmentation_Level','Split_Nuclei','Noise_Filter_Nucleus',...
    'Segmentation_Smoothing_Factor'};
tempMat_SegParameters = array2table([handles.NucnumLevel,handles.NucSegHeight,handles.nuc_noise_disk,...
handles.smoothing_factor],'VariableNames',ImageParameter);
tempMat_SegParameters.Experiment_Directory = handles.masterDir;
tempMat_SegParameters.Image_Ext = handles.imExt;
tempMat_SegParameters.Date = date;
tempMat_SegParameters.BackCorrMethod = handles.BackCorrMethod;
%Correct Image:
switch handles.BackCorrMethod
    case 'CIDRE'
        tempMat_SegParameters.Cidre_Directory = handles.cidreDir;
    case 'RollBallFilter'
        tempMat_SegParameters.RollingFilter = handles.rollfilter;
    case 'ConstThresh'
        tempMat_SegParameters.ConstantThresh = handles.back_thresh;
    case 'ImageSub'
        tempMat_SegParameters.ImageSubFile = handles.CorrIm_File;
end

writetable(tempMat_SegParameters,[handles.expDir filesep 'Results' filesep 'Processing Parameters.csv']);
%save([handles.expDir filesep 'Results' filesep 'Compiled Segmentation Results.mat'],'T_CellData','T_ImData','handles')
end
