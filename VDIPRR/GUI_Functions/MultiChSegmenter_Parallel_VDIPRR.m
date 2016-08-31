function [] = MultiChSegmenter_Parallel_VDIPRR(handles)

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
sample = 1:2:length(handles.im_file);
parfor_progress(length(sample),[],[]);ParallelPoolInfo = Par(length(sample));
%For all images
totCell = zeros(length(sample),1);totIm=length(sample);
sample = 1:2:length(handles.im_file);
parfor i = 1:length(sample)
    Par.tic;
    %Send to segmenter code
    [CO,nucIm] = NaiveSegment_VDIPRR_v1(handles,sample(i))
    totCell(i) = CO.ImData.cellCount
    %Save segmentation in a directory called segmented
    %Call a function to be able to save result
    parforsaverGUI_VDIPRR(CO,handles.expDir)    
    ParallelPoolInfo(i) = Par.toc
    %Update the status of the segmentation.
    parfor_progress([],ParallelPoolInfo(i).ItStop-ParallelPoolInfo(i).ItStart,i);
end
stop(ParallelPoolInfo)
parfor_progress(0,[],[]);
fid = fopen([handles.expDir filesep 'Segmented/NumDetect_Im.txt'], 'w');
fprintf(fid, 'Detection_Count\t%d\tImage_Number\t%d',sum(totCell)+sum(totCell==0),totIm);
fclose(fid);
end

