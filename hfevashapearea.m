function [polygonTable, sedTable] = hfevashapearea(filename)
%HFEVASHAPEAREA Returns the area of each polygon in a hfeva shapefile
%
% [polygonTable, sedTable] = hfevashapearea(filename)
%
% Calculates the area of all polygons in a hfeva shapefile.
%
% Input variables:
%
%   filename:       HFEVA shapefile component (.shp, .shx, or .dbf file)
%
% Output variables:
%
%   polygonTable:   n x 2 array showing sediment category and area (km^2) of
%                   each individual polygon
%
%   sedTable:       n x 2 array showing each unique sediment category found
%                   in the file and the total area (km^2) of that
%                   particular sediment type

% Copyright 2005 Kelly Kearney

Shape = hfevashaperead(filename);

npoly = length(Shape);

polyCat = [Shape.CAT]';

polyArea = zeros(npoly,1);
for ipoly = 1:npoly
    areaTemp = areaint(Shape(ipoly).Lat, Shape(ipoly).Lon, almanac('earth', 'ellipsoid', 'kilometers'));
    iscw = ispolycw(Shape(ipoly).Lon, Shape(ipoly).Lat);
    polyArea(ipoly) = sum(areaTemp(iscw)) - sum(areaTemp(~iscw));
end
polygonTable = [polyCat polyArea];

sedCat = unique(polyCat);
sedArea = zeros(length(sedCat), 1);
for icat = 1:length(sedCat)
    sedArea(icat) = sum(polyArea(polyCat == sedCat(icat)));
end
sedTable = [sedCat sedArea];


