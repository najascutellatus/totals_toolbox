% convert 1-d Macoora 6km lon/lat coordinates to rectangular 2D
% lon/lat grid.

% read the ascii grid file 
% codar_grid_dir = './';
codar_grid_dir = '/Users/codar/Documents/MATLAB/totals_toolbox/grid_files/old_grids/';%'/Volumes/lemus/MARACOOS/grid_hfrnet/';%

codar_grid_file = 'NY_1kmgrid.txt';

try
  d = load([codar_grid_dir codar_grid_file]);
catch
  codar_grid_dir = [];
  d = load([codar_grid_dir codar_grid_file]);
end
  
% split out the lon/lat columns of the grid file
x = d(:,1);
y = d(:,2);

% lon/lat spacing
% the macoora 8km grid file header record says:
% dx=0.117647; dy=0.0899928;
%
% compute dx and dy (lon/lat grid increments) from all possible values in
% the grid file
dx = unique(diff(sort(x)));
dx = dx(2);
dy = unique(diff(sort(y)));
dy = dy(2);

% calculate number of lon/lat coordinates when put on a 2D grid
nx = 1+round(diff([min(x) max(x)])/dx);
ny = 1+round(diff([min(y) max(y)])/dy);

% make vectors of grid lon/lat values that span the entire range
lon = linspace(min(x),max(x),nx);
lat = linspace(min(y),max(y),ny);

% expand into a 2-D set of lon,lat coordinates
[X,Y] = meshgrid(lon,lat);

% find the 1-D index into coordinates corresponding to each row of the
% codar grid file
P = NaN*ones(size(x));
for k=1:length(x)
  del=[(X(:)-x(k)) + sqrt(-1)*(Y(:)-y(k))];
  [ignore,P(k)]=min(del); % don't need the min, only it's location P(k)
end

% Now, when a column of codar data is read from 
% /home/kohut/RealTimeScripts/HFRadarToolBox/RULR/Data/TotalInterp15macoora
% e.g. into a vector named 'data'
% then the vector of data can be reshaped into the appropriate index
% values of a 2D matrix DATA of size [ny nx] by simply assiging 
% to index values in vector P

% example: dummy data are the pointwise lon values
data = x;
DATA = NaN*ones(size(X));
DATA(P) = data;
% 
% lon_data = NaN*ones(size(X));
% lon_data (P) = x;  
% lat_data = NaN*ones(size(Y)); 
% lat_data (P) = y; 

% so if we contour this it should be straight lines if the vector of
% point lon values have gone into correct elements of the 2D matrix.

%contour(X,Y,DATA,30)



