% 
% searches condnumbers in *dat file generarted by exp psyctb file

function [expectvec11to14_3, valvect11to14_3] = getcon_condigazepilot(filemat);

%expectvec11to14_3, valvec11to14_8


findvec = [9:12 52:55 65:68 81:84 97:100 112:115 129:132 172:175]

for fileindex = 1 :size(filemat,1)
    
    filepath = deblank(filemat(fileindex,:)); 
 
 
    blockvec = []; 
    trialvec = []; 
    expectvec = []; 
    conditionvec = []; 
    valvec = []; 
   
fid = fopen(filepath);

a = 1;
	
 while a > 0
	a = fgetl(fid);
   
    if a > 0
    
        indexvec = findstr(a, ' ');% 
        
         trialvec = [trialvec str2num(a(indexvec(2):indexvec(3)))];
         blockvec = [blockvec str2num(a(indexvec(3)+1))];
         conditionvec = [conditionvec str2num(a(indexvec(5):indexvec(6)))];
        expectvec = [expectvec str2num(a(indexvec(6):indexvec(7)))];
        valvec = [valvec str2num(a(indexvec(7):indexvec(7)+1))];
        
    
 
    end
 
 end



 fclose('all'); 
 
end
 
 searchmat = [conditionvec' expectvec' valvec'];
 tempmat = searchmat(findvec,:); 
 
 exp11 = mean(tempmat(tempmat(:,1) ==11 & tempmat(:,2) ~=0,2));
 exp12 = mean(tempmat(tempmat(:,1) ==12 & tempmat(:,2) ~=0,2)); 
 exp13 = mean(tempmat(tempmat(:,1) ==13 & tempmat(:,2) ~=0,2)); 
 exp14 = mean(tempmat(tempmat(:,1) ==14 & tempmat(:,2) ~=0,2)); 
 
 exp21 = mean(tempmat(tempmat(:,1) ==21 & tempmat(:,2) ~=0,2));
 exp22 = mean(tempmat(tempmat(:,1) ==22 & tempmat(:,2) ~=0,2)); 
 exp23 = mean(tempmat(tempmat(:,1) ==23 & tempmat(:,2) ~=0,2)); 
 exp24 = mean(tempmat(tempmat(:,1) ==24 & tempmat(:,2) ~=0,2)); 
 
  exp31 = mean(tempmat(tempmat(:,1) ==31 & tempmat(:,2) ~=0,2));
 exp32 = mean(tempmat(tempmat(:,1) ==32 & tempmat(:,2) ~=0,2)); 
 exp33 = mean(tempmat(tempmat(:,1) ==33 & tempmat(:,2) ~=0,2)); 
 exp34 = mean(tempmat(tempmat(:,1) ==34 & tempmat(:,2) ~=0,2)); 
 
 expectvec11to14_3 = [exp11 exp12 exp13 exp14 exp21 exp22 exp23 exp24 exp31 exp32 exp33 exp34]; 
 
 % for valence
  val11 = mean(tempmat(tempmat(:,1) ==11 & tempmat(:,2) ~=0,3));
 val12 = mean(tempmat(tempmat(:,1) ==12 & tempmat(:,2) ~=0,3)); 
 val13 = mean(tempmat(tempmat(:,1) ==13 & tempmat(:,2) ~=0,3)); 
 val14 = mean(tempmat(tempmat(:,1) ==14 & tempmat(:,2) ~=0,3)); 
 
 val21 = mean(tempmat(tempmat(:,1) ==21 & tempmat(:,2) ~=0,3));
 val22 = mean(tempmat(tempmat(:,1) ==22 & tempmat(:,2) ~=0,3)); 
 val23 = mean(tempmat(tempmat(:,1) ==23 & tempmat(:,2) ~=0,3)); 
 val24 = mean(tempmat(tempmat(:,1) ==24 & tempmat(:,2) ~=0,3)); 
 
  val31 = mean(tempmat(tempmat(:,1) ==31 & tempmat(:,2) ~=0,3));
 val32 = mean(tempmat(tempmat(:,1) ==32 & tempmat(:,2) ~=0,3)); 
 val33 = mean(tempmat(tempmat(:,1) ==33 & tempmat(:,2) ~=0,3)); 
 val34 = mean(tempmat(tempmat(:,1) ==34 & tempmat(:,2) ~=0,3)); 
  
 valvect11to14_3 = [val11 val12 val13 val14 val21 val22 val23 val24 val31 val32 val33 val34]; 

 
 %  eval(['save ' filepath '.con content_cond6 -ascii'])
%  eval(['save ' filepath '.rtvecsorted rtvecsorted -ascii'])
%  eval(['save ' filepath '.picsunblocksRT picunblockmatnew -ascii'])
%  eval(['save ' filepath '.RT.mat RT -mat'])


 