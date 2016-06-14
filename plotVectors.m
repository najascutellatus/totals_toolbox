%-------------------------------------------------
% 13 MHz region - total generation script
%
% Edited by Sage 3/24/2009
% Edited to change the plotting scheme and send it to the new website. October 21 2010 by Erick Rivera. 
% Edited by Mike Smith to process the most recent timestamps rather than a
% set time which was four hours before current time
%-------------------------------------------------
clear all; close all;

% Add HFR_Progs to the path
addpath /home/codaradm/HFR_Progs-2_1_3beta/matlab/general
add_subdirectories_to_path('/home/codaradm/HFR_Progs-2_1_3beta/matlab/',{'CVS','private','@'});
addpath /home/codaradm/operational_scripts/totals_13
addpath('/home/codaradm/operational_scripts/totals_toolbox/')

nTime = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Get current system time in UTC (seconds)
tN = java.lang.System.currentTimeMillis*.001;
tS = epoch2datenum(tN);

%tS = datenum(2012,6,7,13,0,0);
%tE = datenum(2012,4,3,12,0,0);
%Create hourly datenums between now and four hours ago
%dtime = [tS:-1/24:tS-1994/24]; % Intervals of every hour. % Intervals of every hour. 
dtime = [tS-5/24:-1/24:tS-12/24];

%Convert matlab time to string to remove minutes and seconds then back to
%datenum format 
strtime = datestr(dtime, 'dd-mmm-yyyy HH:00:00');
dtime = datenum(strtime);
%dtime = [datenum(2012, 9, 1, 0, 0, 2): 1/24: datenum(2012,9, 28, 0, 0, 2)];

%Open configuration file. sites = site codes, types = RDLi or RDLm
conf = BPU_configuration;

%-----------------------------------------------------------
% Process the most recent timestep first
for x = 1:length(dtime)
  fprintf('****************************************\n');
  fprintf('  Current time: %s\n',datestr(now));
  fprintf('  Processing data time: %s\n',datestr(dtime(x),0))
  
%   % Plot Hourly LSQ Totals
%   try
%     fprintf('Starting BPU_driver_plot_totals\n');
%     BPU_driver_plot_totals(dtime(x),conf,'HourPlot.Print',true);
%   catch
%     fprintf('BPU_driver_plot_totals failed because:\n');
%     res=lasterror;
%     fprintf('%s\n',res.message)
%   end


%   Plot Hourly OI Totals
  try
    fprintf('Starting BPU_driver_plot_totals for OI\n');
    BPU_driver_plot_totals(dtime(x),conf,'HourPlot.Print',true, ...
        'HourPlot.Type','OI','HourPlot.BaseDir',conf.HourPlotOI.BaseDir, ...
        'HourPlot.FilePrefix',conf.HourPlotOI.FilePrefix);
  catch
    fprintf('BPU_driver_plot_totals failed because:\n');
    res=lasterror;
    fprintf('%s\n',res.message)
  end


end

close all

%-----------------------------------------------------------
% Update the javascript file with the most recent time
  create_jsfile('/www/home/codaradm/public_html/images/lastfile.txt',tS-5/24);
