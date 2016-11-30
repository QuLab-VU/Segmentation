function [] = MultiChSegmentNoParallel(handles)

% Multi Channel Cell Segmentation with channel correction without parallel loop 
%%Christian Meyer 12.1.16

h = msgbox('Please Be Patient, This box will close when operation is finished. See Command Window for estimate of time to completion');
child = get(h,'Children');
delete(child(1)) 

%Make a directory for the segemented files
mkdir([handles.expDir filesep 'Segmented'])

%If there was an error leaving the folder unfinished used this commented
%code to finish it.
% filnames = dir([expDir '/Segmented']); temp = [];
% if length(filnames)>2
%     for i = 3:length(filnames)
%         id = strfind(filnames(i).name,'.');
%         temp{i-2} = filnames(i).name(9:id(end)-1)
%     end
%     x = [1:length(handles.NUC.filnms)];
%     y = sort(str2double(temp));
%     unfinishedImages = x(~ismember(x,y));
% else
%     unfinishedImages = 1:length(handles.NUC.filnms);
% end
%For all images
totCell = zeros(max(size(handles.NUC.filnms)),1);totIm = max(size(handles.NUC.filnms));
t = zeros(max(size(handles.NUC.filnms)),1);
for i = 1:max(size(handles.NUC.filnms))
    tic
    %Send to segmenter code
    [CO,Im_array] = NaiveSegmentV8(handles,i);
    totCell(i) = CO.ImData.cellCount;
    %Save segmentation in a directory called segmented
    %Call a function to be able to save result
    save([handles.expDir '/Segmented/' CO.ImData.rw '_' CO.ImData.cl '_' num2str(i) '.mat'], 'CO')
    t(i) = toc;
    str = sprintf('%.2f%% Complete, Estimated Time: %.2f\n',[i/max(size(handles.NUC.filnms))*100,mean(t(1:i))/60*((max(size(handles.NUC.filnms)))-i)]);
    disp(str);
end
fid = fopen([handles.expDir filesep 'Segmented/NumDetect_Im.txt'], 'w');
fprintf(fid, 'Detection_Count\t%d\tImage_Number\t%d',sum(totCell)+sum(totCell==0),totIm);
fclose(fid);
close(h)
end



