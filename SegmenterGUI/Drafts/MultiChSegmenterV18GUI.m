function [] = MultiChSegmenterV18GUI(handles)

% Multi Channel Cell Segmentation with channel correction.  
%%Christian Meyer 12.30.15
%Segmentation code to find the intensities per cell of the each channel for
%a series of images from the CellaVista presorted with the
%cellaVistaFileSorter.
%Option for segmenting just the surface of the cell or segmenting based on
%the nucleus by adding a dilated nuclear channel to the cytoplasmic
%segmentation.
%All functionality assumes images have been separated into separate 
%Channels useing cellaVistaFileSorter.m
%Segmentation of all channels for each image based on nuclear image.
%First nuclei are segmented.  Then each cytoplasmic channel is segmented and 
%added together to come up with a final cytoplamsic bw image
%Finally the cytoplasmic bw image is segmented using a k-nearest neighbor algorithm to
%predict each pixel's respective nuclei.
%The intensity, area, and nuclear and cytoplasmic labels are stored in a structure which is saved to
%a folder called Segemented with the row, channel, and image number in the name.

h = msgbox('Please Be Patient, This box will close when operation is finished. See Command Window for estimate of time to completion');
child = get(h,'Children');
delete(child(1)) 

imExt                   = handles.imExt;
%experiment Directory
expDir                  = handles.expDir;
%Whether to correct with cidrecorrect
cidrecorrect            = handles.cidrecorrect;
%Number of levels used in otsu's method of thresholding
NucnumLevel             = handles.NucnumLevel;
CytonumLevel            = handles.CytonumLevel;
%Segment the surface
surface_segment         = handles.surface_segment;
%Segment by dilating the nucleus
nuclear_segment         = handles.nuclear_segment;
nuclear_segment_factor  = handles.nuclear_segment_factor;
surface_segment_factor  = handles.surface_segment_factor;
%Clear cells touching border?
cl_border               = handles.cl_border;
%Noise disk 5 for 20x 10 for 40X
noise_disk              = handles.noise_disk;
%NOise disk for nuclei
nuc_noise_disk          = handles.nuc_noise_disk;
%Smoothing factor for cytoplasm segmentation.  (-) means to erode image
smoothing_factor        = handles.smoothing_factor;
%Number of channels in the image
numCh                   = handles.numCh;
%Segmentation height for nuclei in the watershed segmentation
NucSegHeight            = handles.NucSegHeight;
%Structure to hold the filenames and segmentation results
NUC                     = handles.NUC;
Cyto                    = handles.Cyto;
%Background correction as oppose to CIDRE?
background_corr         = handles.background_corr;
%File for background correction
CorrIm_file             = handles.CorrIm_file;
%Is this a pathway experiment
bd_pathway              = handles.bd_pathway;
%Binarize by threshold
thresh_based_bin        = handles.thresh_based_bin;
%Threshold binarization
back_thresh             = handles.back_thresh;

%Make a directory for the segemented files
mkdir([handles.expDir filesep 'Segmented'])

%Segmentation occurs in multiple steps
%First nuclei are segmented using Otsu's method to determine background in 
%the nuclear channel.  The image is quantized into three tiers with the top
%two being assigned as nucleus (nucleus in focus and nucleus out of focus)
% Use of a watershed segmentation algorithm then assigns a label to each
% cell
%Each of the fluorescent channels are then binarized, added, and segmented.
%The intensity in each channel for each cell is then subsequently measured.
%Subsequent use of a noise filter and hole filling smooths out the image and
%then use of a watershed segmentation to label all the cells.
%The label for the cell's cytoplasm is determined using a
%kmeans nearest neighbor algorithm from each nucleus
%Each segmented image is saved in a Segmentation folder.


%Initialize functions involved in parallel computing
%Parfor_progress allows for an estimation of the amount of time remaining
%in each segmentation
%Par() is a class variable which records information about the parallel
%processing session and allows the measurement of time to complete each
%iteration.
%Both have been adapted from online code.
% http://www.mathworks.com/matlabcentral/fileexchange/32101-progress-monitor--progress-bar--that-works-with-parfor
% http://www.mathworks.com/matlabcentral/fileexchange/27472-partictoc/content/Par.m
% Respectively
parfor_progress(size(NUC.filnms,2),[],[],[]);ParallelPoolInfo = Par(size(NUC.filnms,2));
num_cores = feature('numCores');
%For all images
totCell = zeros(size(NUC.filnms,2),1);totIm=size(NUC.filnms,2);
parfor i = 1:size(NUC.filnms,2)
    Par.tic;
    im_info = imfinfo(char(NUC.filnms(i)));
    %Send to segmenter code
    [CO,Im_array] = NaiveSegmentV7(cidrecorrect,NucnumLevel,CytonumLevel,surface_segment,...
    nuclear_segment,noise_disk,nuc_noise_disk,nuclear_segment_factor,surface_segment_factor,...
    smoothing_factor,NucSegHeight,numCh,NUC,Cyto,i,background_corr,CorrIm_file,bd_pathway,...
    back_thresh,thresh_based_bin,im_info);
    
    totCell(i) = CO.cellCount
    %Save segmentation in a directory called segmented
    %Call a function to be able to save result
    parforsaverGUI(CO.rw,CO.cl,CO,i,expDir)
    ParallelPoolInfo(i) = Par.toc
    %Update the status of the segmentation.
    parfor_progress([],ParallelPoolInfo(i).ItStop-ParallelPoolInfo(i).ItStart,i,num_cores);
    %save(['Segmented/' rw '_' cl '_' num2str(i) '.mat'], 'CO')
    %Delete the stored variables... Not sure if this is necessary
    CO=structfun(@(f)[] ,CO,'uni',0);
    Im_array = [];
end
stop(ParallelPoolInfo)
parfor_progress(0,[],[],[]);
fid = fopen([expDir filesep 'Segmented/NumDetect_Im.txt'], 'w');
fprintf(fid, 'Detection_Count\t%d\tImage_Number\t%d',sum(totCell)+sum(totCell==0),totIm);
fclose(fid);
end

