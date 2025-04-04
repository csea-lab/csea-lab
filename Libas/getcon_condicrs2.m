% 
% searches condnumbers in *dat file generarted by exp psyctb file

function [outmat_full, hab_acq, rtsyes, rtsno] = getcon_condicrs2(filemat);

% contrast1 = 0.55;
% contrast2 = 0.95;
% contrast3 = 1.64;
% contrast4 = 2.84;
%  contrast5 = 4.93;
% contrast6 = 8.54;
% contrast7 = 14.8;
% contrast8 = 25.66;

% % condicrsI - detection task contrast
% contrast1 = 0.9;
% contrast2 = 1.38;
% contrast3 = 2.13;
% contrast4 = 3.27;
%  contrast5 = 5.03;
% contrast6 = 7.73;
% contrast7 = 11.88;
% contrast8 = 18.26;

% condicrsII - discrimination task contrast
contrast0 = 0;
contrast1 = 1.34;
contrast2 = 1.81;
contrast3 = 2.45;
contrast4 = 3.30;
contrast5 = 4.46;
contrast6 = 6.02;
contrast7 = 8.12;
contrast8 = 10.97;

for fileindex = 1 :size(filemat,1)
    
    filepath = deblank(filemat(fileindex,:)); 
 
    rtvec = []; 
    blockvec = []; 
    trialvec = []; 
    thetavec =[]; 
    respkeyvec = []; 
    contrastvec =[]; 
    correctvec = []; 
     falarmvec = []; 
    guessvec = [];
      
fid = fopen(filepath);

a = 1;
	
 while a > 0
	a = fgetl(fid);
   
    if a > 0
    
        indexvec = findstr(a, ' '); % 
        
        blockvec = [blockvec str2num(a(indexvec(1)+1))];
        trialvec = [trialvec str2num(a(indexvec(2):indexvec(3)))];
        thetavec = [thetavec str2num(a(indexvec(3):indexvec(4)))];
        respkeyvec = [respkeyvec str2num(a(indexvec(4):indexvec(5)))];
        contrastvec = [contrastvec str2num(a(indexvec(5):indexvec(6)))];
        rtvec = [rtvec str2num(a(indexvec(6):indexvec(7)))];
        correctvec = [correctvec (a(indexvec(7)+1))];
        falarmvec = [falarmvec (a(indexvec(7)+1))];
        guessvec = [guessvec (a(indexvec(7)+1))];      
        
    end
 
 end

 correctvec = (correctvec == 'A')
 falarmvec = (falarmvec == 'I')
 guessRvec = (guessvec == 'N' & respkeyvec == 2)
 guessLvec = (guessvec == 'N' & respkeyvec == 1)
 
 outmat_full = [blockvec' trialvec' contrastvec' rtvec' correctvec' thetavec' falarmvec' guessRvec' guessLvec'];
 
 %%%%%%%%%%%%%%%%%%%%%%%%       accuracy   %%%%%%%%%%%%%%%%%%%%%%%%%%%
 % block one _1
 % % hits and misses
 % CS plus (CSp)
 hitvec_C1_CSp_1 = outmat_full(outmat_full(:,3) == contrast1 & outmat_full(:,1) == 1 & outmat_full(:,6) == 20, 5);
 hitvec_C2_CSp_1 = outmat_full(outmat_full(:,3) == contrast2 & outmat_full(:,1) == 1 & outmat_full(:,6) == 20, 5);
 hitvec_C3_CSp_1 = outmat_full(outmat_full(:,3) == contrast3 & outmat_full(:,1) == 1 & outmat_full(:,6) == 20, 5);
 hitvec_C4_CSp_1 = outmat_full(outmat_full(:,3) == contrast4 & outmat_full(:,1) == 1 & outmat_full(:,6) == 20, 5);
 hitvec_C5_CSp_1 = outmat_full(outmat_full(:,3) == contrast5 & outmat_full(:,1) == 1 & outmat_full(:,6) == 20, 5);
 hitvec_C6_CSp_1 = outmat_full(outmat_full(:,3) == contrast6 & outmat_full(:,1) == 1 & outmat_full(:,6) == 20, 5);
 hitvec_C7_CSp_1 = outmat_full(outmat_full(:,3) == contrast7 & outmat_full(:,1) == 1 & outmat_full(:,6) == 20, 5);
 hitvec_C8_CSp_1 = outmat_full(outmat_full(:,3) == contrast8 & outmat_full(:,1) == 1 & outmat_full(:,6) == 20, 5);
 
 favec_C1_CSp_1 = outmat_full(outmat_full(:,3) == contrast1 & outmat_full(:,1) == 1 & outmat_full(:,6) == -20, 7);
 favec_C2_CSp_1 = outmat_full(outmat_full(:,3) == contrast2 & outmat_full(:,1) == 1 & outmat_full(:,6) == -20, 7);
 favec_C3_CSp_1 = outmat_full(outmat_full(:,3) == contrast3 & outmat_full(:,1) == 1 & outmat_full(:,6) == -20, 7);
 favec_C4_CSp_1 = outmat_full(outmat_full(:,3) == contrast4 & outmat_full(:,1) == 1 & outmat_full(:,6) == -20, 7);
 favec_C5_CSp_1 = outmat_full(outmat_full(:,3) == contrast5 & outmat_full(:,1) == 1 & outmat_full(:,6) == -20, 7);
 favec_C6_CSp_1 = outmat_full(outmat_full(:,3) == contrast6 & outmat_full(:,1) == 1 & outmat_full(:,6) == -20, 7);
 favec_C7_CSp_1 = outmat_full(outmat_full(:,3) == contrast7 & outmat_full(:,1) == 1 & outmat_full(:,6) == -20, 7);
 favec_C8_CSp_1 = outmat_full(outmat_full(:,3) == contrast8 & outmat_full(:,1) == 1 & outmat_full(:,6) == -20, 7);

 
 % CS minus (CSm)
 hitvec_C1_CSm_1 = outmat_full(outmat_full(:,3) == contrast1 & outmat_full(:,1) == 1 & outmat_full(:,6) == -20, 5);
 hitvec_C2_CSm_1 = outmat_full(outmat_full(:,3) == contrast2 & outmat_full(:,1) == 1 & outmat_full(:,6) == -20, 5);
 hitvec_C3_CSm_1 = outmat_full(outmat_full(:,3) == contrast3 & outmat_full(:,1) == 1 & outmat_full(:,6) == -20, 5);
 hitvec_C4_CSm_1 = outmat_full(outmat_full(:,3) == contrast4 & outmat_full(:,1) == 1 & outmat_full(:,6) == -20, 5);
 hitvec_C5_CSm_1 = outmat_full(outmat_full(:,3) == contrast5 & outmat_full(:,1) == 1 & outmat_full(:,6) == -20, 5);
 hitvec_C6_CSm_1 = outmat_full(outmat_full(:,3) == contrast6 & outmat_full(:,1) == 1 & outmat_full(:,6) == -20, 5);
 hitvec_C7_CSm_1 = outmat_full(outmat_full(:,3) == contrast7 & outmat_full(:,1) == 1 & outmat_full(:,6) == -20, 5);
 hitvec_C8_CSm_1 = outmat_full(outmat_full(:,3) == contrast8 & outmat_full(:,1) == 1 & outmat_full(:,6) == -20, 5);
 
 favec_C1_CSm_1 = outmat_full(outmat_full(:,3) == contrast1 & outmat_full(:,1) == 1 & outmat_full(:,6) == 20, 7);
 favec_C2_CSm_1 = outmat_full(outmat_full(:,3) == contrast2 & outmat_full(:,1) == 1 & outmat_full(:,6) == 20, 7);
 favec_C3_CSm_1 = outmat_full(outmat_full(:,3) == contrast3 & outmat_full(:,1) == 1 & outmat_full(:,6) == 20, 7);
 favec_C4_CSm_1 = outmat_full(outmat_full(:,3) == contrast4 & outmat_full(:,1) == 1 & outmat_full(:,6) == 20, 7);
 favec_C5_CSm_1 = outmat_full(outmat_full(:,3) == contrast5 & outmat_full(:,1) == 1 & outmat_full(:,6) == 20, 7);
 favec_C6_CSm_1 = outmat_full(outmat_full(:,3) == contrast6 & outmat_full(:,1) == 1 & outmat_full(:,6) == 20, 7);
 favec_C7_CSm_1 = outmat_full(outmat_full(:,3) == contrast7 & outmat_full(:,1) == 1 & outmat_full(:,6) == 20, 7);
 favec_C8_CSm_1 = outmat_full(outmat_full(:,3) == contrast8 & outmat_full(:,1) == 1 & outmat_full(:,6) == 20, 7);
 
 hitsbycontrast_CSp_1 = [sum(hitvec_C1_CSp_1)/length(hitvec_C1_CSp_1) sum(hitvec_C2_CSp_1)/length(hitvec_C2_CSp_1) sum(hitvec_C3_CSp_1)/length(hitvec_C3_CSp_1), ...
  sum(hitvec_C4_CSp_1)/length(hitvec_C4_CSp_1) sum(hitvec_C5_CSp_1)/length(hitvec_C5_CSp_1)   sum(hitvec_C6_CSp_1)/length(hitvec_C6_CSp_1), ...
  sum(hitvec_C7_CSp_1)/length(hitvec_C7_CSp_1)    sum(hitvec_C8_CSp_1)/length(hitvec_C8_CSp_1)];

hitsbycontrast_CSm_1 = [sum(hitvec_C1_CSm_1)/length(hitvec_C1_CSm_1) sum(hitvec_C2_CSm_1)/length(hitvec_C2_CSm_1) sum(hitvec_C3_CSm_1)/length(hitvec_C3_CSm_1), ...
  sum(hitvec_C4_CSm_1)/length(hitvec_C4_CSm_1) sum(hitvec_C5_CSm_1)/length(hitvec_C5_CSm_1)   sum(hitvec_C6_CSm_1)/length(hitvec_C6_CSm_1), ...
  sum(hitvec_C7_CSm_1)/length(hitvec_C7_CSm_1)    sum(hitvec_C8_CSm_1)/length(hitvec_C8_CSm_1)];

fabycontrast_CSp_1 = [sum(favec_C1_CSp_1)/length(favec_C1_CSp_1) sum(favec_C2_CSp_1)/length(favec_C2_CSp_1) sum(favec_C3_CSp_1)/length(favec_C3_CSp_1), ...
  sum(favec_C4_CSp_1)/length(favec_C4_CSp_1) sum(favec_C5_CSp_1)/length(favec_C5_CSp_1)   sum(favec_C6_CSp_1)/length(favec_C6_CSp_1), ...
  sum(favec_C7_CSp_1)/length(favec_C7_CSp_1)    sum(favec_C8_CSp_1)/length(favec_C8_CSp_1)];

fabycontrast_CSm_1 = [sum(favec_C1_CSm_1)/length(favec_C1_CSm_1) sum(favec_C2_CSm_1)/length(favec_C2_CSm_1) sum(favec_C3_CSm_1)/length(favec_C3_CSm_1), ...
  sum(favec_C4_CSm_1)/length(favec_C4_CSm_1) sum(favec_C5_CSm_1)/length(favec_C5_CSm_1)   sum(favec_C6_CSm_1)/length(favec_C6_CSm_1), ...
  sum(favec_C7_CSm_1)/length(favec_C7_CSm_1)    sum(favec_C8_CSm_1)/length(favec_C8_CSm_1)];

 
 guessRvec_C0_CS_1 = outmat_full(outmat_full(:,3) == contrast0 & outmat_full(:,1) == 1, 8)
 guessLvec_C0_CS_1 = outmat_full(outmat_full(:,3) == contrast0 & outmat_full(:,1) == 1, 9)
 guessR_CS_1 = [sum(guessRvec_C0_CS_1)/length(guessRvec_C0_CS_1)]
 guessL_CS_1 = [sum(guessLvec_C0_CS_1)/length(guessLvec_C0_CS_1)]
 
 hitsbycontrast_1 = [hitsbycontrast_CSp_1; hitsbycontrast_CSm_1]; 
 fabycontrast_1 = [fabycontrast_CSp_1; fabycontrast_CSm_1];
 guess_1 = [guessR_CS_1; guessL_CS_1];
 
 
 
 % block two _2
 % % hits and false alarms
 % CS plus (CSp)
 hitvec_C1_CSp_2 = outmat_full(outmat_full(:,3) == contrast1 & outmat_full(:,1) == 2 & outmat_full(:,6) == 20, 5);
 hitvec_C2_CSp_2 = outmat_full(outmat_full(:,3) == contrast2 & outmat_full(:,1) == 2 & outmat_full(:,6) == 20, 5);
 hitvec_C3_CSp_2 = outmat_full(outmat_full(:,3) == contrast3 & outmat_full(:,1) == 2 & outmat_full(:,6) == 20, 5);
 hitvec_C4_CSp_2 = outmat_full(outmat_full(:,3) == contrast4 & outmat_full(:,1) == 2 & outmat_full(:,6) == 20, 5);
 hitvec_C5_CSp_2 = outmat_full(outmat_full(:,3) == contrast5 & outmat_full(:,1) == 2 & outmat_full(:,6) == 20, 5);
 hitvec_C6_CSp_2 = outmat_full(outmat_full(:,3) == contrast6 & outmat_full(:,1) == 2 & outmat_full(:,6) == 20, 5);
 hitvec_C7_CSp_2 = outmat_full(outmat_full(:,3) == contrast7 & outmat_full(:,1) == 2 & outmat_full(:,6) == 20, 5);
 hitvec_C8_CSp_2 = outmat_full(outmat_full(:,3) == contrast8 & outmat_full(:,1) == 2 & outmat_full(:,6) == 20, 5);
 
 favec_C1_CSp_2 = outmat_full(outmat_full(:,3) == contrast1 & outmat_full(:,1) == 2 & outmat_full(:,6) == -20, 7);
 favec_C2_CSp_2 = outmat_full(outmat_full(:,3) == contrast2 & outmat_full(:,1) == 2 & outmat_full(:,6) == -20, 7);
 favec_C3_CSp_2 = outmat_full(outmat_full(:,3) == contrast3 & outmat_full(:,1) == 2 & outmat_full(:,6) == -20, 7);
 favec_C4_CSp_2 = outmat_full(outmat_full(:,3) == contrast4 & outmat_full(:,1) == 2 & outmat_full(:,6) == -20, 7);
 favec_C5_CSp_2 = outmat_full(outmat_full(:,3) == contrast5 & outmat_full(:,1) == 2 & outmat_full(:,6) == -20, 7);
 favec_C6_CSp_2 = outmat_full(outmat_full(:,3) == contrast6 & outmat_full(:,1) == 2 & outmat_full(:,6) == -20, 7);
 favec_C7_CSp_2 = outmat_full(outmat_full(:,3) == contrast7 & outmat_full(:,1) == 2 & outmat_full(:,6) == -20, 7);
 favec_C8_CSp_2 = outmat_full(outmat_full(:,3) == contrast8 & outmat_full(:,1) == 2 & outmat_full(:,6) == -20, 7);
  
 % CS minus (CSm)
 hitvec_C1_CSm_2 = outmat_full(outmat_full(:,3) == contrast1 & outmat_full(:,1) == 2 & outmat_full(:,6) == -20, 5);
 hitvec_C2_CSm_2 = outmat_full(outmat_full(:,3) == contrast2 & outmat_full(:,1) == 2 & outmat_full(:,6) == -20, 5);
 hitvec_C3_CSm_2 = outmat_full(outmat_full(:,3) == contrast3 & outmat_full(:,1) == 2 & outmat_full(:,6) == -20, 5);
 hitvec_C4_CSm_2 = outmat_full(outmat_full(:,3) == contrast4 & outmat_full(:,1) == 2 & outmat_full(:,6) == -20, 5);
 hitvec_C5_CSm_2 = outmat_full(outmat_full(:,3) == contrast5 & outmat_full(:,1) == 2 & outmat_full(:,6) == -20, 5);
 hitvec_C6_CSm_2 = outmat_full(outmat_full(:,3) == contrast6 & outmat_full(:,1) == 2 & outmat_full(:,6) == -20, 5);
 hitvec_C7_CSm_2 = outmat_full(outmat_full(:,3) == contrast7 & outmat_full(:,1) == 2 & outmat_full(:,6) == -20, 5);
 hitvec_C8_CSm_2 = outmat_full(outmat_full(:,3) == contrast8 & outmat_full(:,1) == 2 & outmat_full(:,6) == -20, 5);
 
 favec_C1_CSm_2 = outmat_full(outmat_full(:,3) == contrast1 & outmat_full(:,1) == 2 & outmat_full(:,6) == 20, 7);
 favec_C2_CSm_2 = outmat_full(outmat_full(:,3) == contrast2 & outmat_full(:,1) == 2 & outmat_full(:,6) == 20, 7);
 favec_C3_CSm_2 = outmat_full(outmat_full(:,3) == contrast3 & outmat_full(:,1) == 2 & outmat_full(:,6) == 20, 7);
 favec_C4_CSm_2 = outmat_full(outmat_full(:,3) == contrast4 & outmat_full(:,1) == 2 & outmat_full(:,6) == 20, 7);
 favec_C5_CSm_2 = outmat_full(outmat_full(:,3) == contrast5 & outmat_full(:,1) == 2 & outmat_full(:,6) == 20, 7);
 favec_C6_CSm_2 = outmat_full(outmat_full(:,3) == contrast6 & outmat_full(:,1) == 2 & outmat_full(:,6) == 20, 7);
 favec_C7_CSm_2 = outmat_full(outmat_full(:,3) == contrast7 & outmat_full(:,1) == 2 & outmat_full(:,6) == 20, 7);
 favec_C8_CSm_2 = outmat_full(outmat_full(:,3) == contrast8 & outmat_full(:,1) == 2 & outmat_full(:,6) == 20, 7);
 
 hitsbycontrast_CSp_2 = [sum(hitvec_C1_CSp_2)/length(hitvec_C1_CSp_2) sum(hitvec_C2_CSp_2)/length(hitvec_C2_CSp_2) sum(hitvec_C3_CSp_2)/length(hitvec_C3_CSp_2), ...
  sum(hitvec_C4_CSp_2)/length(hitvec_C4_CSp_2) sum(hitvec_C5_CSp_2)/length(hitvec_C5_CSp_2)   sum(hitvec_C6_CSp_2)/length(hitvec_C6_CSp_2), ...
  sum(hitvec_C7_CSp_2)/length(hitvec_C7_CSp_2)    sum(hitvec_C8_CSp_2)/length(hitvec_C8_CSp_2)];

hitsbycontrast_CSm_2 = [sum(hitvec_C1_CSm_2)/length(hitvec_C1_CSm_2) sum(hitvec_C2_CSm_2)/length(hitvec_C2_CSm_2) sum(hitvec_C3_CSm_2)/length(hitvec_C3_CSm_2), ...
  sum(hitvec_C4_CSm_2)/length(hitvec_C4_CSm_2) sum(hitvec_C5_CSm_2)/length(hitvec_C5_CSm_2)   sum(hitvec_C6_CSm_2)/length(hitvec_C6_CSm_2), ...
  sum(hitvec_C7_CSm_2)/length(hitvec_C7_CSm_2)    sum(hitvec_C8_CSm_2)/length(hitvec_C8_CSm_2)];

fabycontrast_CSp_2 = [sum(favec_C1_CSp_2)/length(favec_C1_CSp_2) sum(favec_C2_CSp_2)/length(favec_C2_CSp_2) sum(favec_C3_CSp_2)/length(favec_C3_CSp_2), ...
  sum(favec_C4_CSp_2)/length(favec_C4_CSp_2) sum(favec_C5_CSp_2)/length(favec_C5_CSp_2)   sum(favec_C6_CSp_2)/length(favec_C6_CSp_2), ...
  sum(favec_C7_CSp_2)/length(favec_C7_CSp_2)    sum(favec_C8_CSp_2)/length(favec_C8_CSp_2)];

fabycontrast_CSm_2 = [sum(favec_C1_CSm_2)/length(favec_C1_CSm_2) sum(favec_C2_CSm_2)/length(favec_C2_CSm_2) sum(favec_C3_CSm_2)/length(favec_C3_CSm_2), ...
  sum(favec_C4_CSm_2)/length(favec_C4_CSm_2) sum(favec_C5_CSm_2)/length(favec_C5_CSm_2)   sum(favec_C6_CSm_2)/length(favec_C6_CSm_2), ...
  sum(favec_C7_CSm_2)/length(favec_C7_CSm_2)    sum(favec_C8_CSm_2)/length(favec_C8_CSm_2)];

 guessRvec_C0_CS_2 = outmat_full(outmat_full(:,3) == contrast0 & outmat_full(:,1) == 2, 8);
 guessLvec_C0_CS_2 = outmat_full(outmat_full(:,3) == contrast0 & outmat_full(:,1) == 2, 9);
 guessR_CS_2 = [sum(guessRvec_C0_CS_2)/length(guessRvec_C0_CS_2)];
 guessL_CS_2 = [sum(guessLvec_C0_CS_2)/length(guessLvec_C0_CS_2)];
 
 hitsbycontrast_2 = [hitsbycontrast_CSp_2; hitsbycontrast_CSm_2]; 
 fabycontrast_2 = [fabycontrast_CSp_2; fabycontrast_CSm_2]; 
 guess_2 = [guessR_CS_2; guessL_CS_2];

 % put it together
 hitsbycontrast = [hitsbycontrast_1; hitsbycontrast_2]
 fabycontrast = [fabycontrast_1; fabycontrast_2]
 guessrate = [guess_1; guess_2]; 

 
%%%%%%%%%%%%%%%%%%%%%%%%       response time   %%%%%%%%%%%%%%%%%%%%%%%%%%%
 % block one _1
 % % rt for hits and misses together
 % CS plus (CSp)
 rtvecyes_C1_CSp_1 = outmat_full(outmat_full(:,3) == contrast1 & outmat_full(:,1) == 1 & outmat_full(:,6) == 20, 4);
 rtvecyes_C2_CSp_1 = outmat_full(outmat_full(:,3) == contrast2 & outmat_full(:,1) == 1 & outmat_full(:,6) == 20, 4);
 rtvecyes_C3_CSp_1 = outmat_full(outmat_full(:,3) == contrast3 & outmat_full(:,1) == 1 & outmat_full(:,6) == 20, 4);
 rtvecyes_C4_CSp_1 = outmat_full(outmat_full(:,3) == contrast4 & outmat_full(:,1) == 1 & outmat_full(:,6) == 20, 4);
 rtvecyes_C5_CSp_1 = outmat_full(outmat_full(:,3) == contrast5 & outmat_full(:,1) == 1 & outmat_full(:,6) == 20, 4);
 rtvecyes_C6_CSp_1 = outmat_full(outmat_full(:,3) == contrast6 & outmat_full(:,1) == 1 & outmat_full(:,6) == 20, 4);
 rtvecyes_C7_CSp_1 = outmat_full(outmat_full(:,3) == contrast7 & outmat_full(:,1) == 1 & outmat_full(:,6) == 20, 4);
 rtvecyes_C8_CSp_1 = outmat_full(outmat_full(:,3) == contrast8 & outmat_full(:,1) == 1 & outmat_full(:,6) == 20, 4);
 
 % CS minus (CSm)
 rtvecyes_C1_CSm_1 = outmat_full(outmat_full(:,3) == contrast1 & outmat_full(:,1) == 1 & outmat_full(:,6) == -20, 4);
 rtvecyes_C2_CSm_1 = outmat_full(outmat_full(:,3) == contrast2 & outmat_full(:,1) == 1 & outmat_full(:,6) == -20, 4);
 rtvecyes_C3_CSm_1 = outmat_full(outmat_full(:,3) == contrast3 & outmat_full(:,1) == 1 & outmat_full(:,6) == -20, 4);
 rtvecyes_C4_CSm_1 = outmat_full(outmat_full(:,3) == contrast4 & outmat_full(:,1) == 1 & outmat_full(:,6) == -20, 4);
 rtvecyes_C5_CSm_1 = outmat_full(outmat_full(:,3) == contrast5 & outmat_full(:,1) == 1 & outmat_full(:,6) == -20, 4);
 rtvecyes_C6_CSm_1 = outmat_full(outmat_full(:,3) == contrast6 & outmat_full(:,1) == 1 & outmat_full(:,6) == -20, 4);
 rtvecyes_C7_CSm_1 = outmat_full(outmat_full(:,3) == contrast7 & outmat_full(:,1) == 1 & outmat_full(:,6) == -20, 4);
 rtvecyes_C8_CSm_1 = outmat_full(outmat_full(:,3) == contrast8 & outmat_full(:,1) == 1 & outmat_full(:,6) == -20, 4);
 
 rtsyes_CSp_1 = [mean(rtvecyes_C1_CSp_1) mean(rtvecyes_C2_CSp_1) mean(rtvecyes_C3_CSp_1), ...
  mean(rtvecyes_C4_CSp_1) mean(rtvecyes_C5_CSp_1)  mean(rtvecyes_C6_CSp_1) mean(rtvecyes_C7_CSp_1) mean(rtvecyes_C8_CSp_1)];

rtsyes_CSm_1 = [mean(rtvecyes_C1_CSm_1) mean(rtvecyes_C2_CSm_1) mean(rtvecyes_C3_CSm_1), ...
  mean(rtvecyes_C4_CSm_1) mean(rtvecyes_C5_CSm_1)  mean(rtvecyes_C6_CSm_1) mean(rtvecyes_C7_CSm_1) mean(rtvecyes_C8_CSm_1)];

rtsyes_1 = [rtsyes_CSp_1 rtsyes_CSm_1]; 

 
 % % correct rejections and false alarms
 % 
 rtsnovec_C0_1 = outmat_full(outmat_full(:,3) == 0 & outmat_full(:,1) == 1, 4);
 
 rtsno_C0_1 = [mean(rtsnovec_C0_1)]
 
 % block two _2
 % % rt for hits and misses together
 % CS plus (CSp)
 rtvecyes_C1_CSp_2 = outmat_full(outmat_full(:,3) == contrast1 & outmat_full(:,1) == 2 & outmat_full(:,6) == 20, 4);
 rtvecyes_C2_CSp_2 = outmat_full(outmat_full(:,3) == contrast2 & outmat_full(:,1) == 2 & outmat_full(:,6) == 20, 4);
 rtvecyes_C3_CSp_2 = outmat_full(outmat_full(:,3) == contrast3 & outmat_full(:,1) == 2 & outmat_full(:,6) == 20, 4);
 rtvecyes_C4_CSp_2 = outmat_full(outmat_full(:,3) == contrast4 & outmat_full(:,1) == 2 & outmat_full(:,6) == 20, 4);
 rtvecyes_C5_CSp_2 = outmat_full(outmat_full(:,3) == contrast5 & outmat_full(:,1) == 2 & outmat_full(:,6) == 20, 4);
 rtvecyes_C6_CSp_2 = outmat_full(outmat_full(:,3) == contrast6 & outmat_full(:,1) == 2 & outmat_full(:,6) == 20, 4);
 rtvecyes_C7_CSp_2 = outmat_full(outmat_full(:,3) == contrast7 & outmat_full(:,1) == 2 & outmat_full(:,6) == 20, 4);
 rtvecyes_C8_CSp_2 = outmat_full(outmat_full(:,3) == contrast8 & outmat_full(:,1) == 2 & outmat_full(:,6) == 20, 4);
 
 % CS minus (CSm)
 rtvecyes_C1_CSm_2 = outmat_full(outmat_full(:,3) == contrast1 & outmat_full(:,1) == 2 & outmat_full(:,6) == -20, 4);
 rtvecyes_C2_CSm_2 = outmat_full(outmat_full(:,3) == contrast2 & outmat_full(:,1) == 2 & outmat_full(:,6) == -20, 4);
 rtvecyes_C3_CSm_2 = outmat_full(outmat_full(:,3) == contrast3 & outmat_full(:,1) == 2 & outmat_full(:,6) == -20, 4);
 rtvecyes_C4_CSm_2 = outmat_full(outmat_full(:,3) == contrast4 & outmat_full(:,1) == 2 & outmat_full(:,6) == -20, 4);
 rtvecyes_C5_CSm_2 = outmat_full(outmat_full(:,3) == contrast5 & outmat_full(:,1) == 2 & outmat_full(:,6) == -20, 4);
 rtvecyes_C6_CSm_2 = outmat_full(outmat_full(:,3) == contrast6 & outmat_full(:,1) == 2 & outmat_full(:,6) == -20, 4);
 rtvecyes_C7_CSm_2 = outmat_full(outmat_full(:,3) == contrast7 & outmat_full(:,1) == 2 & outmat_full(:,6) == -20, 4);
 rtvecyes_C8_CSm_2 = outmat_full(outmat_full(:,3) == contrast8 & outmat_full(:,1) == 2 & outmat_full(:,6) == -20, 4);
 
 rtsyes_CSp_2 = [mean(rtvecyes_C1_CSp_2) mean(rtvecyes_C2_CSp_2) mean(rtvecyes_C3_CSp_2), ...
  mean(rtvecyes_C4_CSp_2) mean(rtvecyes_C5_CSp_2)  mean(rtvecyes_C6_CSp_2) mean(rtvecyes_C7_CSp_2) mean(rtvecyes_C8_CSp_2)];

rtsyes_CSm_2 = [mean(rtvecyes_C1_CSm_2) mean(rtvecyes_C2_CSm_2) mean(rtvecyes_C3_CSm_2), ...
  mean(rtvecyes_C4_CSm_2) mean(rtvecyes_C5_CSm_2)  mean(rtvecyes_C6_CSm_2) mean(rtvecyes_C7_CSm_2) mean(rtvecyes_C8_CSm_2)];

rtsyes_2 = [rtsyes_CSp_2 rtsyes_CSm_2]; 

 
 % % correct rejections and false alarms
 % 
 rtsnovec_C0_2 = outmat_full(outmat_full(:,3) == 0 & outmat_full(:,1) == 2, 4);
 rtsno_C0_2 = [mean(rtsnovec_C0_2)]
 
 % putting rts together
 rtsyes = [rtsyes_1 rtsyes_2] 
 rtsno = [rtsno_C0_1 rtsno_C0_2]
 
 fclose('all'); 
 
end
 
plotmatrixhab = cat(2, [guessR_CS_1; guessL_CS_1], hitsbycontrast(1:2,:));
plotmatrixacq = cat(2, [guessR_CS_2; guessL_CS_2], hitsbycontrast(3:4,:));
hab_acq = [plotmatrixhab; plotmatrixacq]

%  GM7condicrs = [hab_acq1; hab_acq2; hab_acq3; hab_acq4; hab_acq5; hab_acq6; hab_acq7];
 
 %  eval(['save ' filepath '.con content_cond6 -ascii'])
%  eval(['save ' filepath '.rtvecsorted rtvecsorted -ascii'])
%  eval(['save ' filepath '.picsunblocksRT picunblockmatnew -ascii'])
%  eval(['save ' filepath '.RT.mat RT -mat'])

figure
subplot(1,2,1)
plot(hitsbycontrast(1,:), 'm'), hold on, plot(hitsbycontrast(2,:),'c'), plot(0, guessrate(1), '*'), plot(0, guessrate(2), 'o')
%plot(fabycontrast(1,:), '--'), plot(fabycontrast(2,:), ':')
axis([-1 9 -0.1 1.1]), hold off

subplot(1,2,2)
plot(hitsbycontrast(3,:), 'r'), hold on, plot(hitsbycontrast(4,:),'b'), plot(0, guessrate(3), '*'), plot(0, guessrate(4), 'o')
%line(guessrate(3), '--'), line(guessrate(4), ':'),
%plot(fabycontrast(3,:), '--'), plot(fabycontrast(4,:), ':')
axis([-1 9 -0.1 1.1]), hold off


% %% load GM#condicrs.mat
% subj = 18;
% ghit_hcsp = GM18condicrs(1:4:subj*4,:);
% ghit_hcsm = GM18condicrs(2:4:subj*4,:);
% ghit_acsp = GM18condicrs(3:4:subj*4,:);
% ghit_acsm = GM18condicrs(4:4:subj*4,:);
% 
% mean_hcsp = mean(ghit_hcsp); 
% mean_hcsm = mean(ghit_hcsm); 
% mean_acsp = mean(ghit_acsp);
% mean_acsm = mean(ghit_acsm);
% 
% sd_hcsp = std(ghit_hcsp);
% sd_hcsm = std(ghit_hcsm); 
% sd_acsp = std(ghit_acsp);
% sd_acsm = std(ghit_acsm);
% 
% sem_hcsp = std(ghit_hcsp)/sqrt(length(ghit_hcsp));
% sem_hcsm = std(ghit_hcsm)/sqrt(length(ghit_hcsm));
% sem_acsp = std(ghit_acsp)/sqrt(length(ghit_acsp));
% sem_acsm = std(ghit_acsm)/sqrt(length(ghit_acsm));
% 
% % for stats (SPSS formatted)
% ghit18condicrs2 = [ghit_hcsp ghit_hcsm ghit_acsp ghit_acsm] 
% 
% %% figure
% % errorbar in vertical lines
% figure(1), subplot(1,2,1), hold on, errorbar(0:8,mean_hcsp,sem_hcsp.*ones(size(0:1:8)),'-m'), errorbar(0:8,mean_hcsm,sem_hcsm.*ones(size(0:1:8)),'-c'), axis([-1 9 0.2 1]), title('GM 18 habituation'), grid
% subplot(1,2,2), hold on, errorbar(0:8,mean_acsp,sem_acsp.*ones(size(0:1:8)),'-r'), errorbar(0:8,mean_acsm,sem_acsm.*ones(size(0:1:8)),'-b'), axis([-1 9 0.2 1]), title('GM 18 acquisition'), grid, hold off
% 
% % errorbar in shaded areas
% figure(2), shadedErrorBar(0:8,mean_hcsp',sem_hcsp,'-m',0.5), hold on, shadedErrorBar(0:8,mean_hcsm',sem_hcsm,'-c',0.5), axis([-1 9 0.2 1]), title('GM 18 habituation'); grid
% figure(3), shadedErrorBar(0:8,mean_acsp',sem_acsp,'-r',0.5), hold on, shadedErrorBar(0:8,mean_acsm',sem_acsm,'-b',0.5), axis([-1 9 0.2 1]), title('GM 18 acquisition'); grid, hold off
% 
% % plot(rtsyes(1,:), 'm');
% % hold on, plot(rtsyes(2,:),'c');
% % figure(2)
% % plot(rtsyes(3,:), 'r');
% % hold on, plot(rtsyes(4,:),'b');
