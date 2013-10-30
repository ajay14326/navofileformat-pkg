function NewStruct = smallergrids(varargin)
%SMALLERGRIDS Breaks a binary charter file structure into smaller grids
%
% NewStruct = smallergrids(FinStruct)
% NewStruct = smallergrids(FinStruct, OldStruct)
%
% This program breaks the data grid in FinStruct into several smaller
% grids.  FinStruct is created by reading a binary charter file (via
% finread.m).  NewStruct is an n x 1 structure with the following
% fields:
%
% Input variables:
%
%   FinStruct:  structure created via finread or sparsefinread
%
%   OldStruct:  n x 1 structure with the same fields as the output
%               structure.  If included, the new grids created from
%               FinStruct are added to this structure.
%
% Output variables:
%
%   NewStruct:  n x 1 structure with the following fields:
%
%               dataGrid:   200 x 200 grid (smaller for edges) of data
%                           values 
%
%               refvec:     reference vector for the grid
%
%               vertices:   5 x 2 matrix containing latitude (y) values in
%                           the first column and longitude (x) values in
%                           the second, defining the rectangle around the
%                           grid (for inpolygon tests)   

% Copyright 2004-2005 Kelly Kearney

switch nargin
    case 1
        FinStruct = varargin{1};
        newgridCount = 1;
    case 2
        FinStruct = varargin{1};
        OldStruct = varargin{2};
        NewStruct = OldStruct;
        newgridCount = length(OldStruct) + 1;
    otherwise
        error('Wrong number of input arguments');
end

charterRefvec = [60/FinStruct.gridInterval FinStruct.northLat FinStruct.westLon];

[nrows, ncols] = size(FinStruct.dataGrid);
startRows = 1:200:nrows;
endRows   = startRows + 199;
startCols = 1:200:ncols;
endCols   = startCols + 199;
endRows(length(endRows)) = nrows;
endCols(length(endCols)) = ncols;
if (startRows(end) == endRows(end))
    startRows(end) = [];
    endRows(end) = [];
    endRows(end) = endRows(end) + 1;
end
if (startCols(end) == endCols(end))
    startCols(end) = [];
    endCols(end) = [];
    endCols(end) = endCols(end) + 1;
end

for irow = 1:length(startRows)
    for icol = 1:length(startCols)
        NewStruct(newgridCount).dataGrid = FinStruct.dataGrid(startRows(irow):endRows(irow), startCols(icol):endCols(icol));
        [south, west] = setltln(FinStruct.dataGrid, charterRefvec, startRows(irow), startCols(icol)); 
        [north, east] = setltln(FinStruct.dataGrid, charterRefvec, endRows(irow),   endCols(icol));
        NewStruct(newgridCount).refvec = [60/FinStruct.gridInterval north west];
        [latlim, lonlim] = limitm(NewStruct(newgridCount).dataGrid, NewStruct(newgridCount).refvec);
        NewStruct(newgridCount).vertices = [latlim(1) lonlim(1); latlim(2) lonlim(1); latlim(2) lonlim(2); latlim(1) lonlim(2); latlim(1) lonlim(1)];
        newgridCount = newgridCount + 1;
    end
end



