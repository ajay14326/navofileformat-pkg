function Data = fininfo(filename)
%FININFO Reads header data from a binary charter file
%
% Data = fininfo(filename)
%
% This program reads the header data from a .fin file (also known as a
% binary charter file).
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

fclose(fid);