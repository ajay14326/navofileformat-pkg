function NewStruct = refvecvert(OldStruct)
%REFVECVERT Adds refvec and vertices fields to the structure
%
% NewStruct = refvecvert(OldStruct)
%
% This program adds the fields refvec and vertices to a fin file
% structure created via finread.m or fininfo.m. 
%
% Input variables:
%
%   OldStruct:  structure created by finread or fininfo
%
% Output variables:
%
%   NewStruct:  copy of OldStruct with the additional fields:
%
%               refvec:     reference vector for the grid
%
%               vertices:   5 x 2 matrix containing longitude (x) values in
%                           the first column and latitude (y) values in the
%                           second, defining the rectangle around the grid

NewStruct = OldStruct;
NewStruct.refvec = [60/NewStruct.gridInterval NewStruct.northLat NewStruct.westLon];

if isfield(NewStruct, 'dataGrid')
    [latlim, lonlim] = limitm(NewStruct.dataGrid, NewStruct.refvec);
else
    [latlim, lonlim] = limitm(zeros(NewStruct.height, NewStruct.width), NewStruct.refvec);
end
NewStruct.vertices = [latlim(1) lonlim(1); latlim(2) lonlim(1); latlim(2) lonlim(2); latlim(1) lonlim(2); latlim(1) lonlim(1)];

