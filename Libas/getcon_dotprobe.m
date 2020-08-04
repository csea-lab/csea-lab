function [condivec_LR_fastslow, probeconvec, facecondvec, corrvecpercent8, MeanRTvec] = getcon_dotprobe(filepath);

% Gets conditions for dot probe study
% c1 = left horizontal
% c2 = left vertical
% c3 = right horizontal
% c4 = left horizontal
% c11 = Neutral-Neutral 
% c12 = Neutral-Angry
% c13 = Angry-Neutral 
% c14 = Angry-Angry
% c111 = left fast
% c112 = left slow
% c113 = right fast
% c114 = right slow

probeconvec = []; 
respvec = []; 
rtvec = [];
facecondvec = []; 
picvec1 = [];
picvec2 = [];

fid = fopen(filepath);
count = 1;
a = 1
	
 while a > 0
	
     a = fgetl(fid)
     
     if a < 0, break, return, end
 	blankindex = findstr(a, ' ');
 	
    probeconvec = [probeconvec; str2num(a(blankindex(2)+1))];
    respvec = [respvec; str2num(a(blankindex(3)+1: blankindex(4)-1))];
    rtvec = [rtvec; str2num(a(blankindex(4)+1: blankindex(5)-1))];
   
   conletters1 = a(blankindex(6)+5: blankindex(6)+7);
   conletters2 = a(blankindex(7)+5: blankindex(7)+7);
   
   picvec1 = [picvec1; conletters1];
   picvec2 = [picvec2; conletters2];
               
            if strcmp(conletters1, 'ANS') && strcmp(conletters2, 'ANS'), facecondvec = [facecondvec; 14];
            elseif strcmp(conletters1, 'ANS') && strcmp(conletters2, 'NES'), facecondvec = [facecondvec; 13];
           elseif strcmp(conletters1, 'NES') && strcmp(conletters2, 'ANS'), facecondvec = [facecondvec; 12];
            elseif strcmp(conletters1, 'NES') && strcmp(conletters2, 'NES'), facecondvec = [facecondvec; 11];
            end

 end

fclose('all')

outmat = []; 

% do some stats on these vectors
% find correct responses, by hemifield/orientation and by hemifield and condition
 % by hemifield/orientation
 
corrvecleft_1 = find(respvec == 65 & (probeconvec == 2)); % horizontal probe in left visual field; left key (A) correct
corrvecleft_2 = find(respvec == 76 & (probeconvec == 1)); % vertical probe in left visual field; right key (L) correct

corrvecright_1 = find(respvec == 65 & (probeconvec == 4)); % horizontal probe in right visual field; left key (A) correct
corrvecright_2 = find(respvec == 76 & (probeconvec == 3)); % vertical probe in right visual field; right key (L) correct

%by hemfield and condition
 corrvec_11_Lh = find(respvec == 65 & (probeconvec == 2) & (facecondvec == 11)); % con 11 horizontal probe in left visual field; left key (A) correct
 corrvec_11_Lv = find(respvec == 76 & (probeconvec ==1 ) & (facecondvec == 11));% con 11 vertical probe in left visual field; left key (A) correct

 corrvec_12_Lh = find(respvec == 65 & (probeconvec == 2) & (facecondvec == 12)); 
 corrvec_12_Lv = find(respvec == 76 & (probeconvec == 1) & (facecondvec == 12)); 
 
 corrvec_13_Lh = find(respvec == 65 & (probeconvec == 2) & (facecondvec == 13)); 
 corrvec_13_Lv = find(respvec == 76 & (probeconvec == 1) & (facecondvec == 13)); 
 
 corrvec_14_Lh = find(respvec == 65 & (probeconvec == 2) & (facecondvec == 14)); 
 corrvec_14_Lv = find(respvec == 76 & (probeconvec == 1) & (facecondvec == 14)); 

corrvec_11_Rh = find(respvec == 65 & (probeconvec == 4) & (facecondvec == 11)); % con 11 horizontal probe in right visual field; left key (A) correct
corrvec_11_Rv = find(respvec == 76 & (probeconvec == 3) & (facecondvec == 11)); % con 11 vertical probe in right visual field; right key (L) correct
  
corrvec_12_Rh = find(respvec == 65 & (probeconvec == 4) & (facecondvec == 12));
corrvec_12_Rv = find(respvec == 76 & (probeconvec == 3) & (facecondvec == 12));

corrvec_13_Rh = find(respvec == 65 & (probeconvec == 4) & (facecondvec == 13));
corrvec_13_Rv = find(respvec == 76 & (probeconvec == 3) & (facecondvec == 13));

corrvec_14_Rh = find(respvec == 65 & (probeconvec == 4) & (facecondvec == 14));
corrvec_14_Rv = find(respvec == 76 & (probeconvec == 3) & (facecondvec == 14));

corrvec_11_L = [corrvec_11_Lh; corrvec_11_Lv];
corrvec_12_L = [corrvec_12_Lh; corrvec_12_Lv];
corrvec_13_L = [corrvec_13_Lh; corrvec_13_Lv];
corrvec_14_L = [corrvec_14_Lh; corrvec_14_Lv];

corrvec_11_R = [corrvec_11_Rh; corrvec_11_Rv];
corrvec_12_R = [corrvec_12_Rh; corrvec_12_Rv];
corrvec_13_R = [corrvec_13_Rh; corrvec_13_Rv];
corrvec_14_R = [corrvec_14_Rh; corrvec_14_Rv];


% calculate percent correct by hemifield/orientation
        percentcorrleft_V = (length(corrvecleft_2)) ./ length(probeconvec(probeconvec ==1))
        percentcorrleft_H = (length(corrvecleft_1)) ./ length(probeconvec(probeconvec ==2))

        percentcorright_V = (length(corrvecright_2)) ./ length(probeconvec(probeconvec ==3))
        percentcorright_H = (length(corrvecright_1)) ./ length(probeconvec(probeconvec ==4))

        corrvecpercent4 = [percentcorrleft_V percentcorrleft_H percentcorright_V percentcorright_H];

% by hemfield and condition

        percentcorrleft_L11 = (length(corrvec_11_L)) ./ length(facecondvec(facecondvec ==11 & probeconvec < 3));
        percentcorrleft_L12 = (length(corrvec_12_L)) ./ length(facecondvec(facecondvec ==12 & probeconvec < 3));
        percentcorrleft_L13 = (length(corrvec_13_L)) ./ length(facecondvec(facecondvec ==13 & probeconvec < 3));
        percentcorrleft_L14 = (length(corrvec_14_L)) ./ length(facecondvec(facecondvec ==14 & probeconvec < 3));
         
        percentcorrleft_R11 = (length(corrvec_11_R)) ./ length(facecondvec(facecondvec ==11 & probeconvec > 2));
        percentcorrleft_R12 = (length(corrvec_12_R)) ./ length(facecondvec(facecondvec ==12 & probeconvec > 2));
        percentcorrleft_R13 = (length(corrvec_13_R)) ./ length(facecondvec(facecondvec ==13 & probeconvec > 2));
        percentcorrleft_R14 = (length(corrvec_14_R)) ./ length(facecondvec(facecondvec ==14 & probeconvec > 2));

        length(corrvec_11_L), length(facecondvec(facecondvec ==11 & probeconvec < 3))

        corrvecpercent8 = [percentcorrleft_L11 percentcorrleft_L12 percentcorrleft_L13 percentcorrleft_L14  percentcorrleft_R11 percentcorrleft_R12 percentcorrleft_R13 percentcorrleft_R14];

% find rts by condition and do artifact correction 2 stds above median and
% <.18 as too fast

% first for VF and probe orientation

RTs_corr_left_V = rtvec(corrvecleft_2); 
toofastindices = find(RTs_corr_left_V < .18); tooslowindices = find(RTs_corr_left_V > median(RTs_corr_left_V)+ 2*std(RTs_corr_left_V));
RTs_corr_left_V(toofastindices) = []; RTs_corr_left_V(tooslowindices) = []; 
RTleftV = mean(RTs_corr_left_V);

RTs_corr_left_H = rtvec(corrvecleft_1); 
toofastindices = find(RTs_corr_left_H < .18); tooslowindices = find(RTs_corr_left_H > median(RTs_corr_left_H)+ 2*std(RTs_corr_left_H));
RTs_corr_left_H(toofastindices) = []; RTs_corr_left_H(tooslowindices) = []; 
RTleftH = mean(RTs_corr_left_H);

RTs_corr_right_V = rtvec(corrvecright_2); 
toofastindices = find(RTs_corr_right_V < .18); tooslowindices = find(RTs_corr_right_V > median(RTs_corr_right_V)+ 2*std(RTs_corr_right_V));
RTs_corr_right_V(toofastindices) = []; RTs_corr_right_V(tooslowindices) = []; 
RTrightV = mean(RTs_corr_right_V);

RTs_corr_right_H = rtvec(corrvecright_1); 
toofastindices = find(RTs_corr_right_H < .18); tooslowindices = find(RTs_corr_right_H > median(RTs_corr_right_H)+ 2*std(RTs_corr_right_H));
RTs_corr_right_H(toofastindices) = []; RTs_corr_right_H(tooslowindices) = []; 
RTrightH = mean(RTs_corr_right_H);

MeanRTvecOri = [RTleftV RTleftH RTrightV RTrightH]; 


% now VF and face condition
% LVF
RTs_corrvec_11_L= rtvec(corrvec_11_L); 
toofastindices = find(RTs_corrvec_11_L < .18); tooslowindices = find(RTs_corrvec_11_L > median(RTs_corrvec_11_L)+ 2*std(RTs_corrvec_11_L));
RTs_corrvec_11_L(toofastindices) = []; RTs_corrvec_11_L(tooslowindices) = []; 
RTleftV_11 = mean(RTs_corrvec_11_L);

RTs_corrvec_12_L= rtvec(corrvec_12_L); 
toofastindices = find(RTs_corrvec_12_L < .18); tooslowindices = find(RTs_corrvec_12_L > median(RTs_corrvec_12_L)+ 2*std(RTs_corrvec_12_L));
RTs_corrvec_12_L(toofastindices) = []; RTs_corrvec_12_L(tooslowindices) = []; 
RTleftV_12 = mean(RTs_corrvec_12_L);

RTs_corrvec_13_L= rtvec(corrvec_13_L); 
toofastindices = find(RTs_corrvec_13_L < .18); tooslowindices = find(RTs_corrvec_13_L > median(RTs_corrvec_13_L)+ 2*std(RTs_corrvec_13_L));
RTs_corrvec_13_L(toofastindices) = []; RTs_corrvec_13_L(tooslowindices) = []; 
RTleftV_13 = mean(RTs_corrvec_13_L);

RTs_corrvec_14_L= rtvec(corrvec_14_L); 
toofastindices = find(RTs_corrvec_14_L < .18); tooslowindices = find(RTs_corrvec_14_L > median(RTs_corrvec_14_L)+ 2*std(RTs_corrvec_14_L));
RTs_corrvec_14_L(toofastindices) = []; RTs_corrvec_14_L(tooslowindices) = []; 
RTleftV_14 = mean(RTs_corrvec_14_L);

% RVF
RTs_corrvec_11_R= rtvec(corrvec_11_R); 
toofastindices = find(RTs_corrvec_11_R < .18); tooslowindices = find(RTs_corrvec_11_R > median(RTs_corrvec_11_R)+ 2*std(RTs_corrvec_11_R));
RTs_corrvec_11_R(toofastindices) = []; RTs_corrvec_11_R(tooslowindices) = []; 
RTrightV_11 = mean(RTs_corrvec_11_R)

RTs_corrvec_12_R= rtvec(corrvec_12_R); 
toofastindices = find(RTs_corrvec_12_R < .18); tooslowindices = find(RTs_corrvec_12_R > median(RTs_corrvec_12_R)+ 2*std(RTs_corrvec_12_R));
RTs_corrvec_12_R(toofastindices) = []; RTs_corrvec_12_R(tooslowindices) = []; 
RTrightV_12 = mean(RTs_corrvec_12_R);

RTs_corrvec_13_R= rtvec(corrvec_13_R); 
toofastindices = find(RTs_corrvec_13_R < .18); tooslowindices = find(RTs_corrvec_13_R > median(RTs_corrvec_13_R)+ 2*std(RTs_corrvec_13_R));
RTs_corrvec_13_R(toofastindices) = []; RTs_corrvec_13_R(tooslowindices) = []; 
RTrightV_13 = mean(RTs_corrvec_13_R);

RTs_corrvec_14_R= rtvec(corrvec_14_R); 
toofastindices = find(RTs_corrvec_14_R < .18); tooslowindices = find(RTs_corrvec_14_R > median(RTs_corrvec_14_R)+ 2*std(RTs_corrvec_14_R));
RTs_corrvec_14_R(toofastindices) = []; RTs_corrvec_14_R(tooslowindices) = []; 
RTrightV_14 = mean(RTs_corrvec_14_R);

MeanRTvec = [RTleftV_11 RTleftV_12 RTleftV_13 RTleftV_14 RTrightV_11 RTrightV_12 RTrightV_13 RTrightV_14]; 


% now find slow and fast correct responses and assign condition names to 
% the right trials

indexcorrectleft = sort([corrvecleft_1; corrvecleft_2]); % these are still indices into the full 160 vector
indexcorrecright = sort([corrvecright_1; corrvecright_2]);

RTs_corr_left= rtvec(indexcorrectleft); % takes the rts out of the rtvec by condition
RTs_corr_right = rtvec(indexcorrecright); 

dummyleftindex_slow = find(RTs_corr_left > median(RTs_corr_left)); % these are indices into the subvectors for each hemifield
dummyleftindex_fast= find(RTs_corr_left < median(RTs_corr_left));

dummyrightindex_slow= find(RTs_corr_right > median(RTs_corr_right));
dummyrightindex_fast= find(RTs_corr_right < median(RTs_corr_right));

index111 = indexcorrectleft(dummyleftindex_fast);
index112 = indexcorrectleft(dummyleftindex_slow);

index113 = indexcorrecright(dummyrightindex_fast);
index114 = indexcorrecright(dummyrightindex_slow);

condivec_LR_fastslow = zeros(size(probeconvec)); 

condivec_LR_fastslow(index111) = 111; 
condivec_LR_fastslow(index112) = 112; 
condivec_LR_fastslow(index113) = 113; 
condivec_LR_fastslow(index114) = 114; 

end

