function radials2totals(systemType, dbConn, varargin)
%
% Rutgers HFRadar Processing Toolbox
%
% Usage: radials2totals(systemType, dbConn, varargin)
%
% Wrapper function for CODAR_driver_totals that queries the radial
% database and returns the most recent timestamps of all active SeaSonde
% sites. If the optional inputs, startime and endtime, are not entered. The
% function grabs the latest timestamp available for radials and checks if the
% radials were used in the production of totals in the past 12 (default)
% hours.
%
% Setting the parameter 'reDo' to true will forcefully process totals even 
% if they already exist. It bypasses checking the database to see if the 
% totals were already processed, creates the totals, and inserts a new
% record into the database.
%
% This script does not require database usage. Setting useDb to false will
% bypass the database querying portion of the script and will process any
% times between startTime and endTime. If these inputs are not given, the
% script will take the current time in EDT and process the past twelve
% hours. This is best for reprocessing totals in which we do not plan on
% displaying to the public.
%
% OPTIONAL (name, value) PARAMETERS
%   'starttime' - start time (datenum)
%   'endtime'   - end time (datenum)
%   'hours'     - hours before end time to check for new radials
%   'baseDir'   - location of main file folder containing sub-folders
%   for each site
%   'pattType'  - RDLi (Ideal) or RDLm (Measured) pattern radials?
%   'saveDir'   - directory to save totals to
%   'reDo'      - Reprocess totals and insert into database
%   'useDb'     - use the database? Enter 'true'  or 'false'
%
% Created by Mike Smith (michaesm@marine.rutgers.edu) on 3/23/2012.
%
% See also CheckTotals, CODAR_configuration, CODAR_driver_totals 


% Script name
caller = [mfilename '.m'];

% Default values
hours   = 12;
startTime = [];
endTime   = [];
baseDir = '/home/codaradm/data/';
pattType = 'RDLi';
saveDir = '/home/codaradm/data/';
reDo  = false;
useDb = true;
region = 7; %1 = maracoos, 2 = caracoos
pattSelect = 1; % 1 = best; 2 = ideal; 3 = measured; 4 = best, ideal, and measured


% Process optional name/value input parameters -------------------------------
    for x = 1:2:length(varargin)

        name  = varargin{x};
        value = varargin{x+1};

        if isempty(value)
            disp([caller ' - Skipping empty option pairing: ' name]);
            continue;
        elseif ~ischar(name)
            disp([caller ' E: Parameter name must be a string.']);
            return;
        end

        switch lower(name)
            case 'usedb'
                if ~isequal(numel(value),1) || ~islogical(value)
                    fprintf(2,...
                        'Value for %s must be a logical.\n',...
                        name);
                    return;
                end
                useDb = value;
            case 'redo'
                if ~isequal(numel(value), 1) || ~islogical(value)
                    fprintf(2,...
                        'Value for %s must be a logical.\n',...
                        name);
                    return;
                end
                reDo = value;
            case 'basedir'
                if ~ischar(value) || ~isdir(value)
                    fprintf(2,...
                        '%s must be a string specifying a valid directory.\n',...
                        name);
                    return;
                end
                baseDir = value;
            case 'savedir'
                if ~ischar(value) || ~isdir(value)
                    fprintf(2,...
                        '%s must be a string specifying a valid directory.\n',...
                        name);
                    return;
                end
                saveDir = value;
            case 'patttype'
                if ~ischar(value)
                    fprintf(2,...
                        'Pattern type (%s) must be a valid pattern type string.\n',...
                        name);
                    return;
                end
                PattType = value;
            case 'starttime'
                if ~isequal(numel(value),1) || ~isnumeric(value)
                    fprintf(2,...
                        'Invalid start time specified\n');
                    return;
                else
                    try
                        startTime = datenum(value);
                    catch ME
                        fprintf(2,...
                        '%s - %s\n',...
                        ME.identifier,...
                        ME.message);
                    return;
                    end
                end
            case 'endtime'
                if ~isequal(numel(value),1) || ~isnumeric(value)
                    fprintf(2,...
                        'Invalid start time specified\n');
                    return;
                else
                    try
                        endTime = datenum(value);
                    catch ME
                        fprintf(2,...
                        '%s - %s\n',...
                        ME.identifier,...
                        ME.message);
                    return;
                    end
                end
            case 'hours'
                if ~isequal(numel(value),1) || ~isnumeric(value) || value < 0
                    fprintf(2,...
                        'Value for %s must be a positive numeric scalar.\n',...
                        name);
                    return;
                end
                hours = value;
            case 'region'
                if ~isequal(numel(value),1) || ~isnumeric(value) || value < 0
                    fprintf(2,...
                        'Value for %s must be a positive numeric scalar.\n',...
                        name);
                     return;
                 end
                 region = value;
             case 'pattselect'
                if ~isequal(numel(value),1) || ~isnumeric(value) || value < 0
                    fprintf(2,...
                        'Value for %s must be a positive numeric scalar.\n',...
                        name);
                     return;
                 end
                 pattSelect = value;
            otherwise
                fprintf(2,...
                    'Unknown option: %s.\n',...
                    name);
                return;
        end
    end

    if useDb
        %Build MySQL query statement
        dbStatement = ['select hfrSites.site, hfrSites.id as ',...
            'siteId, hfrLatestRadials.Timestamp as latestRadial, ',...
            'hfrFileTypes.type as filePrefix from hfrSites ',...
            'inner join hfrFileTypes on ',...
            '(hfrSites.radialProcessingType = hfrFileTypes.id) inner join ',...
            'hfrLatestRadials on (hfrSites.id = hfrLatestRadials.siteId) ',...
            'inner join hfrSystemTypes on ',...
            '(hfrSystemTypes.id = hfrSites.type) ',...
            'where(hfrSites.region = ' num2str(region) ' AND ',...
            'hfrSites.active = 1 ',...
            'AND hfrSites.type = ' num2str(systemType) ' AND ',...
            'hfrSites.numSites = 1)'];
        
        result = fetchDatafromDB(dbConn, dbStatement);
        
        % Get site codes
         Sites = result(:,1)';
            
        % Get pattern types
        pattType = result(:,4)';

        % Convert Time String to datenum
        radialsTs = datenum(result(:,3), 'yyyy-mm-dd HH:MM:SS.0');


        % Get latest radial time and build past n number of hours
        if ~isempty(startTime)
            tNow = endTime;
            tThen = startTime;
        else
            tNow = max(unique(radialsTs));
            tThen = tNow - hours/24;
        end

        % Build hourly timestamps 
        if systemType == 4;
            tCurrent = [tNow:-1/48:tThen];
        else
            tCurrent = [tNow:-1/24:tThen];
        end

        for x = 1:1:length(tCurrent)
            nTime = {};
            for y = 1:length(Sites)
                file_name = [baseDir 'radials/' Sites{y} '/' pattType{y} '_' Sites{y} '_' datestr(tCurrent(x), 'yyyy_mm_dd_HH00.ruv')];
                if exist(file_name, 'file');
                    nTime = [nTime; file_name]; %Append to matrix the times that do exist
                end
            end
            
            if ~reDo

                % Build query to get the number of radials used in the creation
                % of totals with this specific time stamp
                dbStatement = ['select numRadials, region, pattTypes from hfrTotals where ',...
                'RadialTimestamp = ''' datestr(tCurrent(x), 'yyyy-mm-dd HH:00:00') '''',...
                ' and systemTypeId = ' num2str(systemType) ' AND region = ' num2str(region),...
                ' ORDER BY dateProcessed DESC LIMIT 1'];
                
                oldNumResult = fetchDatafromDB(dbConn, dbStatement);

                if strcmpi(oldNumResult, 'No Data') % Record does not exist. Create Totals and insert record into db.
                    fprintf(1, 'A record for %s does not exist. Total Creation Starting. \n', datestr(tCurrent(x), 'yyyy-mm-dd HH:00:00'));
                    oldNumRadials = 0;
                else % Record exists, but check if the new number of radials is greater than the old number of radials.
                    fprintf(1, 'A record for %s exists. Determining if re-processing is needed. \n', datestr(tCurrent(x), 'yyyy-mm-dd HH:00:00'));
                    oldNumRadials = oldNumResult{1};
                end
            else
                fprintf(1, 'Forcefully reprocessing totals. Bypassing database checking.\n');
                oldNumRadials = 0;
            end
            
            newNumRadials = length(nTime); % Number of Radials that are available for a specific time period
            
            metaData.region = region;
            metaData.tCurrent = tCurrent;
            metaData.dbConn = dbConn;
            metaData.newNumRadials = newNumRadials;
            metaData.oldNumRadials = oldNumRadials;
            metaData.x = x;
            metaData.pattSelect = pattSelect;
                
            % Process current timestamp
            fprintf(1, '****************************************\n');
            fprintf(1, '  Current time: %s\n',datestr(now));
            fprintf(1, '  Processing data time: %s\n',datestr(tCurrent(x),0));
            fprintf(1,  '****************************************\n');
            
            if newNumRadials > oldNumRadials
                if pattSelect == 1;
                    createHourlyTotals(systemType, Sites, pattType, baseDir, saveDir, metaData);
                elseif pattSelect == 2;
                    createHourlyTotals(systemType, Sites, {'RDLi'}, baseDir, saveDir, metaData);
                elseif pattSelect == 3;
                    createHourlyTotals(systemType, Sites, {'RDLm'}, baseDir, saveDir, metaData);
                elseif pattSelect == 4;
                    dbStatement = ['select numRadials, region, pattTypes from hfrTotals where ',...
                        'RadialTimestamp = ''' datestr(tCurrent(x), 'yyyy-mm-dd HH:00:00') '''',...
                        ' and systemTypeId = ' num2str(systemType) ' AND region = ' num2str(region),...
                        ' and pattTypes = 1 ORDER BY dateProcessed DESC LIMIT 1'];
                    result = fetchDatafromDB(dbConn, dbStatement);
                    
                    if strcmpi(result, 'No Data') % Record does not exist. Create Totals and insert record into db.
                        fprintf(1, 'A record for %s does not exist. Total Creation Starting. \n', datestr(tCurrent(x), 'yyyy-mm-dd HH:00:00'));
                        createHourlyTotals(systemType, Sites, pattType, baseDir, saveDir, metaData);
                    else % Record exists, but check if the new number of radials is greater than the old number of radials.
                        if newNumRadials > oldNumRadials
                            createHourlyTotals(systemType, Sites, pattType, baseDir, saveDir, metaData);
                        else
                            fprintf(1, 'not reprocessing\n');
                        end
                    end
                    
                    dbStatement = ['select numRadials, region, pattTypes from hfrTotals where ',...
                        'RadialTimestamp = ''' datestr(tCurrent(x), 'yyyy-mm-dd HH:00:00') '''',...
                        ' and systemTypeId = ' num2str(systemType) ' AND region = ' num2str(region),...
                        ' and pattTypes = 2 ORDER BY dateProcessed DESC LIMIT 1'];
                    result = fetchDatafromDB(dbConn, dbStatement);
                    
                    if strcmpi(result, 'No Data') % Record does not exist. Create Totals and insert record into db.
                        fprintf(1, 'A record for %s does not exist. Total Creation Starting. \n', datestr(tCurrent(x), 'yyyy-mm-dd HH:00:00'));
                        createHourlyTotals(systemType, Sites, {'RDLi'}, baseDir, saveDir, metaData);
                    else % Record exists, but check if the new number of radials is greater than the old number of radials.
                        if newNumRadials > oldNumRadials
                            createHourlyTotals(systemType, Sites, {'RDLi'}, baseDir, saveDir, metaData);
                        else
                            fprintf(1, 'not reprocessing\n');
                        end
                    end

                    dbStatement = ['select numRadials, region, pattTypes from hfrTotals where ',...
                        'RadialTimestamp = ''' datestr(tCurrent(x), 'yyyy-mm-dd HH:00:00') '''',...
                        ' and systemTypeId = ' num2str(systemType) ' AND region = ' num2str(region),...
                        ' and pattTypes = 3 ORDER BY dateProcessed DESC LIMIT 1'];
                    result = fetchDatafromDB(dbConn, dbStatement);

                    if strcmpi(result, 'No Data') % Record does not exist. Create Totals and insert record into db.
                        fprintf(1, 'A record for %s does not exist. Total Creation Starting. \n', datestr(tCurrent(x), 'yyyy-mm-dd HH:00:00'));
                        createHourlyTotals(systemType, Sites, {'RDLm'}, baseDir, saveDir, metaData);
                    else % Record exists, but check if the new number of radials is greater than the old number of radials.
                        if newNumRadials > oldNumRadials
                            createHourlyTotals(systemType, Sites, {'RDLm'}, baseDir, saveDir, metaData);
                        else
                            fprintf(1, 'not reprocessing\n');
                        end                    
                    end
                end
            elseif newNumRadials < 2
                fprintf(1, 'Not enough radials to generate totals. Continuing to next timestep. \n');
            else
                fprintf(1, 'Record exists and timestamp does NOT need to be re-processed. \n');
            end
            clear nTime
        end
    else %Do not use the database.. forcefully reprocess the files...    
        fprintf(1, 'Bypassing database completely. \n');
        if ~isempty(startTime)
            tNow = endTime;
            tThen = startTime;
        else
            tNow = floor(now*24)/24;
            tThen = tNow - hours/24;
        end

        tCurrent = [tNow:-1/24:tThen]; % Build hourly timestamps 

        for x = 1:1:length(tCurrent)
            nTime = {};
            
            % Build configuration file for use in CODAR_driver_totals
            % Leave the second input, Sites, as an empty array with no data
            
            %conf = CODAR_configuration(systemType, [], [], baseDir, saveDir, region);
            metaData.region = region;
            conf = CODAR_configuration_reprocess(systemType, [], [], baseDir, saveDir, metaData.region);
            for y = 1:length(conf.Radials.Sites)
                file_name = [conf.Radials.BaseDir conf.Radials.Sites{y} '/' datestr(tCurrent(x), 'yyyy_mm') '/' conf.Radials.Types{y} '_' conf.Radials.Sites{y} '_' datestr(tCurrent(x), 'yyyy_mm_dd_HH00.ruv')];
                if exist(file_name, 'file');
                    nTime = [nTime; file_name]; %Append to matrix the times that do exist
                end
            end

            % Process current timestamp
            fprintf(1, '****************************************\n');
            fprintf(1, '  Current time: %s\n',datestr(now));
            fprintf(1, '  Processing data time: %s\n',datestr(tCurrent(x),0));
            
            % Hourly Total Creation
            try
                fprintf(1, 'Starting Totals_driver\n');
                [procFname] = CODAR_driver_totals(tCurrent(x),conf, systemType);
                ingestCodar(systemType, procFname, region)
            catch
                fprintf(1, 'Driver_totals failed because: \n');
                res=lasterror;
                fprintf(1, '%s\n',res.message);
            end
  
            clear nTime
        end
    end
end
