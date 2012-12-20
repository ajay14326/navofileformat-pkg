function bathysed2sdui
%BATHYSED2SD Graphical user interface for bathysed2sd
%
% bathysed2sdui
%
% This function calls a gui to create a Fledermaus data object (*.sd file)
% of bathymetry with a sediment overlay.  It is a gui wrapper for the
% bathysed2sd function.

% Copyright 2006 Kelly Kearney

%---------------------------
% File selection gui
%---------------------------

sedFiletypes = {...
                '*.shp; *.chrtr', 'Sediment Files (*.shp, *.chrtr)'
                '*.*', 'All Files'};

bathyFiletypes = {...
                '*.fin', 'Bathymetry Files (*.fin)'
                '*.*', 'All Files'};
            
outputFiletypes = {...
                '*.sd', 'Fledermaus Data Object Files (*.sd)'
                '*.*', 'All Files'};

bgCol = [.8 .8 .8];
scrn = get(0, 'ScreenSize');

figure('Position', [(scrn(3)-400)/2 (scrn(4)-295)/2 400 295], ...
       'Color', bgCol, ...
       'Name', 'bathysed2sd', ...
       'NumberTitle', 'off', ...
       'Menubar', 'none', ...
       'Tag', 'bathysed2sdFig');

uicontrol('Position', [ 10 265 270  20], 'Style', 'Text', 'String', 'Bathymetry Files:', 'HorizontalAlignment', 'left', 'BackgroundColor', bgCol);
uicontrol('Position', [ 10 215 270  50], 'Style', 'Edit', 'BackgroundColor', 'w', 'Tag', 'bathyFile', 'Max', 2, 'HorizontalAlignment', 'left');
uicontrol('Position', [290 215 100  20], 'Style', 'pushbutton', 'String', 'Browse...', 'Callback', {@browse, 'bathyFile', bathyFiletypes});
 
uicontrol('Position', [ 10 190 270  20], 'Style', 'Text', 'String', 'Sediment Files:', 'HorizontalAlignment', 'left', 'BackgroundColor', bgCol);
uicontrol('Position', [ 10 140 270  50], 'Style', 'Edit', 'BackgroundColor', 'w', 'Tag', 'sedFile', 'Max', 2, 'HorizontalAlignment', 'left');
uicontrol('Position', [290 140 100  20], 'Style', 'pushbutton', 'String', 'Browse...', 'Callback', {@browse, 'sedFile', sedFiletypes});
      
uicontrol('Position', [ 10  70 270  20], 'Style', 'Text', 'String', 'Output File:', 'HorizontalAlignment', 'left', 'BackgroundColor', bgCol);
uicontrol('Position', [ 10  50 270  20], 'Style', 'Edit', 'BackgroundColor', 'w', 'Tag', 'outputFile', 'HorizontalAlignment', 'left');
uicontrol('Position', [290  50 100  20], 'Style', 'pushbutton', 'String', 'Browse...', 'Callback', {@browseout, 'outputFile', outputFiletypes});

uicontrol('Position', [ 10  10 100  20], 'Style', 'pushbutton', 'String', 'Create sd file', 'Callback', @createsd);

%---------------------------
% Browse for input files 
% callback
%---------------------------

function browse(hobj, ed, edittag, filterspec)
oldFiles = get(findobj('Tag', edittag), 'String');
[filename, filepath] = uigetfile(filterspec, 'Choose file(s)', 'MultiSelect', 'on');
if isscalar(filename) && ~filename && ~filepath
    return
end
if ischar(filename)
    filename = {filename};
end
newFiles = cellfun(@(f) fullfile(filepath, f), filename, 'UniformOutput', false);
set(findobj('Tag', edittag), 'String', [oldFiles newFiles]);

%---------------------------
% Browse for output file 
% callback
%---------------------------

function browseout(hobj, ed, edittag, filterspec)
[filename, filepath] = uiputfile(filterspec, 'Choose file(s)');
if isscalar(filename) && ~filename && ~filepath
    return
end
set(findobj('Tag', edittag), 'String', fullfile(filepath, filename));

%---------------------------
% Create sd file
%---------------------------

function createsd(hobj, ed)
bathyFilenames = get(findobj('Tag', 'bathyFile'), 'String');
sedFilenames = get(findobj('Tag', 'sedFile'), 'String');
outputFilename = get(findobj('Tag', 'outputFile'), 'String');
bathysed2sd(bathyFilenames, sedFilenames, outputFilename);
close(findobj('Tag', 'bathysed2sdFig'));