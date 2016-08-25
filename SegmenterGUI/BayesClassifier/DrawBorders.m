function [] = DrawBorders(handles,im_idx,seg_file,im_cell_id,classLabel,ax1,ax2,CO,num_nuc,num_apo,num_over,num_under,num_mito)
axes(ax1);cla;
%Load the segmentation structure
load([handles.expDir filesep 'Segmented/' seg_file(1).name]);
im = imread(char(CO.filename));
if size(im,3)~=1
    im = rgb2gray(im);
end
im = im./max(im(:));
imshow(im,[]); hold on;

properties = regionprops(CO.Nuc_label,'BoundingBox','PixelIdxList');
for p = 1:length(properties)
    tempIm = zeros(properties(p).BoundingBox(4),properties(p).BoundingBox(3));
    [y,x] = ind2sub(size(im),properties(j).PixelIdxList);
    y = y-properties(j).BoundingBox(2)+.5; x = x-properties(j).BoundingBox(1)+.5;
    tempIm(sub2ind(size(tempIm),y,x)) = 1;
    tempIm = imdilate(tempIm,strel('disk',1));
    BW = bwperim(tempIm);
    [y,x] = find(BW);
    x = x + properties(j).BoundingBox(1)-.5;y = y+properties(j).BoundingBox(2)-.5;
    [~,loc] = ismember([im_idx,CO.cellId(p)],im_cell_id,'rows');
    if loc~=0
        switch classLabel{loc}
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
        end
    else
        gscatter(x,y,[],'w','.',2);
    end
end
set(gca,'XLabel',[],'YLabel',[])

axes(ax2)
cla
instructions = sprintf('Key:\nn  = Nucleus\nm  = Mitotic Cell\na  = Apoptotic Cell\no  = Over Segmented\nu  = Under Segmented\n-> = Advance 1 image\n<- = Previous Image\ns  = Skip 10 images\nt  = Toggle image\nd  = Delete Previous');
text(0,.5,instructions)
str = sprintf('Counts\nNuclear: %d\nOver Segmented: %d\nUnder Segmented: %d\nMitotic Cells: %d\nApoptotic Cells: %d',num_nuc,num_over,num_under,num_mito,num_apo);
text(0,.9,str)