function bingham_struc2at(filepath)
% navigate into folderthat has output from bingham_avgsubj
% and then bingham_struc2at(filepath), where filepath is the .mat file

temp1 = load(filepath); 

happy = temp1.GMspectrum.amphappy(1:31,:); 

SaveAvgFile([filepath '.happy.at'], happy, [], [], 5000);

end