function [polyTable, attribTable] = shapefilearea(varargin)
%SHAPEFILEAREA Calculates area covered by shapefile polygons
%
% [polygonTable, attribTable] = shapefilearea(shapefile, attrib)
% [polygonTable, attribTable] = shapefilearea(shapestruct, attrib)
%
% Creates two tables of values holding information regarding the area
% covered by indivdual shapefile polygons and a specified attribute
% throughout the file.
%
% Input variables:
%
%   shapefile:      name of shapefile, base name or component name
%
%   shapestruct:    structure returned by shaperead function
%
%   attrib:         fieldname of attribute of interest
%
% Output variables:
%
%   polygonTable:   n x 3 table, where n is the number of polygons in the
%                   file.  
%                       Column 1: the polygon index
%                       Column 2: attribute value for polygon
%                       Column 3: area of polygon
%   
%   attribTable:    n x 2 table, where n is the number of unique attribute
%                   values associated with the polygons in the file
%                       Column 1: attribute value for polygon
%                       Column 2: total area of polygons with that
%                                 attribute
%
% Copyright 2005 Kelly Kearney

%------------------------------
% Check input
%------------------------------

if ischar(varargin{1})
    Shape = shaperead(varargin{1}, 'UseGeoCoords', true);
elseif isstruct(varargin{1})
    Shape = varargin{1};
    if ~isfield(Shape, 'Lat') || ~isfield(Shape, 'Lon')
        error('Input struct must use geographic coordinates');
    end
end

attrib = varargin{2};
if ~isfield(Shape, attrib)
    error('Attribute not found in shapefile');
end

%------------------------------
% Calculate area of individual
% polygons
%------------------------------

npoly = length(Shape);

polyArea = zeros(npoly,1);
for ipoly = 1:npoly
    areaTemp = areaint(Shape(ipoly).Lat, Shape(ipoly).Lon, almanac('earth', 'ellipsoid', 'kilometers'));
    iscw = ispolycw(Shape(ipoly).Lon, Shape(ipoly).Lat);
    polyArea(ipoly) = sum(areaTemp(iscw)) - sum(areaTemp(~iscw));
end

attribClass = class(Shape(1).(attrib));

switch attribClass
    case 'char'
        polyAttrib = {Shape.(attrib)};
    case {'logical', 'double'}
        polyAttrib = [Shape.(attrib)];
    otherwise
        error('Attribute values must be character arrays or scalars');
end

%------------------------------
% Calculate area of individual
% polygons
%------------------------------

uniqueAttrib = unique(polyAttrib);
nattrib = length(uniqueAttrib);
uniqueArea = zeros(nattrib, 1);
for iat = 1:nattrib
    uniqueArea(iat) = sum(polyArea(ismember(polyAttrib, uniqueAttrib(iat))));
end

%------------------------------
% Output tables
%------------------------------

switch attribClass
    case 'char'
        polyTable = [num2cell(1:npoly)' polyAttrib' num2cell(polyArea)];
        attribTable = [uniqueAttrib' num2cell(uniqueArea)];
    case {'logical', 'double'}
        polyTable = [(1:npoly)' polyAttrib' polyArea];
        attribTable = [uniqueAttrib' uniqueArea];
    otherwise
        error('Attribute values must be character arrays or scalars');
end