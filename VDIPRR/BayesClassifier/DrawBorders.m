function [T,CO] = DrawBorders(handles,im_idx,seg_file,ax1,CO,contrast)
global classMat
global classLabel
global im_cell_id

axes(ax1);cla;
%Load the segmentation structure
load([handles.expDir filesep 'Segmented/' seg_file(im_idx).name]);
im = double(imread(char(CO.filename)));
T = struct2table(CO.Nuc);
if size(im,3)~=1
    im = rgb2gray(im);
end
im = im.^(1/contrast);
im = im./max(im(:));
imshow(im,[]); hold on;

properties = regionprops(CO.Nuc_label,'BoundingBox','PixelIdxList');
for j = 1:length(properties)
    tempIm = zeros(properties(j).BoundingBox(4),properties(j).BoundingBox(3));
    [y,x] = ind2sub(size(im),properties(j).PixelIdxList);
    y = y-properties(j).BoundingBox(2)+.5; x = x-properties(j).BoundingBox(1)+.5;
    tempIm(sub2ind(size(tempIm),y,x)) = 1;
    BW = bwperim(tempIm);
    BW = imdilate(tempIm,strel('disk',2));
    [y,x] = find(BW);
    x = x + properties(j).BoundingBox(1)-.5;y = y+properties(j).BoundingBox(2)-.5;
    [loc, id] = ismember([im_idx,j],im_cell_id,'rows');
    if loc==1
        switch classLabel{id}
            case 'over'
                gscatter(x,y,[],'g','.',2);
            case 'under'
                gscatter(x,y,[],'m','.',2);
            case 'nuc'
                gscatter(x,y,[],'c','.',2);
            case 'apo'
                gscatter(x,y,[],'r','.',2);
            case 'mito'
                gscatter(x,y,[],'b','.',2);
            case 'junk'
                gscatter(x,y,[],'y','.',4);
            case 'newborn'
                gscatter(x,y,[],[161, 202, 241]./255,'.',2) %Baby blue
        end
    else
        gscatter(x,y,[],'w','.',2);
    end
end
set(gca,'XLabel',[],'YLabel',[])

