function output_args=forIteration(input_args)
% Usage
% 

X = input_args.X.Value;
Iteration = input_args.Loop.Value;
ImageFolder = input_args.ImageFolder.Value;
ImageNameStart = input_args.ImageNameStart.Value;
ImageNameEnd = input_args.ImageNameEnd.Value;
ImageType = input_args.ImageType.Value;
ImageNameMiddle_Initial = input_args.ImageNameMiddle_Initial.Value;

loop_functions=input_args.LoopFunctions;

NumberFormat = '%03d';

for i = X:(Iteration-1);
    if i < 1
        ImageNameMiddle = str2num(ImageNameMiddle_Initial);
        ImageNameOne = ImageNameMiddle+0;
        ImageNameTwo = ImageNameMiddle+1;
        ImageNameThree = ImageNameMiddle+2;
        
        ChannelOneImage=[ImageNameStart num2str(ImageNameOne,NumberFormat) ImageNameEnd ImageType];
        ChannelTwoImage=[ImageNameStart num2str(ImageNameTwo,NumberFormat) ImageNameEnd ImageType];
        ChannelThreeImage=[ImageNameStart num2str(ImageNameThree,NumberFormat) ImageNameEnd ImageType];
        
        output_args.ImageNameMiddle = ImageNameOne;
        output_args.Identifier = ImageNameOne;
        output_args.ChannelOne =   [ImageFolder ChannelOneImage];
        output_args.ChannelTwo =   [ImageFolder ChannelTwoImage];
        output_args.ChannelThree = [ImageFolder ChannelThreeImage];
        
        loop_function_instance_name=loop_functions{i}.InstanceName;
        callFunction(loop_function_instance_name,false);
        
    elseif i >=1
        ImageNameMiddle_Next = input_args.ImageNameMiddle_Next.Value;
        ImageNameMiddle = str2num(ImageNameMiddle_Next);
        ImageNameOne = ImageNameMiddle+0;
        ImageNameTwo = ImageNameMiddle+1;
        ImageNameThree = ImageNameMiddle+2;
        
        ChannelOneImage=[ImageNameStart num2str(ImageNameOne,NumberFormat) ImageNameEnd ImageType];
        ChannelTwoImage=[ImageNameStart num2str(ImageNameTwo,NumberFormat) ImageNameEnd ImageType];
        ChannelThreeImage=[ImageNameStart num2str(ImageNameThree,NumberFormat) ImageNameEnd ImageType];
        
        output_args.ImageNameMiddle = ImageNameOne;
        output_args.Identifier = ImageNameOne;
        output_args.ChannelOne = [ImageFolder ChannelOneImage];
        output_args.ChannelTwo = [ImageFolder ChannelTwoImage];
        output_args.ChannelThree = [ImageFolder ChannelThreeImage];
    
    end 
    loop_function_instance_name=loop_functions{i}.InstanceName;
        callFunction(loop_function_instance_name,false);
end
