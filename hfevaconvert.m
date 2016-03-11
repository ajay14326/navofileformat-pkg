function newvalue = hfevaconvert(value, convertfrom, convertto)
%HFEVACONVERT Converts between HFEVA values based on reference table
%
% newvalue = hfevaconvert(value, convertfrom, convertto)
% 
% This function performs conversions between HFEVA sediment values using
% the HFEVA reference table. 
%
% If multiple matches are found (e.g. converting from rmz to cat), only the
% first is returned.  If convertto is either 'label' or 'color', newvalue
% with be a cell array with the same dimensions as value.  Otherwise,
% newvalue will be a numeric array.
%
% Input variables:
%
%   value:          original values, any dimension.  Numerical array if
%                   original values are type IDs, categories, or RMZ
%                   values, cell array if originalvalues are labels or
%                   color values     
%
%   convertfrom:    'typeid', 'label', 'cat', 'rmz'
%
%   convertto:      'typeid', 'label', 'cat', 'rmz', 'color'
%
% Output variables:
%
%   newvalue:       converted values.  If convertto is either 'label' or
%                   'color', newvalue with be a cell array with the same
%                   dimensions as value.  Otherwise, newvalue will be a
%                   numeric array.   

% Copyright 2005 Kelly Kearney

hfevaRef = hfevatable;
columns = {'typeid', 'label', 'cat', 'color', 'rmz'};

[checkFrom, fromIndex] = ismember(convertfrom, columns);
[checkTo,   toIndex]   = ismember(convertto,   columns);

% Get row indices

originalSize = size(value);
value = value(:);
switch convertfrom
    case {'typeid', 'cat', 'rmz'}
        startCat = cell2mat(hfevaRef(:,fromIndex));
        [tf, valueIndex] = ismember(value, startCat);
        if ~all(tf)
            error('Values must belong to the convertfrom type');
        end
    case 'label'
        [tf, valueIndex] = ismember(value, hfevaRef(:,2));
        if ~all(tf)
            error('Values must belong to the convertfrom type');
        end
        
end
endCat = hfevaRef(:,toIndex);
newvalue = endCat(valueIndex);

switch convertto
    case {'color', 'label'}
        newvalue = reshape(newvalue, originalSize);
    case {'typeid', 'cat', 'rmz'}
        newvalue = cell2mat(newvalue);
        newvalue = reshape(newvalue, originalSize);
end