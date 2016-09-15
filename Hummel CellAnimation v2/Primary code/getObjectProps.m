function output_args=getObjectProps(input_args)
% Usage
% 
% 

objects_lbl=input_args.NucleiLeft.Value;
% objects_lbl=input_args.LabelMatrix.Value;
% objects_idx=objects_lbl>0;
objects_idx=objects_lbl>0;
I = input_args.CytoImage.Value;
I2 = input_args.Image.Value;

% Added on 20NOV12 by SGH
cells_props=regionprops(objects_lbl,I,'Centroid','Area','Eccentricity','MajorAxisLength','MinorAxisLength',...
    'Perimeter','Solidity','ConvexArea', 'PixelIdxList', 'PixelList','MeanIntensity', 'PixelValues');
cells_centroids=[cells_props.Centroid]';
centr_len=size(cells_centroids,1);
cells_centroids=[cells_centroids(2:2:centr_len) cells_centroids(1:2:centr_len)];

shape_params=[[cells_props.Area]'];
% test = sum(cells_props.PixelValues)

cells_props2=regionprops(objects_lbl,I2,'Centroid','Area','Eccentricity','MajorAxisLength','MinorAxisLength',...
    'Perimeter','Solidity','ConvexArea', 'PixelIdxList', 'PixelList','MeanIntensity');

shape_params2=[[cells_props2.Area]' [cells_props2.MeanIntensity]'];



output_args.ShapeParameters=shape_params;
output_args.ShapeParameters2=shape_params2;
output_args.Labels=objects_idx;
% output_args.Centroids=cells_centroids;
% End of Add

%end getObjectProps
end