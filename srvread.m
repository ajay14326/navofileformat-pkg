function Data = srvread(filename)
%SRVREAD Reads an ISS-60 survey file
%
% Data = srvread(filename)
%
% Reads data from an ISS-60 survey file.
%
% Input variables:
%
%   filename:   name of survey file
%
% Output variables:
%
%   Data:       1 x 1 structure with the following fields:
%
%               name:           name of survey (appears as "Description"
%                               when file is loaded in ISS-60) 
%
%               WaypointLabel:  1 x 1 structure
%
%                   base:                   base name for waypoints
%                   initial:                initial counter for waypoint 
%                                           names
%                   increment:  counter step size for new waypoint names
%
%               TransectLabel:  1 x 1 structure
%                   base:                   base name for transects
%                   initial:                initial counter for transect 
%                                           names
%                   increment:              counter step size for new 
%                                           transect names
%
%               Ladder:         1 x 1 structure of details associated with
%                               a ladder survey (fields will be empty if
%                               file was not created as a ladder survey) 
%                   refWptLabel:            label of reference waypoint
%                   refWptRepresentation:   representation of reference 
%                                           waypoint
%                   distance:               length of survey lines, m
%                   azimuth:                azimuth of survey lines
%                   space:                  distance between survey lines,
%                                           m
%                   lead:                   length of leadins and leadouts,
%                                           m
%                   count:                  number of lines in survey
%                   xtrackAzimuth:          crosstrack azimuth
%                   xtrackSpace:            crosstrack spacing, m
%                               
%               Ellipse:        1 x 1 structure of details associated with
%                               an ellipse survey (fields will be empty if
%                               file was not created as an ellipse survey)
%                   refWptLabel:            label of reference waypoint
%                   majorAxis:              length of major axis, m
%                   minorAxis:              length of minor axis, m
%                   majorAzimuth:           azimuth of major axis
%                   space:                  distance between survey lines,
%                                           m
%                   azimuth:                azimuth of survey lines
%                   lead:                   length of leadins and leadouts,
%                                           m
%
%               Polygon:        1 x 1 structure of details associated with
%                               an ellipse survey (fields will be empty if
%                               file was not created as an ellipse survey)
%                   wptLabel:               name of waypoints
%                   space:                  distance between survey lines,
%                                           m        
%                   azimuth:                azimuth of survey lines
%                   lead:                   length of leadins and leadouts,
%                                           m
%                   count:                  number of lines in survey
%                   xtrackAzimuth:          crosstrack azimuth
%                   xtrackSpace:            crosstrack spacing, m
%
%               area:           name of area file used to create the
%                               survey, empty if no area file was used
%
%               Transect:       1 x 1 structure holding details of
%                               transects.  Each field holds a n x 1 array
%                               or cell array, where n is the number of
%                               transect lines in the survey
%                   name:                   transect line label
%                   wptLabel1:              label of endpoint waypoint 1
%                   wptLabel2:              label of enpoint waypoint 2
%                   status:                 8-character string, see ISS-60
%                                           documentation for explanation
%                   direction:              8-character string, see ISS-60
%                                           documentation for explanation
%                   distance:               length of transect line, but
%                                           often holds 0 since this is no
%                                           longer used in ISS-60
%
%               Waypoint:       1 x 1 structure holding details of
%                               waypoints.  Each field holds a n x 1 array
%                               or cell array, where n is the number of
%                               waypoints in the survey
%                   label:                  waypoint label
%                   lat:                    latitude of waypoint
%                   lon:                    longitude of waypoint
%                   name:                   name of waypoint
%                   depth:                  depth of waypoint, m
%                   status:                 8-character string, see ISS-60
%                                           documentation for explanation
%                   connect:                specifies whether to connect
%                                           waypoint to previous waypoint

% Copyright 2006 Kelly Kearney

%-----------------------------
% Group file line types
%-----------------------------

perl('parsesrv.pl', filename);

%-----------------------------
% Read survey info
%-----------------------------

fid = fopen('other.temp', 'rt');

a1 = fgetl(fid);
if str2num(a1(1))
    Data.name = a1(3:end);
else
    Data.name = '';
end

a2 = textscan(fid, '%d', 1);
if a2{1}
    b2 = textscan(fid, '%s %d %d', 1);
    Data.WaypointLabel.base = b2{1}{:};
    Data.WaypointLabel.initial = b2{2};
    Data.WaypointLabel.increment = b2{3};
else
    Data.WaypointLabel.base = '';
    Data.WaypointLabel.initial = [];
    Data.WaypointLabel.increment = [];
end

a3 = textscan(fid, '%d', 1);
if a3{1}
    b3 = textscan(fid, '%s %d %d', 1);
    Data.TransectLabel.base = b3{1}{:};
    Data.TransectLabel.initial = b3{2};
    Data.TransectLabel.increment = b3{3};
else
    Data.TransectLabel.base = '';
    Data.TransectLabel.initial = [];
    Data.TransectLabel.increment = [];
end

a4 = textscan(fid, '%d', 1);
if a4{1}
    b4 = textscan(fid, '%s %s %f %f %f %f %f %f %f %f', 1);
    Data.Ladder.refWptLabel = b4{1}{:};
    Data.Ladder.refWptRepresentation = b4{2}{:};
    Data.Ladder.distance = b4{3};
    Data.Ladder.azimuth = b4{4};
    Data.Ladder.space = b4{5};
    Data.Ladder.lead = b4{6};
    Data.Ladder.count = b4{7};
    Data.Ladder.xtrackAzimuth = b4{8};
    Data.Ladder.xtrackSpace = b4{9};
else
    Data.Ladder.refWptLabel = '';
    Data.Ladder.refWptRepresentation = '';
    Data.Ladder.distance = [];
    Data.Ladder.azimuth = [];
    Data.Ladder.space = [];
    Data.Ladder.lead = [];
    Data.Ladder.count = [];
    Data.Ladder.xtrackAzimuth = [];
    Data.Ladder.xtrackSpace = [];
end
    
a5 = textscan(fid, '%d', 1);
if a5{1}
    b5 = textscan(fid, '%s %f %f %f %f %f %f', 1);
    Data.Ellipse.refWptLabel = b5{1}{:};
    Data.Ellipse.majorAxis = b5{2};
    Data.Ellipse.minorAxis = b5{3};
    Data.Ellipse.majorAzimuth = b5{4};
    Data.Ellipse.space = b5{5};
    Data.Ellipse.azimuth = b5{6};
    Data.Ellipse.lead = b5{7};
else
    Data.Ellipse.refWptLabel = '';
    Data.Ellipse.majorAxis = [];
    Data.Ellipse.minorAxis = [];
    Data.Ellipse.majorAzimuth = [];
    Data.Ellipse.space = [];
    Data.Ellipse.azimuth = [];
    Data.Ellipse.lead = [];
end

a6 = textscan(fid, '%d', 1);
if a6{1}
    b6 = textscan(fid, '%s %f %f %f %f %f %f', 1);
    Data.Polygon.wpt1Label = b6{1}{:};
    Data.Polygon.space = b6{2};
    Data.Polygon.azimuth = b6{3};
    Data.Polygon.lead = b6{4};
    Data.Polygon.count = b6{5};
    Data.Polygon.xtrackAzimuth = b6{6};
    Data.Polygon.xtrackSpace = b6{7};
else
    Data.Polygon.wpt1Label = '';
    Data.Polygon.space = [];
    Data.Polygon.azimuth = [];
    Data.Polygon.lead = [];
    Data.Polygon.count = [];
    Data.Polygon.xtrackAzimuth = [];
    Data.Polygon.xtrackSpace = [];
end

a7 = textscan(fid, '%d', 1);
if a7{1}
    b7 = textscan(fid, '%s', 1);
    Data.area = b7{1}{:};
else
    Data.area = '';
end

fclose(fid);

%-----------------------------
% Read transect info
%-----------------------------

fid = fopen('lines.temp', 'rt');
c = textscan(fid, '%s %s %s %s %s %f');
fclose(fid);

Data.Transect.name = c{1};
Data.Transect.wpt1Label = c{2};
Data.Transect.wpt2Label = c{3};
Data.Transect.status = c{4};
Data.Transect.direction = c{5};
Data.Transect.distance = c{6};

%-----------------------------
% Read waypoint info
%-----------------------------

fid = fopen('wpt.temp', 'rt');
d = textscan(fid, '%s %f %f %s %f %s %f');
fclose(fid);

Data.Waypoint.label = d{1};
Data.Waypoint.lat = d{2};
Data.Waypoint.lon = d{3};
Data.Waypoint.name = d{4};
Data.Waypoint.depth = d{5};
Data.Waypoint.status = d{6};
Data.Waypoint.connect = d{7};

%-----------------------------
% Read exclusion info
%-----------------------------

fid = fopen('exclude.temp', 'rt');
e = textscan(fid, '%s %s');
fclose(fid);

Data.Exclude.type = e{1};
Data.Exclude.name = e{2};

%-----------------------------
% Delete temporary files
%-----------------------------

delete exclude.temp lines.temp other.temp wpt.temp;