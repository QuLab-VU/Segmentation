function [handles] = plateInfo_reader(handles)
fid = fopen([handles.expDir filesep 'PlateInfo.MBK']);
if fid==-1
    error(['No PlateInfo.MBK file in' handles.expDir])
end
%Move through the first couple lines which are header information
tline = fgetl(fid);tline = fgetl(fid);tline = fgetl(fid);
%Find the names of the variables
c_idx_temp = strfind(tline,',');
varname = cell(0);
for i = 1:length(c_idx_temp)-1
    varname{i} = tline(c_idx_temp(i)+1:c_idx_temp(i+1)-1);
end
%Skip another line of header
tline = fgetl(fid);

%Create a structure to hold the image information
T = struct();
for i = 1:length(varname)
    if i~=17
        T.(varname{i}) = cell(0);
    end
end

%Get the data
tline = fgetl(fid);cnt = 1;
while ischar(tline)
    [A] = textscan(tline,'%s\t');
    for i = 1:length(varname)-1
        if i < 17
            T.(varname{i}){cnt} = A{1}{i+1};
        else
            T.(varname{i+1}){cnt} = A{1}{i+1};
        end
    end
    cnt = cnt + 1;
    tline = fgetl(fid);
end

T.DATENUM = [];T.DATESTR = cell(0);
for i = 1:length(T.T_POSITION)
    T.DATENUM(i) = datenum([T.T_POSITION{i} ' ' T.T_MICROSECONDS{i}]); 
    T.DATESTR{i} = [T.T_POSITION{i} ' ' T.T_MICROSECONDS{i}];
end

%send it back in the handles structure
handles.FileInfo = T;
% 
% for i = 1:length(varname)
%     if i~=17
%     str = sprintf('%s %s',T.(varname{i}){1},varname{i});
%     disp(str)
%     end
% end
