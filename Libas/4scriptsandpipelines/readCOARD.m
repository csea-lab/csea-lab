
function


%%
% a subfunction that reads the 6 log files and determines the order of congruent and incongruent. 
logname1 = 'HOA1conflankMN.log'
logname2 = 'HOA1conflankEF.log'
logname3 = 'HOA1conflankUV.log'
logname4 = 'HOA1incflankEF.log'
logname5 = 'HOA1incflankMN.log'
logname6 = 'HOA1incflankUV.log'

incflag = zeros(1,6); 

fid1 = fopen(logname1); 
line1 = fgetl(fid1); 
inctext = strfind(line1,'inc'); 
if inctext > 1, incflag(1) = 1; end
dateline = fgetl(fid1);
datelineonly = dateline(end-7:end);
hour = str2num(datelineonly(1:2));
minute = str2num(datelineonly(4:5));
sec = str2num(datelineonly(7:end));
starttimeinsecs(1)=sec+minute*60+hour*3600

fid2 = fopen(logname2); 
line1 = fgetl(fid2); 
inctext = strfind(line1,'inc'); 
if inctext > 1, incflag(2) = 1; end
dateline = fgetl(fid2);
datelineonly = dateline(end-7:end);
hour = str2num(datelineonly(1:2));
minute = str2num(datelineonly(4:5));
sec = str2num(datelineonly(7:end));
starttimeinsecs(2)=sec+minute*60+hour*3600 

fid3 = fopen(logname3); 
line1 = fgetl(fid3); 
inctext = strfind(line1,'inc'); 
if inctext > 1, incflag(3) = 1; end
dateline = fgetl(fid3);
datelineonly = dateline(end-7:end);
hour = str2num(datelineonly(1:2));
minute = str2num(datelineonly(4:5));
sec = str2num(datelineonly(7:end));
starttimeinsecs(3)=sec+minute*60+hour*3600 

fid4 = fopen(logname4); 
line1 = fgetl(fid4); 
inctext = strfind(line1,'inc'); 
if inctext > 1, incflag(4) = 1; end
dateline = fgetl(fid4);
datelineonly = dateline(end-7:end);
hour = str2num(datelineonly(1:2));
minute = str2num(datelineonly(4:5));
sec = str2num(datelineonly(7:end));
starttimeinsecs(4)=sec+minute*60+hour*3600 

fid5 = fopen(logname5); 
line1 = fgetl(fid5); 
inctext = strfind(line1,'inc'); 
if inctext > 1, incflag(5) = 1; end
dateline = fgetl(fid5);
datelineonly = dateline(end-7:end);
hour = str2num(datelineonly(1:2));
minute = str2num(datelineonly(4:5));
sec = str2num(datelineonly(7:end));
starttimeinsecs(5)=sec+minute*60+hour*3600 

fid6 = fopen(logname6); 
line1 = fgetl(fid6); 
inctext = strfind(line1,'inc'); 
if inctext > 1, incflag(6) = 1; end
dateline = fgetl(fid6);
datelineonly = dateline(end-7:end);
hour = str2num(datelineonly(1:2));
minute = str2num(datelineonly(4:5));
sec = str2num(datelineonly(7:end));
starttimeinsecs(6)=sec+minute*60+hour*3600 
    
[sorted, index] = sort(starttimeinsecs); 

blockflagvector = incflag(index)+1; 

blockmarkers =[]; 
for x = 1:6
    blockmarkers = [blockmarkers; ones(200,1).* blockflagvector(x)]; 
end

blockmarkers = blockmarkers .* 200; 

%%
filename = 'event_coard_test.txt'; % this is created by eeglab -> save events

order = 1; % this is input by th euser to reflect the block order


% the portion below reads in the eeglab event file
fid = fopen(filename);
dummy = fgetl(fid); 
mat = []; 
line = 1; 

% go through the lines of the event file and extrat all triggers
while line > 0 
    line = fgetl(fid), if line == -1, break, return, end
    mat = [mat; str2num(line)]; 
end

fclose('all') 

% event file is now closed, now extract triggers/markers of interest
eventtime =[]; 
eventcode = []; 
for x = 1:length(mat(:, 2))-1
    if mat(x, 2) == 1 || mat(x, 2) == 6
    % disp(x), disp(mat(x, :)), pause
        eventtime = [eventtime mat(x, 4)];
        eventcode = [eventcode mat(x, 2).*10 + mat(x+1, 2)];
    end
end

%%
% put it all together
neweventcode = eventcode(1:1200)' + blockmarkers; 

% make an output matrix
eventsout  = [column(1:1200) neweventcode zeros(1200,1) eventtime(1:1200)' column(1:1200)]; 

    