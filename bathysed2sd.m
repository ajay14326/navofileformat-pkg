function bathysed2sd(bathyfiles, sedfiles, outputfile)
%BATHYSED2SD Create Fledermaus surface of bathymetry with sediment overlay
%
% This function uses the bathymetry and sediment data in the input files to
% create a Fledermaus data object (*.sd file) of bathymetry with a sediment
% overlay.  This function uses Fledermaus command line functions to
% construct the data object, and therefore requires Fledermaus along with a
% valid license in order to run. 
%
% Input variables:
%
%   bathyfiles: string or cell array of strings with filename(s) of *.fin
%               bathymetry files.  Ideally, all bathymetry files should
%               have the same resolution; if differences exist, the
%               coarsest resolution will be used.
%
%   sedfiles:   string or cell array of strings with filename(s) of
%               sediment files.  These files can be either HFEVA sediment
%               shapefiles or OAML charter files.
%
%   outputfile: name of output .sd file

% Copyright 2006 Kelly Kearney

%----------------------------
% Check and process input
% filenames
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

if ischar(sedfiles)
    sedfiles = cellstr(sedfiles);
end
nsedfiles = length(sedfiles);
for ifile = 1:nsedfiles
    if ~exist(sedfiles{ifile}, 'file')
        error('Could not find sediment file: %s', sedfiles{ifile});
    end
end

if ~ischar(outputfile)
    error('Outputfile must be a string');
end

%----------------------------
% Interpolate sediment values
% and save to fin files
%----------------------------

for ifile = 1:nbathyfiles
    
    bathyTempName = sprintf('bathy%02d.fin', ifile);
    sedTempName   = sprintf('sed%02d.fin', ifile);
    
    if ~exist(bathyTempName, 'file') || ~exist(sedTempName, 'file') % in case memory problems cause crash

        makesedfin(bathyfiles{ifile}, sedfiles, sedTempName);
        copyfile(bathyfiles{ifile}, bathyTempName);
        
    end
    
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

if any(isspace(outputfile))
    outputfile = sprintf('"%s"', outputfile);
end

%----------------------------
% Use Fledermaus command
% line functions to overlay
% sediment on bathymetry
%----------------------------

% Create dtm files from fin files

fprintf('Converting from .fin to .dtm\n');
for ifin = 1:nbathyfiles
    [s,r] = system(sprintf('cmdop fintoscalar -in bathy%02d.fin -out bathy%02d -dtm', ifin, ifin));
    [s,r] = system(sprintf('cmdop fintoscalar -in sed%02d.fin -out sed%02d -dtm', ifin, ifin));    
end

% Merge dtm files

fprintf('Merging .dtm files\n');

bathyString = sprintf('bathy%02d.dtm ', 1:nbathyfiles);
sedString   = sprintf('sed%02d.dtm ', 1:nbathyfiles);

[s,r] = system(sprintf('cmdop dtmmerge -in %s -out allbathy.dtm -cellsize %f', bathyString, cellSize));
[s,r] = system(sprintf('cmdop dtmmerge -in %s -out allsed.dtm -cellsize %f', sedString, cellSize));
movefile('allsed.dtm', 'allsed.scalar');

% Create shade file

fprintf('Creating shade file\n');

cmapText = {...
    '-999999.000000 -2000.000000 0 0 0 0 0 0'
    '-2000.000000 -1000.000000 0 0 0 0 0 0'
    '-1000.000000 -888.500000 200 200 200 200 200 200'
    '-888.500000 -23.500000 255 255 255 255 255 255'
    '-23.500000 -22.500000 140 140 255 140 140 255'
    '-22.500000 -21.500000 165 170 230 165 170 230'
    '-21.500000 -20.500000 70 230 255 70 230 255'
    '-20.500000 -19.500000 170 200 225 170 200 225'
    '-19.500000 -18.500000 25 255 200 25 255 200'
    '-18.500000 -17.500000 175 240 215 175 240 215'
    '-17.500000 -16.500000 150 225 150 150 225 150'
    '-16.500000 -15.500000 160 230 175 160 230 175'
    '-15.500000 -14.500000 200 255 105 200 255 105'
    '-14.500000 -13.500000 215 235 200 215 235 200'
    '-13.500000 -12.500000 255 255 220 255 255 220'
    '-12.500000 -11.500000 215 225 155 215 225 155'
    '-11.500000 -10.500000 255 255 140 255 255 140'
    '-10.500000 -9.500000 185 195 40 185 195 40'
    '-9.500000 -8.500000 255 235 0 255 235 0'
    '-8.500000 -7.500000 210 190 30 210 190 30'
    '-7.500000 -6.500000 255 215 0 255 215 0'
    '-6.500000 -5.500000 255 180 0 255 180 0'
    '-5.500000 -4.500000 255 220 220 255 220 220'
    '-4.500000 -3.500000 255 190 190 255 190 190'
    '-3.500000 -2.500000 255 150 150 255 150 150'
    '-2.500000 -1.500000 255 0 0 255 0 0'
    '-1.500000 0.000000 220 0 220 220 0 220'
    '0.000000 999999.000000 0 0 0 0 0 0'};
printtextarray(cmapText, 'hfeva.asc');

[s,r] = system('cmdop mkctable -in  hfeva.asc -out hfeva');
[s,r] = system('cmdop shade -dtm allbathy.dtm -cmap hfeva.cmap -scalar allsed.scalar -out bathysed.shade');

% Assemble sd object

fprintf('Assembling .sd file\n');
[s,r] = system(sprintf('cmdop objectbuilder -t SonarDTM -out %s -in allbathy.dtm bathysed.shade allbathy.geo', outputfile));

%----------------------------
% Delete intermediate files 
%----------------------------

delete('allbathy.dtm', 'allbathy.geo', 'allsed.geo', 'allsed.scalar', ...
       'bathysed.shade', 'hfeva.asc', 'hfeva.cmap');
for ifile = 1:nbathyfiles
    delete(sprintf('bathy%02d.fin', ifile), sprintf('sed%02d.fin', ifile), ...
           sprintf('bathy%02d.dtm', ifile), sprintf('sed%02d.dtm', ifile), ...
           sprintf('bathy%02d.geo', ifile), sprintf('sed%02d.geo', ifile));
end
    