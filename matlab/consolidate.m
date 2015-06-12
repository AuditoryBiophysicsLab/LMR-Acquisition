function [] = Consolidate(outfile_prefix)
%Allows a user to graphically select a directory whose children are
%directories of dicoms to be consolidated.
%The directory of consolidated of dicoms will be a child of the specified
%parent directory.
%If this function needs to be automated, i.e. not require one to graphically
%pick the parent directory, one can add an input argument for parent_dir and
%comment/remove the line that defines parent-dir with uigetdir.
%Metadata values SeriesInstanceUID and SeriesNumber are fixed so Amira
%recognizes a stream of dicom files as a single object. Amira may raise
%flags in a column labeled 'image number.' Right click this column header
%and select 'Remove Column.'

%Initial Configuration (ConfigurationCheck.m must be in the same directory as Consolidate.m):
assert(ConfigurationCheck == 1,'Configuration Incorrect, check path');

%Recursively acquires paths of all files in parent directory:
parent_dir = uigetdir('','Select Parent Directory');  
file_paths = get_files(parent_dir);  %Recursively acquire absolute paths to files in parent_dir
fprintf('All files loaded.\n');  %Report progress to console

%Get unique files:
slice_locations = [];  %Vector of SliceLocations
count = 1;  %Used to iterate below
[r,~] = size(file_paths);
unique_paths = cell(r,1);  %Initialize cell array for paths of unique dicoms

%Compare a SliceLocation to list of those already checked
for a = 1:numel(file_paths)
    temp_info = dicominfo(file_paths{a});  %Temp struct of dicom metadata
    temp_sl = temp_info.SliceLocation;  %Temp SliceLocation
    if ~ismember(temp_sl,slice_locations)
        slice_locations(count) = temp_sl;
        unique_paths{count} = file_paths{a};
        count = count + 1;
    end
end
unique_paths = unique_paths(1:count - 1);
clear count slide_locations r file_paths
fprintf('Unique slices found.\n');  %Report progress to console


%Copy files whose slice location hadn't been seen yet into a new directory
fprintf('Copying files.\n');  %Report progress to console
destination = fullfile(parent_dir,'consolidated');
mkdir(destination);
for b = 1:numel(unique_paths)  %Copy truested files to new location
    temp_file = dicomread(unique_paths{b});
    temp_meta = dicominfo(unique_paths{b});
    temp_meta.SeriesInstanceUID = '1';  %Set constant SeriesInstanceUID for Amira
    temp_meta.SeriesNumber = 1;  %Set constant SeriesNumber for Amira
    dicomwrite(temp_file,fullfile(destination,sprintf('%s_%d.dcm',outfile_prefix,b)),temp_meta);
end
fprintf('Complete. Files located at %s\n',destination);  %Report progress to console

end

function file_paths = get_files(directory)
dir_data = dir(directory);  %Get the data for directory
dir_index = [dir_data.isdir];  %Find the index for directories
file_paths = {dir_data(~dir_index).name}';  %Get a list of the files

if ~isempty(file_paths)
    file_paths = cellfun(@(x) fullfile(directory,x),file_paths,'UniformOutput',false);  %Prepend path to files
end

sub_dirs = {dir_data(dir_index).name};  %Get a list of  subdirectories
validIndex = ~ismember(sub_dirs,{'.','..'});  %Find index of subdirectories that are not '.' or '..'

for n = find(validIndex)  %Loop over valid subdirectories
    next_dir = fullfile(directory,sub_dirs{n});  %Get  subdirectory path
    file_paths = [file_paths; get_files(next_dir)];  %Recursively call get_files
end

end