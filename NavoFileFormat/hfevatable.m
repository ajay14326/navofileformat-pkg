function table = hfevatable
%HFEVATABLE Returns HFEVA sediment properties
%
% table = hfevatable
%
% This function returns a lookup table of HFEVA sediment values.  The table
% is a cell array with the following columns: 
%   
%   Type ID:            Categorization system for the HFEVA 23 system
%
%   Sediment Type:      HFEVA standard sediment type, a label associated
%                       with each of the 32 sediment types, plus 'No Data'
%                       and 'Land' categories  
%   
%   Sediment Category:  Categorization system for the HFEVA 32 system
%
%   Color:              [red green blue] array for standard colors
%                       associated with each sediment type.  Values are
%                       listed for a 0-255 scale.  
%
%   RMZ:                mean grain size (phi) associated with each sediment
%                       type 
%
% There are 34 rows in the table, corresponding to the 32 sediment types,
% plus categories for No Data and Land.
%
% Output variables:
%
%   table:  34 x 5 cell array of HFEVA table data

% Copyright 2006 Kelly Kearney

table = {...
   1, 'Rough Rock'         ,  54, [220   0 220], -9.0
   2, 'Rock'               ,   1, [255   0 0  ], -7.0
   3, 'Cobble'             ,  61, [255 150 150], -3.0
   3, 'Gravel'             ,  12, [255 150 150], -3.0
   3, 'Pebble'             ,  62, [255 150 150], -3.0
   4, 'Sandy Gravel'       ,  13, [255 190 190], -1.0
   5, 'Very Coarse Sand'   ,  21, [255 220 220], -0.5
   6, 'Muddy Sandy Gravel' ,  15, [255 180 0  ],  0.0
   7, 'Coarse Sand'        ,  22, [255 215 0  ],  0.5
   7, 'Gravelly Sand'      ,  20, [255 215 0  ],  0.5
   8, 'Gravelly Muddy Sand',  18, [210 190 30 ],  1.0
   9, 'Sand'               ,   2, [255 235 0  ],  1.5
   9, 'Medium Sand'        ,  23, [255 235 0  ],  1.5
  10, 'Muddy Gravel'       ,  17, [185 195 40 ],  2.0
  11, 'Fine Sand'          ,  24, [255 255 140],  2.5
  11, 'Silty Sand'         ,   3, [255 255 140],  2.5
  12, 'Muddy Sand'         ,  95, [215 225 155],  3.0
  13, 'Very Fine Sand'     ,  25, [255 255 220],  3.5
  14, 'Clayey Sand'        ,  26, [215 235 200],  4.0
  15, 'Coarse Silt'        ,  53, [200 255 105],  4.5
  16, 'Sandy Silt'         ,   4, [160 230 175],  5.0
  16, 'Gravelly Mud'       ,  33, [160 230 175],  5.0
  17, 'Medium Silt'        ,  52, [150 225 150],  5.5
  17, 'Sand-Silt-Clay'     ,   9, [150 225 150],  5.5
  18, 'Silt'               ,   5, [175 240 215],  6.0
  18, 'Sandy Mud'          ,  96, [175 240 215],  6.0
  19, 'Fine Silt'          ,  51, [25  255 200],  6.5
  19, 'Clayey Silt'        ,   6, [25  255 200],  6.5
  20, 'Sandy Clay'         ,  42, [170 200 225],  7.0
  21, 'Very Fine Silt'     ,  50, [70  230 255],  7.5
  22, 'Silty Clay'         ,   7, [165 170 230],  8.0
  23, 'Clay'               ,   8, [140 140 255],  9.0
 888, 'No Data'            , 888, [255 255 255],  NaN
 999, 'Land'               , 999, [200 200 200],  NaN};