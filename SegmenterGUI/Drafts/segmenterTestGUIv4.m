function [] =  segmenterTestGUIv4(handles)
% Multi Channel Cell Segmentation with channel correction. Single figure generation 
%%Christian Meyer 10.22.15.  This is to test the segmentation parameters
h = msgbox('Please Be Patient, This box will close when operation is finished')
child = get(h,'Children');
delete(child(1)) 

im = handles.imNum;
imExt = handles.imExt;
cidrecorrect = handles.cidrecorrect;
NucnumLevel = handles.NucnumLevel;
CytonumLevel = handles.CytonumLevel;
surface_segment = handles.surface_segment;
nuclear_segment = handles.nuclear_segment;
nuclear_segment_factor = handles.nuclear_segment_factor;
surface_segment_factor = handles.surface_segment_factor;
cl_border = handles.cl_border;
noise_disk = handles.noise_disk;
nuc_noise_disk = handles.nuc_noise_disk;
smoothing_factor = handles.smoothing_factor;
numCh = handles.numCh;
NUC = handles.NUC;
Cyto = handles.Cyto;
%Segmentation height for nuclei in the watershed segmentation
NucSegHeight = handles.NucSegHeight;
%Background correction as oppose to CIDRE?
background_corr = handles.background_corr;
%File for background correction
CorrIm_file = handles.CorrIm_file;
%Is this a pathway experiment
bd_pathway = handles.bd_pathway;
%Binarize by threshold
thresh_based_bin = handles.thresh_based_bin;
%Threshold binarization
back_thresh = handles.back_thresh;

im_info = imfinfo(char(NUC.filnms(im)));
%Send to segmenter code
[CO,Im_array] = NaiveSegmentV7(cidrecorrect,NucnumLevel,CytonumLevel,surface_segment,...
    nuclear_segment,noise_disk,nuc_noise_disk,nuclear_segment_factor,surface_segment_factor,...
    smoothing_factor,NucSegHeight,numCh,NUC,Cyto,im,background_corr,CorrIm_file,bd_pathway,...
    back_thresh,thresh_based_bin,im_info);
%Plot the result
if ~handles.viewNuc
    p = regionprops(CO.label,'PixelIdxList');
    sz = size(CO.label);
    tempIm = zeros(sz(1),sz(2),3);
    cnt = 1;
    col = jet(length(p));
    randIdx = randperm(length(p));
    for i = 1:length(p)
        [x,y] = ind2sub(size(CO.label),p(i).PixelIdxList);
        for j = 1:length(x)
            tempIm(x(j),y(j),:) = col(randIdx(i),:);
        end
        cnt = cnt+1;
    end
    tempIm = imdilate(tempIm,strel('disk',5));
    axes(handles.axes1)
    imshowpair(Im_array(:,:,handles.ChtoSeg+1),tempIm,'blend','Scaling','independent')
    % hold on
    % if handles.ChtoSeg > 0
    % chnm = ['CH_' num2str(handles.ChtoSeg)];
    %     for i = 1:CO.cellCount
    %       str = sprintf('%.0f',CO.(chnm).Intensity(i)/CO.(chnm).Area(i));
    %       text(CO.Centroid(i,1),CO.Centroid(i,2),str,'color', [1,1,1])
    %     end
    % end
    % figure()
    % hist(CO.(chnm).Intensity./CO.(chnm).Area)
else
    p = regionprops(CO.Nuc_label,'PixelIdxList');
    sz = size(CO.Nuc_label);
    tempIm = zeros(sz(1),sz(2),3);
    cnt = 1;
    col = jet(length(p));
    randIdx = randperm(length(p));
    for i = 1:length(p)
        [x,y] = ind2sub(size(CO.Nuc_label),p(i).PixelIdxList);
        for j = 1:length(x)
            tempIm(x(j),y(j),:) = col(randIdx(i),:);
        end
        cnt = cnt+1;
    end
    tempIm = imdilate(tempIm,strel('disk',5));
    axes(handles.axes1)
    imshowpair(Im_array(:,:,handles.ChtoSeg+1),tempIm,'blend','Scaling','independent')
    % hold on
    % if handles.ChtoSeg > 0
    % chnm = ['CH_' num2str(handles.ChtoSeg)];
    %     for i = 1:CO.cellCount
    %       str = sprintf('%.0f',CO.(chnm).Intensity(i)/CO.(chnm).Area(i));
    %       text(CO.Centroid(i,1),CO.Centroid(i,2),str,'color', [1,1,1])
    %     end
    % end
    % figure()
    % hist(CO.(chnm).Intensity./CO.(chnm).Area)
end
close(h)
%save('tempHandles.mat','handles')


