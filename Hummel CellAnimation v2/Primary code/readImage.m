function output_args=readImage(input_args)
%simple wrapper for the MATLAB imread function
%Input Structure Members
%ImageName - Path to the image to be loaded.
%Output Structure Members
%Image - The image matrix.

image_name=input_args.ImageName.Value;
img_channel=input_args.ImageChannel.Value;
img_to_proc=imread(image_name);
switch img_channel
    case 'r'
        img_to_proc=img_to_proc(:,:,1);
    case 'g'
        img_to_proc=img_to_proc(:,:,2);
    case 'b'
        img_to_proc=img_to_proc(:,:,3);
end
output_args.Image=img_to_proc;

%end readImage
end