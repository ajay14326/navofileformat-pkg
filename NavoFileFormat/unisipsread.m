function DATA = unisipsread(filename)
%UNISIPSREAD Reads data from a unisips file
%
% Data = unisipsread(filename)
%
% This function reads in the information stored in a unisips file and
% stores it in the structure Data.
%
% Input variables:
%
%   filename:   name of unisips file
%
% Output variables:
%
%   Data:       1 x 1 structure with the following fields
%
%               FileHeader:     1 x 1 structure holding information from
%                               the unisips file header. 
%
%               RecordHeader:   1 x 1 structure holding information from
%                               the record headers associated with each
%                               sonar record (row).  Each field of this
%                               structure holds 1 x n array, where n is the
%                               number of records in the file.
%
%               recordData:     n x m array of sonar record data

% Copyright 2005 Kelly Kearney

fid = fopen(filename);

%------------------------------
% Read file header
%------------------------------

maxSysId             = 30;
maxFormatId          = 10;
maxPlatformId        = 40;
maxProcessingId      = 20;
maxClassSpace        = 15;
maxDistributionSpace = 16;
spare1 = 150 - maxSysId - maxFormatId - maxPlatformId - maxProcessingId + 1;

FileHeader.rows               = fread(fid, 1, 'int', 'b');
FileHeader.cols               = fread(fid, 1, 'int', 'b');
FileHeader.pixelRes           = fread(fid, 1, 'float', 'b');
FileHeader.sysId              = char(fread(fid, maxSysId, 'char', 'b')');
FileHeader.formatId           = char(fread(fid, maxFormatId, 'char', 'b')');
FileHeader.platformId         = char(fread(fid, maxPlatformId, 'char', 'b')');
FileHeader.processingSystem   = char(fread(fid, maxProcessingId, 'char', 'b')');
spare1                        = fread(fid, spare1, 'char', 'b');
FileHeader.classification     = char(fread(fid, maxClassSpace, 'char')');
FileHeader.distributionLimits = char(fread(fid, maxDistributionSpace, 'char')');
FileHeader.securityKey        = fread(fid, 1, 'short', 'b');
FileHeader.centerRow          = fread(fid, 1, 'short', 'b');
FileHeader.centerCol          = fread(fid, 1, 'short', 'b');
FileHeader.centerLat          = fread(fid, 1, 'double', 'b');
FileHeader.centerLon          = fread(fid, 1, 'double', 'b');
FileHeader.maxLat             = fread(fid, 1, 'double', 'b');
FileHeader.minLat             = fread(fid, 1, 'double', 'b');
FileHeader.maxLon             = fread(fid, 1, 'double', 'b');
FileHeader.minLon             = fread(fid, 1, 'double', 'b');
FileHeader.version            = fread(fid, 1, 'float', 'b');
FileHeader.creationDate       = char(fread(fid, 16, 'char', 'b')');
FileHeader.nominalTowdepth    = fread(fid, 1, 'float', 'b');
FileHeader.startDtg           = fread(fid, 1, 'double', 'b');
FileHeader.endDtg             = fread(fid, 1, 'double', 'b');
FileHeader.startYear          = fread(fid, 1, 'int', 'b');
FileHeader.endYear            = fread(fid, 1, 'int', 'b');
FileHeader.pulseLength        = fread(fid, 1, 'float', 'b');
FileHeader.frequency          = fread(fid, 1, 'float', 'b');
FileHeader.portFrequency      = fread(fid, 1, 'float', 'b');
FileHeader.starboardFrequency = fread(fid, 1, 'float', 'b');
FileHeader.bandWidth          = fread(fid, 1, 'float', 'b');
spare2                        = fread(fid, 20, 'char', 'b');
FileHeader.processingHistory  = fread(fid, 2, 'int', 'b');
FileHeader.bitsPerPixel       = fread(fid, 1, 'short', 'b');
FileHeader.numBoundaryPts     = fread(fid, 1, 'short', 'b');
FileHeader.boundaryPtsLoc     = fread(fid, 1, 'int', 'b');
extraSpace                    = fread(fid, 168, 'uchar', 'b');

%------------------------------
% Read records
%------------------------------

RecordHeader = struct('year',     NaN(1,FileHeader.rows), ...
                      'layback',  NaN(1,FileHeader.rows), ...
                      'time',     NaN(1,FileHeader.rows), ...
                      'roll',     NaN(1,FileHeader.rows), ...
                      'pitch',    NaN(1,FileHeader.rows), ...
                      'heading',  NaN(1,FileHeader.rows), ...
                      'fishSpd',  NaN(1,FileHeader.rows), ...
                      'lat',      NaN(1,FileHeader.rows), ...
                      'lon',      NaN(1,FileHeader.rows), ...
                      'cbDepth',  NaN(1,FileHeader.rows), ...
                      'towDepth', NaN(1,FileHeader.rows));

recordData = zeros(FileHeader.rows, FileHeader.cols);

for irec = 1:FileHeader.rows
    
    %------------------------------
    % Read record header
    %------------------------------
   
    RecordHeader.year(irec)     = fread(fid, 1, 'int', 'b');
    pad0                        = fread(fid, 2, 'char', 'b');
    lbTemp                      = fread(fid, 1, 'ushort', 'b');
    RecordHeader.layback(irec)  = bitand(lbTemp, 32767)/10;
    RecordHeader.time(irec)     = fread(fid, 1, 'double', 'b');
    RecordHeader.roll(irec)     = fread(fid, 1, 'float', 'b');
    RecordHeader.pitch(irec)    = fread(fid, 1, 'float', 'b');
    RecordHeader.heading(irec)  = fread(fid, 1, 'float', 'b');
    RecordHeader.fishSpd(irec)  = fread(fid, 1, 'float', 'b');
    RecordHeader.lat(irec)      = fread(fid, 1, 'double', 'b');
    RecordHeader.lon(irec)      = fread(fid, 1, 'double', 'b');
    RecordHeader.cbDepth(irec)  = fread(fid, 1, 'float', 'b');
    RecordHeader.towDepth(irec) = fread(fid, 1, 'float', 'b');
    
    recordData(irec,1:FileHeader.cols) = fread(fid, FileHeader.cols, 'uchar'); 

end

DATA.FileHeader   = FileHeader;
DATA.RecordHeader = RecordHeader;
DATA.recordData   = recordData;

fclose(fid);


