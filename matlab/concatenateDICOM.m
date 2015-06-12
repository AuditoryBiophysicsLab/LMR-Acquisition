%%% Takes all DICOMs found recursively below the root directory specified
%%% and creates a coallated DICOM at the target location
function concatenateDICOM(rootDir, targetPath)
%% input checking
assert(isdir(rootDir), 'specified root directory is invalid');
assert(isdir(targetPath),'specified target path is invalid');
if(~isempty(dir2(targetPath,'*.dcm')))
    decision = input(sprintf('Warning: the target directory %s already contains dicom files. Do you want to proceed? Y/N [N]',targetPath),'s');
    if(~strcmpi(decision,'y'))
        disp('Exiting.');
        return;
    end
end
    
%% get a list of all the dicoms from rootDir down
dicomList = dir2(rootDir,'-r','*.DCM'); %filenames are in dicomList(i).name ; full path by fullfile(rootDir,dicomList(i).name)

%% get dicominfo for each to retrieve metadata
%hacky; get the first series UID and number.
UID = dicomuid();
seriesNumber = '1';
progress = '';
for i=1:length(dicomList)
    fullPath = fullfile(rootDir,dicomList(i).name);
    
    %% change each dicom's metadata so they all have the same value for 'SeriesInstanceUID' (possibly generate a new one with dicomuid)
    metadata = dicominfo(fullPath);
    metadata.SeriesInstanceUID = UID;
    metadata.SeriesNumber = seriesNumber;
    
    %% write a new dicom file containing the old imagedata and the new metadata to a new dicom in targetPath (should involve dicomwrite(imageData,fileName,metadata) )
    [x,m]=dicomread(fullPath);
    outPath = fullfile(targetPath,dicomList(i).name);
    dicomwrite(x,m,outPath,metadata);
    
    %% update progress
    percentDone = 100 * i / 10000;
    msg = sprintf('Copying: %3.1f', percentDone); 
    fprintf([progress, msg]);
    progress = repmat(sprintf('\b'), 1, length(msg));
end
end