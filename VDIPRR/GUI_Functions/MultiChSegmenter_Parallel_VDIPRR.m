function [] = MultiChSegmenter_Parallel_VDIPRR(handles)

% Multi Channel Cell Segmentation with channel correction running parallel.  
%%Christian Meyer 9.19.16

h = msgbox('Please Be Patient, Segmenting Plate. See Command Window for estimate of time to completion for this plate');
child = get(h,'Children');
delete(child(1)) 


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
num_cores = feature('numCores');
parfor_progress(length(sample),[],[],[]);ParallelPoolInfo = Par(length(sample));
%For all images
totCell = zeros(length(sample),1);totIm=length(sample);
sample = 1:handles.numCh:length(handles.im_file);
parfor i = 1:length(sample)
    Par.tic;
    %Send to segmenter code
    [CO,nucIm] = NaiveSegment_VDIPRR_v1(handles,sample(i))
    totCell(i) = CO.ImData.cellCount
    %Save segmentation in a directory called segmented
    %Call a function to be able to save result
    parforsaverGUI_VDIPRR(CO,handles.startdate)    
    ParallelPoolInfo(i) = Par.toc
    %Update the status of the segmentation.
    parfor_progress([],ParallelPoolInfo(i).ItStop-ParallelPoolInfo(i).ItStart,i,num_cores);
end
stop(ParallelPoolInfo)
parfor_progress(0,[],[],[]);
%Write a text file to keep track of number of cells counted in each image
%for preallocation purposes in the export segmentation function.
fid = fopen([handles.expDir filesep 'Segmented_' handles.startdate filesep 'NumDetect_Im.txt'], 'w');
fprintf(fid, 'Detection_Count\t%d\tImage_Number\t%d',sum(totCell)+sum(totCell==0),totIm);
fclose(fid);
try
    close(h)
end
end