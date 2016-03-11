function makesedfin(finFilename, sedInputFilenames, outputFilename)
%MAKESEDFIN Creates a sediment charter file for a bathymetry file
%
% makesedfin(finFilename, sedInputFilenames, outputFilename)
%
% This function creates a charter file holding sediment data that
% corresponds to the bathymetry data in the input .fin file.  It copys the
% nulls found in the bathymetry file to the new file, and then interpolates
% the remaining values using the data found in the sediment input files.
%
% Input variables:
%
%   finFilename:        a bathymetry charter file (*.fin file)
%
%   sedInputFilenames:  filename or cell array of filenames, either hfeva
%                       shapefiles or OAML charter files 
%
%   outputFilename:     name of output sediment charter file

% Copyright 2006 Kelly Kearney

%---------------------------
% Check input
%---------------------------

if ~exist(finFilename, 'file')
    error('Could not find bathymetry file %s', finFilename);
end

if ischar(sedInputFilenames)
    sedInputFilenames = {sedInputFilenames};
end
nsedfiles = length(sedInputFilenames);

for ifile = 1:nsedfiles
    if ~exist(sedInputFilenames{ifile}, 'file')
        error('Could not find sediment file %s', sedInputFilenames{ifile});
    end
end

%---------------------------
% Read in sediment files
%---------------------------

[blah, blah, ext] = cellfun(@fileparts, sedInputFilenames, 'UniformOutput', false);
isShapefile = cellfun(@(a) any(strcmp(a, {'.shp', '.shx', '.dbf'})), ext);

SedShape = [];
SedGrid = [];

commonFields = {'Lon' 'Lat' 'typeId'};

for ifile = 1:nsedfiles
   if isShapefile(ifile)
       Temp = hfevashaperead(sedInputFilenames{ifile});
       tempFields = fieldnames(Temp);
       extraFields = tempFields(~ismember(tempFields, commonFields));
       Temp = rmfield(Temp, extraFields);
       SedShape = [SedShape Temp];
   else
       Temp = oamlsedread(sedInputFilenames{ifile});
       SedGrid = [SedGrid Temp];
   end
end

%---------------------------
% Open bathy file, check 
% format, and read header
%---------------------------

% Find machine format

fid1 = fopen(finFilename); 
possibleFormats = 'cblsandg';
testEndian = zeros(8,1);
for iformat = 1:length(possibleFormats)
    fseek(fid1, 28, 'bof');
    testEndian(iformat) = fread(fid1, 1, 'int32', possibleFormats(iformat));
end
formatIndex = find(testEndian == 66051, 1, 'first');
if isempty(formatIndex)
    error('No machine format match found for the bathymetry file');
else
    machineFormat = possibleFormats(formatIndex);
end

% Read header

fseek(fid1, 0, 'bof');
westLon  = fread(fid1, 1, 'float32', machineFormat);
eastLon  = fread(fid1, 1, 'float32', machineFormat);
southLat = fread(fid1, 1, 'float32', machineFormat);
northLat = fread(fid1, 1, 'float32', machineFormat);
gridInterval = fread(fid1, 1, 'float32', machineFormat);
width = fread(fid1, 1, 'int32', machineFormat);
height = fread(fid1, 1, 'int32', machineFormat);
endianValue = fread(fid1, 1, 'int32', machineFormat);
minimumValue = fread(fid1, 1, 'float32', machineFormat);
maximumValue = fread(fid1, 1, 'float32', machineFormat);

% Skip the zeros padding the end of the header

nZeros = width - 10;
paddingZeros = fread(fid1, nZeros, 'float32', machineFormat);

%---------------------------
% Write header for sediment
% file
%---------------------------

fid2 = fopen(outputFilename, 'w', 'l');

fwrite(fid2, westLon, 'float32');
fwrite(fid2, eastLon, 'float32');
fwrite(fid2, southLat, 'float32');
fwrite(fid2, northLat, 'float32');
fwrite(fid2, gridInterval, 'float32');
fwrite(fid2, width, 'int32');
fwrite(fid2, height, 'int32');
fwrite(fid2, 66051, 'int32');
fwrite(fid2, -10, 'float32');
fwrite(fid2, 1010, 'float32');
fwrite(fid2, paddingZeros, 'float32');

%---------------------------
% Read bathymetry file one  
% line at a time and 
% find corresponding 
% sediment values
%---------------------------

% Get lat and lon that would be returned by meshgrat but prevent
% unnecessary gridding

refvec = [60/gridInterval northLat westLon];
epsilon = 1.0E-10;
[lat, lon] = limitm(zeros(height,width), refvec);
lat = linspace(min(lat)+epsilon, max(lat)-epsilon, height);
lon = linspace(min(lon)+epsilon, max(lon)-epsilon, width);

% Get sediment grid vertices

boxLat = [];
boxLon = [];
for igrid = 1:length(SedGrid)
    boxLat = [boxLat SedGrid(igrid).vertices(:,1)' NaN];
    boxLon = [boxLon SedGrid(igrid).vertices(:,2)' NaN];
end
        
% Row by row bathy-to-sed

waitbarString = sprintf('Creating sediment charter file for %s', strrep(finFilename, '\', '\\'));
hwait = waitbar(1/height, waitbarString); 
for irow = 1:height
    
    bathyRow = fread(fid1, width, 'float32', machineFormat);
    sedRow = NaN(size(bathyRow));
    
    % Copy nulls
    
    isNull = bathyRow > maximumValue;
    sedRow(isNull) = bathyRow(isNull);
    
    % Interpolate with shapefile
    
    if ~isempty(SedShape)
        needShape = isnan(sedRow);
        shapeLon = lon(needShape);
        shapeLat = repmat(lat(irow), size(shapeLon));
        sedRow(needShape) = interpshapefile(SedShape, shapeLat, shapeLon, 'typeId');
    end
    
    % Interpolate with grid file
    
    if ~isempty(SedGrid)
        
        rowLon = lon;
        rowLat = repmat(lat(irow), size(rowLon));
        [in, index] = inpolygons(rowLon, rowLat, boxLon, boxLat);
        index = cell2mat(index);
        
        needGrid = isnan(sedRow);

        for ibox = 1:length(SedGrid)
            needThisBox = needGrid & (index == ibox)';
            [sedLat, sedLon] = meshgrat(SedGrid(ibox).dataGrid, SedGrid(ibox).refvec);
            sedRow(needThisBox) = interp2(sedLon, sedLat, SedGrid(ibox).dataGrid, rowLon(needThisBox), rowLat(needThisBox), 'nearest');
        end
              
    end 
    
    % Fill in remaining nulls
    
    sedRow(isnan(sedRow)) = 1e16;
    
    % Write to sediment file
    
    fwrite(fid2, sedRow, 'float32');
    
    waitbar(irow/height, hwait);

end
close(hwait);

fclose(fid1);
fclose(fid2);

