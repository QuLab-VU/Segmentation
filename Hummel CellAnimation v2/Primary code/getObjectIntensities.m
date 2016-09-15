function output_args=getObjectIntensities(input_args)
% Usage
% This module is used to return the object intensities from objects in a label matrix using the corresponding intensity image.
% Input Structure Members
% LabelMatrix – The label matrix containing the objects for which the mean intensity data will be extracted.
% IntensityImage – Matrix containing the intensity image.
% Output Structure Members
% MeanIntensities – Array containing the mean intensities for each object in the label matrix.

% objects_lbl=input_args.Labels.Value;
objects_lbl=input_args.LabelMatrix.Value;
objects_idx=objects_lbl>0;
% objects_idx=objects_lbl;


intensity_img=input_args.IntensityImage.Value;
objects_intensities=accumarray(objects_lbl(objects_idx),intensity_img(objects_idx));
object_areas=accumarray(objects_lbl(objects_idx),1);
output_args.MeanIntensities=objects_intensities./object_areas;




%end getObjectIntensities
end