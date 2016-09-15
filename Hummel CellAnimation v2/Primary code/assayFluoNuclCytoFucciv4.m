% This module is designed to do three things: 1. Get Nuclei IDs, 2. Overlay
% Nuclei IDs over a segmented Cyto Image in order to determine intensity of
% specific expression related stain and 3. Also get intensity of Fucci
% cells to determine point of cell cycle.
function []=assayFluoNuclCyto()
    
global functions_list;
functions_list=[];

% USER SPECIFIC INFORMATION ON WHERE DATA EXISTS
ImageFolder='~/Dropbox/Test_images/20121217 A375/D02/';
OutputFolder=ImageFolder;
ImageNameStart='20121217111425-';   
ImageNameMiddle= '000';
ImageNameEnd='-R04-C02';
ImageType='.tiff';
%
% USER SPECIFIC DATA REGARDING THE WELL BEING ANALYZED
Experiment_Date= {'20120710'};
Cell_Type= {'A375'};
Well_Name={'B04'};
Time={'72h'};
Drug={'PLX-4720'};
Concentration={'0'};
Iteration = 9;
ChannelStep = 3;
X = 0;
NumberFormat='%03d';

% NucleiImage = [ImageFolder ChannelOneImage];
% CytoImage = [ImageFolder ChannelTwoImage];
% FucciImage = [ImageFolder ChannelThreeImage];

CellOutlines=[ImageFolder 'outlines.jpg'];
CellOutlinesFucci=[ImageFolder 'outlinesfucci.jpg'];
ImageProperties=[ImageFolder 'ImageProperties.csv'];

% CellIntensities=[OutputFolder 'intensity_data.mat'];
% CellProp=[OutputFolder 'Properties_data.mat'];
% end script variables
image_read_loop_functions=[];


iteration.InstanceName='Iteration';
iteration.FunctionHandle=@forIteration;
iteration.FunctionArgs.X.Value=X;
iteration.FunctionArgs.Loop.Value = Iteration;
iteration.FunctionArgs.ImageFolder.Value = ImageFolder;
iteration.FunctionArgs.ImageNameStart.Value=ImageNameStart;
iteration.FunctionArgs.ImageNameEnd.Value=ImageNameEnd;
iteration.FunctionArgs.ImageType.Value=ImageType;
iteration.FunctionArgs.ImageNameMiddle_Initial.Value=ImageNameMiddle;
iteration.FunctionArgs.LoopFunctions=image_read_loop_functions;
iteration.FunctionArgs.ImageNameMiddle_Next.FunctionInstance='ContinueTracks';
iteration.FunctionArgs.ImageNameMiddle_Next.OutputArg='ImageMiddleName_Next';
functions_list=addToFunctionChain(functions_list,iteration);

%% Script will run through the nuclei image first
readnuclei.InstanceName='ReadNuclei';
readnuclei.FunctionHandle=@readImage;
readnuclei.FunctionArgs.ImageChannel.Value='r';
% readnuclei.FunctionArgs.ImageName.Value=NucleiImage;
readnuclei.FunctionArgs.ImageName.FunctionInstance='Iteration';
readnuclei.FunctionArgs.ImageName.OutputArg='ChannelOne';
functions_list=addToFunctionChain(functions_list,readnuclei);

normalizenuclearimage.InstanceName='NormalizeNuclearImage';
normalizenuclearimage.FunctionHandle=@imNorm;
normalizenuclearimage.FunctionArgs.IntegerClass.Value='uint8'; 
normalizenuclearimage.FunctionArgs.RawImage.FunctionInstance='ReadNuclei';
normalizenuclearimage.FunctionArgs.RawImage.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,normalizenuclearimage);

thresholdnuclei.InstanceName='ThresholdNuclei';
thresholdnuclei.FunctionHandle=@generateBinImgUsingLocAvg;
thresholdnuclei.FunctionArgs.ClearBorder.Value=true;
thresholdnuclei.FunctionArgs.ClearBorderDist.Value=0;
thresholdnuclei.FunctionArgs.Strel.Value='disk';
thresholdnuclei.FunctionArgs.StrelSize.Value=15;
thresholdnuclei.FunctionArgs.BrightnessThresholdPct.Value=1.15;
thresholdnuclei.FunctionArgs.Image.FunctionInstance='ReadNuclei';
thresholdnuclei.FunctionArgs.Image.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,thresholdnuclei);

intensityfilternuclei.InstanceName='IntensityFilterNuclei';
intensityfilternuclei.FunctionHandle=@generateBinImgUsingGlobInt;
intensityfilternuclei.FunctionArgs.ClearBorder.Value=false;
intensityfilternuclei.FunctionArgs.ClearBorderDist.Value=0;
intensityfilternuclei.FunctionArgs.IntensityThresholdPct.Value=0.10;
intensityfilternuclei.FunctionArgs.Image.FunctionInstance='ThresholdNuclei';
intensityfilternuclei.FunctionArgs.Image.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,intensityfilternuclei);

clearnoisepixels.InstanceName='ClearNoisePixels';
clearnoisepixels.FunctionHandle=@clearSmallObjects;
clearnoisepixels.FunctionArgs.MinObjectArea.Value=60;
clearnoisepixels.FunctionArgs.Image.FunctionInstance='IntensityFilterNuclei';
clearnoisepixels.FunctionArgs.Image.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,clearnoisepixels);

fillnucleiholes.InstanceName='FillNucleiHoles';
fillnucleiholes.FunctionHandle=@fillHoles;
fillnucleiholes.FunctionArgs.Image.FunctionInstance='ClearNoisePixels';
fillnucleiholes.FunctionArgs.Image.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,fillnucleiholes);

labelnuclei.InstanceName='LabelNuclei';
labelnuclei.FunctionHandle=@labelObjects;
labelnuclei.FunctionArgs.Image.FunctionInstance='FillNucleiHoles';
labelnuclei.FunctionArgs.Image.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,labelnuclei);
% end Nuclei section  

%% Begin Cytoplasm 
readcyto.InstanceName='ReadCyto';
readcyto.FunctionHandle=@readImage;
readcyto.FunctionArgs.ImageChannel.Value='r';
% readcyto.FunctionArgs.ImageName.Value=CytoImage;
readcyto.FunctionArgs.ImageName.FunctionInstance='Iteration';
readcyto.FunctionArgs.ImageName.OutputArg='ChannelTwo';
functions_list=addToFunctionChain(functions_list,readcyto);

normalizecytoimage.InstanceName='NormalizeCytoImage';
normalizecytoimage.FunctionHandle=@imNorm;
normalizecytoimage.FunctionArgs.IntegerClass.Value='uint8';
normalizecytoimage.FunctionArgs.RawImage.FunctionInstance='ReadCyto';
normalizecytoimage.FunctionArgs.RawImage.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,normalizecytoimage);

intensityfilter.InstanceName='IntensityFilter';
intensityfilter.FunctionHandle=@generateBinImgUsingGlobInt;
intensityfilter.FunctionArgs.ClearBorder.Value=false;
intensityfilter.FunctionArgs.ClearBorderDist.Value=0;
intensityfilter.FunctionArgs.IntensityThresholdPct.Value=0.10;
intensityfilter.FunctionArgs.Image.FunctionInstance='NormalizeCytoImage';
intensityfilter.FunctionArgs.Image.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,intensityfilter);

clearnoisepixelscyto.InstanceName='ClearNoisePixelsCyto';
clearnoisepixelscyto.FunctionHandle=@clearSmallObjects;
clearnoisepixelscyto.FunctionArgs.MinObjectArea.Value=60;
clearnoisepixelscyto.FunctionArgs.Image.FunctionInstance='IntensityFilter';
clearnoisepixelscyto.FunctionArgs.Image.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,clearnoisepixelscyto);
%% Begin Reading Fucci Image
readfucci.InstanceName='ReadFucci';
readfucci.FunctionHandle=@readImage;
readfucci.FunctionArgs.ImageChannel.Value='r';
% readfucci.FunctionArgs.ImageName.Value=FucciImage;
readfucci.FunctionArgs.ImageName.FunctionInstance='Iteration';
readfucci.FunctionArgs.ImageName.OutputArg='ChannelThree';
functions_list=addToFunctionChain(functions_list,readfucci);

normalizefucciimage.InstanceName='NormalizeFucciImage';
normalizefucciimage.FunctionHandle=@imNorm;
normalizefucciimage.FunctionArgs.IntegerClass.Value='uint8'; 
normalizefucciimage.FunctionArgs.RawImage.FunctionInstance='ReadFucci';
normalizefucciimage.FunctionArgs.RawImage.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,normalizefucciimage);

thresholdfucci.InstanceName='ThresholdFucci';
thresholdfucci.FunctionHandle=@generateBinImgUsingLocAvg;
thresholdfucci.FunctionArgs.ClearBorder.Value=true;
thresholdfucci.FunctionArgs.ClearBorderDist.Value=0;
thresholdfucci.FunctionArgs.Strel.Value='disk';
thresholdfucci.FunctionArgs.StrelSize.Value=15;
thresholdfucci.FunctionArgs.BrightnessThresholdPct.Value=1.15;
thresholdfucci.FunctionArgs.Image.FunctionInstance='ReadFucci';
thresholdfucci.FunctionArgs.Image.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,thresholdfucci);

intensityfilterfucci.InstanceName='IntensityFilterFucci';
intensityfilterfucci.FunctionHandle=@generateBinImgUsingGlobInt;
intensityfilterfucci.FunctionArgs.ClearBorder.Value=false;
intensityfilterfucci.FunctionArgs.ClearBorderDist.Value=0;
intensityfilterfucci.FunctionArgs.IntensityThresholdPct.Value=0.10;
intensityfilterfucci.FunctionArgs.Image.FunctionInstance='ThresholdFucci';
intensityfilterfucci.FunctionArgs.Image.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,intensityfilterfucci);

clearnoisepixelsfucci.InstanceName='ClearNoisePixelsFucci';
clearnoisepixelsfucci.FunctionHandle=@clearSmallObjects;
clearnoisepixelsfucci.FunctionArgs.MinObjectArea.Value=60;
clearnoisepixelsfucci.FunctionArgs.Image.FunctionInstance='IntensityFilterFucci';
clearnoisepixelsfucci.FunctionArgs.Image.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,clearnoisepixelsfucci);

fillfucciholes.InstanceName='FillNucleiHolesFucci';
fillfucciholes.FunctionHandle=@fillHoles;
fillfucciholes.FunctionArgs.Image.FunctionInstance='ClearNoisePixelsFucci';
fillfucciholes.FunctionArgs.Image.OutputArg='Image';
functions_list=addToFunctionChain(functions_list,fillfucciholes);

% intensityfilterfucciagain.InstanceName='IntensityFilterFucciAgain';
% intensityfilterfucciagain.FunctionHandle=@generateBinImgUsingGlobInt;
% intensityfilterfucciagain.FunctionArgs.ClearBorder.Value=false;
% intensityfilterfucciagain.FunctionArgs.ClearBorderDist.Value=0;
% intensityfilterfucciagain.FunctionArgs.IntensityThresholdPct.Value=0.10;
% intensityfilterfucciagain.FunctionArgs.Image.FunctionInstance='ClearNoisePixelsFucci';
% intensityfilterfucciagain.FunctionArgs.Image.OutputArg='Image';
% functions_list=addToFunctionChain(functions_list,intensityfilterfucciagain);
% 
% showfucci.InstanceName='ShowFucci';
% showfucci.FunctionHandle=@displayImage;
% showfucci.FunctionArgs.FigureNr.Value=1;
% showfucci.FunctionArgs.Image.FunctionInstance='IntensityFilterFucciAgain';
% showfucci.FunctionArgs.Image.OutputArg='Image';
% functions_list=addToFunctionChain(functions_list,showfucci);
% 
% showfuccitest.InstanceName='ShowFucciTest';
% showfuccitest.FunctionHandle=@displayImage;
% showfuccitest.FunctionArgs.FigureNr.Value=2;
% showfuccitest.FunctionArgs.Image.FunctionInstance='FillNucleiHolesFucci';
% showfuccitest.FunctionArgs.Image.OutputArg='Image';
% functions_list=addToFunctionChain(functions_list,showfuccitest);

%% This section is used to begin analysis of image intensity
segmentcyto.InstanceName='SegmentCyto';
segmentcyto.FunctionHandle=@segmentCytoUsingNuclei_v2;
segmentcyto.FunctionArgs.CytoImage.FunctionInstance='ClearNoisePixelsCyto';
segmentcyto.FunctionArgs.CytoImage.OutputArg='Image';
segmentcyto.FunctionArgs.NuclearLabel.FunctionInstance='LabelNuclei';
segmentcyto.FunctionArgs.NuclearLabel.OutputArg='LabelMatrix';
functions_list=addToFunctionChain(functions_list,segmentcyto);

% Nuclei ID'd cell intensity
getobjectprops.InstanceName='GetShapeParametersNuclei';
getobjectprops.FunctionHandle=@getObjectPropsv2;
getobjectprops.FunctionArgs.NucIntensityImage.FunctionInstance='ReadNuclei';
getobjectprops.FunctionArgs.NucIntensityImage.OutputArg='Image';
getobjectprops.FunctionArgs.IntensityImage.FunctionInstance='ReadCyto';
getobjectprops.FunctionArgs.IntensityImage.OutputArg='Image';
getobjectprops.FunctionArgs.Image.FunctionInstance='FillNucleiHoles';
getobjectprops.FunctionArgs.Image.OutputArg='Image';
getobjectprops.FunctionArgs.LabelMatrix.FunctionInstance='SegmentCyto';
getobjectprops.FunctionArgs.LabelMatrix.OutputArg='LabelMatrix';
getobjectprops.FunctionArgs.NucleiLeft.FunctionInstance='SegmentCyto';
getobjectprops.FunctionArgs.NucleiLeft.OutputArg='LabelMatrixLeft';
functions_list=addToFunctionChain(functions_list,getobjectprops);

% Generate the overall showing the cell outlines and locations based on the
% cyto image and nuclei image
savecelloutlines.InstanceName='SaveCellOutlines';
savecelloutlines.FunctionHandle=@displayObjectOutlinesv2;
savecelloutlines.FunctionArgs.FileName.Value=CellOutlines;
savecelloutlines.FunctionArgs.ShowIDs.Value=true;
savecelloutlines.FunctionArgs.Image.FunctionInstance='NormalizeCytoImage';
savecelloutlines.FunctionArgs.Image.OutputArg='Image';
savecelloutlines.FunctionArgs.ObjectsLabel.FunctionInstance='SegmentCyto';
savecelloutlines.FunctionArgs.ObjectsLabel.OutputArg='LabelMatrix';
functions_list=addToFunctionChain(functions_list,savecelloutlines);

%% This cell is used to determine the intensity of the Fucci Image
segmentfucci.InstanceName='SegmentFucci';
segmentfucci.FunctionHandle=@segmentFucciUsingNuclei;
segmentfucci.FunctionArgs.FucciImage.FunctionInstance='ClearNoisePixelsFucci';
segmentfucci.FunctionArgs.FucciImage.OutputArg='Image';
segmentfucci.FunctionArgs.NuclearLabel.FunctionInstance='LabelNuclei';
segmentfucci.FunctionArgs.NuclearLabel.OutputArg='LabelMatrix';
functions_list=addToFunctionChain(functions_list,segmentfucci);

% Nuclei ID'd cell intensity
getobjectpropsfucci.InstanceName='GetShapeParametersFucci';
getobjectpropsfucci.FunctionHandle=@getObjectPropsFucci;
getobjectpropsfucci.FunctionArgs.IntensityImage.FunctionInstance='ReadFucci';
getobjectpropsfucci.FunctionArgs.IntensityImage.OutputArg='Image';
getobjectpropsfucci.FunctionArgs.Image.FunctionInstance='FillNucleiHoles';
getobjectpropsfucci.FunctionArgs.Image.OutputArg='Image';
getobjectpropsfucci.FunctionArgs.LabelMatrix.FunctionInstance='SegmentFucci';
getobjectpropsfucci.FunctionArgs.LabelMatrix.OutputArg='LabelMatrix';
getobjectpropsfucci.FunctionArgs.NucleiLeft.FunctionInstance='SegmentFucci';
getobjectpropsfucci.FunctionArgs.NucleiLeft.OutputArg='LabelMatrixLeft';
functions_list=addToFunctionChain(functions_list,getobjectpropsfucci);

savecelloutlinesfucci.InstanceName='SaveCellOutlinesFucci';
savecelloutlinesfucci.FunctionHandle=@displayObjectOutlinesFucci;
savecelloutlinesfucci.FunctionArgs.FileName.Value=CellOutlinesFucci;
savecelloutlinesfucci.FunctionArgs.ShowIDs.Value=true;
savecelloutlinesfucci.FunctionArgs.Image.FunctionInstance='NormalizeFucciImage';
savecelloutlinesfucci.FunctionArgs.Image.OutputArg='Image';
savecelloutlinesfucci.FunctionArgs.ObjectsLabel.FunctionInstance='SegmentFucci';
savecelloutlinesfucci.FunctionArgs.ObjectsLabel.OutputArg='LabelMatrix';
functions_list=addToFunctionChain(functions_list,savecelloutlinesfucci);

%% Data Continuation Loop

continuedata.InstanceName='ContinueData';
continuedata.FunctionHandle=@continueData;
% continuedata.FunctionArgs.LoopNumber.FunctionInstance='SegmentationLoop';
% continuedata.FunctionArgs.Original.Value=Original;
continuedata.FunctionArgs.Identifier.FunctionInstance='Iteration';
continuedata.FunctionArgs.Identifier.OutputArg='Identifier';
continuedata.FunctionArgs.ImageNameOne.FunctionInstance='Iteration';
continuedata.FunctionArgs.ImageNameOne.OutputArg='ImageNameOne';
continuedata.FunctionArgs.NumberFormat.Value=NumberFormat;
continuedata.FunctionArgs.ImageLoop.Value=ImageNameMiddle;
continuedata.FunctionArgs.LoopNumber.Value=ImageNameMiddle; % 'LoopCounter';
continuedata.FunctionArgs.CellType.Value=Cell_Type;
continuedata.FunctionArgs.WellName.Value=Well_Name;
continuedata.FunctionArgs.ExperimentDate.Value=Experiment_Date;
continuedata.FunctionArgs.Time.Value=Time;
continuedata.FunctionArgs.Drug.Value=Drug;
continuedata.FunctionArgs.Concentration.Value=Concentration;
continuedata.FunctionArgs.ChannelStep.Value=ChannelStep;
continuedata.FunctionArgs.ObjectsLabel.FunctionInstance='LabelNuclei';
continuedata.FunctionArgs.ObjectsLabel.OutputArg='LabelMatrix';
continuedata.FunctionArgs.ObjectsArea.FunctionInstance='GetShapeParametersNuclei';
continuedata.FunctionArgs.ObjectsArea.OutputArg='ShapeParameters';
continuedata.FunctionArgs.ObjectsIntensity.FunctionInstance='GetShapeParametersNuclei';
continuedata.FunctionArgs.ObjectsIntensity.OutputArg='Intensity';
continuedata.FunctionArgs.ObjectsIntensityNuclei.FunctionInstance='GetShapeParametersNuclei';
continuedata.FunctionArgs.ObjectsIntensityNuclei.OutputArg='NucleiIntensity';
continuedata.FunctionArgs.ObjectsIntensityFucci.FunctionInstance='GetShapeParametersFucci';
continuedata.FunctionArgs.ObjectsIntensityFucci.OutputArg='Intensity';
% continuedata.FunctionArgs.Tracks2.FunctionInstance2='ContinueData';
% continuedata.FunctionArgs.Tracks2.OutputArg2='Tracks';
functions_list=addToFunctionChain(functions_list,continuedata);

% startdata.InstanceName='StartData';
% startdata.FunctionHandle=@startData;
% startdata.FunctionArgs.TimeFrame.Value=TimeFrame;
% startdata.FunctionArgs.CurFrame.FunctionInstance='LabelNuclei';
% startdata.FunctionArgs.CurFrame.InputArg='LabelMatrix';
% startdata.FunctionArgs.Shapes.FunctionInstance='GetShapeParametersNuclei';
% startdata.FunctionArgs.Shapes.InputArg='ShapeParameters';
% startdata.FunctionArgs.ShapeParameters.FunctionInstance='GetShapeParametersNuclei';
% startdata.FunctionArgs.ShapeParameters.InputArg='Intensity';

% segmentationloop.InstanceName='SegmentationLoop';
% segmentationloop.FunctionHandle=@forLoop;
% segmentationloop.FunctionArgs.StartLoop.Value=0;
% segmentationloop.FunctionArgs.EndLoop.Value=9;
% segmentationloop.FunctionArgs.IncrementLoop.Value=1;
% segmentationloop.FunctionArgs.Tracks.Value=[];
% segmentationloop.KeepValues.ObjectsLabel.FunctionInstance='LabelNuclei';
% segmentationloop.KeepValues.ObjectsLabel.OutputArg='LabelMatrix';
% segmentationloop.KeepValues.ObjectsArea.FunctionInstance='GetShapeParametersNuclei';
% segmentationloop.KeepValues.ObjectsArea.OutputArg='ShapeParameters';
% segmentationloop.KeepValues.ObjectsIntensity.FunctionInstance='GetShapeParametersNuclei';
% segmentationloop.KeepValues.ObjectsIntensity.OutputArg='Intensity';
% segmentationloop.KeepValues.ObjectsIntensityNuclei.FunctionInstance='GetShapeParametersNuclei';
% segmentationloop.KeepValues.ObjectsIntensityNuclei.OutputArg='NucleiIntensity';
% segmentationloop.KeepValues.ObjectsIntensityFucci.FunctionInstance='GetShapeParametersFucci';
% segmentationloop.KeepValues.ObjectsIntensityFucci.OutputArg='Intensity';
% segmentationloop.LoopFunctions=image_read_loop_functions;
% functions_list=addToFunctionChain(functions_list,segmentationloop);
%% Saving the intensities and area of the cells

savedataformatfucci.InstanceName='SaveDataFormat';
savedataformatfucci.FunctionHandle=@SaveDataSpreadsheetFucci; 
savedataformatfucci.FunctionArgs.ImageFolder.Value=ImageFolder;
savedataformatfucci.FunctionArgs.CellType.Value=Cell_Type;
savedataformatfucci.FunctionArgs.WellName.Value=Well_Name;
savedataformatfucci.FunctionArgs.ExperimentDate.Value=Experiment_Date;
savedataformatfucci.FunctionArgs.Time.Value=Time;
savedataformatfucci.FunctionArgs.Drug.Value=Drug;
savedataformatfucci.FunctionArgs.Concentration.Value=Concentration;
savedataformatfucci.FunctionArgs.ObjectsLabel.FunctionInstance='LabelNuclei';
savedataformatfucci.FunctionArgs.ObjectsLabel.OutputArg='LabelMatrix';
savedataformatfucci.FunctionArgs.ObjectsArea.FunctionInstance='GetShapeParametersNuclei';
savedataformatfucci.FunctionArgs.ObjectsArea.OutputArg='ShapeParameters';
savedataformatfucci.FunctionArgs.ObjectsIntensity.FunctionInstance='GetShapeParametersNuclei';
savedataformatfucci.FunctionArgs.ObjectsIntensity.OutputArg='Intensity';
savedataformatfucci.FunctionArgs.ObjectsIntensityNuclei.FunctionInstance='GetShapeParametersNuclei';
savedataformatfucci.FunctionArgs.ObjectsIntensityNuclei.OutputArg='NucleiIntensity';
savedataformatfucci.FunctionArgs.ObjectsIntensityFucci.FunctionInstance='GetShapeParametersFucci';
savedataformatfucci.FunctionArgs.ObjectsIntensityFucci.OutputArg='Intensity';
functions_list=addToFunctionChain(functions_list,savedataformatfucci);

% ImageNameMiddle = ImageNameMiddle + ChannelStep;

% ImageNameMiddle = ImageNameMiddle + ChannelStep;

%% 
global dependencies_list;
global dependencies_index;
dependencies_list={};
dependencies_index=java.util.Hashtable;
makeDependencies([]);
runFunctions();


end
