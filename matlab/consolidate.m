function [] = consolidate( dir_array )
%Testing function for consolidate.m
%dir_array must be a cell array of strings specifying paths to directories
%of dicoms to analyze.
%consolidate.m loops through specified directories, determines uniqueness
%of each image by comparing SliceLocation attribute of .dcm file and copies
%to new directory.

%Get cell array of directory structures
dir_array = reshape(dir_array,1,numel(dir_array));
numdir = length(dir_array);
file_array = cell(1,numdir);
for a = 1:numdir
    file_array{a} = ls(dir_array{a});
end
disp('Directories loaded.');

%Get unique files
slice_locations = [];  %Vector of SliceLocations
count = 1;  %Used to iterate below
file_paths = cell(1,1);  %Cell array of filepaths to dicoms determined to be unique
mkdir C:\consolidated\

for b = 1:numel(dir_array)
    %b loops through directories of interest
    [r,~] = size(file_array{b});  %r = number of items in direcyory b
    for c = 3:r
        %c loops through all files on directory at a time; begins at 3 because first two items are always . and ..
        current_filepath = sprintf('%s\\%s',dir_array{b},file_array{b}(c,:));  %Make string of full file path
        temp_info = dicominfo(current_filepath);  %Makes struct of all attributes of dicom file
        if ~ismember(temp_info.SliceLocation,slice_locations)  %If this SliceLocation hasn't been seen yet
            slice_locations(count) = temp_info.SliceLocation;  %Add this SliceLocation to slice_locations vector
            file_paths{count} = current_filepath;  %Add this filepath to array of trusted file paths
            count = count + 1;  %Iterate
        end
    end
end
disp('Unique slices found.');

%Copy files whose slice location hadn't been seen yet into a new directory
disp('Copying files.');
for d = 1:numel(file_paths)  %Copy truested files to new location
    copyfile(char(file_paths(d)),'C:\consolidated\');
end
disp('Complete. Files located at C:\consloidated\');

end

