function [] =  segmenterTestGUI_VDIPRR(handles)
% Multi Channel Cell Segmentation with channel correction. Single figure generation 
%%Christian Meyer 10.22.15.  This is to test the segmentation parameters
h = msgbox('Please Be Patient, This box will close when operation is finished');
child = get(h,'Children');
delete(child(1)) 
im = handles.imNum;
%Send to segmenter code;
[CO,nucIm] = NaiveSegment_VDIPRR_v1(handles,im);
CO.ImData.filename
%Plot the result
axes(handles.axes1)
nucIm = nucIm.^(1/handles.contrast); nucIm = nucIm./max(nucIm(:));
imshow(nucIm,[]); hold on;
properties = regionprops(CO.Nuc_label,'PixelIdxList','BoundingBox');
col = jet(length(properties));
randIdx = randperm(length(properties));
for i = 1:length(properties)
    tempIm = zeros(properties(i).BoundingBox(4),properties(i).BoundingBox(3));
    [y,x] = ind2sub(size(nucIm),properties(i).PixelIdxList);
    y = y-properties(i).BoundingBox(2)+.5; x = x-properties(i).BoundingBox(1)+.5;
    tempIm(sub2ind(size(tempIm),y,x)) = 1;
    BW = bwperim(tempIm);
    [y,x] = ind2sub(size(tempIm),find(BW));
    x = x + properties(i).BoundingBox(1)-.5;y = y+properties(i).BoundingBox(2)-.5;    
    gscatter(x,y,[],col(randIdx(i),:),'',.1);
end
set(gca,'XLabel',[],'YLabel',[])
close(h)
%save('tempHandles.mat','handles')


