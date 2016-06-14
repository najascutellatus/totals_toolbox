function result = fetchDatafromDB(dbConn, dbStatement)
% Query database for data on system type
if isconnection(dbConn)
    result = get(fetch(exec(dbConn, dbStatement)), 'Data');
else
    fprintf(1, 'Connection failed: %s', dbConn.Message);
    return
end