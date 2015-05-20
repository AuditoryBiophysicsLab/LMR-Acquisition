
function ExtractCZI(fileName)    
    %% Initial configuration
    assert(ConfigurationCheck==1,'Configuration incorrect, check path');
    %% get data about the file
    [path,name,ext]=fileparts(which(fileName)); %using `which` ensures we get an absolute path
    % make sure the file has the right extension
    assert(strcmpi(ext,'.czi'),'a CZI file was not given');            
    %% open the file for serialization
    s = bfopen(fileName);
    %% make a directory
    dataDir = fullfile(path,name);    
    assert(mkdir(dataDir)==1, 'error creating directory!');    
    %% serialize the metadata to XML
    metadata=char(s{1,4}.dumpXML());
    %save(fullfile(dataDir,[name,'-metadata.xml']),'metadata','-ascii');    
    fid=fopen(fullfile(dataDir,[name,'-metadata.xml']),'w');
    fprintf(fid,metadata);
    fclose(fid);
    %% export images as TIFFs
    seriesCount = size(s,1);    
    for i=1:seriesCount
        thisSeries = s{i,1};
        thisPlaneCount = size(thisSeries,1);
        thisMap=s{1,3}{i};
        
        if(isempty(thisMap))
            map=colormap(gray);
        else
            map = colormap(thisMap);
        end
        
        for j=1:thisPlaneCount            
            imgName=sprintf('series %d plane %d.tiff',i,j);
            img = s{i,1}{j,1};
            imwrite(img,map,fullfile(dataDir,imgName));
        end
    end   
end