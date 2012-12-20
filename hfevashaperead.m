function HfevaStruct = hfevashaperead(filename)
%HFEVASHAPEREAD Loads a shape file containing hfeva sediment data
%
% HfevaStruct = hfevashaperead(filename)
%
% This function is an extension of the Matlab function shaperead, designed
% to work with a specific type of file: a HFEVA sediment shapefile.  These
% files hold only polygon objects, each of which describes the sediment of
% the enclosed polygon based on the HFEVA 32 sediment category (CAT field).
%
% Input variables:
%
%   filename:   filename or base name of a shapefile component file.  The
%               main file (.shp), index file (.shx), and xBASE file (.dbf)
%               must all share this file name and be located in the same
%               directory.    
%
% Output variables:
%
%   HfevaStruct:    n x 1 structure with the following fields:
%
%                   Geometry:       'Polygon'
%
%                   Bounding Box:   2-by-2 numerical array specifying the
%                                   minimum and maximum feature coordinate
%                                   values in each dimension       
%
%                   Lon:            1 x m array of longitude of polygon 
%                                   vertices
%
%                   Lat:            1 x m array of latitude of polygon
%                                   vertices  
%
%                   CAT:            HFEVA 32 sediment category
%
%                   AREA:           area of polygon (field may not be 
%                                   present)
%
%                   PERIMETER:      length of polygon perimeter (field may
%                                   not be present)  
%
%                   LABEL:          HFEVA Standard Sediment Type label
%                                   (field may not be present)  
%
%                   CONFIDENCE:     ?? (field may not be present)
%
%                   F:              ?? (field may not be present)
%
%                   SECURITY:       ?? (field may not be present)
%
%                   ORIGINATOR:     ?? (field may not be present)
%
%                   SENSOR:         ?? (field may not be present)
%
%                   color:          1 x 3 array, [red green blue], for
%                                   HFEVA sediment type color 
%
%                   typeID:         HFEVA type ID corresponding to the
%                                   sediment category 
%
%                   rmz:            mean grain size corresponding to the
%                                   sediment category 
%
%                   patchFace:      face matrix for face-vertex plotting of
%                                   the polygon 
%
%                   patchVertices:  vertices matrix for face-vertex 
%                                   plotting of the polygon    

% Copyright 2005 Kelly Kearney

%-----------------------------
% Load shapefile and check 
% that contains it is the 
% right type of data
%-----------------------------

try
    HfevaStruct = shaperead(filename, 'UseGeoCoords', true);
catch
    error('Error reading shapefile. Check that file exists and is a shapefile.');
end

if ~isfield(HfevaStruct, 'CAT')
    error('No CAT field found.  Check file type');
end

if ~all(strcmp('Polygon', {HfevaStruct.Geometry}))
    error('Found a non-polygon element in this file.  Shapefile must contain only sediment polygons.');
end

%-----------------------------
% Load HFEVA reference table 
%-----------------------------

hfevaRef = hfevatable;

%-----------------------------
% Add color, typeID, rmz, 
% patchFace, and patchVertices
% fields
%-----------------------------

for ipoly = 1:length(HfevaStruct)
    
    [tf, tableIndex] = ismember(HfevaStruct(ipoly).CAT, cell2mat(hfevaRef(:,3)));
    HfevaStruct(ipoly).color  = hfevaRef{tableIndex, 4} ./ 255;
    HfevaStruct(ipoly).typeId = hfevaRef{tableIndex, 1};
    HfevaStruct(ipoly).rmz    = hfevaRef{tableIndex, 5};
    
    [HfevaStruct(ipoly).patchFace, HfevaStruct(ipoly).patchVertices] = ...
        poly2fv(HfevaStruct(ipoly).Lon, HfevaStruct(ipoly).Lat);
    
end



