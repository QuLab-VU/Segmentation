function [classMat,im_cell_id,classLabel] = reDrawBorders(label,y,x,CO,idx,ax1,ax2,num_nuc,num_over,num_under,num_mito,num_apo)
[~, m_id] = min(sqrt((CO.xpos-x).^2+(CO.ypos-y).^2));
axes(ax1)
imtemp = bwperim(CO.Nuc_label==CO.cellId(m_id));
[i,j] = ind2sub(size(imtemp),find(imtemp));
switch label
    case 'over'
        hold on
        gscatter(j,i,[],'g','.',2);
        set(gca,'XLabel',[],'YLabel',[])
    case 'under'
        hold on
        gscatter(j,i,[],'m','.',2);
        set(gca,'XLabel',[],'YLabel',[])
    case 'nuc'
        hold on
        gscatter(j,i,[],'c','.',2);
        set(gca,'XLabel',[],'YLabel',[])
    case 'apo'
        hold on
        gscatter(j,i,[],'r','.',2);
        set(gca,'XLabel',[],'YLabel',[])
    case 'mito'
        hold on
        gscatter(j,i,[],'b','.',2);
        set(gca,'XLabel',[],'YLabel',[])
end
classMat     = [CO.Nuc.Area(CO.cellId(m_id)),CO.Nuc.Perimeter(CO.cellId(m_id)),CO.Nuc.Solidity(CO.cellId(m_id)),CO.Nuc.EulerNumber(CO.cellId(m_id)),CO.Nuc.ConvexArea(CO.cellId(m_id)),CO.Nuc.EquivDiameter(CO.cellId(m_id)),...
                CO.Nuc.MajorAxisLength(CO.cellId(m_id)),CO.Nuc.MinorAxisLength(CO.cellId(m_id)),CO.Nuc.Circularity(CO.cellId(m_id)),CO.Nuc.Extension(CO.cellId(m_id)),CO.Nuc.Dispersion(CO.cellId(m_id)),CO.Nuc.Elongation(CO.cellId(m_id)),...
                CO.Nuc.Huc_mom1(CO.cellId(m_id)),CO.Nuc.Huc_mom2(CO.cellId(m_id)),CO.Nuc.Huc_mom3(CO.cellId(m_id)),CO.Nuc.Huc_mom4(CO.cellId(m_id)),CO.Nuc.Huc_mom5(CO.cellId(m_id)),CO.Nuc.Huc_mom6(CO.cellId(m_id)),CO.Nuc.Huc_mom7(CO.cellId(m_id)),...
                CO.Nuc.Mean_Pixel_Dist(CO.cellId(m_id)),CO.Nuc.Min_Pixel_Dist(CO.cellId(m_id)),CO.Nuc.Max_Pixel_Dist(CO.cellId(m_id)),CO.Nuc.Std_Pixel_Dist(CO.cellId(m_id)),...
                CO.Nuc.Mean_Intensity(CO.cellId(m_id)),CO.Nuc.Min_Intensity(CO.cellId(m_id)),CO.Nuc.Max_Intensity(CO.cellId(m_id)),CO.Nuc.Std_Intensity(CO.cellId(m_id)),...
                CO.Nuc.Mean_Gradient_Full(CO.cellId(m_id)),CO.Nuc.Min_Gradient_Full(CO.cellId(m_id)),CO.Nuc.Max_Gradient_Full(CO.cellId(m_id)),CO.Nuc.Std_Gradient_Full(CO.cellId(m_id)),...
                CO.Nuc.Mean_Dist_to_closest_objs(CO.cellId(m_id))];
       
im_cell_id    = [idx,CO.cellId(m_id)];
classLabel    = label;
            
axes(ax2)
cla
instructions = sprintf('Key:\nn  = Nucleus\nm  = Mitotic Cell\na  = Apoptotic Cell\no  = Over Segmented\nu  = Under Segmented\n-> = Advance 1 image\n<- = Previous Image\ns  = Skip 10 images\nt  = Toggle image\nd  = Delete Previous')
text(0,.5,instructions)
str = sprintf('Counts\nNuclear: %d\nOver Segmented: %d\nUnder Segmented: %d\nMitotic Cells: %d\nApoptotic Cells: %d',num_nuc,num_over,num_under,num_mito,num_apo);
text(0,.9,str)