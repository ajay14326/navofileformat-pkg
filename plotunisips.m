function plotunisips(input)
%PLOTUNISIPS Plots a unisips file
% 
% plotunisips(file)
% plotunisips(unisipsStructure)
%
% Plots the data in a unisips file or unisips structure.  The viewer
% contains two figures and an information bar:
%
% Entire image figure: This figure displays the entire unisips file.  It
% also serves as a panner for the full-resolution figure.  Currently, you
% should only pan when not zoomed in in the full-resolution figure.
%
% Full-resolution figure: This figure displays the portion of the image
% within the panner at full resolution (1 pixel per data point).  You can
% zoom in and pan around this portion of the image by left-clicking (zoom
% in 10%), right-clicking (zoom out 10%), and moving the pointer within the
% figure (pan).  Double-clicking returns to the original image.  
%
% Information bar: Displays information from the record headers.  Note that
% the Lon field displays longitude along the center of the file, not at
% individual points.
%
% The zoom-and-pan function for the full-resolution figure is derived from
% Brett Shoelson's zoom2cursor.m program, available from the Matlab Central
% File Exchange.
%
% Input variables:
%
%   file:               name of unisips file
%
%   unisipsStructure:   structure returned by unisipsread

% Copyright 2005 Kelly Kearney


%------------------------------
% Check input and load file
% if necessary
%------------------------------

inputIsFile = ischar(input) && exist(input, 'file');
inputIsUstruct = isstruct(input) && isfield(input, 'FileHeader') && ...
                 isfield(input, 'RecordHeader') && isfield(input, 'recordData');
             
if inputIsFile
    disp('Reading file...');
    Udata = unisipsread(input);
elseif inputIsUstruct
    Udata = input;
else
    error('Input must be either a unisips filename or a unisips structure');
end

%------------------------------
% Set up figures and axes
%------------------------------

% Determine figure sizes

scrn = get(0, 'ScreenSize');
[nrows, ncols] = size(Udata.recordData);

maxHeight = scrn(4) - 100;
w1 = 150;
h1 = (nrows*150)/ncols;
if h1 > maxHeight
    h1 = maxHeight;
    w1 = (h1*ncols)/nrows;
end

remainingWidth = scrn(3) - 150 - w1;
if ncols <= remainingWidth
    w2 = ncols;
else
    w2 = remainingWidth;
end
h2 = (3*w2)/4;
      
% Entire file figure (left)

handles.fig1 = figure('Position', [50 scrn(4)-50-h1 w1 h1], ...
                      'Name', 'Entire File', ...
                      'NumberTitle', 'off', ...
                      'MenuBar', 'none', ...
                      'Pointer', 'crosshair', ...
                      'Tag', 'fig1');
                 
handles.axis1 = subplot('Position', [0 0 1 1]); 
imagesc(Udata.recordData);
colormap(gray);
xlim = get(handles.axis1, 'XLim');
ylim = get(handles.axis1, 'YLim');
hold on;

handles.rectPlot = plot([1 w2 w2 1 1], [1 1 h2 h2 1], 'g', 'HitTest', 'off');
set(handles.rectPlot, 'Tag', 'pannerBox');
set(handles.axis1, 'XLim', xlim, 'YLim', ylim);

% Full resolution image: 1 pixel per data point (right)

handles.fig2 = figure('Position', [100+w1 scrn(4)-50-h2 w2 h2], ...
                      'Name', 'Full Resolution', ...
                      'NumberTitle', 'off', ...
                      'MenuBar', 'none', ...
                      'Pointer', 'crosshair', ...
                      'Tag', 'fig2');
                  
handles.axis2 = subplot('Position', [0 0 1 1]);
imagesc(Udata.recordData);
colormap(gray);
set(handles.axis2, 'XLim', [0 w2], 'YLim', [0 h2]);

% Information bar

handles.fig3 = figure('Position', [100+w1 scrn(4)-h2-150 w2 50], ...
                      'Name', 'Image information', ...
                      'NumberTitle', 'off', ...
                      'MenuBar', 'none', ...
                      'Tag', 'fig3', ...
                      'Color', 'w');

infoWidth = w2/6;
uicontrol(handles.fig3, 'Position', [10+infoWidth*0 25 infoWidth 20], 'String', 'Lat:',        'Tag', 'lat',       'Style', 'Text', 'BackgroundColor', 'w', 'HorizontalAlignment', 'left');
uicontrol(handles.fig3, 'Position', [10+infoWidth*1 25 infoWidth 20], 'String', 'Lon:',        'Tag', 'lon',       'Style', 'Text', 'BackgroundColor', 'w', 'HorizontalAlignment', 'left');
uicontrol(handles.fig3, 'Position', [10+infoWidth*2 25 infoWidth 20], 'String', 'Time:',       'Tag', 'time',      'Style', 'Text', 'BackgroundColor', 'w', 'HorizontalAlignment', 'left');
uicontrol(handles.fig3, 'Position', [10+infoWidth*3 25 infoWidth 20], 'String', 'Year:',       'Tag', 'year',      'Style', 'Text', 'BackgroundColor', 'w', 'HorizontalAlignment', 'left');
uicontrol(handles.fig3, 'Position', [10+infoWidth*4 25 infoWidth 20], 'String', 'Layback:',    'Tag', 'layback',   'Style', 'Text', 'BackgroundColor', 'w', 'HorizontalAlignment', 'left');
uicontrol(handles.fig3, 'Position', [10+infoWidth*0  5 infoWidth 20], 'String', 'Roll:',       'Tag', 'roll',      'Style', 'Text', 'BackgroundColor', 'w', 'HorizontalAlignment', 'left');
uicontrol(handles.fig3, 'Position', [10+infoWidth*1  5 infoWidth 20], 'String', 'Pitch:',      'Tag', 'pitch',     'Style', 'Text', 'BackgroundColor', 'w', 'HorizontalAlignment', 'left');
uicontrol(handles.fig3, 'Position', [10+infoWidth*2  5 infoWidth 20], 'String', 'Heading:',    'Tag', 'heading',   'Style', 'Text', 'BackgroundColor', 'w', 'HorizontalAlignment', 'left');
uicontrol(handles.fig3, 'Position', [10+infoWidth*3  5 infoWidth 20], 'String', 'Fish Speed:', 'Tag', 'fishSpeed', 'Style', 'Text', 'BackgroundColor', 'w', 'HorizontalAlignment', 'left');
uicontrol(handles.fig3, 'Position', [10+infoWidth*4  5 infoWidth 20], 'String', 'CB Depth:',   'Tag', 'cbDepth',   'Style', 'Text', 'BackgroundColor', 'w', 'HorizontalAlignment', 'left');
uicontrol(handles.fig3, 'Position', [10+infoWidth*5  5 infoWidth 20], 'String', 'TowDepth:',   'Tag', 'towDepth',  'Style', 'Text', 'BackgroundColor', 'w', 'HorizontalAlignment', 'left');

% Set additional properties

set(handles.fig1, 'CloseRequestFcn', {@closeAll});
set(handles.fig2, 'CloseRequestFcn', {@closeAll});
set(handles.fig3, 'CloseRequestFcn', {@closeAll});

set(handles.axis1, 'Tag', 'axis1');
set(handles.axis2, 'Tag', 'axis2');

setappdata(handles.fig1, 'panStatus', 0);

zoomPct = 1;
setappdata(handles.fig2, 'zoomPct', zoomPct);
setappdata(handles.fig2, 'fullresXlim', [0 w2]);
setappdata(handles.fig2, 'fullresYlim', [0 h2]);

setappdata(handles.fig1, 'Udata', Udata);

set(handles.fig1, 'WindowButtonDownFcn',   {@panner, 'down'}, ...
                  'WindowButtonUpFcn',     {@panner, 'up'}, ...
                  'WindowButtonMotionFcn', {@panner, 'move'}, ...
                  'KeyPressFcn',            @panwitharrows);
               
set(handles.fig2, 'WindowButtonDownFcn',   {@zoompan, 'zoom'}, ...
                  'WindowButtonMotionFcn', {@zoompan, 'move'});

%*****************************Subfunctions*********************************

%------------------------------
% Close Program
%------------------------------

function closeAll(hobj, ed)
delete(findobj('Tag', 'fig1'));
delete(findobj('Tag', 'fig2'));
delete(findobj('Tag', 'fig3'));

%------------------------------
% Panner motion (green box)
%------------------------------

function panner(hobj, ed, motionType)

switch motionType
    case 'down'
        setappdata(hobj, 'panStatus', 1);
    case 'up'
        setappdata(hobj, 'panStatus', 0);
    case 'move'
        panStatus = getappdata(hobj, 'panStatus');
        if panStatus
            
            zoomPct = getappdata(findobj('Tag', 'fig2'), 'zoomPct');
            if zoomPct ~= 1
                errordlg('Return to original resolution before panning', 'panerror', 'on');
                return
            end
            
            haxis1 = findobj('Tag', 'axis1');
            haxis2 = findobj('Tag', 'axis2');
            hfig2  = findobj('Tag', 'fig2');
            hbox   = findobj('Tag', 'pannerBox'); 
            
            pointerLoc = get(haxis1, 'CurrentPoint');
            xlim = get(haxis2, 'XLim');
            ylim = get(haxis2, 'YLim');
            width = diff(xlim);
            height = diff(ylim);
            pointerRow = pointerLoc(1,2);
            pointerCol = pointerLoc(1,1);
            xlimits = get(haxis1, 'XLim');
            ylimits = get(haxis1, 'YLim');
            
            xmax = min(pointerCol + width/2, xlimits(2));
            ymax = min(pointerRow + height/2, ylimits(2));
            xmin = xmax - width;
            ymin = ymax - height;

            if xmin < xlimits(1)
                xmin = xlimits(1);
                xmax = xlimits(1) + width;
            end
            if ymin < ylimits(1)
                ymin = ylimits(1);
                ymax = ylimits(1) + height;
            end
            
            fullresXlim = [xmin xmax];
            fullresYlim = [ymin ymax];
            
            setappdata(hfig2, 'fullresXlim', fullresXlim);
            setappdata(hfig2, 'fullresYlim', fullresYlim);
            
            set(haxis2, 'XLim', fullresXlim, 'YLim', fullresYlim);
            set(hbox, 'XData', [xmin xmax xmax xmin xmin], 'YData', [ymin ymin ymax ymax ymin]);
            
        end
end

%------------------------------
% Zoom and pan in full-res 
% figure
%------------------------------

function zoompan(hobj, ed, motionType)

% Zoom and pan

haxis2 = findobj('Tag', 'axis2');
zoomPct = getappdata(hobj, 'zoomPct');
pointerLoc = get(haxis2, 'CurrentPoint');
xPos = pointerLoc(1,1);
yPos = pointerLoc(1,2);

fullresXlim = getappdata(hobj, 'fullresXlim');
fullresYlim = getappdata(hobj, 'fullresYlim');
xrange = diff(fullresXlim);
yrange = diff(fullresYlim);

if strcmp(motionType, 'zoom')
    switch get(gcf,'selectiontype')
        case 'normal'
            zoomPct = max(0.01,zoomPct*0.9);
        case 'alt'
            zoomPct = min(1,zoomPct*1.1);
        case 'open'
            zoomPct = 1;
    end
end
    
xdist = zoomPct * xrange;
ydist = zoomPct * yrange;

x1 = min(max(fullresXlim(1),xPos-0.5*xdist), fullresXlim(1)+(xrange-xdist)) + 0.5;
y1 = min(max(fullresYlim(1),yPos-0.5*ydist), fullresYlim(1)+(yrange-ydist)) + 0.5;
x2 = x1 + xdist;
y2 = y1 + ydist;

set(haxis2, 'XLim', [x1 x2], 'YLim', [y1 y2]);
setappdata(hobj, 'zoomPct', zoomPct);
        
% Additional data based on pointer location

Udata = getappdata(findobj('Tag', 'fig1'), 'Udata');

set(findobj('Tag', 'lat'      ), 'String', sprintf('Lat: %f',        Udata.RecordHeader.lat(round(yPos))));
set(findobj('Tag', 'lon'      ), 'String', sprintf('Lon: %f',        Udata.RecordHeader.lon(round(yPos))));
set(findobj('Tag', 'time'     ), 'String', sprintf('Time: %f',       Udata.RecordHeader.time(round(yPos))));
set(findobj('Tag', 'year'     ), 'String', sprintf('Year: %d',       Udata.RecordHeader.year(round(yPos))));
set(findobj('Tag', 'layback'  ), 'String', sprintf('Layback: %f',    Udata.RecordHeader.layback(round(yPos))));
set(findobj('Tag', 'roll'     ), 'String', sprintf('Roll: %f',       Udata.RecordHeader.roll(round(yPos))));
set(findobj('Tag', 'pitch'    ), 'String', sprintf('Pitch: %f',      Udata.RecordHeader.pitch(round(yPos))));
set(findobj('Tag', 'heading'  ), 'String', sprintf('Heading: %f',    Udata.RecordHeader.heading(round(yPos))));
set(findobj('Tag', 'fishSpeed'), 'String', sprintf('Fish Speed: %f', Udata.RecordHeader.fishSpd(round(yPos))));
set(findobj('Tag', 'cbDepth'  ), 'String', sprintf('CB Depth: %f',   Udata.RecordHeader.cbDepth(round(yPos))));
set(findobj('Tag', 'towDepth' ), 'String', sprintf('Tow Depth: %f',  Udata.RecordHeader.towDepth(round(yPos))));

%------------------------------
% Move panner using keyboard 
% arrow keys
%------------------------------

function panwitharrows(hobj, ed)
curchar = double(get(hobj, 'CurrentCharacter'));
if ismember(curchar, [28 29 30 31])

    haxis1 = findobj('Tag', 'axis1');
    haxis2 = findobj('Tag', 'axis2');
    hfig2  = findobj('Tag', 'fig2');
    hbox   = findobj('Tag', 'pannerBox'); 
    
    xlimits = get(haxis1, 'XLim');
    ylimits = get(haxis1, 'YLim');
            
    panBoxX = get(hbox, 'XData');
    panBoxY = get(hbox, 'YData');
    xmaxOld = max(panBoxX);
    xminOld = min(panBoxX);
    ymaxOld = max(panBoxY);
    yminOld = min(panBoxY);
    
    xlim = get(haxis2, 'XLim');
    ylim = get(haxis2, 'YLim');
    width = diff(xlim);
    height = diff(ylim);
    
    xStep = .1 * width;
    yStep = .1 * height;
    
    switch curchar
        case 28 % left
            xmin = max(xminOld - xStep, xlimits(1));
            xmax = xmin + width;
            ymin = yminOld;
            ymax = ymaxOld;
        case 29 % right
            xmax = min(xmaxOld + xStep, xlimits(2));
            xmin = xmax - width;
            ymin = yminOld;
            ymax = ymaxOld;
        case 30 % up
            xmin = xminOld;
            xmax = xmaxOld;
            ymin = max(yminOld - yStep, ylimits(1));
            ymax = ymin + height;
        case 31 % down
            xmin = xminOld;
            xmax = xmaxOld;
            ymax = min(ymaxOld + yStep, ylimits(2));
            ymin = ymax - height;
    end
    
    fullresXlim = [xmin xmax];
    fullresYlim = [ymin ymax];
    
    setappdata(hfig2, 'fullresXlim', fullresXlim);
    setappdata(hfig2, 'fullresYlim', fullresYlim);

    set(haxis2, 'XLim', fullresXlim, 'YLim', fullresYlim);
    set(hbox, 'XData', [xmin xmax xmax xmin xmin], 'YData', [ymin ymin ymax ymax ymin]);
    
end




