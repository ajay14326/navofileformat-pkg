function varargout = plotshapefile(varargin)
%PLOTSHAPEFILE Plots a shapefile
%
% plotshapefile(filename, Param1, Value1, ...)
% plotshapefile(shapeStruct, ...)
% handles = plotshapefile(...)
%
% Plots polygons, polylines, points, and multipoints from a shapefile.  By
% default, all objects are colored black, and polygons are unfilled.  These
% defaults can be modified by including color tables for each set (see
% below for format).
%
% Input Variables:
%
%   filename:           Shapefile name.  The extension of filename can be 
%                       .shp, .dbf or .shx, or be omitted. 
%
%   shapeStruct:        shapefile structure, produced by a shaperead 
%                       command.
%
%   Parameters (passed as param-value pairs)
%
%   'Bounds':           [south north west east] boundary coordinates for
%                       map plot.  The default is the bounding box for the
%                       shapefile.
%
%   'PolyColorTable':   1 x 3 cell array {fieldname, choices, colors},
%                       where fieldname specifies an attribute field of the
%                       shapefile that will be used for color reference 
%                       when filling polygons, choices is a 1 x n list of
%                       possible values for that attribute field, and
%                       colors is a n x 3 array of color values for each
%                       possible value.   
%
%   'PointColorTable':  1 x 3 cell array, same format as 'PolyColorTable',
%                       used to color Point and MultiPoint objects 
%
%   'LineColorTable':   1 x 3 cell array, same format as 'PolyColorTable',
%                       used to color PolyLine objects
%
% Output variables:       
%
%   handles:            structure holding the handles of the figure, map
%                       plot, map axis, and colorbar
%
% Example:
%
%   plotshapefile('test.shp', 'PolyColorTable', {'CAT', [1 2 3], ...
%                 [1 0 0; 0 1 0; 0 0 1]);

% Copyright 2005 Kelly Kearney


%--------------------------
% Parse inputs
%--------------------------

% First input, shapefile

if isstruct(varargin{1})
    Shapefile = varargin{1};
    if ~all(isfield(Shapefile, {'Geometry', 'BoundingBox', 'Lat', 'Lon'}))
        error('First input must be a shapefile structure with geographic coordinates or a valid shapefile');
    end
elseif ischar(varargin{1})
    if ~exist(varargin{1}, 'file') && ~exist([varargin{1} '.shp'], 'file')
        error('Could not find shapefile');
    end
    Shapefile = shaperead(varargin{1}, 'UseGeoCoords', true);
else
    error('First input argument must be a shapefile geographic data structure or the name of a shapefile');
end

% Other inputs

inputVars = varargin(2:end);
if mod(numel(inputVars), 2)
    error('Additional inputs must be in parameter-value pairs');
end
inputVars = reshape(inputVars, 2, []);
if ~all(cellfun(@ischar, inputVars(1,:)))
    error('Additional inputs must be in parameter-value pairs');
end
params = lower(inputVars(1,:));
vals = inputVars(2,:);

Params = struct('bounds', [], 'polycolortable', [], 'pointcolortable', [], 'linecolortable', []);

for ipar = 1:length(params)
    if ~isfield(Params, params{ipar})
        error('Invalid parameter: %s', params{ipar});
    end
    Params.(params{ipar}) = vals{ipar};
end

if isempty(Params.bounds)
   bounds = cell2mat({Shapefile.BoundingBox}');
   Params.bounds = [min(bounds(:,2)) max(bounds(:,2)) min(bounds(:,1)) max(bounds(:,1))];
end


%--------------------------
% Create figure and map 
% axis
%--------------------------

mInterval = (Params.bounds(4) - Params.bounds(3))/5;
pInterval = (Params.bounds(2) - Params.bounds(1))/5;

scrnsz = get(0, 'ScreenSize');
handles.figure = figure('Position', [(scrnsz(3)-800)/2 (scrnsz(4)-600)/2 800 600], ...
                        'Renderer', 'zbuffer', ...
                        'Color', 'w');
                    
handles.mapPlot = subplot('Position', [.1 .1 .8 .8]);
handles.mapAxis = axesm('MapProjection', 'mercator', ...
                        'FLatLimit', Params.bounds(1:2), ...
                        'FLonLimit', Params.bounds(3:4), ...
                        'Grid', 'on', ...
                        'MLineLocation', mInterval, ...
                        'PLineLocation', pInterval, ...
                        'MeridianLabel', 'on', ...
                        'ParallelLabel', 'on', ...
                        'MLabelLocation', mInterval, ...
                        'PLabelLocation', pInterval, ...
                        'MLabelRound', -2, ...
                        'PLabelRound', -2);
axis tight;
                    
%--------------------------
% Plot polygons 
%--------------------------

Polygons = Shapefile(ismember({Shapefile.Geometry}, 'Polygon'));

if isempty(Params.polycolortable)
    fillPoly = false;
else
    fillPoly = true;
    [attribName, attribChoices, attribColors] = parsecolortable(Params.polycolortable, Polygons);
end
    
for ipoly = 1:length(Polygons)
    
    if fillPoly
        [tf, loc] = ismember(Polygons(ipoly).(attribName), attribChoices);
        if ~all(tf)
            error('The polygon color table attribute choices do not match those in the shapefile');
        end
        col = attribColors(loc,:);
    
        [f, v] = poly2fv(Polygons(ipoly).Lon, Polygons(ipoly).Lat);
        vlat = v(:,2);
        vlon = v(:,1);
    
        handles.polyPatch(ipoly) = patchm(vlat(f'), vlon(f'), ...
                                  'FaceColor', col, ...
                                  'EdgeColor', 'none');
    end
    handles.polyOutline(ipoly) = plotm(Polygons(ipoly).Lat, Polygons(ipoly).Lon, 'k');
    
end

%--------------------------
% Plot points and 
% multipoints 
%--------------------------

Points = Shapefile(ismember({Shapefile.Geometry}, {'Point', 'Multipoint'}));

if isempty(Params.pointcolortable)
    colorPoints = false;
else
    colorPoints = true;
    [attribName, attribChoices, attribColors] = parsecolortable(Params.pointcolortable, Points);
end

for ipoint = 1:length(Points)
    if colorPoints
        [tf, loc] = ismember(Points(ipoint).(attribName), attribChoices);
        if ~all(tf)
            error('The point color table attribute choices do not match those in the shapefile');
        end
        col = attribColors(loc,:);
    else
        col = 'k';
    end
        
    handles.points(ipoint) = plotm(Points(ipoint).Lat, Points(ipoint).Lon, 'Marker', 'o', 'Color', col, 'LineStyle', 'none');
end

%--------------------------
% Plot polylines
%--------------------------

Lines = Shapefile(ismember({Shapefile.Geometry}, 'PolyLine'));

if isempty(Params.linecolortable)
    colorLines = false;
else
    colorLines = true;
    [attribName, attribChoices, attribColors] = parsecolortable(Params.linecolortable, Lines);
end

for iline = 1:length(Lines)
    if colorLines
        [tf, loc] = ismember(Lines(iline).(attribName), attribChoices);
        if ~all(tf)
            error('The line color table attribute choices do not match those in the shapefile');
        end
        col = attribColors(loc,:);
    else
        col = 'k';
    end
        
    handles.lines(iline) = plotm(Lines(iline).Lat, Lines(iline).Lon, 'Marker', '.', 'Color', col);
end

%--------------------------
% Output
%--------------------------

if nargout == 1
    varargout{1} = handles;
end

%--------------------------
% Subfunction: Parse color 
% table
%--------------------------

function [name, choices, colors] = parsecolortable(colortable, Struct)
if ~iscell(colortable) || length(colortable) ~= 3
    error('Color tables must be 1 x 3 cell arrays');
end
name = colortable{1};
choices = colortable{2};
colors = colortable{3};
if isempty(choices) && isempty(colors)
    attribClass = class(Struct(1).(name));
    switch attribClass
        case 'char'
            choices = unique({Struct.(name)});
        case {'logical', 'double'}
            choices = unique([Struct.(name)]);
        otherwise
            error('Attribute values must be character arrays or scalars');
    end
    colors  = jet(length(choices));
end
