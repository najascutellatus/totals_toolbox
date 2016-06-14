function createHourlyTotals(systemType, Sites, pattType, baseDir, saveDir, metaData)
    
    if length(pattType) > 1
            pattSelect = 1;
    else
        if strcmpi(pattType, 'RDLi')
            pattSelect = 2;
        elseif strcmpi(pattType, 'RDLm')
            pattSelect = 3;
        end
    end
        % Build configuration file for use in CODAR_driver_totals
        conf = CODAR_configuration(systemType, Sites, pattType, baseDir, saveDir, metaData.region);

        % Hourly Total Creation
        try
            
            fprintf(1,  'Making Hourly Totals. \n');
            [procFname] = CODAR_driver_totals(metaData.tCurrent(metaData.x), conf, systemType);
            ingestCodar(systemType, procFname, metaData.region, pattSelect) 
            
            if exist(procFname, 'file')            % Check if the file was created. If it was, insert the record.
                fprintf(1, 'The file %s exists. Inserting record into database. \n', procFname);
                fprintf(1, '%s radials were used in the generation of the IOOS region #%s, %s totals. \n',...
                    num2str(metaData.newNumRadials), num2str(metaData.region), datestr(metaData.tCurrent(metaData.x)));
                fastinsert(metaData.dbConn, 'hfrTotals',...
                    {'systemTypeId', 'radialTimestamp', 'numRadials', 'region', 'pattTypes'},...
                    {systemType, datestr(metaData.tCurrent(metaData.x), 'yyyy-mm-dd HH:MM:00'),...
                    metaData.newNumRadials, metaData.region, pattSelect});
            end
            
        catch
            fprintf(1, 'Total Creation failed because: \n');
            res=lasterror;
            fprintf(1, '%s\n',res.message);
        end    

end