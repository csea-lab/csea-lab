% m bradley april 2015 translated old Pascal SCR routines to Matlab and wrote interface; 
%  revised 2016 specifically to score ERP peaks; 
%  By reversing waveforms, you can score both positive and negative peaks in separate runs.
%
% This program scores peak responses using
% two parameters below control scoring: SLOPE and MIN SIZE. They can be changed below.
% Defaults are .10 for slope and .05 for min size which works for EGI data.
% 
% It asks for 1) an input file, 2) an output file name, 3) sampling rate, and 4) whether you want to view plots
%
% It expects the input file to have the following format:
% SubNum (no characters),  trial number, data1..n, 
% For example:
% 1114321	1 	2.56  2.54 2.34 2.34.....
% 1114321  2  2.62  2.47 2.83......
%
%  The program outputs the following data for each trial and each PEAK that it finds
% TotalNumRespThisTrial, ThisResponse, OnsetLatency,PeakLatency,OnsetAmp,PkAmp,OnsetToPeak
%   4022408	  2	1              1           4150           4850          5.155         5.7275         0.5725
%   4022408	  3	3              1           1900           2600          4.985            6.3          1.315
%   4022408	  3	3              2           3600           4250         5.1625         6.3875          1.225
%   4022408	  3	3              3           4450           5400          6.205           9.16          2.955
%
% If you enter "Y" when asked to view the data, you will see a plot for each trial
% You will be asked if you want to reject each trial: If you do, type R or
% r; if you don't simply hit the return...
%
%
%
prompt='Enter input file name:  ';
iname=input(prompt,'s');
prompt='Enter output file name: ';
ofile=input(prompt,'s');
fid=fopen(ofile, 'wt' );
ifile=load (iname);
sz=size(ifile);
s=ifile(:,1);               % subjects
t=ifile(:,2);                 % trial numbers
%c=ifile(:,3); 			% channel number
dat=ifile(:,3:sz(:,2));  % data for each trial starts at column 3 for each row of data..
numpts=length(3:sz(:,2));  % number of points for each line of data e.g. 108
prompt = 'Enter sampling rate in Hz ';   %Sampling rate in Hz
SR = input (prompt);
xmax=numpts*(1000/SR);      % 108 values; SR=10, 1000/10=100 ms per sample x 108=10800 s in each line
startv = 0;
endv = xmax;				% 10800
nElem = numpts;			% 108
iview=0;
prompt='Do you want to view plots?  Y or N   ';
view=input(prompt,'s');
if view =='Y' iview=1; figure; end
ikeep=1;
x =0: (endv-startv)/(nElem-1):xmax;   %  (10800-0)/ (108-1); beg spacing end
%x= 1: length(3:sz(:,2));     % get x from 1 to length of trial
sd=size(dat);	                % number of trials overall to score			
maxd=sd(:,1)+1;              % number of lines in this data file + 1; 17 for 16 conditions
cntr=1;                              % start scoring each trial in file
% do each line in file
while cntr<maxd    % 1<17
  ikeep=1;
  sub=s(cntr,1);
  disp(['Working on sub ',num2str(sub),' Trial = ',num2str(t(cntr,1))]);
   y1=permute(dat,[2,1]);      % transpose data file so each line is in a column
   y=y1(:,cntr);			    % get column from 1 to 17 
  P=ScoreERP(x,y,SR,numpts,iview);  
  if iview == 1
% I have this here instead of in subroutine because the subroutine doesn't
% know sub and trial number and I didn't feel like sending those as
% variables too.
      str= (['Subject ' num2str(sub) ' Trial ' num2str(t(cntr,1))]);
       dim=[.2 .9 .1 .1];
       annotation('textbox',dim,'FontSize',14,'String',str);
      prompt='      Enter R or r to reject trial; Return to Accept ';
      keep=input(prompt,'s');
      if keep =='R' ikeep=0; end
      if keep =='r' ikeep=0; end
      clf;
  end
    if ikeep == 1
    % P returns 9 datapts per SCR:
    % NumResp,NumThis,Onlat,Pklat,baseAmp,peakAmp,SCR
    oc=size(P);
    nscr=oc(:,1);    
    Q=num2str(P);
       if (oc>0) 
          for r=1:oc    % write all the scrs found on this trial
          fprintf(fid,'%10d\t%3d\t%s\n',s(cntr,1),t(cntr,1),Q(r,:));
          % output= subjectNumber,trialnumber, resp number, onlat,base,peak,SCR
          end     
       end 
    end
 cntr=cntr+1;                   % do next trial
end
close all
clear
%------------------------------
%
function P=ScoreERP(x,SCL,SR,INUM,draw)
%function P=ScoreERP(x,SCL,SR,latp,INUM,draw)
% Scores ERP peaks returning a list of peak scores that
% include NumResp,NumThisResp,Onlat(ms),Pklat(ms), BaseAmp, PkAmp,SCR
% arguments are the array of  waveform data to be scored this trial
% the SAMPLING RATE,,the Number of samples for each waveform, and whether a plot will
% be displayed
%old routine filter data for smoothing; calls it 6x
for i=1:6
ifilt(1)=(.75*SCL(1))+(0.25*SCL(2));
 ifilt(INUM)=(.75*SCL(INUM))+(0.25*SCL(INUM-1));
 for j=2:INUM-1
   ifilt(j)=(SCL(j-1)+(2*SCL(j))+SCL(j+1))/4;
   end;
 SCL=ifilt;
   end;
% get differential
for i=2:INUM-1
  dY(i)=(SCL(i+1)-SCL(i-1))/2;end;
  dY(1)=dY(2);
  dY(INUM)=dY(INUM-1);
% more
		for i = 2 :INUM - 1 
			ddy(i) = (SCL(i + 1) - 2 * SCL(i) + SCL(i - 1)) / 4;
       end;
		ddy(1) = ddy(2);
		ddy(INUM) = ddy(INUM - 1);
		iwende = 1;
		nreac = 0;
%*** find pt of inflection ***)
		ncand = 0;
       maxp=INUM-1;
		for iwende=1:maxp
	      i11=0;
			if (ddy(1,iwende) < 0) i11=1; 
           elseif (ddy(1,iwende+1) >=0 ) i11 = 1;  
           elseif i11==0 
               if (dY(1,iwende + 1) > dY(1,iwende))  iwende=iwende+1;  end;
            elseif dY(1,iwende) <= 0 i11=1 ; 
            end;
              %ddy(1,iwende)
              %ddy(1,iwende+1)
              %dY(1,iwende)		 
           if i11 == 0 
			ncand = ncand + 1;
			tw(ncand) = iwende;
			dyamp(ncand) = dY(1,iwende);
           end  % if
       end;  %for
%(*** find base ***)
		for icand = 1:ncand
			dylim = 0.10 * dyamp(icand);  %  SLOPE PARAMETER CAN BE CHANGED
			ifoot = tw(icand);
			while (ifoot > 1) && (dY(ifoot) > dylim)
					ifoot = ifoot - 1; end
			tf(icand) = ifoot;
		end;
%(*** find amplitude ***)
		for icand = 1:ncand
				iampl = tw(icand);
				while (iampl < INUM) && (dY(iampl) > 0)
					iampl = iampl + 1;  end
				if iampl > 1 
					if SCL(iampl - 1) > SCL(iampl)iampl = iampl - 1; end
               end
				ta(icand) = iampl;
			end;
%(*** test base(i) <= pt of inflec (1 .. i-1) ***)
		for icand = 2:ncand
				itest = icand - 1;
				while (tw(itest) < 0) && (itest > 1)
					itest = itest - 1; end
				if tf(icand) <= tw(itest) tw(icand) = -1;  end
			end;
%(*** test base(i) > ampl(pred) ***)
		ivalid = 0;
		oldivalid = 0;
		for icand = 1:ncand
				if tw(icand) > 0 
						oldivalid = ivalid;
						ivalid = icand;
					end;
				if oldivalid > 0 
					if (ta(oldivalid) > tf(ivalid)) ta(oldivalid) = tf(ivalid);
                   end
               end
			end;
%(*** test amplitude against smallest change criteria***)
		for icand = 1:ncand
			if tw(icand) > 0 
					if ((SCL(ta(icand)) - SCL(tf(icand))) < .05) ; %  SIZE CRITERION CAN BE CHANGED
						tw(icand) = -1; end
                   if ta(icand) < tf(icand) tw(icand)= -1; end
           end
       end
%(*****) make sure onlat is after BASE lat
		ireac = 0;
		for icand = 1:ncand
			if ((tw(icand) > 0) && (nreac < 50)) 
					ireac = ireac + 1;
					itfoot(ireac) = tf(icand);
					itampl(ireac) = ta(icand);
           end
       end
% dec 2015; added a test whether the time between start of 1 response and the pk amplitude of the preceding
% response is too short
 nreac=ireac;
P=[0 0 0 0 0 0 0];
for i = 1: nreac 
   basey = SCL(itfoot(i));
   pky=SCL(itampl(i));
	SCR= SCL(itampl(i)) - SCL(itfoot(i));
	onlat= itfoot(i)*(1000/SR);
   pklat= itampl(i)*(1000/SR);
   P(i,:)= [nreac i onlat pklat basey pky SCR];
end
   if draw ==1
    miny=min(SCL)-.5;
maxy=max(SCL)+.5;
maxx=INUM*(1000/SR);
plot(x,SCL);
S=P;
 if ( P(:,1) > 0 ) 
     S(:,4)=S(:,4)-15;
     S(:,6)=(S(:,6)*.02)+S(:,6);
    text(S(:,4), S(:,6),num2str(S(:,2)),'FontSize', 14);end
axis([0,maxx,miny,maxy]);
 set(findall(gca, 'Type', 'Line'),'LineWidth',2);
end      