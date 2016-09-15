function output_args=saveWrapper(input_args)
% Simple module to wrap the Matlab save function
% Input Structure Members
% SaveData – Data to be saved.
% FileName – Path to the location where the data will be saved.
% Output Structure Members
% None.


saved_data=input_args.SaveData.Value;
save(input_args.FileName.Value,'saved_data');
output_args=[];

%end saveCellsLabel
end