% Generate approximately evenly distributed points on sphere using
% Golden Section spiral algorithm 
%    http://www.softimageblog.com/archives/115

%% DART software - Copyright UCAR. This open source software is provided
% by UCAR, "as is", without charge, subject to all terms of use at
% http://www.image.ucar.edu/DAReS/DART/DART_download
%
% DART $Id$

close all; clear;

% Generate obs_sequence input for this problem

% For diagnostic test need a null data value and a null qc value
diagnostic_test = false;

% Input is in hectopascals - this was intended to be the mandatory levels (see below).
levels = [1000 850 700 500 400 300 200 150 100 50 30 20 10 7 5];

% the nice thing about standards is there are so many of them.  mandatory levels, according to:
% wisconsin: http://www.meteor.wisc.edu/~hopkins/aos100/raobdoc.htm
% the surface, 1000, 925, 850, 700, 500, 400, 300, 250, 200, 150, 100, 70, 50, and 10 mb.
%
% the AMS glossary: http://amsglossary.allenpress.com/glossary/search?id=mandatory-level1
% 1000, 850, 700, 500, 400, 300, 200, 150, 100, 50, 30, 20, 10, 7, 5, 3, 2, and 1 mb.
%
% the Office of Federal Coordinator of Meterology: http://www.ofcm.gov/fmh3/text/chapter5.htm
% 1000, 925, 850, 700, 500, 400, 300, 250, 200, 150, 100, 70, 50, 30, 20, 10 hPa, plus it says
% that these levels should be considered standard: 7, 5, 3, 2, and 1 hPa.
%
% the ones that this program generates right now:
% 1000, 850, 700, 500, 400, 300, 200, 150, 100, 50, 30, 20, 10, 7, 5 mb.

% Date information is overwritten by create_fixed_network_sequence
year = 2008;
month = 10;
day = 1;
hour = 0;

% Number of roughly evenly distributed points in horizontal
n = 600;
x(1:n) = 0;
y(1:n) = 0;
z(1:n) = 0;

% Total number of observations at single time is levels*n*3
num_obs = size(levels, 2) * n * 3;
 
inc = pi * (3 - sqrt(5));
off = 2 / n;
for k = 1:n
   y(k) = (k-1) * off - 1 + (off / 2);
   r = sqrt(1 - y(k)*y(k));
   phi = (k-1) * inc; 
   x(k) = cos(phi) * r;
   z(k) = sin(phi) * r;
end 

% Now convert to latitude and longitude
for k = 1:n
   lon(k) = atan2(y(k), x(k)) + pi;
   lat(k) = asin(z(k));
   % Input is in degrees of lat and longitude
   dlon(k) = rad2deg(lon(k));
   dlat(k) = rad2deg(lat(k));
end

% Need to generate output for driving create_obs_sequence
fid = fopen('even_create_input', 'w');

% Output the total number of observations
fprintf(fid, '%6i\n', num_obs);
% 0 copies of data
if(diagnostic_test) 
   fprintf(fid, '%2i\n', 1);
else
   fprintf(fid, '%2i\n', 0);
end

% 0 QC fields
if(diagnostic_test) 
   fprintf(fid, '%2i\n', 1);
else
   fprintf(fid, '%2i\n', 0);
end

% Metadata for data copy
if(diagnostic_test)
   fprintf(fid, '"observations"\n');
end
% Metadata for qc
if(diagnostic_test)
   fprintf(fid, '"Quality Control"\n');
end


% Loop to create each observation
for hloc = 1:n
   for vloc = 1:size(levels, 2)
      for field = 1:3
         % 0 indicates that there is another observation; 
         fprintf(fid, '%2i\n', 0);
         % Specify obs kind by string
         if(field == 1)
            fprintf(fid, 'RADIOSONDE_TEMPERATURE\n');
         elseif(field == 2)
            fprintf(fid, 'RADIOSONDE_U_WIND_COMPONENT\n');
         elseif(field == 3)
            fprintf(fid, 'RADIOSONDE_V_WIND_COMPONENT\n');
         end
         % Select pressure as the vertical coordinate
         fprintf(fid, '%2i\n', 2);
         % The vertical pressure level
         fprintf(fid, '%5i\n', levels(vloc));
         % Lon and lat in degrees next
         fprintf(fid, '%6.2f\n', dlon(hloc));
         fprintf(fid, '%6.2f\n', dlat(hloc));
         % Now the date and time
         fprintf(fid, '%5i %3i %3i %3i %2i %2i \n', year, month, day, hour, 0, 0);
         % Finally, the error variance, 1 for temperature, 4 for winds
         if(field == 1)
            fprintf(fid, '%2i\n', 1);
         else
            fprintf(fid, '%2i\n', 4);
         end
     
         % Need value and qc for testing
         if(diagnostic_test)
            fprintf(fid, '%2i\n', 1);
            fprintf(fid, '%2i\n', 0);
         end
      end   
   end
end

% File name
fprintf(fid, 'set_def.out\n');

% Done with output, close file
fclose(fid);



% Some plotting to visualize this observation set
plot(lon, lat, '*');
hold on

% Plot an approximate CAM T85 grid for comparison
% 256x128 points on A-grid
% Plot latitude lines first
del_lat = pi / 128;
for i = 1:128
   glat = del_lat * i - pi/2;
   a = [0 2*pi];
   b = [glat glat];
   plot(a, b, 'k');
end

del_lon = 2*pi / 256;
for i = 1:256
   glon = del_lon*i;
   a = [glon glon];
   b = [-pi/2,  pi/2];
   plot(a, b, 'k');
end

% <next few lines under version control, do not edit>
% $URL$
% $Revision$
% $Date$
