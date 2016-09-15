% This module is designed to determine the intensity of an object by doing 
% two things: 
% 1. Get Nuclei IDs,
% 2. Overlay Nuclei IDs over a intensity object channel image. 
% The data is saved in overlays and a .csv file with area and intensity
function []=assayFluoNuclCyto()
global functions_list;
functions_list=[];
% script variables

ImageFolder='~/Dropbox/Stain Images for Analysis/20121109_skmel5/24hr/';
Path='~/Documents/Files/';
% Path='~/Dropbox/Stephen and Darren Shared/20121709 skmel5 data/';
Channel_One   =[ImageFolder '20121207171723-3783-R02-C02.tiff']; % Image folder is directory dependent
Channel_Two =[ImageFolder   '20121207171723-3784-R02-C02.tiff'];
Channel_Three=[ImageFolder  '20121207171723-3785-R02-C02.tiff'];
Frame='test2';
Well='C11';

% USER SPECIFIC DATA REGARDING THE WELL BEING ANALYZED
Experiment_Date= {'20121109'};
Cell_Type= {'skmel5'};
Time={'24'};
Drug={'PLX-4720'};
Concentration={'unknown'};



ImageNumber={Frame};
ImageNumber1=Frame;
Well_Name={Well};
filesep='/';
% Well_Name={'D04'};
% ImageNumber={'1'};
% ImageNumber1='1';
OutputFolder=[Path Well filesep];
% OutputFolder='~/Dropbox/Stain Images for Analysis/A647Staining-2012-12-17-BP-p70-p90-0hr-A375/';
% OutputFolder=ImageFolder;
% CellOutlines=[ImageFolder 'outlines.jpg'];
% CellOutlinesFucci=[ImageFolder 'outlinesfucci.jpg'];
% ImageProperties=[ImageFolder 'ImageProperties.csv'];
NucleiImage = Channel_One;
CytoImage = Channel_Two;
FucciImage= Channel_Three;
NameChannel1='Overlay_Two';
NameChannel2='Overlay_Three';
DataFile='ImageProperties';
Type='.jpg';
Type2='.csv';
CellOutlines=[OutputFolder NameChannel1 ImageNumber1 Type];
CellOutlinesFucci=[OutputFolder NameChannel2 ImageNumber1 Type];
ImageProperties=[OutputFolder DataFile ImageNumber1 Type2];
% CellOutlines=[OutputFolder 'outlines.jpg'];
% CellOutlinesFucci=[OutputFolder 'outlinesfucci.jpg'];
% ImageProperties=[OutputFolder 'ImageProperties.csv'];

% end script variables
%% Script will run through the nuclei image first
readnuclei.InstanceName='ReadNuclei';
readnuclei.FunctionHandle=@readImage;
readnuclei.FunctionArgs.ImageChannel.Value='r';
readnuclei.FunctionArgs.ImageName.Value=NucleiImage;
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
readcyto.FunctionArgs.ImageName.Value=CytoImage;
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
readfucci.FunctionArgs.ImageName.Value=FucciImage;
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
savecelloutlines.FunctionHandle=@displayObjectOutlinesv3;
savecelloutlines.FunctionArgs.FileName.Value=CellOutlines;
savecelloutlines.FunctionArgs.ShowIDs.Value=true;
savecelloutlines.FunctionArgs.Image.FunctionInstance='NormalizeCytoImage';
savecelloutlines.FunctionArgs.Image.OutputArg='Image';
% savecelloutlines.FunctionArgs.ObjectsLabel.FunctionInstance='SegmentCyto';
savecelloutlines.FunctionArgs.ObjectsLabel.FunctionInstance='LabelNuclei';
savecelloutlines.FunctionArgs.ObjectsLabel.OutputArg='LabelMatrix';
savecelloutlines.FunctionArgs.ObjectsLabelTwo.FunctionInstance='SegmentCyto';
savecelloutlines.FunctionArgs.ObjectsLabelTwo.OutputArg='LabelMatrix';
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
savecelloutlinesfucci.FunctionHandle=@displayObjectOutlinesv3;
% savecelloutlinesfucci.FunctionHandle=@displayObjectOutlinesFucci;
savecelloutlinesfucci.FunctionArgs.FileName.Value=CellOutlinesFucci;
savecelloutlinesfucci.FunctionArgs.ShowIDs.Value=true;
savecelloutlinesfucci.FunctionArgs.Image.FunctionInstance='NormalizeFucciImage';
savecelloutlinesfucci.FunctionArgs.Image.OutputArg='Image';
% savecelloutlinesfucci.FunctionArgs.ObjectsLabel.FunctionInstance='SegmentFucci';
savecelloutlinesfucci.FunctionArgs.ObjectsLabel.FunctionInstance='LabelNuclei';
savecelloutlinesfucci.FunctionArgs.ObjectsLabel.OutputArg='LabelMatrix';
savecelloutlinesfucci.FunctionArgs.ObjectsLabelTwo.FunctionInstance='SegmentFucci';
savecelloutlinesfucci.FunctionArgs.ObjectsLabelTwo.OutputArg='LabelMatrix';
functions_list=addToFunctionChain(functions_list,savecelloutlinesfucci);

%% Saving the intensities and area of the cells
% THE IMMEDIATE FOLLOWING THAT IS COMMENTED OUT IS USED IN CASE THE PRIMARY
% SAVING METHOD HAS AN ERROR
% saveit.InstanceName='SaveData';
% saveit.FunctionHandle=@saveWrapper;
% saveit.FunctionArgs.FileName.Value=CellIntensities;
% saveit.FunctionArgs.SaveData.FunctionInstance='GetShapeParametersNuclei';
% saveit.FunctionArgs.SaveData.OutputArgs='Intensity';
% functions_list=addToFunctionChain(functions_list,saveit);
% 
% savearea.InstanceName='SaveArea';
% savearea.FunctionHandle=@saveProperties;
% savearea.FunctionArgs.FileName.Value=CellProp;
% savearea.FunctionArgs.SaveData.FunctionInstance='GetShapeParametersNuclei';
% savearea.FunctionArgs.SaveData.OutputArgs='ShapeParameters';
% functions_list=addToFunctionChain(functions_list,savearea);

savedataformatfucci.InstanceName='SaveDataFormat';
savedataformatfucci.FunctionHandle=@SaveDataSpreadsheetFucciv3; 
savedataformatfucci.FunctionArgs.ImageFolder.Value=OutputFolder;
% savedataformatfucci.FunctionArgs.ImageFolder.Value=ImageFolder;
savedataformatfucci.FunctionArgs.CellType.Value=Cell_Type;
savedataformatfucci.FunctionArgs.WellName.Value=Well_Name;
savedataformatfucci.FunctionArgs.ExperimentDate.Value=Experiment_Date;
savedataformatfucci.FunctionArgs.Time.Value=Time;
savedataformatfucci.FunctionArgs.Drug.Value=Drug;
savedataformatfucci.FunctionArgs.Concentration.Value=Concentration;
savedataformatfucci.FunctionArgs.ImageNumber.Value=ImageNumber;
savedataformatfucci.FunctionArgs.ImageNumber1.Value=ImageNumber1;
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



%% 
global dependencies_list;
global dependencies_index;
dependencies_list={};
dependencies_index=java.util.Hashtable;
makeDependencies([]);
runFunctions();


end
