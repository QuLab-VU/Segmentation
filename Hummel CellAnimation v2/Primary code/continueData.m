function output_args=continueData(input_args)
% continueTracks
% Usage
% This module is used to continue the tracks with the new track assignments as tracking progresses from frame to frame.
% Input Structure Members
% CurFrame – Integer value representing the current frame number.
% TrackAssignments – Matrix containing the new track assignments.
% TimeFrame – Integer value representing the current time frame.
% Output Structure Members
% NewTracks – Matrix containing the new tracks for the current frame.
% Tracks – Matrix containing the tracks including the new track assignments.
    % cur_iteration = input_args.LoopNumber.Value;
global dependencies_list;
global dependencies_index;


    Cell_ID=input_args.ObjectsLabel.Value;
    Cell_Area=input_args.ObjectsArea.Value;
    Cell_Intensity=input_args.ObjectsIntensity.Value;
    Cell_FucciIntensity=input_args.ObjectsIntensityFucci.Value;
    Cell_NucleiIntensity=input_args.ObjectsIntensityNuclei.Value;

    Cell_ID = unique(Cell_ID);
    Cell_ID(Cell_ID==0) = [];

    ExperimentDate = repmat(strcat(input_args.ExperimentDate.Value),[size(Cell_ID),1]);
    WellName = repmat(input_args.WellName.Value,[size(Cell_ID),1]);
    Time = repmat(input_args.Time.Value,[size(Cell_ID),1]);
    CellType = repmat(input_args.CellType.Value,[size(Cell_ID),1]);
    Drug = repmat(input_args.Drug.Value,[size(Cell_ID),1]);
    Concentration = repmat(input_args.Concentration.Value,[size(Cell_ID),1]);
    ImageNumber = repmat(input_args.Identifier.Value,[size(Cell_ID),1]);

    FormatSpreadsheet = struct('ExperimentDate',1, 'WellName',2, 'Time',3, 'CellType',4, 'Drug',5, ...
        'Concentration',6, 'ImageNumber',7, 'CellID', 8, 'Area',9, 'One_Intensity',10, 'Two_Intensity',11, 'Three_Intensity',12);

    FormatSpreadsheet.ExperimentDate=ExperimentDate;
    FormatSpreadsheet.WellName=WellName;
    FormatSpreadsheet.Time=Time;
    FormatSpreadsheet.CellType=CellType;
    FormatSpreadsheet.Drug=Drug;
    FormatSpreadsheet.Concentration=Concentration;
    FormatSpreadsheet.ImageNumber=ImageNumber;
    FormatSpreadsheet.CellID=Cell_ID;
    FormatSpreadsheet.Area=Cell_Area;
    FormatSpreadsheet.One_Intensity=Cell_NucleiIntensity;
    FormatSpreadsheet.Two_Intensity=Cell_Intensity;
    FormatSpreadsheet.Three_Intensity=Cell_FucciIntensity;


    output_args.NewTracks = [FormatSpreadsheet];
    NumberFormat = input_args.NumberFormat.Value;
    ChannelStep = input_args.ChannelStep.Value;
   % ImageNameMiddle = str2num(input_args.ImageNameOne);
    ImageNameMiddle = input_args.Identifier.Value;
    ImageNameMiddle = ImageNameMiddle + ChannelStep;
    output_args.ImageNameMiddle_Next = num2str(ImageNameMiddle,NumberFormat);



% if input_args.ImageLoop.Value == input_args.Original.Value + 0
%     cur_iteration = input_args.LoopNumber.Value;
% 
%     Cell_ID=input_args.ObjectsLabel.Value;
%     Cell_Area=input_args.ObjectsArea.Value;
%     Cell_Intensity=input_args.ObjectsIntensity.Value;
%     Cell_FucciIntensity=input_args.ObjectsIntensityFucci.Value;
%     Cell_NucleiIntensity=input_args.ObjectsIntensityNuclei.Value;
% 
%     Cell_ID = unique(Cell_ID);
%     Cell_ID(Cell_ID==0) = [];
% 
%     ExperimentDate = repmat(strcat(input_args.ExperimentDate.Value),[size(Cell_ID),1]);
%     WellName = repmat(input_args.WellName.Value,[size(Cell_ID),1]);
%     Time = repmat(input_args.Time.Value,[size(Cell_ID),1]);
%     CellType = repmat(input_args.CellType.Value,[size(Cell_ID),1]);
%     Drug = repmat(input_args.Drug.Value,[size(Cell_ID),1]);
%     Concentration = repmat(input_args.Concentration.Value,[size(Cell_ID),1]);
%     ImageNumber = repmat(input_args.LoopNumber.Value,[size(Cell_ID),1]);
% 
%     FormatSpreadsheet = struct('ExperimentDate',1, 'WellName',2, 'Time',3, 'CellType',4, 'Drug',5, ...
%         'Concentration',6, 'ImageNumber',7, 'CellID', 8, 'Area',9, 'One_Intensity',10, 'Two_Intensity',11, 'Three_Intensity',12);
% 
%     FormatSpreadsheet.ExperimentDate=ExperimentDate;
%     FormatSpreadsheet.WellName=WellName;
%     FormatSpreadsheet.Time=Time;
%     FormatSpreadsheet.CellType=CellType;
%     FormatSpreadsheet.Drug=Drug;
%     FormatSpreadsheet.Concentration=Concentration;
%     FormatSpreadsheet.ImageNumber=ImageNumber;
%     FormatSpreadsheet.CellID=Cell_ID;
%     FormatSpreadsheet.Area=Cell_Area;
%     FormatSpreadsheet.One_Intensity=Cell_NucleiIntensity;
%     FormatSpreadsheet.Two_Intensity=Cell_Intensity;
%     FormatSpreadsheet.Three_Intensity=Cell_FucciIntensity;
% 
% 
%     output_args.NewTracks_1 = [FormatSpreadsheet];
% 
% elseif input_args.ImageLoop.Value == input_args.Original.Value + 3
%     cur_iteration = input_args.LoopNumber.Value;
% 
%     Cell_ID=input_args.ObjectsLabel.Value;
%     Cell_Area=input_args.ObjectsArea.Value;
%     Cell_Intensity=input_args.ObjectsIntensity.Value;
%     Cell_FucciIntensity=input_args.ObjectsIntensityFucci.Value;
%     Cell_NucleiIntensity=input_args.ObjectsIntensityNuclei.Value;
% 
%     Cell_ID = unique(Cell_ID);
%     Cell_ID(Cell_ID==0) = [];
% 
%     ExperimentDate = repmat(strcat(input_args.ExperimentDate.Value),[size(Cell_ID),1]);
%     WellName = repmat(input_args.WellName.Value,[size(Cell_ID),1]);
%     Time = repmat(input_args.Time.Value,[size(Cell_ID),1]);
%     CellType = repmat(input_args.CellType.Value,[size(Cell_ID),1]);
%     Drug = repmat(input_args.Drug.Value,[size(Cell_ID),1]);
%     Concentration = repmat(input_args.Concentration.Value,[size(Cell_ID),1]);
%     ImageNumber = repmat(input_args.LoopNumber.Value,[size(Cell_ID),1]);
% 
%     FormatSpreadsheet = struct('ExperimentDate',1, 'WellName',2, 'Time',3, 'CellType',4, 'Drug',5, ...
%         'Concentration',6, 'ImageNumber',7, 'CellID', 8, 'Area',9, 'One_Intensity',10, 'Two_Intensity',11, 'Three_Intensity',12);
% 
%     FormatSpreadsheet.ExperimentDate=ExperimentDate;
%     FormatSpreadsheet.WellName=WellName;
%     FormatSpreadsheet.Time=Time;
%     FormatSpreadsheet.CellType=CellType;
%     FormatSpreadsheet.Drug=Drug;
%     FormatSpreadsheet.Concentration=Concentration;
%     FormatSpreadsheet.ImageNumber=ImageNumber;
%     FormatSpreadsheet.CellID=Cell_ID;
%     FormatSpreadsheet.Area=Cell_Area;
%     FormatSpreadsheet.One_Intensity=Cell_NucleiIntensity;
%     FormatSpreadsheet.Two_Intensity=Cell_Intensity;
%     FormatSpreadsheet.Three_Intensity=Cell_FucciIntensity;
% 
% 
%     output_args.NewTracks_2 = [FormatSpreadsheet];
% end
% output_args.Tracks=[input_args.Tracks2.Value; output_args.NewTracks];

% trackAssignments=input_args.TrackAssignments.Value;
% [dummy tracks_sort_idx]=sort(trackAssignments(:,2));
% tracks_ids_sorted=trackAssignments(tracks_sort_idx,1);
% cur_time=(input_args.CurFrame.Value-1)*input_args.TimeFrame.Value;
% output_args.NewTracks=[tracks_ids_sorted repmat(cur_time,size(tracks_ids_sorted,1),1) input_args.CellsCentroids.Value...
%     input_args.ShapeParameters.Value input_args.ShapeParameter_Area.Value];
% output_args.Tracks=[input_args.Tracks.Value; output_args.NewTracks];
% output_args.NewSliceNumber=[cur_time input_args.SliceNumber.Value];
% output_args.SliceNumber_Total=[input_args.SliceNumber.Value output_args.NewSliceNumber.Value];

%end continueTracks
end