function [] = reDrawBorders(label,x,y,CO,idx,ax1,T)
global classMat
global classLabel
global im_cell_id

[~, m_id] = min(sqrt((CO.Centroid(:,1)-x).^2+(CO.Centroid(:,2)-y).^2));

[loc, id] = ismember([idx,CO.cellId(m_id)],im_cell_id,'rows');
if loc == 0
    classMat(end+1,:)         = T(m_id,:);
    im_cell_id(end+1,:)     = [idx,CO.cellId(m_id)];
    classLabel{end+1}       = label;
else
    classMat(id,:)          = T(m_id,:);
    im_cell_id(id,:)        = [idx,CO.cellId(m_id)];
    classLabel{id}          = label;
end

axes(ax1)
imtemp = CO.Nuc_label == CO.cellId(m_id);
imtemp = bwperim(imtemp);
imtemp = imdilate(imtemp,strel('disk',2));
[i,j] = ind2sub(size(imtemp),find(imtemp));
hold on
switch label
    case 'over'
        gscatter(j,i,[],'g','.',2);
    case 'under'
        gscatter(j,i,[],'m','.',2);
    case 'nuc'
        gscatter(j,i,[],'c','.',2);
    case 'apo'
        gscatter(j,i,[],'r','.',2);
    case 'mito'
        gscatter(j,i,[],'b','.',2);
    case 'junk'
        gscatter(j,i,[],'y','.',2);
    case 'newborn'
        gscatter(j,i,[],[161, 202, 241]./255,'.',2) %Baby blue
end
set(gca,'XLabel',[],'YLabel',[])





%{
classMat     = [CO.Nuc.Area(CO.cellId(m_id)),CO.Nuc.Perimeter(CO.cellId(m_id)),CO.Nuc.Solidity(CO.cellId(m_id)),CO.Nuc.EulerNumber(CO.cellId(m_id)),CO.Nuc.ConvexArea(CO.cellId(m_id)),CO.Nuc.EquivDiameter(CO.cellId(m_id)),...
                CO.Nuc.MajorAxisLength(CO.cellId(m_id)),CO.Nuc.MinorAxisLength(CO.cellId(m_id)),CO.Nuc.Circularity(CO.cellId(m_id)),CO.Nuc.Extension(CO.cellId(m_id)),CO.Nuc.Dispersion(CO.cellId(m_id)),CO.Nuc.Elongation(CO.cellId(m_id)),...
                CO.Nuc.Hu_mom1(CO.cellId(m_id)),CO.Nuc.Hu_mom2(CO.cellId(m_id)),CO.Nuc.Hu_mom3(CO.cellId(m_id)),CO.Nuc.Hu_mom4(CO.cellId(m_id)),CO.Nuc.Hu_mom5(CO.cellId(m_id)),CO.Nuc.Hu_mom6(CO.cellId(m_id)),CO.Nuc.Hu_mom7(CO.cellId(m_id)),...
                CO.Nuc.Mean_Pixel_Dist(CO.cellId(m_id)),CO.Nuc.Min_Pixel_Dist(CO.cellId(m_id)),CO.Nuc.Max_Pixel_Dist(CO.cellId(m_id)),CO.Nuc.Std_Pixel_Dist(CO.cellId(m_id)),...
                CO.Nuc.Mean_Intensity(CO.cellId(m_id)),CO.Nuc.Min_Intensity(CO.cellId(m_id)),CO.Nuc.Max_Intensity(CO.cellId(m_id)),CO.Nuc.Std_Intensity(CO.cellId(m_id)),...
                CO.Nuc.Mean_Gradient_Full(CO.cellId(m_id)),CO.Nuc.Min_Gradient_Full(CO.cellId(m_id)),CO.Nuc.Max_Gradient_Full(CO.cellId(m_id)),CO.Nuc.Std_Gradient_Full(CO.cellId(m_id)),...
                CO.Nuc.Mean_Dist_to_closest_objs(CO.cellId(m_id))];

%}