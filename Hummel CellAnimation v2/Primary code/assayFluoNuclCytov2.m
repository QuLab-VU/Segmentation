function []=assayFluoNuclCyto()

global functions_list;
functions_list=[];

% script variables
ImageFolder='~/Dropbox/Test_Images/7-10 Data/72 h/Well B11/';
NucleiImage=[ImageFolder '20120719150507-5613-R02-C11.jpg']; % Image folder is directory dependent
CytoImage=[ImageFolder '20120719150507-5614-R02-C11.jpg'];
OutputFolder=ImageFolder;
% Experiment_Date='20120710';
% Cell_Type='A375';
% Well_Name='B04';
% Time='72h';
% Drug='PLX-4720';
% Concentration='6.4';
CellOutlines=[ImageFolder 'outlines.jpg'];
ImageProperties=[ImageFolder 'ImageProperties.csv'];
% CellIntensities=[OutputFolder 'intensity_data.mat'];
% CellProp=[OutputFolder 'Properties_data.mat'];
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

%% begin cytoplasm 
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
getobjectprops.FunctionArgs.IntensityImage.FunctionInstance='ReadCyto';
getobjectprops.FunctionArgs.IntensityImage.OutputArg='Image';
getobjectprops.FunctionArgs.Image.FunctionInstance='FillNucleiHoles';
getobjectprops.FunctionArgs.Image.OutputArg='Image';
getobjectprops.FunctionArgs.LabelMatrix.FunctionInstance='SegmentCyto';
getobjectprops.FunctionArgs.LabelMatrix.OutputArg='LabelMatrix';
getobjectprops.FunctionArgs.NucleiLeft.FunctionInstance='SegmentCyto';
getobjectprops.FunctionArgs.NucleiLeft.OutputArg='LabelMatrixLeft';
functions_list=addToFunctionChain(functions_list,getobjectprops);

%% Generate the overall showing the cell outlines and locations
savecelloutlines.InstanceName='SaveCellOutlines';
savecelloutlines.FunctionHandle=@displayObjectOutlinesv2;
savecelloutlines.FunctionArgs.FileName.Value=CellOutlines;
savecelloutlines.FunctionArgs.ShowIDs.Value=true;
savecelloutlines.FunctionArgs.Image.FunctionInstance='NormalizeCytoImage';
savecelloutlines.FunctionArgs.Image.OutputArg='Image';
savecelloutlines.FunctionArgs.ObjectsLabel.FunctionInstance='SegmentCyto';
savecelloutlines.FunctionArgs.ObjectsLabel.OutputArg='LabelMatrix';
functions_list=addToFunctionChain(functions_list,savecelloutlines);

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

savedataformat.InstanceName='SaveDataFormat';
savedataformat.FunctionHandle=@SaveDataSpreadsheet; 
savedataformat.FunctionArgs.ImageFolder.Value=ImageFolder;
savedataformat.FunctionArgs.ObjectsLabel.FunctionInstance='LabelNuclei';
savedataformat.FunctionArgs.ObjectsLabel.OutputArg='LabelMatrix';
savedataformat.FunctionArgs.ObjectsArea.FunctionInstance='GetShapeParametersNuclei';
savedataformat.FunctionArgs.ObjectsArea.OutputArg='ShapeParameters';
savedataformat.FunctionArgs.ObjectsIntensity.FunctionInstance='GetShapeParametersNuclei';
savedataformat.FunctionArgs.ObjectsIntensity.OutputArg='Intensity';
functions_list=addToFunctionChain(functions_list,savedataformat);



%% 
global dependencies_list;
global dependencies_index;
dependencies_list={};
dependencies_index=java.util.Hashtable;
makeDependencies([]);
runFunctions();


end
