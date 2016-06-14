addpath(genpath('/home/codaradm/operational_scripts/totals_toolbox/'))
%which process_codar_totals_into_netcdf
% Add the snctools jar file
disp( 'Adding NetCDF libraries...' );
lasterr('');
try
    javaaddpath('/home/coolgroup/matlabToolboxes/netcdfAll-4.2.jar');
    addpath(genpath('/home/coolgroup/matlabToolboxes')); 
catch
    disp(['NetCDF-4 Error: ' lasterr]);
end

start_time = datenum(2011, 1, 1, 1, 0, 0);
end_time = datenum(2012,3,0,0,0,0);
% 3/30/21 --> 3/20/0 not working??
%this one is messed up??%end_time = datenum(2012, 3, 30, 21, 0, 0);
%start_time = datenum(2012,7,0,0,0,0);
%end_time = datenum(2012,8,13,0,0,0)
dtime = [end_time:-1/24:start_time];
strtime = datestr(dtime, 'dd-mmm-yyyy HH:00:00');
dtime = datenum(strtime);

for h = 1:length(dtime)
    file_name = ['/home/codaradm/data/totals/maracoos/oi/ascii/13MHz/OI_BPU_' datestr(dtime(h), 'yyyy_mm_dd_HH00')];
    file_name2 = ['/home/codaradm/data/totals/maracoos/oi/nc/13MHz/RU_13MHz_' datestr(dtime(h), 'yyyy_mm_dd_HH00')];
    if exist(file_name2, 'file');
        continue
    else
        ingestCodar(3, file_name)
    end
end
