function [handles] = InitializeHandles_VDIPRR(handles)
handles.imExt = get(findobj('Tag','edit6'),'String');
handles.numCh = str2double(get(findobj('Tag','edit4'),'String'));
handles.NucnumLevel = str2double(get(findobj('Tag','edit11'),'String'));
handles.Parallel = get(findobj('Tag','checkbox6'),'Value');

handles.smoothing_factor = str2double(get(findobj('Tag','edit10'),'String'));
handles.nuc_noise_disk = str2double(get(findobj('Tag','edit15'),'String'));
handles.cidrecorrect = (get(findobj('Tag','checkbox1'),'Value'));
if isempty(handles.CorrIm_file)
    msgbox('Error: No Control Image Selected')
    return
end
handles.background_corr = get(findobj('Tag','checkbox9'),'Value');
handles.back_thresh = get(findobj('Tag','slider4'),'Value');
handles.thresh_based_bin = get(findobj('Tag','checkbox10'),'Value');

mkdir([handles.expDir filesep 'Results']);
%Set up structure with the filenames of the images to be segmented
%Nuclei Directory (N)
%A lot of messy code to set up the file structure depending on whether it
%is the bd pathway or cellavista instrument.
str = sprintf('*%s',handles.imExt);
im_filnm = dir([handles.expDir filesep str]);
to_remove = zeros(length(im_filnm),1);
for j = 1:length(im_filnm)
    if ~isempty(findstr(im_filnm(j).name,'Thumb_'))
        to_remove(j) = 1;
    end
end
im_filnm = im_filnm(to_remove~=1);
to_order = [];
for j = 1:length(im_filnm)
        temp_id = strfind(im_filnm(j).name,'.');
        to_order(end+1) = str2double(im_filnm(j).name(1:temp_id-1));
end
im_filnm = im_filnm(to_remove~=1);
[~, reorder_id] = sort(to_order,'ascend');
im_filnm = im_filnm(reorder_id);
for j = 1:length(im_filnm)
    im_filnm(j).name = strcat(handles.expDir, filesep, im_filnm(j).name);
end
handles.im_file = im_filnm;

 
if (handles.cidrecorrect)
   handles.CIDREmodel.v = csvread([handles.cidreDir filesep 'cidre_model_v.csv']);
   handles.CIDREmodel.z = csvread([handles.cidreDir filesep 'cidre_model_z.csv']);
end  
