function output_args=getObjectPropsFucci(input_args)
% This module is used to calculate the parameters of the objects (cells)
% within the image. It uses the regionprops function encoded into MATLAB

% Inputs
objects_lbl=input_args.NucleiLeft.Value;
objects_idx=objects_lbl>0;
I = input_args.Image.Value;

Image_Cyto=input_args.IntensityImage.Value;

% Functions of the module
cells_props=regionprops(objects_lbl,I,'Centroid','Area','Eccentricity','MajorAxisLength','MinorAxisLength',...
    'Perimeter','Solidity','ConvexArea', 'PixelIdxList', 'PixelList','MeanIntensity','PixelValues');
shape_params=[[cells_props.Area]'];
% objects_intensities=accumarray(objects_lbl(objects_idx),I(objects_idx));

cells_props_cyto=regionprops(objects_lbl,Image_Cyto,'Centroid','Area','Eccentricity','MajorAxisLength','MinorAxisLength',...
    'Perimeter','Solidity','ConvexArea', 'PixelIdxList', 'PixelList','MeanIntensity','PixelValues');
objects_intensities_cyto=accumarray(objects_lbl(objects_idx),Image_Cyto(objects_idx));

% Output data of the module
output_args.ShapeParameters=shape_params; % calculates the area of the cells
output_args.Intensity=objects_intensities_cyto; % provides the intensities for all objects 
                                                % based on the intensity image and object ID
output_args.Labels=objects_lbl; % change from objects_idx


end