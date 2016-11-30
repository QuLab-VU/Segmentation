function [] = MultiChSegmenterV19GUI(handles)

% Multi Channel Cell Segmentation with channel correction.  
%%Christian Meyer 12.1.16 christian.t.meyer@vanderbilt.edu
%Segmentation code to find the intensities per cell of the each channel for
%a series of images from the CellaVista presorted with the
%cellaVistaFileSorter or from the BD Pathway
%Option for segmenting just the surface of the cell or segmenting based on
%the nucleus by adding a dilated nuclear channel to the cytoplasmic
%segmentation.
%The intensity, area, and nuclear and cytoplasmic labels are stored in a structure which is saved to
%a folder called Segemented with the row, channel, and image number in the name.

h = msgbox('Please Be Patient, This box will close when operation is finished. See Command Window for estimate of time to completion');
child = get(h,'Children');
delete(child(1)) 

%Make a directory for the segemented files
mkdir([handles.expDir filesep 'Segmented'])

%Segmentation occurs in multiple steps
%First nuclei are segmented using Otsu's method to determine background in 
%the nuclear channel.  The image is quantized into multiple tiers with all
%but the lowest being assigned as nucleus to account for nuclei slightly
%less brigth or out of focus
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
parfor_progress(max(size(handles.NUC.filnms)),[],[],[]);ParallelPoolInfo = Par(max(size(handles.NUC.filnms)));
num_cores = feature('numCores');
%For all images
totCell = zeros(max(size(handles.NUC.filnms)),1);totIm=max(size(handles.NUC.filnms));
parfor i = 1:max(size(handles.NUC.filnms))
    Par.tic;
    %Send to segmenter code
    [CO,Im_array] = NaiveSegmentV8(handles,i);
    totCell(i) = CO.ImData.cellCount
    %Save segmentation in a directory called segmented
    %Call a function to be able to save result
    parforsaverGUI(CO.ImData.rw,CO.ImData.cl,CO,i,handles.expDir)
    ParallelPoolInfo(i) = Par.toc
    %Update the status of the segmentation.
    parfor_progress([],ParallelPoolInfo(i).ItStop-ParallelPoolInfo(i).ItStart,i,num_cores);
end
stop(ParallelPoolInfo)
parfor_progress(0,[],[],[]);
fid = fopen([handles.expDir filesep 'Segmented/NumDetect_Im.txt'], 'w');
fprintf(fid, 'Detection_Count\t%d\tImage_Number\t%d',sum(totCell)+sum(totCell==0),totIm);
fclose(fid);
end

