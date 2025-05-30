

filename = '80_Filtered_RR_Data.csv';

a = readtable(filename);

time_indices = table2array(a(1:4,4));

for timeindex=1:length(time_indices)

    conditionlabel =  char(table2array(a(timeindex,5)));

    if strcmp(conditionlabel,  'Control')
      indextemp = min(find(table2array(a(:,1) > time_indices(timeindex))));
      HRtimeseries_control = table2array(a(indextemp-15:indextemp+50,3));

    elseif strcmp(conditionlabel,  'Dry Apnea')
      indextemp = min(find(table2array(a(:,1) > time_indices(timeindex))));
      HRtimeseries_dry = table2array(a(indextemp-15:indextemp+50,3));

     elseif strcmp(conditionlabel,  'SAFI')
      indextemp = min(find(table2array(a(:,1) > time_indices(timeindex))));
      HRtimeseries_SAFI = table2array(a(indextemp-15:indextemp+50,3));

      elseif strcmp(conditionlabel,  'FIA')
      indextemp = min(find(table2array(a(:,1) > time_indices(timeindex))));
      HRtimeseries_FIA= table2array(a(indextemp-15:indextemp+50,3));

    end

end

outmat = [HRtimeseries_control'; HRtimeseries_dry'; HRtimeseries_SAFI'; HRtimeseries_FIA'];

writematrix(outmat, [filename '.HR.csv'])

plot(outmat')