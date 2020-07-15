% getcon_AB
% searches logfile and pulls out % correct values 

function [outvecT2, outvecT1] = getcon_ABGville2(filepath)

conditionvec1 = []; 
conditionvec2 = []; 
correctvecT1 = []; 
correctvecT2 = []; 

fid = fopen(filepath);
trialcount = 1;
a = 1;

while a > 0
    
    a = fgetl(fid)
        
    if a < 0, break, return, end
    
    blankindex = find(a == ' ');
   
    % determine condition: lag between T1 and T2 (varies 1 to 3) and valence
    % of distractor (1 to 3)    
    
    conditionvec2 = [conditionvec2; str2num(deblank(a(blankindex(length(blankindex))-1))) ]; 
    conditionvec1 = [conditionvec1; str2num(deblank(a(blankindex(length(blankindex))-3))) ]; 
    
      % determine T1 correct or not
      
      T1 = a(blankindex(2):blankindex(2)+2); 
      
      respT1 = (a(blankindex(4):blankindex(5)+1)) 
      
      if T1(2) == respT1(2), correctvecT1 = [correctvecT1; 1]; else correctvecT1 = [correctvecT1; 0]; end
      
       % determine T2 correct or not
      
      T2 = a(blankindex(3):blankindex(3)+2);
      
      respT2 = (a(blankindex(6):blankindex(7)+1))
      
      if T2(2) == respT2(2) && T2(3) == respT2(4), correctvecT2 = [correctvecT2; 1]; else correctvecT2 = [correctvecT2; 0]; end
    
end % end loop over lines (=trials)[

conditionvec = [conditionvec1 conditionvec2]; 
correctvecT2 

%extract T1|T2 for the 9 conditions:
% 1) find indices for 9 conditions
index_11 = find(conditionvec(:,1) == 1 & conditionvec(:,2) ==1);
index_12 = find(conditionvec(:,1) == 1 & conditionvec(:,2) ==2);
index_13 = find(conditionvec(:,1) == 1 & conditionvec(:,2) ==3);

index_21 = find(conditionvec(:,1) == 2 & conditionvec(:,2) ==1); 
index_22 = find(conditionvec(:,1) == 2 & conditionvec(:,2) ==2); 
index_23 = find(conditionvec(:,1) == 2 & conditionvec(:,2) ==3); 

index_31 = find(conditionvec(:,1) == 3 & conditionvec(:,2) ==1); 
index_32 = find(conditionvec(:,1) == 3 & conditionvec(:,2) ==2); 
index_33 = find(conditionvec(:,1) == 3 & conditionvec(:,2) ==3); 

% find indices for correct T1 in those trials
corrT1_11 = find(correctvecT1(index_11) ==1);
corrT1_12 = find(correctvecT1(index_12) ==1);
corrT1_13 = find(correctvecT1(index_13) ==1); 

corrT1_21 = find(correctvecT1(index_21) ==1); 
corrT1_22 = find(correctvecT1(index_22) ==1); 
corrT1_23 = find(correctvecT1(index_23) ==1); 

corrT1_31 = find(correctvecT1(index_31) ==1); 
corrT1_32 = find(correctvecT1(index_32) ==1); 
corrT1_33 = find(correctvecT1(index_33) ==1); 


% find indices for correct T2 in those trials
corrT2_11 = find(correctvecT2(index_11(corrT1_11))==1); 
corrT2_12 = find(correctvecT2(index_12(corrT1_12))==1); 
corrT2_13 = find(correctvecT2(index_13(corrT1_13))==1); 

corrT2_21 = find(correctvecT2(index_21(corrT1_21))==1); 
corrT2_22 = find(correctvecT2(index_22(corrT1_22))==1); 
corrT2_23 = find(correctvecT2(index_23(corrT1_23))==1); 

corrT2_31 = find(correctvecT2(index_31(corrT1_31))==1); 
corrT2_32 = find(correctvecT2(index_32(corrT1_32))==1); 
corrT2_33 = find(correctvecT2(index_33(corrT1_33))==1); 

% calc percentages T1 percent correct

percT1_11 = length(corrT1_11)/length(index_11); 
percT1_12 = length(corrT1_12)/length(index_12); 
percT1_13 = length(corrT1_13)/length(index_12); 

percT1_21 = length(corrT1_21)/length(index_21); 
percT1_22 = length(corrT1_22)/length(index_22); 
percT1_23 = length(corrT1_23)/length(index_23); 

percT1_31 = length(corrT1_31)/length(index_31); 
percT1_32 = length(corrT1_32)/length(index_32); 
percT1_33 = length(corrT1_33)/length(index_33); 

% calc percentages: T2 given T1
perc_11 = length(corrT2_11)/length(corrT1_11);
perc_12 = length(corrT2_12)/length(corrT1_12);
perc_13 = length(corrT2_13)/length(corrT1_13);

perc_21 = length(corrT2_21)/length(corrT1_21);
perc_22 = length(corrT2_22)/length(corrT1_22);
perc_23 = length(corrT2_23)/length(corrT1_23);

perc_31 = length(corrT2_31)/length(corrT1_31);
perc_32 = length(corrT2_32)/length(corrT1_32);
perc_33 = length(corrT2_33)/length(corrT1_33);


outvecT1 = [percT1_11 percT1_12 percT1_13 percT1_21 percT1_22 percT1_23 percT1_31 percT1_32 percT1_33]

outvecT2 = [perc_11 perc_12 perc_13 perc_21 perc_22 perc_23 perc_31 perc_32 perc_33]

% 
% 
subplot(2,1,1), bar(outvecT1)
subplot(2,1,2),bar(outvecT2)

fclose('all')

%contentvec = contentvec';

%contentRTmat = [contentvec respvec ];

%eval(['save ' filepath '.con contentvec -ascii'])

