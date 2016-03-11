function varargout = plothfevashape(varargin)
%PLOTHFEVASHAPE Plots the polygons in a hfeva shapefile
%
% plothfevashape(fileName)
% plothfevashape(fileName, north, south, east, west)
% handles = plothfevashape(...)
%
% This program plots the polygons in a hfeva shapefile to a mercator
% projection.
%
% Input variables:
%
%   fileName:       base name or full name of any shapefile component
%
%   north, south, 
%   east, west:     boundaries for plotted map.  If not included, the
%                   boundaries are set to the bounding box from the
%                   shapefile.
%
% Output variables:
%
%   handles:        structure holding the handles of the figure, map plot,
%                   map axis, and colorbar 

% Copyright 2005 Kelly Kearney

%--------------------------
% Check input and output 
% arguments
%--------------------------

if ~ismember(nargin, [1 5])
    error('Wrong number of input arguments');
end

if ~ismember(nargout, [0 1])
    error('Wrong number of output arguments');
end

if nargin == 5
    fileName = varargin{1};
    north    = varargin{2};
    south    = varargin{3};
    east     = varargin{4};
    west     = varargin{5};
elseif nargin == 1
    fileName = varargin{1};
    Info = shapeinfo(fileName);
    north = Info.BoundingBox(2,2);
    south = Info.BoundingBox(1,2);
    west  = Info.BoundingBox(1,1);
    east  = Info.BoundingBox(2,1);
end

%--------------------------
% Plot shapefile poygons 
%--------------------------

ShapefileData = hfevashaperead(fileName);

mInterval = (east - west)/5;
pInterval = (north - south)/5;

scrnsz = get(0, 'ScreenSize');
handles.figure = figure('Position', [(scrnsz(3)-800)/2 (scrnsz(4)-600)/2 800 600], ...
                        'Renderer', 'zbuffer', ...
                        'Color', 'w');

handles.mapPlot = subplot('Position', [.1 .1 .7 .8]);
handles.mapAxis = axesm('MapProjection', 'mercator', ...
                        'FLatLimit', [south north], ...
                        'FLonLimit', [west east], ...
                        'Grid', 'on', ...
                        'MLineLocation', mInterval, ...
                        'PLineLocation', pInterval, ...
                        'MeridianLabel', 'on', ...
                        'ParallelLabel', 'on', ...
                        'MLabelLocation', mInterval, ...
                        'PLabelLocation', pInterval, ...
                        'MLabelRound', -2, ...
                        'PLabelRound', -2);
                    
for ipoly = 1:length(ShapefileData)
    f     = ShapefileData(ipoly).patchFace;
    vlat  = ShapefileData(ipoly).patchVertices(:,2);
    vlon  = ShapefileData(ipoly).patchVertices(:,1);
    color = ShapefileData(ipoly).color;
    handles.patch(ipoly) = patchm(vlat(f'), vlon(f'), ...
                                  'FaceColor', color, ...
                                  'EdgeColor', 'none');
end
axis tight;

%--------------------------
% Plot colorbar
%--------------------------

handles.colorbar = hfevacolorbar([.85 .1 .12 .8], 7);

if nargout == 1
    varargout{1} = handles;
end