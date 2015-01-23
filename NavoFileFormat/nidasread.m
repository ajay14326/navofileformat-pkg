function Data = nidasread(filename)
%NIDASREAD Reads data from a Nidas-generated sound speed file
%
% Data = nidasread(filename)
%
% This function returns a 1 x 3 or 1 x 4 stucture array holding the sound
% speed data associated with the typical, minimum, maximum, and (if
% present) alternate sound speed profiles in a Nidas text file (format used
% for MEDAL databases).
%
% Input variables:
%
%   filename:       name of Nidas file
%
% Output variables:
%
%   Data:           1 x 3 or 1 x 4 structure array with fields:
%
%       Header:         header data, fieldnames describe contents
%
%       vertices:       n x 2 array of polygon vertices describing region
%                       where the profiles are applicable, 
%                       [latitude longitude] 
%
%       depth:          m x 1 array of depths, m
%
%       temperature:    m x 1 array of temperatures, °C
%
%       salinity:       m x 1 array of salinity values, ppt
%
%       soundSpeed:     m x 1 array of sound speed values, m/s
%
%       pressure:       m x 1 array of pressure values, 

% Copyright 2006 Kelly Kearney

fid = fopen(filename, 'rt');

isvp = 0;
continueLooping = 1;

headerFields = {'xlat', 'xlon', 'year', 'month', 'day', 'hour', 'source', ...
                'nparam', 'provinceNumber', 'measurementType', ...
                'regionCode', 'ndepths', 'nverts'};
            
while (continueLooping == 1)
    
    isvp = isvp + 1;
    
    htemp = textscan(fid, '%f', 13);
    
    if isempty(htemp{1})
        continueLooping = 0;
        break;
    end
    
    htemp = num2cell(htemp{1,1});
    Data(isvp).Header = cell2struct(htemp, headerFields, 1);
    
    verts = textscan(fid, '%f', 40);
    verts = reshape(verts{1,1}, 2, 20);
    isnull = (verts(1,:) == -99) & (verts(2,:) == -99);
    verts(:, isnull) = [];
    Data(isvp).vertices = verts';
    
    vars = textscan(fid, '%f %f %f %f %f', Data(isvp).Header.ndepths);  
    Data(isvp).depth       = vars{1};
    Data(isvp).temperature = vars{2};
    Data(isvp).salinity    = vars{3};
    Data(isvp).soundSpeed  = vars{4};
    Data(isvp).pressure    = vars{5};

end

fclose(fid);