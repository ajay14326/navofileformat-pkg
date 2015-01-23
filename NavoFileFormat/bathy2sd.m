function bathy2sd(bathyfiles, cmapfile, outputfile)
%BATHYSED2SD Create Fledermaus surface of bathymetry
%
% bathy2sd(bathyfiles, cmapfile, outputfile)
%
% This function creates a Fledermaus data object (*.sd file) of bathymetry
% from .fin files.  The bathymetry values are determined my merging
% the data in the given bathymetry files.  This function uses Fledermaus
% command line functions to construct the data object, and therefore
% requires Fledermaus along with a valid license in order to run. 
%
% Input variables:
%
%   bathyfiles: string or cell array of strings with filename(s) of *.fin
%               bathymetry files.  Ideally, all bathymetry files should
%               have the same resolution; if differences exist, the
%               coarsest resolution will be used.
%
%   cmapfile:   name of Fledermaus colormap file
%
%   outputfile: name of output .sd file

% Copyright 2006 Kelly Kearney

%----------------------------
% Check input
%----------------------------

if ischar(bathyfiles)
    bathyfiles = cellstr(bathyfiles);
end
nbathyfiles = length(bathyfiles);
for ifile = 1:nbathyfiles
    if ~exist(bathyfiles{ifile}, 'file')
        error('Could not find bathymetry file: %s', bathyfiles{ifile});
    end
end

if ~exist(cmapfile, 'file')
    error('Could not find colormap file');
end

if ~ischar(outputfile)
    error('Outputfile must be a string');
end

%----------------------------
% Determine cell size
%----------------------------

for ifin = 1:nbathyfiles
    Header(ifin) = fininfo(bathyfiles{ifin});
end
cellSize = max([Header.gridInterval])/60;

%----------------------------
% Quote filenames with spaces
% to avoid errors with 
% command line functions
%----------------------------

for ifin = 1:nbathyfiles
    if any(isspace(bathyfiles{ifin}));
        bathyfiles{ifin} = sprintf('"%s"', bathyfiles{ifin});
    end
end
if any(isspace(cmapfile))
    cmapfile = sprintf('"%s"', cmapfile);
end
if any(isspace(outputfile))
    outputfile = sprintf('"%s"', outputfile);
end

%----------------------------
% Use Fledermaus command
% line functions to create
% data object
%----------------------------

% Create dtm files from fin files

fprintf('Converting from .fin to .dtm\n');
for ifin = 1:nbathyfiles
    [s,r] = system(sprintf('cmdop fintoscalar -in %s -out bathy%02d -dtm', bathyfiles{ifin}, ifin));  
end

% Merge dtm files

fprintf('Merging .dtm files\n');
bathyString = sprintf('bathy%02d.dtm ', 1:nbathyfiles);
[s,r] = system(sprintf('cmdop dtmmerge -in %s -out allbathy.dtm -cellsize %f', bathyString, cellSize));

% Create shade file

fprintf('Creating shade file\n');
[s,r] = system(sprintf('cmdop shade -dtm allbathy.dtm -cmap %s -out bathy.shade', cmapfile));

% Assemble sd object

fprintf('Assembling .sd file\n');
[s,r] = system(sprintf('cmdop objectbuilder -t SonarDTM -out %s -in allbathy.dtm bathy.shade allbathy.geo', outputfile));

%----------------------------
% Delete intermediate files
%----------------------------

delete('allbathy.dtm', 'allbathy.geo', 'bathy.shade');
for ifile = 1:nbathyfiles
    delete(sprintf('bathy%02d.dtm', ifile), ...
           sprintf('bathy%02d.geo', ifile));
end
