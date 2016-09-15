function output_args=fillHoles(input_args)
%simple wrapper for MATLAB imfill function
output_args.Image=imfill(input_args.Image.Value,'holes');

%end fillHoles
end