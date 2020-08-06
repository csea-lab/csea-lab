% searches condnumbers in *dat file generated by rdkiaps file
function [RTvecEarlyLate, outmat] = getresponse_rdkAK(filepath);
% can print out all of this...function [ conditionvec, RT, errorvec, onsettime, targetvec, earlylatelabel, picvec, outmat, RTvecEarlyLate, correctvec] = getresponse_rdk(filepath);

condvec = []; 

picvec = [];

fid = fopen(filepath)

trialcount = 1;
a = 1;
	
 while a > 0
	
     a = fgetl(fid);
     
     if a < 0, break, return, end
            
     % find the blanks - > so I know where the picture name is 
     blankindices = find(a== ' '); 
     
      conditionTar = deblank(a(blankindices(3)+1)); %target/non-target condition file is after 3rd blank (1, 2, or 3)
      
      targetvec(trialcount) = str2num(conditionTar);
      
      onsettimetemp = deblank(a(blankindices(4):blankindices(4)+2));
      
      onsettime(trialcount) = str2num(onsettimetemp).*116.666 - 116.66;
            
     
     picturestring = (a((blankindices(7)+1:blankindices(7)+2))); %get the picture name info after the 7th blank
     picturestring_long = (a((blankindices(7)+1:blankindices(7)+4))); %get the picture name info after the 7th blank
     picvec = [picvec; picturestring_long];
     
     
     rt(trialcount) = str2num(a(blankindices(6):blankindices(7))); %get the RT info after the 6th blank
     
     if rt(trialcount) < 0, rt(trialcount) = rt(trialcount)+ 8751; end %should be 8650?? and add the 4 retraces too 66.6ms    
          
               if picturestring ==  'er', condition(trialcount) = 1;
                elseif picturestring ==  'ct', condition(trialcount) = 2;    
                elseif picturestring ==  'ca', condition(trialcount) = 2;
                elseif picturestring ==  'wr', condition(trialcount) = 3;
                elseif picturestring ==  'wk', condition(trialcount) = 3;
                elseif picturestring ==  'cw', condition(trialcount) = 4;
                elseif picturestring ==  'co', condition(trialcount) = 4; 
                elseif picturestring ==  'mu', condition(trialcount) = 5;
                elseif picturestring ==  'mt', condition(trialcount) = 5;    
                elseif picturestring ==  'sn', condition(trialcount) = 6;
                
                end
      
              trialcount;
 
              
trialcount = trialcount + 1; 
 end % while loop trials
 
 
fclose('all')
  
targetvec = targetvec' .* 100; 

conditionvec = condition' + targetvec; 
  
conditionvec1to6 = condition'; %condition = picture conditions, 1-6

rt = rt' .*0.001; %change RT into seconds

onsettime = onsettime' .*0.001; %change onset time also into seconds


RT = rt-onsettime; % convert rt relative to picture offset to RT relative to target

earlylatelabel = zeros(size(RT)); 
earlylatelabel(find(onsettime>3.750)) = 2;
earlylatelabel(find(onsettime>1 & onsettime<3.751 & onsettime>0)) = 1;

conditionvecRT =  rt;  %create a vector for RT and save as .conRT file 

condition = condition' .*100;% condition zero R.Time --> 106.4753 (Cond 1 w/RT = 6.4753 sec)

conditionvecPicRT =[conditionvec  RT];% can use a semi-colon to have the conditionvec and RT values not stacked but side by side 


% %create a vector that has 1s for correct responses, for each trial
indexvec_press = find(RT > .15);
correctvec = zeros(size(condition)); %empty vector to populate
targettrialindices = find(targetvec > 100 & targetvec <  299); %299 excludes the double-flick trials

%  the original code had x2 as = 1 also, but it should be zero...
for x1 = 1:length(correctvec) 
    if ismember(x1,targettrialindices) && ismember(x1,indexvec_press), correctvec(x1) = 1; end %correct response = 1
end
%if its not a target trial and they didn't press after 150 ms, incorrect
for x2 = 1:length(correctvec) 
    if ~ismember(x2,targettrialindices) && ismember(x2,indexvec_press), correctvec(x2) = 0; end %incorrect response = 0 
end

% finally create a comprehensive output matrix with trial-by-trial data

outmat = [conditionvec RT correctvec]; 
%output matrix of condivion vec (target/nontarget and condition#), RT, and
%correct(1)/incorrect(0) response 

% find all the response times for all conditions
indices_101 = find(conditionvecPicRT(:,1) == 101); response_101 = conditionvecPicRT(indices_101,2); 
indices_102 = find(conditionvecPicRT(:,1) == 102); response_102 = conditionvecPicRT(indices_102,2); 
indices_103 = find(conditionvecPicRT(:,1) == 103); response_103 = conditionvecPicRT(indices_103,2); 
indices_104 = find(conditionvecPicRT(:,1) == 104); response_104 = conditionvecPicRT(indices_104,2); 
indices_105 = find(conditionvecPicRT(:,1) == 105); response_105 = conditionvecPicRT(indices_105,2); 
indices_106 = find(conditionvecPicRT(:,1) == 106); response_106 = conditionvecPicRT(indices_106,2); 
indices_201 = find(conditionvecPicRT(:,1) == 201); response_201 = conditionvecPicRT(indices_201,2);
indices_202 = find(conditionvecPicRT(:,1) == 202); response_202 = conditionvecPicRT(indices_202,2); 
indices_203 = find(conditionvecPicRT(:,1) == 203); response_203 = conditionvecPicRT(indices_203,2); 
indices_204 = find(conditionvecPicRT(:,1) == 204); response_204 = conditionvecPicRT(indices_204,2); 
indices_205 = find(conditionvecPicRT(:,1) == 205); response_205 = conditionvecPicRT(indices_205,2); 
indices_206 = find(conditionvecPicRT(:,1) == 206); response_206 = conditionvecPicRT(indices_206,2); 
%Don't do anything for the double flick conditions?! 

%percent error: nontargets -> false alarms
%erroneous response if clicked the mouse at all for the non-targets
error_101 = length(find(response_101) > 0)/length(indices_101);
error_102 = length(find(response_102) > 0)/length(indices_102);
error_103 = length(find(response_103) > 0)/length(indices_103);
error_104 = length(find(response_104) > 0)/length(indices_104);
error_105 = length(find(response_105) > 0)/length(indices_105);
error_106 = length(find(response_106) > 0)/length(indices_106);

% in original code: 
% % now for conditions with targets: Mean RT
% %correct response if clicked after 150 ms 
indices_correct_201 =  find(response_201 > 0) ; meanRT_201 = mean(response_201(indices_correct_201));
indices_correct_202 =  find(response_202 > 0) ; meanRT_202 = mean(response_202(indices_correct_202));
indices_correct_203 =  find(response_203 > 0) ; meanRT_203 = mean(response_203(indices_correct_203));
indices_correct_204 =  find(response_204 > 0) ; meanRT_204 = mean(response_204(indices_correct_204));
indices_correct_205 =  find(response_205 > 0) ; meanRT_205 = mean(response_205(indices_correct_205));
indices_correct_206 =  find(response_206 > 0) ; meanRT_206 = mean(response_206(indices_correct_206));


% % % now for conditions with targets: Mean RT  
% % %correct response if clicked after 150 ms 
% 
% % now to include the part about the correct responses....???(correctvec)
% indices_correct_201 =  find(response_201 > 0.15 & correctvec(indices_201) == 1) ; meanRT_201 = mean(response_201(indices_correct_201));
% indices_correct_202 =  find(response_202 > 0.15 & correctvec(indices_202) == 1) ; meanRT_202 = mean(response_202(indices_correct_202));
% indices_correct_203 =  find(response_203 > 0.15 & correctvec(indices_203) == 1) ; meanRT_203 = mean(response_203(indices_correct_203));
% indices_correct_204 =  find(response_204 > 0.15 & correctvec(indices_204) == 1) ; meanRT_204 = mean(response_204(indices_correct_204));
% indices_correct_205 =  find(response_205 > 0.15 & correctvec(indices_205) == 1) ; meanRT_205 = mean(response_205(indices_correct_205));
% indices_correct_206 =  find(response_206 > 0.15 & correctvec(indices_206) == 1) ; meanRT_206 = mean(response_206(indices_correct_206));

% % now for conditions with targets: Mean RT SPLIT BY EARLY AND LATE
% %correct response if clicked after 150 ms
% %%%%%%% EARLY RTs
% indices_correct_201_early =  find(response_201 > 0.15 & earlylatelabel(indices_201) ==1) ; meanRT_201_early = mean(response_201(indices_correct_201_early));
% indices_correct_202_early =  find(response_202 > 0.15 & earlylatelabel(indices_202) ==1) ; meanRT_202_early = mean(response_202(indices_correct_202_early));
% indices_correct_203_early =  find(response_203 > 0.15 & earlylatelabel(indices_203) ==1) ; meanRT_203_early = mean(response_203(indices_correct_203_early));
% indices_correct_204_early =  find(response_204) > 0.15 & earlylatelabel(indices_204) ==1 ; meanRT_204_early = mean(response_204(indices_correct_204_early));
% indices_correct_205_early =  find(response_205) > 0.15 & earlylatelabel(indices_205) ==1 ; meanRT_205_early = mean(response_205(indices_correct_205_early));
% indices_correct_206_early =  find(response_206) > 0.15 & earlylatelabel(indices_206) ==1 ; meanRT_206_early = mean(response_206(indices_correct_206_early));

% now for conditions with targets: Mean RT SPLIT BY EARLY AND LATE
%correct response if clicked after 150 ms
%%%%%%% EARLY RTs
% added this: & correctvec(indices_201) == 1

indices_correct_201_early =  find(response_201 > 0.15 & earlylatelabel(indices_201) ==1 & correctvec(indices_201) == 1) ; meanRT_201_early = mean(response_201(indices_correct_201_early));
indices_correct_202_early =  find(response_202 > 0.15 & earlylatelabel(indices_202) ==1 & correctvec(indices_202) == 1) ; meanRT_202_early = mean(response_202(indices_correct_202_early));
indices_correct_203_early =  find(response_203 > 0.15 & earlylatelabel(indices_203) ==1 & correctvec(indices_203) == 1) ; meanRT_203_early = mean(response_203(indices_correct_203_early));
indices_correct_204_early =  find(response_204 > 0.15 & earlylatelabel(indices_204) ==1 & correctvec(indices_204) == 1) ; meanRT_204_early = mean(response_204(indices_correct_204_early));
indices_correct_205_early =  find(response_205 > 0.15 & earlylatelabel(indices_205) ==1 & correctvec(indices_205) == 1) ; meanRT_205_early = mean(response_205(indices_correct_205_early));
indices_correct_206_early =  find(response_206 > 0.15 & earlylatelabel(indices_206) ==1 & correctvec(indices_206) == 1) ; meanRT_206_early = mean(response_206(indices_correct_206_early));

% now for conditions with targets: Mean RT SPLIT BY EARLY AND LATE
%%%%% LATE RTS
%correct response if clicked after 150 ms 
%added this:  & correctvec(indices_201) == 1

indices_correct_201_late =  find(response_201 > 0.15 & earlylatelabel(indices_201) ==2 & correctvec(indices_201) == 1) ; meanRT_201_late = mean(response_201(indices_correct_201_late));
indices_correct_202_late =  find(response_202 > 0.15 & earlylatelabel(indices_202) ==2 & correctvec(indices_202) == 1) ; meanRT_202_late = mean(response_202(indices_correct_202_late));
indices_correct_203_late =  find(response_203 > 0.15 & earlylatelabel(indices_203) ==2 & correctvec(indices_203) == 1) ; meanRT_203_late = mean(response_203(indices_correct_203_late));
indices_correct_204_late =  find(response_204 > 0.15 & earlylatelabel(indices_204) ==2 & correctvec(indices_204) == 1) ; meanRT_204_late = mean(response_204(indices_correct_204_late));
indices_correct_205_late =  find(response_205 > 0.15 & earlylatelabel(indices_205) ==2 & correctvec(indices_205) == 1) ; meanRT_205_late = mean(response_205(indices_correct_205_late));
indices_correct_206_late =  find(response_206 > 0.15 & earlylatelabel(indices_206) ==2 & correctvec(indices_206) == 1) ; meanRT_206_late = mean(response_206(indices_correct_206_late));

%prints out the early and late RT's for target erotic (201) condition
%response_201(indices_correct_201_early)
%response_201(indices_correct_201_late)
% meanRT_201_early
meanRT_201_early
indices_correct_201_early
response_201(indices_correct_201_early)

% for conditions without targets: mean RT of the false alarms
meanRT_101 = mean(response_101); 
meanRT_102 = mean(response_102); 
meanRT_103 = mean(response_103); 
meanRT_104 = mean(response_104); 
meanRT_105 = mean(response_105); 
meanRT_106 = mean(response_106); 

% percent error: targets -> misses overall
error_201 = 1- length(indices_correct_201)/length(indices_201);
error_202 = 1- length(indices_correct_202)/length(indices_202);
error_203 = 1- length(indices_correct_203)/length(indices_203);
error_204 = 1- length(indices_correct_204)/length(indices_204);
error_205 = 1- length(indices_correct_205)/length(indices_205);
error_206 = 1- length(indices_correct_206)/length(indices_206);


%%%%% percent errors for early and late  indices_correct_201_early
%%% EARLY
% percent error: targets -> misses EARLY
error_201_early = 1- length(indices_correct_201_early)/length(indices_correct_201_early);
error_202_early = 1- length(indices_correct_202_early)/length(indices_correct_202_early);
error_203_early = 1- length(indices_correct_203_early)/length(indices_correct_203_early);
error_204_early = 1- length(indices_correct_204_early)/length(indices_correct_204_early);
error_205_early = 1- length(indices_correct_205_early)/length(indices_correct_205_early);
error_206_early = 1- length(indices_correct_206_early)/length(indices_correct_206_early);


%%%%% percent errors for early and late  indices_correct_201_early
%%% LATE
% percent error: targets -> misses LATE
error_201_late = 1- length(indices_correct_201_late)/length(indices_correct_201_late);
error_202_late = 1- length(indices_correct_202_late)/length(indices_correct_202_late);
error_203_late = 1- length(indices_correct_203_late)/length(indices_correct_203_late);
error_204_late = 1- length(indices_correct_204_late)/length(indices_correct_204_late);
error_205_late = 1- length(indices_correct_205_late)/length(indices_correct_205_late);
error_206_late = 1- length(indices_correct_206_late)/length(indices_correct_206_late);



errorvec_earlylate = [error_201_early error_202_early error_203_early error_204_early error_205_early error_206_early error_201_late error_202_late error_203_late error_204_late error_205_late error_206_late]';
% errorvec_earlylate 1st 6 are early, last 6 are late --> percent errors 

hitRTvec_early =  [meanRT_201_early meanRT_202_early meanRT_203_early meanRT_204_early meanRT_205_early meanRT_206_early]'; 
%RT vector for early targets (hits); 

hitRTvec_late =  [meanRT_201_late meanRT_202_late meanRT_203_late meanRT_204_late meanRT_205_late meanRT_206_late]'; 
% RT vector for late targets (hits)

RTvecEarlyLate = [meanRT_201_early meanRT_202_early meanRT_203_early meanRT_204_early meanRT_205_early meanRT_206_early meanRT_201_late meanRT_202_late meanRT_203_late meanRT_204_late meanRT_205_late meanRT_206_late];
%dont need ; to separate to VECTORS into columns (matrix? yes)...use ; to separate within a vector..BUT I need them in a row here so I can use it in SPSS 

rtvec = [meanRT_101 meanRT_102 meanRT_103 meanRT_104 meanRT_105 meanRT_106 meanRT_201 meanRT_202 meanRT_203 meanRT_204 meanRT_205 meanRT_206]'; 
%RT vector for overall RT not including earlylate labels (entire trial) for targets and non-targets

errorvec = [error_101 error_102 error_103 error_104 error_105 error_106 error_201 error_202 error_203 error_204 error_205 error_206]'; 
%<- false alarm vector 1st 6: non-targets, 2nd 6: targets


% eval(['save ' filepath '.conRTvecEarlyLate RTvecEarlyLate -ascii']) 
% 
% eval(['save ' filepath '.conPicName picvec -ascii']) 
% 
% eval(['save ' filepath '.conOutmat outmat -ascii']) 
% 
 %eval(['save ' filepath '.con conditionvec -ascii'])
% 
 eval(['save ' filepath '.con1t6 conditionvec1to6 -ascii'])
% 
% eval(['save ' filepath '.conRTVec rtvec -ascii'])
% 
% eval(['save ' filepath '.conErrorVec errorvec -ascii'])
% 
% eval(['save ' filepath '.conRT conditionvecRT -ascii'])
% 
% eval(['save ' filepath '.conhitRTvecEarly hitRTvec_early -ascii'])
% 
% eval(['save ' filepath '.conhitRTvecLate hitRTvec_late -ascii'])
% 
% eval(['save ' filepath '.conerrorvecEarlyLate errorvec_earlylate -ascii'])


%eval(['save ' filepath '.conPicRT conditionvecPicRT -ascii'])




% 
% % %*USE THIS WHEN A VALUE FOR MISS > 1******
% a = find(targetvec == 0); 
% b = find(targetvec == 1);
% c = find(targetvec == 2);
% d = find(targetvec == 3);
% 
% output = [length(a) length(b) length(c) length(d)]; 
% 
% hits = output(2)/40;
% falsealarms = output(3)/(320-40);
% misses = output(4)/40;
% corrrej = output(1)/(320-40);
% outvector = [hits misses falsealarms corrrej]
% % %BACK TO ORIGINAL STUFF: 