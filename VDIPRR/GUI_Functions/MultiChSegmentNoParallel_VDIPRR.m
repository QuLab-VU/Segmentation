function [] = MultiChSegmentNoParallel_VDIPRR(handles)

% Multi Channel Cell Segmentation with channel correction without parallel loop 
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

filnames = dir([expDir '/Segmented']); temp = [];
if length(filnames)>2
    for i = 3:length(filnames)
        temp{i-2} = filnames(i).name(9:strfind(filnames(i).name,'.')-1)
    end
    x = [1:length(handles.im_file)];
    y = sort(str2double(temp));
    unfinishedImages = x(~ismember(x,y));
else
    unfinishedImages = 1:length(handles.im_file);
end

%For all images
totCell = zeros(length(handles.im_file),1);totIm=length(handles.im_file);
for i = 1:2:size(unfinishedImages,2)
    tic
    im = unfinishedImages(i);
    [CO,nucIm] = NaiveSegment_VDIPRR_v1(handles,im);
    totCell(i) = CO.ImInfo.cellCount;
    %Save segmentation in a directory called segmented
    %Call a function to be able to save result
    save([expDir filesep 'Segmented/' CO.filename '.mat'], 'CO')
    t(i) = toc;
    fprintf('%.2f%% Complete, Estimated Time: %.2f\n',i/length(unfinishedImages)*100,mean(t)/60*(length(unfinishedImages)-i))
end
fid = fopen([handles.expDir filesep 'Segmented/NumDetect_Im.txt'], 'w');
fprintf(fid, 'Detection_Count\t%d\tImage_Number\t%d',sum(totCell)+sum(totCell==0),totIm);
fclose(fid);
close(h)




