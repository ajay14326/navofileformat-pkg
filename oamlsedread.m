function Data = oamlsedread(filename)
%OAMLSEDREAD Loads an OAML sediment charter file
%
% Data = oamlsedread(filename)
%
% This program loads the data from an OAML charter file using
% finread.m, creates a reference vector, breaks the grid into smaller grids
% and uses the dataGrid values (type ID) to create an rmz grid.
%
% This function was written to preprocess these files for use in navo2cass.
%
% Input variables:
%
%   filename:   name of OAML sediment database file, in fin file (binary charter
%               file) format
%
% Output variables:
%
%   Data:       1 x n structure with the following fields:
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
%
%               refvec:         a reference vector for the grid
%
%               vertices:       5 x 2 matrix containing latitude (y) values
%                               in the first column and longitude (x)
%                               values in the second, defining the
%                               rectangle around the grid (for inpolygon
%                               tests)

% Copyright 2004-2005 Kelly Kearney


% Read original charter file and split into smaller grids

OriginalData = finread(filename);
Data = smallergrids(OriginalData);

% Convert grid to rmz (NaN for land and nodata)

for igrid = 1:length(Data)
    Data(igrid).rmz = hfevaconvert(Data(igrid).dataGrid, 'typeid', 'rmz');
end




