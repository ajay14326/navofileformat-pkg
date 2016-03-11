function varargout = hfevacolorbar(varargin)
%HFEVACOLORBAR Adds a vertical HFEVA colorbar to current figure
% 
% hfevacolorbar(positionVector, fontSize);
% hfevacolorbar(positionVector, fontSize, indices);
% h = hfevacolorbar(...)
%
% This program adds a vertical colorbar in the position indicated by
% positionVector.  Each color is labeled by HFEVA standard sediment type,
% using the fontSize specified.  The colorbar is for labeling purposes
% only; it is not associated with and has no impact on the colormaps of any
% existing axes. 
%
% If an array of indices in provided, only those sediment types are
% included.  See hfevatable for available sediment types and corresponding
% indices.
%
% Input variables:
%
%   positionVector: 1 x 4 vector, [left bottom width height]
%
%   fontSize:       font size to be used for colorbar labels
%
%   indices:        vector of indices correspnding to the sediment types to
%                   be displayed.  See hfevatable for available sediment
%                   types and corresponding indices.
%
% Output variables:
%
%   h:              handle of new colorbar

% Copyright 2005 Kelly Kearney

if nargin == 2
    positionVector = varargin{1};
    fontSize = varargin{2};
    indices = 1:34;
elseif nargin == 3
    positionVector = varargin{1};
    fontSize = varargin{2};
    indices = varargin{3};
end

hfeva = hfevatable;
colorCodes = cell2mat(hfeva(indices,4)) ./ 255;
names = hfeva(indices,2)';

dy = 1/(length(indices));
ybot = 0:dy:1-dy;
ytop = dy:dy:1;
ymid = mean([ybot;ytop]);

Y = [ybot; ybot; ytop; ytop; ybot];
X = repmat([0 1 1 0 0]', 1, length(indices));
C = zeros(1,length(indices),3);
C(1,:,:) = colorCodes;

handles.cb = axes('Position', positionVector);
patch(X, Y, C);
text(repmat(.5, 1, length(indices)), ymid, names, 'FontSize', fontSize, 'HorizontalAlignment', 'center'); 
set(handles.cb, 'XLim', [0 1], 'YLim', [0 1], 'Visible', 'off');

if nargout == 1
    varargout{1} = handles.cb;
end
