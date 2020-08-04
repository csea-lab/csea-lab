
% firstload the source model which is located in the libas/4data folder
load dipoles_symmetric.dat

% when doing this for the first time, check the source model by plotting
plot3(dipoles_symmetric(:,1), dipoles_symmetric(:,2), dipoles_symmetric(:,3))

% this should look like a 1950 lampshade, 4 shells on a unit sphere

% next load the electrode locations in Cartesian coordinates
load elek129HCLnorm.dat
% this for example loads the sensor positions for the 120 HCL net. elek files are located in the 4data folder as well
% again, check to make sure that the sensor positions fit on a unit sphere
plot3(elek129HCLnorm(:,1),elek129HCLnorm(:,2),elek129HCLnorm(:,3), '*')

% if not on a unit sphere, then put on a unit sphere by a simple
% multiplication
% elek129HCLnorm = elek129HCLnorm.*10
% replot to make sure that the positions lie on a unit sphere
% plot3(elek129HCLnorm(:,1),elek129HCLnorm(:,2),elek129HCLnorm(:,3), '*')

% if you need the Cartesian coordinates for a sensor net, then load in
% appropriate sensor set into emegs2d and export as an ascii cartesian
% coordinates file. load the file into the workspace and proceed from there
% (should have a 3 x # of sensors format, so transpose if necessary)

% now ready to do source analysis
% first calculate leadfield (this will be the same for all people with this electrode net
% so you can save and use for later studies with the SAME sensor net
[lfd_mat, orientations]=compute_lfdmat(dipoles_symmetric', elek129HCLnorm', 'eeg', 'xyz');
% note that the dipoles and the eleks need to have dimensions of 3 by something (3 x eleks and 3 x dipoles)
% this is why the dipoles were transposed in the example above
% for those interested, look at the compute_lfdmat program and the function it calls

% now for the source estimation proper: invmap_reduce_as
% reads .at files and saves .at files, look at the function for
% explanations; use invmap_reduce_app for single trials
[diploc, lfdmat, data, G, invsol] = invmap_reduce_as(lfd_mat, dipoles_symmetric, 0.02, 'fom101.fl18h2.E1.at11.ar', elek129HCLnorm', 'rad', 55:111,0.1,4);

% for 350 locations
load locations_350.mat
[diploc, lfdmat, data, G, invsol] = invmap_reduce_as(lfd_mat, dipoles_symmetric, 0.001, 'fom101.fl18h2.E1.at11.ar', locations_350', 'rad', 55:111,0.1,1);

% for mat files
for file = 1:size(filemat,1);
[diploc, lfdmat, data, G, invsol] = invmap_reduce_mat(lfdmat, dipoles_symmetric, 0.02, pwd, filemat(file,:), pwd, [], giessen64elecsXYZ4MNE', 1, 1300, 'rad', 200:300);
end
