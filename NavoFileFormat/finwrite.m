function finwrite(outputfile, west, east, south, north, gridint, data)
%FINWRITE Creates a binary charter file from the given data
%
% finwrite(outputfile, west, east, south, north, gridint, data)
%
% Writes the input data to a fin file, also known as a binary charter file.
%
% Input variables:
%
%   outputfile: name of file to be created
%
%   west:       west longitude of area in decimal degrees
%
%   east:       east longitude of area in decimal degrees
%
%   south:      south latitude of area in decimal degrees
%
%   north:      north latitude of area in decimal degrees
%
%   gridint:    grid interval in minutes
%
%   data:       array of data values, with the southernmost data in row 1
%               (top) and the westernmost data in column 1 (left)

% Copywrite 2006 Kelly Kearney

% Get input and calculate additional values

if nargin ~= 7
    error('Wrong number of input arguments');
end

outputfile   = varargin{1};
west      = varargin{2};
east      = varargin{3};
south     = varargin{4};
north     = varargin{5};
gridint = varargin{6};
data     = varargin{7};

[height, width] = size(data);
endianValue = 66051;
dataValues = unique(data(:));
dataValues(dataValues > 1e15) = [];
minimumValue = min(dataValues);
maximumValue = max(dataValues);
padding = zeros(width - 10, 1);

fid = fopen(outputfile, 'w', 'l');

% Write the header

fwrite(fid, west, 'float32');
fwrite(fid, east, 'float32');
fwrite(fid, south, 'float32');
fwrite(fid, north, 'float32');
fwrite(fid, gridint, 'float32');
fwrite(fid, width, 'int32');
fwrite(fid, height, 'int32');
fwrite(fid, endianValue, 'int32');
fwrite(fid, minimumValue, 'float32');
fwrite(fid, maximumValue, 'float32');

% Write padding for header

fwrite(fid, padding, 'float32');

% Write data grid

fwrite(fid, data', 'float32');

% Close file

fclose(fid);


