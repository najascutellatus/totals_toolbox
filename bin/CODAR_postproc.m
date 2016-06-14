%-------------------------------------------------
% PUERTO RICO HF-Radar Processing Toolbox
%
% Processing script
%   Change the dates below to specify the range to reprocess
%   Then use the following command:
% nohup /usr/local/matlab/R2009b/bin/matlab -nodesktop -display :99 < BPU_postproc.m > nohup_totals.txt &
% Processing in Arctic using CODARADM
% nohup /usr/local/MATLAB/R2011a/bin/matlab -nodesktop -display :982 < BPU_postproc.m > nohup_09072011.txt &
% NY Harbor Domain: Full Region
%   Master script for real-time processing of LSQ and OI Totals
%   Also plots totals and errors for full-region 
%   
%
% Edited by Erick Rivera 10/21/2009
%-------------------------------------------------
clear all; close all;

% Add HFR_Progs to the path
addpath /home/codaradm/HFR_Progs-2_1_3beta/matlab/general
add_subdirectories_to_path('/home/codaradm/HFR_Progs-2_1_3beta/matlab/',{'CVS','private','@'});
% addpath /home/codaradm/operational_scripts/totals
addpath /home/lemus/CODAR/totals_13mHz/scripts

%-----------------------------------BEgining Date------------------------Endind Date------------------------
for dtime = fliplr( datenum(2011,08,01,00,0,0):1/24:datenum(2011,09,07,05,0,0) + 2/(24*60*60) )

  fprintf('****************************************\n');
  fprintf('  Current time: %s\n',datestr(now));
  fprintf('  Processing data time: %s\n',datestr(dtime,0))

  % Load the MARCOOS Configuration
  % Created a configuration file for December 2008 and changing the
  % directories to my home directory.  The end of the name is yymmdd of the
  % file creation
  
  conf = BPU_configuration;

  % Hourly Total Creation
  try
    fprintf('Starting BPU_driver_totals_nolsq\n');
    BPU_driver_totals(dtime,conf);
  catch
    fprintf('BPU_driver_totals failed because:\n');
    res=lasterror;
    fprintf('%s\n',res.message)
  end
 % Plot Hourly LSQ Totals
%   try
%     fprintf('Starting BPU_driver_plot_totals\n');
%     BPU_driver_plot_totals(dtime,conf,'HourPlot.Print',true);
%   catch
%     fprintf('NY_driver_plot_totals failed because:\n');
%     res=lasterror;
%     fprintf('%s\n',res.message)
%   end
%   Plot Hourly OI Totals
%   try
%     fprintf('Starting MARC_driver_plot_totals for OI\n');
%     BPU_driver_plot_totals(dtime,conf,'HourPlot.Print',true, ...
%         'HourPlot.Type','OI','HourPlot.BaseDir',conf.HourPlotOI.BaseDir, ...
%         'HourPlot.FilePrefix',conf.HourPlotOI.FilePrefix);
%   catch
%     fprintf('MARC_driver_plot_totals failed because:\n');
%     res=lasterror;
%     fprintf('%s\n',res.message)
%   end
end

%close all


close all
