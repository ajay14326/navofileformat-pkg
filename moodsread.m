function Data = moodsread(filename)
%MOODSREAD Reads sound velocity profiles from a MOODS data file
%
% Data = moodsread(filename)
%
% This programs reads the data from a MOODS database text file.  A MOODS
% file includes one or more subfiles listing depth, temperature, salinity
% (may be missing), and sound speed (may be missing), preceded by a large
% text header.  Although most header data is never used, this program
% stores it all. 
%
% Input variables:
%
%   filename:   name of MOODS text file (data.moods.txt)
%
% Output variables:
%
%   Data:       1 x n structure, where n is the number of profiles in the
%               file. The header fields are too numerous to list here;
%               their names are self-explanatory (or if not, this author is
%               ignorant of their meaning or purpose as well).  The
%               important fields are the following:
%
%               latitude: latitude where svp was collected
%
%               longitude: longitude where svp was collected
%
%               observationDtg: date and time of collection, YYYYMMDDHHMMSS
%
%               depth: depths of readings, meters
%
%               temperature: temperature at each depth, °C
%
%               salinity: salinity at each depth, ppt
%
%               soundSpeed: sound speed at each depth, m/s

% Copyright 2004-2005 Kelly Kearney

fid = fopen(filename);
isvp = 0;
continueLooping = 1;
while (continueLooping == 1)
    
    isvp = isvp + 1;
    
    % Read header line 1
    
    header = fgetl(fid);
    if ~ischar(header)
        continueLooping = 0;
        break;
    end
    
    Data(isvp).moodsHeaderKey      = str2num(header(1:8));
    Data(isvp).latitude            = str2num(header(10:17));
    Data(isvp).longitude           = str2num(header(19:27));
    Data(isvp).observationDtg      = header(29:42);
    Data(isvp).moodsCruiseNumber   = str2num(header(44:51));
    Data(isvp).moodsEnclosure      = str2num(header(53:55)); 
    Data(isvp).moodsClassification = str2num(header(57:63));
    Data(isvp).project             = str2num(header(65:68)); 
    Data(isvp).numberOfParameters  = str2num(header(70:70));
    Data(isvp).instrumentType      = str2num(header(72:75)); 
    Data(isvp).sourceType          = str2num(header(77:80));
    
    % Read header line 2
    
    header = fgetl(fid);
    
    Data(isvp).firstDataDepth       = str2num(header(1:5));
    Data(isvp).lastDataDepth        = str2num(header(7:11));
    Data(isvp).oceanFloorDepth      = str2num(header(13:17));
    Data(isvp).bottomDepthSource    = str2num(header(19));
    Data(isvp).profileOverLand      = str2num(header(21));
    Data(isvp).questionableDtgCode  = str2num(header(23));
    Data(isvp).allSalinitiesZero    = str2num(header(25));
    Data(isvp).allTemperaturesZero  = str2num(header(27));
    Data(isvp).salinitySpike        = str2num(header(29));
    Data(isvp).temperatureSpike     = str2num(header(31));
    Data(isvp).oservationTooDeep    = str2num(header(33));
    Data(isvp).profileInEez         = str2num(header(35));
    Data(isvp).duplicateSuspectCode = str2num(header(37));
    Data(isvp).loadDate             = header(39:46);
    Data(isvp).headerLastChangeDtg  = header(48:55);
    Data(isvp).profileLastChangeDtg = header(57:64);
    Data(isvp).downgradeDate        = header(66:73);
    Data(isvp).downgradeCode        = str2num(header(75));
    
    % Read header line 3
    
    header = fgetl(fid);
    
    Data(isvp).nodcCountryCode        = header(1:2);
    Data(isvp).nodcInstituteCode      = header(4:5);
    Data(isvp).nodcPlatformCode       = header(7:8);
    Data(isvp).whoiEezCountryCode     = str2num(header(10:13));
    Data(isvp).cooperativeCountryCode = header(15:16);
    Data(isvp).originatorsStationName = header(18:29);
    Data(isvp).castNumber             = str2num(header(31:35));
    Data(isvp).castDirectionCode      = header(37:37);
    Data(isvp).cruiseNumber           = header(39:45);
    Data(isvp).dayOfYear              = str2num(header(47:49));
    Data(isvp).securityKey            = str2num(header(51:53));
    Data(isvp).qualityReviewCode      = str2num(header(55:57));
    Data(isvp).profileInTw            = str2num(header(59:59));
    Data(isvp).twCountryCode          = header(61:64);
    Data(isvp).hslNumber              = header(68:74);
    Data(isvp).oclTsprobeCode         = str2num(header(76:79));
    
    % Read header line 4
    
    header = fgetl(fid);
    
    Data(isvp).programVersion              = str2num(header(1:3));
    Data(isvp).depthExceedEnvLevitusTemp   = str2num(header(5));
    Data(isvp).modLevitusStdDevTemp        = str2num(header(7:9));
    Data(isvp).percentLevitusTempDisagree  = str2num(header(11:13));
    Data(isvp).depthExceedEnvLevitusSal    = str2num(header(15));
    Data(isvp).modLevitusStdDevSal         = str2num(header(17:19));
    Data(isvp).percentLevitusSalDisagree   = str2num(header(21:23));
    Data(isvp).depthExceedEnvNavoclimTemp  = str2num(header(25));
    Data(isvp).navoclimStdDevTemp          = str2num(header(27:29));
    Data(isvp).percentNavoclimTempDisagree = str2num(header(31:33));
    Data(isvp).depthExceedEnvNavoclimSal   = str2num(header(35));
    Data(isvp).navoclimStdDevSal           = str2num(header(37:39));
    Data(isvp).percentNavoclimSalDisagree  = str2num(header(41:43));
    Data(isvp).dateOfQualityReview         = header(45:52);
    Data(isvp).profileInCz                 = str2num(header(54));
    Data(isvp).profileInDc                 = str2num(header(56));
    Data(isvp).eezCountryCode              = header(58:61);
    Data(isvp).czCountryCode               = header(63:66);
    Data(isvp).dcCountryCode               = header(68:71);
    Data(isvp).headerEditHistoryFlag       = str2num(header(73));
    Data(isvp).profileEditHistoryFlag      = str2num(header(75));
    Data(isvp).ctdSerialNumberFlag         = str2num(header(77));
  
    % Read header line 5
    
    header = fgetl(fid);
    
    Data(isvp).nodcAccessionNumber   = str2num(header(1:8));
    Data(isvp).oclStationNumber      = str2num(header(10:17));
    Data(isvp).wod98UniqueNumber     = str2num(header(19:26));
    Data(isvp).depthPrecision        = str2num(header(28));
    Data(isvp).temperaturePrecision  = str2num(header(30));
    Data(isvp).salinityPrecision     = str2num(header(32));
    Data(isvp).soundSpeedPrecision   = str2num(header(34));
    Data(isvp).latPrecision          = str2num(header(35));
    Data(isvp).lonPrecision          = str2num(header(36));
    Data(isvp).wmo1770InstrumentCode = str2num(header(38:40));
    Data(isvp).wmo4770RecorderCode   = str2num(header(42:44));
    Data(isvp).callSign              = header(46:51);
    Data(isvp).temperatureAtypical   = str2num(header(53:55));
    Data(isvp).salinityAtypical      = str2num(header(57:59));
    Data(isvp).soundSpeedAtypical    = str2num(header(61:63));
    Data(isvp).wrongLocationCode     = str2num(header(65));
    Data(isvp).mhkDuplicateId        = str2num(header(67:74));
    Data(isvp).numberOfDataCycles    = str2num(header(76:80));
    
    % Read header line 6
    
    header = fgetl(fid);
    
    Data(isvp).temperatureMethod           = str2num(header(1:3));
    Data(isvp).salinityMethod              = str2num(header(5:7));
    Data(isvp).nodcStationQcCode           = str2num(header(9));
    Data(isvp).refSst                      = str2num(header(11:18));
    Data(isvp).refSstIntrument             = str2num(header(20:21));
    Data(isvp).digitizationMethod          = str2num(header(23:24));
    Data(isvp).digitizationInterval        = str2num(header(26:27));
    Data(isvp).depthFixCode                = str2num(header(29));
    Data(isvp).temperatureNoisy            = str2num(header(31:32));
    Data(isvp).highVerticalGradient        = str2num(header(34:35));
    Data(isvp).temperatureSuspect          = str2num(header(37:38));
    Data(isvp).salinityNoisy               = str2num(header(40:41));
    Data(isvp).salinitySuspect             = str2num(header(43:44));
    Data(isvp).densityInversion            = str2num(header(46:47));
    Data(isvp).temperatureCoarseResolution = str2num(header(49:50));
    Data(isvp).salinityCoarseResolution    = str2num(header(52:53));
    Data(isvp).temperatureMarkedAsSalinity = str2num(header(55:56));
    Data(isvp).salinityMarkedAsTemperature = str2num(header(58:59));
    Data(isvp).nodcTemperatureCode         = str2num(header(61:62));
    Data(isvp).nodcSalinityCode            = str2num(header(64:65));
    Data(isvp).temperatureGeneralQuality   = str2num(header(67:69));
    Data(isvp).salinityGeneralQuality      = str2num(header(71:73));
    Data(isvp).soundSpeedGeneralQuality    = str2num(header(75:77));
    Data(isvp).editFlagProgramVersion      = str2num(header(78:80));
    
    % Read svp data
    
    for idata = 1:Data(isvp).numberOfDataCycles
        data = fgetl(fid);
        if Data(isvp).numberOfParameters == 4
            Data(isvp).depth(idata)       = str2num(data(1:10));
            Data(isvp).temperature(idata) = str2num(data(12:19));
            Data(isvp).salinity(idata)    = str2num(data(21:28));
            Data(isvp).soundSpeed(idata)  = str2num(data(30:39));
        elseif Data(isvp).numberOfParameters == 3
            Data(isvp).depth(idata)       = str2num(data(1:10));
            Data(isvp).temperature(idata) = str2num(data(12:19));
            Data(isvp).salinity(idata)    = str2num(data(21:28));
        elseif Data(isvp).numberOfParameters == 2
            Data(isvp).depth(idata)       = str2num(data(1:10));
            Data(isvp).temperature(idata) = str2num(data(12:19));
        end
    end
    
    % Read ctd serial number data
    
    if (Data(isvp).ctdSerialNumberFlag == 1)
        Data(isvp).ctdSerialNumberData = fgetl(fid);
    end
    
    % Read header edit history
    
    if (Data(isvp).headerEditHistoryFlag == 1)
        heh = fgetl(fid);
        Data(isvp).numberOfHeaderEdits = str2num(heh(5:9));
        for iheh = 1:Data(isvp).numberOfHeaderEdits
            Data(isvp).headerEditHistoryData(iheh,:) = fgetl(fid);
        end
    end
    
    % Read profile edit history
    
    if (Data(isvp).profileEditHistoryFlag == 1)
        peh = fgetl(fid);
        Data(isvp).numberOfProfileEdits = str2num(peh(5:9));
        for ipeh = 1:Data(isvp).numberOfProfileEdits
            Data(isvp).profileEditHistoryData(ipeh,:) = fgetl(fid);
        end
    end

end

fclose(fid);
