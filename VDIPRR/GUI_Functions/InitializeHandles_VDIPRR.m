function [handles] = InitializeHandles_VDIPRR(handles)
%This function reads the segmentation parameters from each widget into a
%structure passed to the segmentation functions called handles
handles.imExt = get(handles.edit6,'String');
handles.NucnumLevel = str2double(get(handles.edit11,'String'));
handles.Parallel = get(handles.checkbox6,'Value');

%Which background correction method?
switch handles.BackCorrMethod
    case 'RollBallFilter'
        handles.rollfilter = str2double(get(handles.edit18,'String'));
    case 'ConstThresh'
        handles.back_thresh = get(handles.slider4,'Value');
    case 'ImageSub'
        if isempty(handles.CorrIm_file)
            msgbox('Error: No Control Image Selected')
            return
        end
    case 'CIDRE'
        if isempty(handles.cidreDir)
            msgbox('Error: No CIDRE Directory Selected')
            return
        end        
        handles.CIDREmodel.v = csvread([handles.cidreDir filesep 'cidre_model_v.csv']);
        handles.CIDREmodel.z = csvread([handles.cidreDir filesep 'cidre_model_z.csv']);
end


handles.smoothing_factor = str2double(get(handles.edit10,'String'));
handles.nuc_noise_disk = str2double(get(handles.edit15,'String'));


%Set up structure with the filenames of the images to be segmented
%Nuclei Directory (N)
%A lot of messy code to set up the file structure as matlab reorders images
%sometimes.
str = sprintf('*%s',handles.imExt);
im_filnm = dir([handles.expDir filesep str]);
to_remove = zeros(length(im_filnm),1);
for j = 1:length(im_filnm)
    if ~isempty(findstr(im_filnm(j).name,'Thumb_'))  %This is to remove all the thumbnail images in the folder from list to segment
        to_remove(j) = 1;
    end
end
im_filnm = im_filnm(to_remove~=1);
%This corrects for matlabs ordering where 100.jpg comes before 9.jpg
to_order = [];
for j = 1:length(im_filnm)
        temp_id = strfind(im_filnm(j).name,'.');
        to_order(end+1) = str2double(im_filnm(j).name(1:temp_id-1));
end
[~, reorder_id] = sort(to_order,'ascend');
im_filnm = im_filnm(reorder_id);
for j = 1:length(im_filnm)
    im_filnm(j).name = strcat(handles.expDir, filesep, im_filnm(j).name);
end
handles.im_file = im_filnm;

[handles] = plateInfo_reader(handles);
handles.numCh = length(unique(handles.FileInfo.SOURCE_ILLUMINATION));