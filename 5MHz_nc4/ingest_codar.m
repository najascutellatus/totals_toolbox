addpath('/home/codaradm/operational_scripts/totals_toolbox/5MHz_nc4');
% source_dir = '/home/lemus/MARACOOS/totals/ascii/';
source_dir = '/home/codaradm/data/totals/maracoos/oi/ascii/5MHz/';
 
% Add the snctools jar file
disp( 'Adding NetCDF libraries...' );
lasterr('');
try
    javaaddpath('/home/coolgroup/matlabToolboxes/netcdfAll-4.2.jar');
    addpath(genpath('/home/coolgroup/matlabToolboxes')); 
catch
    disp(['NetCDF-4 Error: ' lasterr]);
end

opt = 'new'; % activitate John Wilkin changes for scanning for last NumDaysOld of files
NumDaysOld = 10;

% Pre-load grid preferences
load('/home/codaradm/data/grid_files/nc_templates/netcdf_2d_grids/OI_6km_ExtendedGrid.mat');

if strcmp(opt,'new')
  source_files = [source_dir 'OI_MARA_*'];
else
  c=fix(clock);
end

%% This file is used for the MARACOOS extended grid totals /home/lemus/MARACOOS/scripts_nc/template_maracoos_compress.nc
output_base_dir = '/home/codaradm/data/totals/maracoos/oi/nc/5MHz';
template_filename = '/home/codaradm/data/grid_files/nc_templates/OI_6km_nc4_template.nc';
%template_filename = '/home/codaradm/operatmonal_scripts/totals_maracoos/scripts_nc/template_maracoos_compress.nc';
%% This file is used for the Josh totals /home/lemus/MARACOOS/scripts_nc/template_macoora_inertial.nc
%
% Right now, just take the last 60 in the directory.
codar_files = dir(source_files);
% codar_files = dlist(end-60:end);
% codar_files = dlist;

%
% If this variable is non-empty at the end, then we use it to construct a new "latest"
% dataset.
output_netcdf_filename = [];

% Run Wilkin's macoora6km_to_grid.m to get 2D lat/lon
%maracoos6km_to_grid

lat_size = nc_getdiminfo( template_filename, 'lat' );
lon_size = nc_getdiminfo( template_filename, 'lon' );
lat_size = lat_size.Length;
lon_size = lon_size.Length;


for j = 1:length(codar_files)

	%
	% Don't process a directory, of course.
	if codar_files(j).isdir
		continue;
	end

	%
	% Don't process if the file is empty.
	if codar_files(j).bytes == 0
		continue;
  end

  if strcmp(opt,'new')
% %     Don't process if the file is more than NumDaysOld
    if datenum(now)-datenum(codar_files(j).date) > NumDaysOld
      continue;
    end
  end
  
	%
	% determine the timestamp
	[d,count] = sscanf ( codar_files(j).name, 'OI_MARA_%d_%d_%d_%d' );
	if ( count ~= 4 )
		msg = sprintf ( '%s:  could not parse timestamp from %s\n', mfilename, codar_files(j).name );
		error ( msg );
	end

	gmt_time = datenum ( d(1), d(2), d(3), d(4)/100, 0, 0 );

	%time_dir = sprintf ( '%s/%s/%s', datestr(gmt_time,'YYYY'), datestr(gmt_time,'mm' ), datestr(gmt_time,'dd' ) );

	%
	% make sure that the output directory exists.
	[success,message,messageID] = mkdir(output_base_dir);

	%output_netcdf_filename = sprintf ( '%s/OI_MARC_%d_%d.nc', output_base_dir, d(1), d(2) );

   new_name = strrep(codar_files(j).name, 'OI_MARA', 'RU_5MHz');
    output_netcdf_filename = sprintf ( '%s/%s.totals.nc', output_base_dir, new_name );

	%
	% Does the file already exist?
	if exist ( output_netcdf_filename, 'file' )
      continue;
   else
      [success,message,messageID] = copyfile(template_filename, output_netcdf_filename);
	end

   %
   % Add the history attribute
   %blurb = sprintf ( 'Converted into netCDF by %s',  );
   nc_attput ( output_netcdf_filename, nc_global, 'history', 'Hourly codar combined into one monthly file. See source attribute' );

%    nc_attput ( output_netcdf_filename, nc_global, 'source', codar_files(j).name );

   nc_attput ( output_netcdf_filename, nc_global, 'source', source_files );

	fprintf ( 1, 'Processing %s into %s\n', codar_files(j).name, output_netcdf_filename );

	text_file = sprintf ( '%s%s', source_dir, codar_files(j).name );

	process_codar_totals_into_netcdf ( text_file, output_netcdf_filename, gmt_time, lat_size, lon_size, P);


end

%copyfile(output_netcdf_file_name, '/home/codaradm/data/totals/maracoos/oi/ascii/5MHz/');

%if ~isempty(output_netcdf_filename )


	%
	% Copy this last one to the "latest" dataset.
%	latest = sprintf ( '%s/latest.nc', output_base_dir );
%	theCommand = sprintf ( 'cp %s %s', output_netcdf_filename, latest );
%	unix ( theCommand );

%end
