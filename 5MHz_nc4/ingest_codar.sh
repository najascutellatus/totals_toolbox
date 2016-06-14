#!/bin/bash
. ~/.bashrc
#---------------------------------------
# Rutgers Codar Processing Script
# # Main call script for BPU matlab processing to create Netcdf files
# # Edited 10/13/11 by Rivera
# #---------------------------------------
 export MATLAB_SHELL="/bin/sh"
#
# # Setup logfile
 LOGFILE=`date "+/home/codaradm/logs/totals_maracoos_nc/MARA_NETCDF_%Y_%m_%d_%H%M.txt"`
#
# # Start script
 date >> $LOGFILE
#
# # Add VNCserver check
# /home/codaradm/operational_scripts/totals_13/check_vncserver.sh
 
# # Run the Master Matlab file
#cd /home/codaradm/operational_scripts/totals_maracoos/scripts_nc
cd /home/codaradm/operational_scripts/totals_toolbox/5MHz_nc4/
 # setenv LD_LIBRARY_PATH /usr/lib64
/usr/local/bin/matlab -nodisplay < /home/codaradm/operational_scripts/totals_toolbox/5MHz_nc4/ingest_codar.m >> $LOGFILE 
#
 date >> $LOGFILE
#
 exit 0
#
#
