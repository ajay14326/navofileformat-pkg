function plotfin(filename)
%PLOTFIN Creates a quick plot of data in a charter file
%
% plotfin(filename)
%
% This function plots the data in a fin file to a mercator axis.  For quick
% plots, no labels, colorbars, etc.
%
% Input variables:
%
%   filename: name of fin file

% Copyright 2006 Kelly Kearney

Data = sparsefinread(filename);
[refvec, map] = fin2map(Data);

isnull = map > (Data.maximumValue + 100);
map(isnull) = NaN;

mInterval = (Data.eastLon - Data.westLon)/5;
pInterval = (Data.northLat - Data.southLat)/5;

figure;
axesm('MapProjection', 'mercator', ...
      'FLatLimit', [Data.southLat Data.northLat], ...
      'FLonLimit', [Data.westLon Data.eastLon], ...
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
meshm(map, refvec);
colorbar;