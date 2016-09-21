function [] =  segmenterTestGUI_VDIPRR(handles)
% Multi Channel Cell Segmentation with channel correction. Single figure generation 
%%Christian Meyer 10.22.15.  This is to test the segmentation parameters
h = msgbox('Please Be Patient, This box will close when operation is finished');
%save('Handles.mat','handles')
child = get(h,'Children');
delete(child(1)) 
im = handles.imNum;
%Send to segmenter code;
[CO,nucIm] = NaiveSegment_VDIPRR_v1(handles,im);
CO.ImData.filename
%hf = figure('Visible','on')

%Plot the result
axes(handles.axes1)
nucIm = nucIm.^(1/handles.contrast); nucIm = nucIm./max(nucIm(:));
imshow(nucIm,[]); hold on;
properties = regionprops(CO.Nuc_label,'PixelIdxList','BoundingBox');
col = jet(length(properties));
rndIdx = randperm(length(properties));
x_tot = []; y_tot = [];group = [];
for i = 1:length(properties)
    tempIm = zeros(properties(i).BoundingBox(4),properties(i).BoundingBox(3));
    [y,x] = ind2sub(size(nucIm),properties(i).PixelIdxList);
    y = y-properties(i).BoundingBox(2)+.5; x = x-properties(i).BoundingBox(1)+.5;
    tempIm(sub2ind(size(tempIm),y,x)) = 1;
    BW = bwperim(tempIm);
    [y,x] = ind2sub(size(tempIm),find(BW));
    x = x + properties(i).BoundingBox(1)-.5;y = y+properties(i).BoundingBox(2)-.5; 
    x_tot = [x_tot;x]; y_tot = [y_tot;y];
    group = [group;repmat(i,length(x),1)];
end
for i = 1:length(properties)
    idx = group==i;
    plot(x_tot(idx),y_tot(idx),'.','MarkerSize',.1,'Color',col(rndIdx(i),:))
end
%gscatter(x_tot,y_tot,group,col(rndIdx,:),'',.1,'off');
set(gca,'XLabel',[],'YLabel',[])
try
    close(h)
end
%save('tempHandles.mat','handles')

