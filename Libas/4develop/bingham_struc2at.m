function bingham_struc2at(filepath)
% navigate into folder that has output from bingham_avgsubj, filed suffix
% should be something along the lines of GMspectrum.mat
% and then bingham_struc2at(filepath), where filepath is the .mat file

temp1 = load(filepath); 

happy = temp1.GMspectrum_15HzFace.amphappy(1:31,:); 

SaveAvgFile([filepath '.happy.at'], happy, [], [], 5000);

angry = temp1.GMspectrum_15HzFace.ampangry(1:31,:); 

SaveAvgFile([filepath '.angry.at'], angry, [], [], 5000);

sad = temp1.GMspectrum_15HzFace.ampsad(1:31,:); 

SaveAvgFile([filepath '.sad.at'], sad, [], [], 5000);

end