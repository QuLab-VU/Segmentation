function output_args=displayImage(input_args)
%displayImage module
%create or select figure FigureNr and display the image provided in Image

showmaxfigure(input_args.FigureNr.Value), imshow(input_args.Image.Value,[]);
output_args=[];

end