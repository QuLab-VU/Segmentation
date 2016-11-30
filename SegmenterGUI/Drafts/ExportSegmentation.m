function [handles] = ExportSegmentation(handles)
%Function for exporting the data after segmentation.
%Cell Events.csv contains each cell's data
%Image Events is a summary of each image segmented
%Handles.mat contains handle to the segmenter and all the parameters
%Processing Parameters.csv contains all the segmentation parameters used

seg_file = dir([handles.expDir filesep 'Segmented/*.mat']);

handles.numCh
%Open resulting segmentation
seg_file = dir([handles.expDir filesep 'Segmented_' handles.startdate filesep '*.mat']);
%Open a text file that was written as the segmentation was being run that
%counted the number of cells in each image to allow for preallocating the
%total number of cells
fid = fopen([handles.expDir filesep 'Segmented_' handles.startdate filesep 'NumDetect_Im.txt'], 'r');
if fid < 0
    error('Cannot open file with cell count'); 
end
data = textscan(fid,'%s %d %s %d','delimiter','\t');
handles.totCell = double(data{2});
handles.totIm = double(data{4});

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
    load([handles.expDir filesep 'Segmented_' handles.startdate filesep seg_file(i).name])
    if i == 1
        T_CellData  = struct2table(CO.CData);
        T_ImData    = struct2table(CO.ImData);
    else
        T_CellData = [T_CellData; struct2table(CO.CData)];
        T_ImData   = [T_ImData; struct2table(CO.ImData)];
    end
end

writetable(T_CellData,[handles.expDir filesep 'Results_' handles.startdate filesep  'Cell_Events.csv'])
writetable(T_ImData, [handles.expDir filesep 'Results_' handles.startdate filesep 'Image_Events.csv'])

ImageParameter = {'Number_Flourescent_Channels_ex_Nuc','Nuclear_Segmentation_Level','Cytoplasm_Segmentation_Level'...
    'Split_Nuclei','Noise_Filter_Cytoplasm','Noise_Filter_Nucleus','Segmentation_Smoothing_Factor',...
    'Segment_by_Nuclear_Dilation','Nuclear_Dilation_Factor','Segment_Cell_Surface',...
    'Cell_Surface_Dilation_Factor','Clear_Border_Cells','BD_pathway_exp','Reduced_ParameterSet'};
tempMat_SegParameters = array2table([handles.numCh,handles.NucnumLevel,handles.CytonumLevel,handles.NucSegHeight,handles.noise_disk,handles.nuc_noise_disk,...
handles.smoothing_factor,handles.nuclear_segment,...
handles.nuclear_segment_factor,handles.surface_segment,handles.surface_segment_factor,...
handles.cl_border,handles.bd_pathway,handles.ParmReduced],'VariableNames',ImageParameter);
tempMat_SegParameters.Experiment_Directory = handles.expDir;
tempMat_SegParameters.Image_Ext = handles.imExt;
tempMat_SegParameters.Date = date;
tempMat_SegParameters.BackCorrMethod = handles.BackCorrMethod;
%Correct Image:
switch handles.BackCorrMethod
    case 'CIDRE'
        tempMat_SegParameters.Cidre_Directory = handles.cidreDir;
    case 'Rolling_Ball'
        tempMat_SegParameters.RollingFilter = handles.rollfilter;
    case 'GainMap_Image'
        for q = 1:handles.numCh
            str = ['GainMap_', num2str(i)];
            tempMat_SegParameters.(str) = handles(q).CorrIm_file;
        end
    case 'Const_Threshold'
        tempMat_SegParameters.ConstantThresh = handles.back_thresh;
    case 'Control_Image'
        for q = 1:handles.numCh
            str = ['ControlImage_', num2str(i)];
            tempMat_SegParameters.(str) = handles(q).CorrIm_file;
        end
end
    

writetable(tempMat_SegParameters,[handles.expDir filesep 'Processing Parameters.csv']);

end