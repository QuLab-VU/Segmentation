function [handles] =  segmenterTestGUIv5(handles)
% Multi Channel Cell Segmentation with channel correction. Single figure generation 
%%Christian Meyer 11.30.16.  This is to test the segmentation parameters
h = msgbox('Please Be Patient, This box will close when operation is finished');
child = get(h,'Children');
delete(child(1)) 

%Send to segmenter code
[CO,Im_array] = NaiveSegmentV8(handles,handles.imNum);
%Plot the result
if ~handles.viewNuc && handles.numCh>0 %If you want channels other than the nuclear one
    p       = regionprops(CO.label,'PixelIdxList');
    sz      = size(CO.label);
    tempIm  = zeros(sz(1),sz(2),3);
    cnt     = 1;
    col     = jet(length(p));
    randIdx = randperm(length(p));
    for i = 1:length(p)
        [x,y] = ind2sub(size(CO.label),p(i).PixelIdxList);
        for j = 1:length(x)
            tempIm(x(j),y(j),:) = col(randIdx(i),:);
        end
        cnt = cnt+1;
    end
    axes(handles.axes1)
    imshowpair(Im_array(:,:,handles.ChtoSeg+1),tempIm,'blend','Scaling','independent')
    %If you want to plot the integrated intensity on the image
    % hold on
    % if handles.ChtoSeg > 0
    % chnm = ['CH_' num2str(handles.ChtoSeg)];
    %     for i = 1:CO.cellCount
    %       str = sprintf('%.0f',CO.CData.Nuc.Mean_Intensity);
    %       text(CO.CData.Centroid(i,1),CO.CData.Centroid(i,2),str,'color', [1,1,1])
    %     end
    % end
    % figure()
    % hist(CO.(chnm).Intensity./CO.(chnm).Area)
else %View the nuclear segmentation
    p           = regionprops(CO.Nuc_label,'PixelIdxList');
    sz          = size(CO.Nuc_label);
    tempIm      = zeros(sz(1),sz(2),3);
    cnt         = 1;
    col         = jet(length(p));
    randIdx     = randperm(length(p));
    for i = 1:length(p)
        [x,y] = ind2sub(size(CO.Nuc_label),p(i).PixelIdxList);
        for j = 1:length(x)
            tempIm(x(j),y(j),:) = col(randIdx(i),:);
        end
        cnt = cnt+1;
    end
    axes(handles.axes1)
    imshowpair(Im_array(:,:,handles.ChtoSeg+1),tempIm,'blend','Scaling','independent')
    %If you want to plot the integrated intensity on the image
    % hold on
    % if handles.ChtoSeg > 0
    % chnm = ['CH_' num2str(handles.ChtoSeg)];
    %     for i = 1:CO.cellCount
    %       str = sprintf('%.0f',CO.CData.Nuc.Mean_Intensity);
    %       text(CO.CData.Centroid(i,1),CO.CData.Centroid(i,2),str,'color', [1,1,1])
    %     end
    % end
    % figure()
    % hist(CO.(chnm).Intensity./CO.(chnm).Area)
end
handles.tempIm = tempIm;
handles.cur_im = squeeze(Im_array(:,:,handles.ChtoSeg+1));
close(h)
%save('tempHandles.mat','handles')


