function DATA = finread(filename)
%FINREAD Reads data from a .fin file (also known as binary charter file)
%
% DATA = finread(filename)
%
% This program reads the data from a .fin file (also known as a
% binary charter file).  This file format is usually associated with
% bathymetry data, although it is also used for other data types (for
% example, the OAML Sediment Database).
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
%               dataGrid:       Grid of values, with the southernmost data
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
DATA.westLon  = fread(fid, 1, 'float32', machineFormat);
DATA.eastLon  = fread(fid, 1, 'float32', machineFormat);
DATA.southLat = fread(fid, 1, 'float32', machineFormat);
DATA.northLat = fread(fid, 1, 'float32', machineFormat);
DATA.gridInterval = fread(fid, 1, 'float32', machineFormat);
DATA.width = fread(fid, 1, 'int32', machineFormat);
DATA.height = fread(fid, 1, 'int32', machineFormat);
DATA.endianValue = fread(fid, 1, 'int32', machineFormat);
DATA.minimumValue = fread(fid, 1, 'float32', machineFormat);
DATA.maximumValue = fread(fid, 1, 'float32', machineFormat);

% Skip the zeros padding the end of the header

nZeros = DATA.width - 10;
paddingZeros = fread(fid, nZeros, 'float32', machineFormat);

%---------------------------
% Read data grid
%---------------------------

ndata = DATA.width * DATA.height;
dataPoints = fread(fid, ndata, 'float32', machineFormat);

inverseGrid = zeros(DATA.width, DATA.height);
inverseGrid(1:ndata) = dataPoints(1:ndata);

DATA.dataGrid = inverseGrid';
fclose(fid);