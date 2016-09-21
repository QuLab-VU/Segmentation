function [] = MultiChSegmentNoParallel_VDIPRR(handles)

% Multi Channel Cell Segmentation
%%Christian Meyer 9.19.16
%Segmentation code to count nuclei
%Segmentation of stain channels for each image based on nuclear image.

h = msgbox('Please Be Patient, This box will close when operation is finished. See Command Window for estimate of time to completion');
filnames = dir([handles.expDir filesep 'Segmented']); temp = [];
if length(filnames)>2
    for i = 3:length(filnames)
        temp{i-2} = filnames(i).name(9:strfind(filnames(i).name,'.')-1);
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
    save([handles.expDir filesep 'Segmented' filesep CO.filename '.mat'], 'CO')
    t(i) = toc;
    fprintf('%.2f%% Complete, Estimated Time: %.2f\n',i/length(unfinishedImages)*100,mean(t)/60*(length(unfinishedImages)-i))
end
fid = fopen([handles.expDir filesep 'Segmented' filesep 'NumDetect_Im.txt'], 'w');
fprintf(fid, 'Detection_Count\t%d\tImage_Number\t%d',sum(totCell)+sum(totCell==0),totIm);
fclose(fid);
try
    close(h)
end




