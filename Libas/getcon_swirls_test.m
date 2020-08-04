% 
% In the replic experiments, people can press or not press the button and
% it does not change the pictures fate, i.e. pictures disappear after 1
% second no matter what. thsu there can be false alarms (people press the
% button when there is non-target (this is true for the new experiments) as
% well as miss the target (misses, impssobel in th enew experiments, in
% which the target was on (in the "disappear") conditions until button
% press...

function [rtmeans6, errors12] = getcon_swirls_test(filemat);

% for means: rtmeans = [mean(RT.rt_101) mean(RT.rt_102) mean(RT.rt_103) mean(RT.rt_104) mean(RT.rt_105) mean(RT.rt_106)]

for fileindex = 1 :size(filemat,1)
    
    filepath = deblank(filemat(fileindex,:)); 

convec = []; 
blockvec = []; 
respvec = [];
content_cond6 =[];
rtvec = []; 


fid = fopen(filepath)

a = 1;
	
 while a > 0
	a = fgetl(fid);
    if a > 0
    
         temp3 = findstr(a, ' ');
        
        rtvec = [rtvec str2num(a(temp3(5):length(a)))];
        blockvec = [blockvec str2num(a(temp3(1):temp3(2)))];
        
        respvec = [respvec str2num(a(temp3(3):temp3(4)))];
        convec = [convec str2num(a(temp3(4):temp3(5)))];
    
    end
 end


 rtvec = rtvec'; 
 respvec = respvec'; 
 blockvec = blockvec';
 convec = convec';
 
  condandRTmat  = [convec rtvec];
%  

%  
 RT.rt_101 = condandRTmat(find(condandRTmat(:,1)==101 & respvec ==1),2)
 RT.rt_102 = condandRTmat(find(condandRTmat(:,1)==102 & respvec ==1),2);
 RT.rt_103 = condandRTmat(find(condandRTmat(:,1)==103 & respvec ==1),2);
 RT.rt_104 = condandRTmat(find(condandRTmat(:,1)==104 & respvec ==1),2);
 RT.rt_105 = condandRTmat(find(condandRTmat(:,1)==105 & respvec ==1),2);
 RT.rt_106 = condandRTmat(find(condandRTmat(:,1)==106 & respvec ==1),2);
 
 RT.rt_201 = condandRTmat(find(condandRTmat(:,1)==201 & respvec ==1),2);
 RT.rt_202 = condandRTmat(find(condandRTmat(:,1)==202 & respvec ==1),2);
 RT.rt_203 = condandRTmat(find(condandRTmat(:,1)==203 & respvec ==1),2);
 RT.rt_204 = condandRTmat(find(condandRTmat(:,1)==204 & respvec ==1),2);
 RT.rt_205 = condandRTmat(find(condandRTmat(:,1)==205 & respvec ==1),2);
 RT.rt_206 = condandRTmat(find(condandRTmat(:,1)==206 & respvec ==1),2);
%  
%  outmat4spss = condandRTmat';
%  

% misses: 
errors_101 = 1-length(RT.rt_101)./length(find(condandRTmat(:,1)==101)) ;
 errors_102 = 1-length(RT.rt_102)./length(find(condandRTmat(:,1)==102)) ;
 errors_103 = 1-length(RT.rt_103)./length(find(condandRTmat(:,1)==103)) ;
 errors_104 = 1-length(RT.rt_104)./length(find(condandRTmat(:,1)==104)) ;
 errors_105 = 1-length(RT.rt_105)./length(find(condandRTmat(:,1)==105)) ;
 errors_106 = 1-length(RT.rt_106)./length(find(condandRTmat(:,1)==106)) ;

 % false alarms
 errors_201 = length(RT.rt_201)./length(find(condandRTmat(:,1)==201)) ;
 errors_202 = length(RT.rt_202)./length(find(condandRTmat(:,1)==202)) ;
 errors_203 = length(RT.rt_203)./length(find(condandRTmat(:,1)==203)) ;
 errors_204 = length(RT.rt_204)./length(find(condandRTmat(:,1)==204)) ;
 errors_205 = length(RT.rt_205)./length(find(condandRTmat(:,1)==205)) ;
 errors_206 = length(RT.rt_206)./length(find(condandRTmat(:,1)==206)) ;
%  
  errors12 = [errors_101 errors_102 errors_103 errors_104 errors_105 errors_106 errors_201 errors_202 errors_203 errors_204 errors_205 errors_206]; 
  rtmeans6 = [mean(RT.rt_101) mean(RT.rt_102) mean(RT.rt_103) mean(RT.rt_104) mean(RT.rt_105) mean(RT.rt_106)];
%  
%  fclose('all')
% % 
% %  eval(['save ' filepath '.con content_cond6 -ascii'])
% %  eval(['save ' filepath '.rtvecsorted rtvecsorted -ascii'])
% %  eval(['save ' filepath '.picsunblocksRT picunblockmatnew -ascii'])
% %  eval(['save ' filepath '.RT.mat RT -mat'])
end
 