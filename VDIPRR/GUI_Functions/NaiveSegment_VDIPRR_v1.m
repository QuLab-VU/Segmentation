function [CO,nucIm] = NaiveSegment_VDIPRR_v1(handles,im)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Initially read in information about the image and store
im_info = imfinfo(char(handles.im_file(im).name));
CO = struct(); %Cellular object structure.  This is where all the information to be saved is stored
%Find the name of image with the row and column number
%Store the row and column names from the filename  This assumes a specific
%filename format!

CO.ImData.filename = handles.im_file(im).name;
idx = strfind(CO.ImData.filename,'.');
idx2 = strfind(CO.ImData.filename,filesep);
CO.ImData.ImName = CO.ImData.filename(idx2(end)+1:idx-1);
file_loc = find(cellfun(@(s) ~isempty(strfind(CO.ImData.ImName, s)), handles.FileInfo.IMAGE_ID));
CO.ImData.Time = handles.FileInfo.DATESTR{file_loc};
CO.ImData.WELL_X = str2double(handles.FileInfo.WELL_X{file_loc});
CO.ImData.WELL_Y = str2double(handles.FileInfo.WELL_Y{file_loc});
CO.ImData.ImNum = im;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Now read in all the different channels
%Read in all the images into Im_array matrix and correct for illumination with CIDRE or
%tophat.  Store the nuclear image first!
nucIm = imread(handles.im_file(im).name);
cytoIm = imread(handles.im_file(im+1).name);

%Convert to single matrix image if rgb image
if size(nucIm,3) ~=1
    nucIm = rgb2gray(nucIm);
    im_info.BitDepth = im_info.BitDepth./3;
end
nucIm = double(nucIm);
%Correct Image:
switch handles.BackCorrMethod
    case 'CIDRE'
        nucIm = (nucIm)./(handles.CIDREmodel.v)*mean(handles.CIDREmodel.v(:));
    case 'RollBallFilter'
         tempIm = imopen(nucIm,strel('disk',handles.rollfilter));
         nucIm = nucIm - tempIm;
    case 'ConstThresh'
        nucIm  = nucIm - max(nucIm(:))*handles.back_thresh;
    case 'ImageSub'
        cont = uint16(imread(handles.CorrIm_file));
        nucIm = (nucIm - cont);
        nucIm(nucIm<0) = 0;
end

%The image array holds all the different images read in
%read in fucci
if size(cytoIm,3) ~=1
    cytoIm = rgb2gray(cytoIm);
end
cytoIm = double(cytoIm);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Now segment the Nucleus

%To avoid segmenting blank images...  Make Variable in future?
if max(std(nucIm)) < 3
    Nuc_label = zeros(size(Nuc_label));
else %Otherise binarize image with Otsu's thresholding
    s = warning('error','images:multithresh:degenerateInput');
    s = warning('error','images:multithresh:noConvergence'); cnt = 0;
    %Try binarizing with the user defined level, if doesn't converge decrease by 1 and try again.
    try num = multithresh(nucIm,handles.NucnumLevel); 
    catch exception
        while cnt<handles.NucnumLevel-1
            try 
                num = multithresh(nucIm,handles.NucnumLevel-cnt);
                break;
            end
            cnt = cnt+1;
        end
    end
    SegIm_array	= imquantize(nucIm, num);
    SegIm_array(SegIm_array < handles.NucnumLevel-1) = 0; %Background
    SegIm_array(SegIm_array >= handles.NucnumLevel-1) = 1; %Nuclei
    % Remove Noise using the noise_disk
    noise = imtophat(SegIm_array, strel('disk', handles.nuc_noise_disk));
    SegIm_array = SegIm_array - noise;
    %Smooth resulting Segmentation
    SegIm_array = imdilate(SegIm_array,strel('disk',handles.smoothing_factor));
    % Fill Holes
    %SegIm_array = imfill(SegIm_array, 'holes');
    %To separate touching nuclei, compute the distance of the binary 
    %transformed image using the bright areas of the image as the basins 
    %by inverse of the distance measure
    D = -bwdist(~SegIm_array);
    D = -imhmax(-D,handles.NucSegHeight);  %Suppress values below NucSegHeight.
    Nuc_label = watershed(D);
    Nuc_label(SegIm_array == 0) = 0; %Write all the background to zero.
end

border_cells    = [Nuc_label(1,:)   Nuc_label(:,size(Nuc_label,2))'   Nuc_label(size(Nuc_label,1),:)  Nuc_label(:,1)'];
border_cells    = unique(border_cells(border_cells~=0));

%This is the end of cytoplasm segmentation.
%Store similar information for the Nucleus segmentation.
%This information will eventually be used in the baysian classifier to
%identify different cells.
p	= regionprops(Nuc_label,'PixelIdxList','Perimeter','MajorAxisLength',...
    'MinorAxisLength','EquivDiameter','Solidity','EulerNumber','ConvexArea','Centroid','Eccentricity');
AvgInt = zeros(size(p,1),1); Area = zeros(size(p,1),1); Perimeter = zeros(size(p,1),1);MajorAxisLength = zeros(size(p,1),1); 
MinorAxisLength = zeros(size(p,1),1); EquivDiameter = zeros(size(p,1),1); Solidity = zeros(size(p,1),1); 
EulerNumber = zeros(size(p,1),1); ConvexArea= zeros(size(p,1),1);Centroid = zeros(size(p,1),2);CytoInt = zeros(size(p,1),1);
Edge = zeros(size(p,1),1);
if size(p,1) ~= 0
    for k = 1:size(p,1)
        Centroid(k,:)       = p(k).Centroid;
        AvgInt(k)           = sum(nucIm(p(k).PixelIdxList))/length(p(k).PixelIdxList);
        Area(k)             = length(p(k).PixelIdxList);
        Perimeter(k)        = p(k).Perimeter;
        MajorAxisLength(k)  = p(k).MajorAxisLength;
        MinorAxisLength(k)  = p(k).MinorAxisLength;
        EquivDiameter(k)    = p(k).EquivDiameter;
        Solidity(k)         = p(k).Solidity;
        EulerNumber(k)      = p(k).EulerNumber;
        ConvexArea(k)       = p(k).ConvexArea;
        Edge(k)             = ismember(k,border_cells);
        CytoInt(k)          = sum(cytoIm(p(k).PixelIdxList))/length(p(k).PixelIdxList);
    end
    CO.CData.ImName = cell(size(p,1),1);
    for i = 1:size(p,1)
        CO.CData.ImName{i} = CO.ImData.ImName;
    end
    %For each channel save information into the structure
    CO.CData.Centroid_one           = Centroid(:,1);
    CO.CData.Centroid_two           = Centroid(:,2);
    CO.CData.cellId                 = zeros(size(p,1),1);
    CO.CData.cellId(:,1)            = 1:size(p,1);
    CO.ImData.NucBackground         = median(nucIm(Nuc_label==0));
    CO.ImData.CytoBackground        = median(cytoIm(Nuc_label==0));
    CO.CData.AvgInt                 = AvgInt;
    CO.CData.CytoInt                = CytoInt;
    CO.CData.Area                   = Area;
    CO.CData.Perimeter              = Perimeter;
    CO.CData.Solidity               = Solidity;
    CO.CData.EulerNumber            = EulerNumber;
    CO.CData.ConvexArea             = ConvexArea;
    CO.CData.Edge                   = Edge;
    CO.CData.MajorAxisLength        = MajorAxisLength;
    CO.CData.MinorAxisLength        = MinorAxisLength;
    CO.CData.EquivDiameter          = EquivDiameter;
    %Run the CellFeatureSets function to extract 26 features of
    %segmented cells
    [FeatureSet, FeatureSetVarLabels]     = CellFeatureSets(nucIm,Nuc_label,[1:size(p,1)],[]);
    CO.CData.Circularity                  = FeatureSet(:,3);
    CO.CData.Hu_mom1                      = FeatureSet(:,4);
    CO.CData.Hu_mom2                      = FeatureSet(:,5);
    CO.CData.Hu_mom3                      = FeatureSet(:,6);
    CO.CData.Hu_mom4                      = FeatureSet(:,7);
    CO.CData.Hu_mom5                      = FeatureSet(:,8);
    CO.CData.Hu_mom6                      = FeatureSet(:,9);
    CO.CData.Hu_mom7                      = FeatureSet(:,10);
    CO.CData.Extension                    = FeatureSet(:,11);
    CO.CData.Dispersion                   = FeatureSet(:,12);
    CO.CData.Elongation                   = FeatureSet(:,13);
    CO.CData.Mean_Dist_to_closest_objs    = FeatureSet(:,14);
    CO.CData.Mean_Pixel_Dist              = FeatureSet(:,15);
    CO.CData.Max_Pixel_Dist               = FeatureSet(:,16);
    CO.CData.Min_Pixel_Dist               = FeatureSet(:,17);
    CO.CData.Std_Pixel_Dist               = FeatureSet(:,18);
    CO.CData.Mean_Intensity               = FeatureSet(:,19);
    CO.CData.Min_Intensity                = FeatureSet(:,20);
    CO.CData.Max_Intensity                = FeatureSet(:,21);
    CO.CData.Std_Intensity                = FeatureSet(:,22);
    CO.CData.Mean_Gradient_Full           = FeatureSet(:,23);
    CO.CData.Min_Gradient_Full            = FeatureSet(:,24);
    CO.CData.Max_Gradient_Full            = FeatureSet(:,25);
    CO.CData.Std_Gradient_Full            = FeatureSet(:,26);
else % if no cells give everyone a nan
    CO.CData.ImName{1} = CO.ImData.ImName;
    %For each channel save information into the structure
    CO.CData.Centroid_one           = nan;
    CO.CData.Centroid_two           = nan;
    CO.CData.cellId                 = nan;
    CO.CData.cellId(:,1)            = nan;
    CO.ImData.NucBackground         = median(nucIm(Nuc_label==0));
    CO.ImData.CytoBackground        = median(cytoIm(Nuc_label==0));
    CO.CData.AvgInt                 = nan;
    CO.CData.CytoInt                = nan;
    CO.CData.Area                   = nan;
    CO.CData.Perimeter              = nan;
    CO.CData.Solidity               = nan;
    CO.CData.EulerNumber            = nan;
    CO.CData.ConvexArea             = nan;
    CO.CData.Edge                   = nan;
    CO.CData.MajorAxisLength        = nan;
    CO.CData.MinorAxisLength        = nan;
    CO.CData.EquivDiameter          = nan;
    CO.CData.Circularity                  = nan;
    CO.CData.Hu_mom1                      = nan;
    CO.CData.Hu_mom2                      = nan;
    CO.CData.Hu_mom3                      = nan;
    CO.CData.Hu_mom4                      = nan;
    CO.CData.Hu_mom5                      = nan;
    CO.CData.Hu_mom6                      = nan;
    CO.CData.Hu_mom7                      = nan;
    CO.CData.Extension                    = nan;
    CO.CData.Dispersion                   = nan;
    CO.CData.Elongation                   = nan;
    CO.CData.Mean_Dist_to_closest_objs    = nan;
    CO.CData.Mean_Pixel_Dist              = nan;
    CO.CData.Max_Pixel_Dist               = nan;
    CO.CData.Min_Pixel_Dist               = nan;
    CO.CData.Std_Pixel_Dist               = nan;
    CO.CData.Mean_Intensity               = nan;
    CO.CData.Min_Intensity                = nan;
    CO.CData.Max_Intensity                = nan;
    CO.CData.Std_Intensity                = nan;
    CO.CData.Mean_Gradient_Full           = nan;
    CO.CData.Min_Gradient_Full            = nan;
    CO.CData.Max_Gradient_Full            = nan;
    CO.CData.Std_Gradient_Full            = nan;
end        

%Save the nucleus information
%%Count the number of cells in the image from the number of labels
CO.ImData.cellCount = max(max(Nuc_label));     
CO.Nuc_label = Nuc_label;


