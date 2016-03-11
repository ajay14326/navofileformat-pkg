function Data = sparsefinread(filename)
%SPARSEFINREAD Read a .fin file and stores data in sparse format
%
% Data = finread(filename)
%
% This program reads the data from a .fin file (also known as a
% binary charter file).  This file format is usually associated with
% bathymetry data, although it is also used for other data types (for
% example, the OAML Sediment Database).  The main data grid is read and
% saved in sparse format.  This function should be prefered over finread
% for large, high-resolution files where the majority of the file holds
% null values (for example, route bathymetry along a diagonal course).
%
% Input variables:
%
%   filename:   fin filename
%
% Output variables:
%   
%   Data:       1 x 1 structure with the following fields
%
%               westLon:        West longitude of area in decimal degrees
%       
%               eastLon:        East longitude of area in decimal degrees
%       
%               southLat:       South latitude of area in decimal degrees
%
%               northLat:       North latitude of area in decimal degrees
%
%               gridInterval:   Grid interval in minutes
%
%               width:          Width of area in grid cells
%
%               height:         Height of area in grid cells
%
%               endianValue:    Endian value, 66501, used to check whether
%                               file is big endian or little endian (no
%
%               minimumValue:   Minimum depth value in file (meters)
%
%               maximumValue:   Maximum depth value in file (meters)
%
%               dataGrid:       sparse array, with the southernmost data
%                               in row 1 (top) and the westernmost data in
%                               column 1 (left)

% Copyright 2006 Kelly Kearney

%---------------------------
% Open file, get machine 
% format
%---------------------------

fid = fopen(filename); 
possibleFormats = 'cblsandg';
testEndian = zeros(8,1);
for iformat = 1:length(possibleFormats)
    fseek(fid, 28, 'bof');
    testEndian(iformat) = fread(fid, 1, 'int32', possibleFormats(iformat));
end
formatIndex = find(testEndian == 66051, 1, 'first');
if isempty(formatIndex)
    error('No machine format match found for this file');
else
    machineFormat = possibleFormats(formatIndex);
end

%---------------------------
% Read the header 
%---------------------------

fseek(fid, 0, 'bof');
Data.westLon  = fread(fid, 1, 'float32', machineFormat);
Data.eastLon  = fread(fid, 1, 'float32', machineFormat);
Data.southLat = fread(fid, 1, 'float32', machineFormat);
Data.northLat = fread(fid, 1, 'float32', machineFormat);
Data.gridInterval = fread(fid, 1, 'float32', machineFormat);
Data.width = fread(fid, 1, 'int32', machineFormat);
Data.height = fread(fid, 1, 'int32', machineFormat);
Data.endianValue = fread(fid, 1, 'int32', machineFormat);
Data.minimumValue = fread(fid, 1, 'float32', machineFormat);
Data.maximumValue = fread(fid, 1, 'float32', machineFormat);

% Skip the zeros padding the end of the header

nZeros = Data.width - 10;
paddingZeros = fread(fid, nZeros, 'float32', machineFormat);

%---------------------------
% Read data grid
%---------------------------

% Count number of non-null vals

startPos = ftell(fid);

ngood = 0;
for irow = 1:Data.height
    bathyRow = fread(fid, Data.width, 'float32', machineFormat);
    isNull = bathyRow > Data.maximumValue;
    ngood = ngood + length(find(~isNull));
end

cols = zeros(ngood,1);
rows = zeros(ngood,1);
vals = zeros(ngood,1);
nold = 0;
fseek(fid, startPos, 'bof');
for irow = 1:Data.height
    
    bathyRow = fread(fid, Data.width, 'float32', machineFormat);
    
    isZeroHeight = bathyRow == 0;
    bathyRow(isZeroHeight) = eps;

    isNull = bathyRow > Data.maximumValue;
    
    newCol = find(~isNull);
    newRow = repmat(irow, size(newCol));
    newVal = bathyRow(~isNull);

    nnew = length(newVal);
    cols((nold + 1):(nold + nnew),1) = newCol;
    rows((nold + 1):(nold + nnew),1) = newRow;
    vals((nold + 1):(nold + nnew),1) = newVal;
    nold = nold + nnew;

end

Data.dataGrid = sparse(rows, cols, vals, Data.height, Data.width);
    
    
    