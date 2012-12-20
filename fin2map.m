function [refvec, map, verts] = fin2map(varargin)
%FIN2MAP Returns the reference vector and map for a fin file structure
%
% [refvec, map, verts] = fin2map(S)
% [refvec, map, verts] = fin2map(S, gridsize)
%
% This function converts the data in a fin file structure (created via
% finread, sparsefinread, or fininfo) to Matlab's standard map and
% reference vector format.  It also returns the matrix of points defining
% the outline of the resulting grids.  
%
% Input variables:
%
%   S:          fin file structure
%
%   gridsize:   1 x 2 size vector, [nrows ncols], specifying the size of
%               the output grids.  Note that grids along the northern and
%               eastern edge may vary from this size if the dataset does
%               not evenly divide into grids of this size.
%
% Output variables:
%
%   If a gridsize is provided, these variables will instead be m x n cell
%   arrays holding the indicated values for each resulting grid.  
%
%   refvec:     1 x 3 reference vector. 
%
%   map:        grid of data values.  If S does not include a dataGrid
%               field (i.e. was created via fininfo), map will be empty.
%
%   verts:      n x 2 array, [lat lon], of polygon surrounding the data
%               grid

% Copyright 2006 Kelly Kearney

%--------------------------
% Check and parse input
%--------------------------

S = varargin{1};
finfields = {'westLon', 'eastLon', 'southLat', 'northLat', ...
             'gridInterval', 'width', 'height', 'endianValue', ...
             'minimumValue', 'maximumValue'};
             
if ~isstruct(S) || ~all(isfield(S, finfields))
    error('S must be a fin file structure');
end
nodata = false;
if ~isfield(S, 'dataGrid')
    nodata = true;
    S.dataGrid = spalloc(S.height, S.width, 0);
end

if nargin == 2
    gridsize = varargin{2};
    if ~all(size(gridsize) == [1 2])
        error('gridsize must be a 1 x 2 vector');
    end
end

%--------------------------
% Create grid(s) and 
% reference vector(s)
%--------------------------

cellsperdegree = 60/S.gridInterval;

if nargin == 1
    
    refvec = [cellsperdegree S.northLat S.westLon];
    [latlim, lonlim] = limitm(S.dataGrid, refvec);
    verts = [latlim(1) lonlim(1); latlim(2) lonlim(1); latlim(2) lonlim(2); latlim(1) lonlim(2); latlim(1) lonlim(1)];
    if nodata
        map = [];
    else
        map = S.dataGrid;
    end
    
else
    
    % Indices of smaller grids
    
    row1 = 1:gridsize(1):S.height;
    col1 = 1:gridsize(2):S.width;
    row2 = row1 + (gridsize(1)-1);
    col2 = col1 + (gridsize(2)-1);
    row2(length(row2)) = S.height;
    col2(length(col2)) = S.width;
    
    % Make sure no grid contains only one row or column
    
    if (row1(end) == row2(end))
        row1(end) = [];
        row2(end) = [];
        row2(end) = row2(end) + 1;
    end
    if (col1(end) == col2(end))
        col1(end) = [];
        col2(end) = [];
        col2(end) = col2(end) + 1;
    end
    
    nrows = length(row1);
    ncols = length(col1);
    
    map    = cell(nrows, ncols);
    refvec = cell(nrows, ncols);
    verts  = cell(nrows, ncols);
    for irow = 1:nrows
        for icol = 1:ncols
            
            if ~nodata
                map{irow, icol} = S.dataGrid(row1(irow):row2(irow), col1(icol):col2(icol));
            end
                
            [south, west] = setltln(S.dataGrid, [cellsperdegree S.northLat, S.westLon], row1(irow), col1(icol));
            [north, east] = setltln(S.dataGrid, [cellsperdegree S.northLat, S.westLon], row2(irow), col2(icol));

            refvec{irow,icol} = [cellsperdegree north west];
            
            if nodata
                nmaprow = length(row1(irow):row2(irow));
                nmapcol = length(col1(icol):col2(icol));
                [latlim, lonlim] = limitm(zeros(nmaprow, nmapcol), refvec{irow, icol});
            else
                [latlim, lonlim] = limitm(map{irow, icol}, refvec{irow, icol});
            end
            verts{irow, icol} = [latlim(1) lonlim(1); latlim(2) lonlim(1); latlim(2) lonlim(2); latlim(1) lonlim(2); latlim(1) lonlim(1)];
                    
        end
    end
    
end
    
            
            
            
            
            
            
            
    
    
    
    
