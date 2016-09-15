function output_args=showLabelMatrix(input_args)
% Usage
% This module is used to show a MATLAB label matrix and pause execution.
% Input Structure Members
% FigureNr – The handle number of the MATLAB figure. If it doesn’t exist it will be created.
% LabelMatrix – The label matrix to be displayed.
% Output Structure Members
% None.

showmaxfigure(input_args.FigureNr.Value), imshow(label2rgb(input_args.LabelMatrix.Value));
output_args=[];

end
