% 
% searches condnumbers in *dat file generarted by exp psyctb file

function [output_all, rtmeansbyblock, errorsbyblock] = getcon_swirls3blocks_2(filemat);

% for means: rtmeans = [mean(RT.rt_101) mean(RT.rt_102) mean(RT.rt_103) mean(RT.rt_104) mean(RT.rt_105) mean(RT.rt_106)]

for fileindex = 1 :size(filemat,1)
    
    filepath = deblank(filemat(fileindex,:)); 

condvec = []; 
blockvec = []; 
content_cond3 = [];
content_cond6 =[];
rtvec = []; 
picvec = [];

neutralportvec = [2104	2107	2200	2210	2270	2302	2305	2441	2493	2512];
neutralprofvec= [2191	2221	2377	2382	2383	2384	2393	2396	2411	2488]; 

unplattackvec = [2811	6190	6230	6231	6242	6243	6244	6250	6260	6313]; 
unplmutilvec = [3001	3015	3100	3102	3120	3130	3168	3185	3150	3225];

pleaseroticvec = [4604	4651	4652	4653	4658	4668	4670	4680	4690	4694]; 
pleasromancevec = [4599	4610	4612	4623	4624	4626	4628	4640	4641	4700];


fid = fopen(filepath)

a = 1;
	
 while a > 0
	a = fgetl(fid);
    if a > 0
    
        index1 = findstr(a, '.jpg '); % its a pic
        index2= findstr(a, '.jpg.s'); % its a nonpic
        temp3 = findstr(a, ' '); index3 = temp3(6)+1; 
        indexblock=temp3(1) + 1; 
        
        rtvec = [rtvec str2num(a(index3:length(a)))];
        blockvec = [blockvec str2num(a(indexblock))];

        if isempty (index2); condvec = [condvec 1];
            picnum = str2num(a(index1(1)-5:index1(1)-1));
        else condvec = [condvec 2];             
            picnum = str2num(a(index2(1)-5:index2(1)-1));
        end
        
        picvec = [picvec picnum];
              
        
        % broad contents
         if  ismember(picnum, [pleaseroticvec pleasromancevec]), content_cond3 = [content_cond3  1+condvec(length(condvec))*10]; 
         elseif ismember(picnum, [neutralportvec neutralprofvec]), content_cond3 = [content_cond3  2+condvec(length(condvec))*10]; 
         else content_cond3 = [content_cond3  3+condvec(length(condvec))*10]; 
         end
         
         % specific contents
         if  ismember(picnum, [pleasromancevec]), content_cond6 = [content_cond6  1+condvec(length(condvec))*100]; 
         elseif ismember(picnum, [pleaseroticvec]), content_cond6 = [content_cond6  2+condvec(length(condvec))*100];
         elseif ismember(picnum, [neutralportvec]), content_cond6 = [content_cond6  3+condvec(length(condvec))*100];
         elseif ismember(picnum, [neutralprofvec]), content_cond6 = [content_cond6  4+condvec(length(condvec))*100];
         elseif ismember(picnum, [unplattackvec]), content_cond6 = [content_cond6  5+condvec(length(condvec))*100];
         else content_cond6 = [content_cond6  6+condvec(length(condvec))*100]; 
         end     
    end
 end

 content_cond3 = content_cond3'; 
 content_cond6 = content_cond6'; 
 
 rtvec = rtvec'; 
 picvec = picvec'; 
 blockvec = blockvec';
 
 condandRTmat  = [content_cond6 rtvec];
 
 picundblockmat = [picvec+blockvec*10000 rtvec];
 
 indexpics = find(condandRTmat(:,1)<107); 
 
 picundblockmat = picundblockmat(indexpics,:)';
 
 [dummy, sortedindices]=sort(picundblockmat(1,:));
 
 picunblockmatnew =picundblockmat(:,sortedindices);
 
 rtvecsorted=picunblockmatnew(2,:);
  
%  RT.rt_101 = condandRTmat(find(condandRTmat(:,1)==201),2);
%  RT.rt_102 = condandRTmat(find(condandRTmat(:,1)==202),2);
%  RT.rt_103 = condandRTmat(find(condandRTmat(:,1)==203),2);
%  RT.rt_104 = condandRTmat(find(condandRTmat(:,1)==204),2);
%  RT.rt_105 = condandRTmat(find(condandRTmat(:,1)==205),2);
%  RT.rt_106 = condandRTmat(find(condandRTmat(:,1)==206),2);
%  
%  RT.rt_201 = condandRTmat(find(condandRTmat(:,1)==101),2);
%  RT.rt_202 = condandRTmat(find(condandRTmat(:,1)==102),2);
%  RT.rt_203 = condandRTmat(find(condandRTmat(:,1)==103),2);
%  RT.rt_204 = condandRTmat(find(condandRTmat(:,1)==104),2);
%  RT.rt_205 = condandRTmat(find(condandRTmat(:,1)==105),2);
%  RT.rt_206 = condandRTmat(find(condandRTmat(:,1)==106),2);
%  
%  outmat4spss = condandRTmat';
%  
%  errors_201 = length(RT.rt_201(RT.rt_201 > 0))/length(RT.rt_201);
%  errors_202 = length(RT.rt_202(RT.rt_202 > 0))/length(RT.rt_202);
%  errors_203 = length(RT.rt_203(RT.rt_203 > 0))/length(RT.rt_203);
%  errors_204 = length(RT.rt_204(RT.rt_204 > 0))/length(RT.rt_204);
%  errors_205 = length(RT.rt_205(RT.rt_205 > 0))/length(RT.rt_205);
%  errors_206 = length(RT.rt_206(RT.rt_206 > 0))/length(RT.rt_206);
%  
%  errors = [errors_201 errors_202 errors_203 errors_204 errors_205 errors_206]; 
%  rtmeans = [mean(RT.rt_101) mean(RT.rt_102) mean(RT.rt_103) mean(RT.rt_104) mean(RT.rt_105) mean(RT.rt_106)]
%  
%  
 % do it by block
 rtmeanstemp =[]; 
 rtmeansbyblock =[]; 
 errorstemp = []; 
 errorsbyblock = []; 
 
 %reverse conditions for exp 2
 
for blocknum = 1:3
 
 RT.rt_101 = condandRTmat(find(condandRTmat(:,1)==201 & blockvec == blocknum),2);
 RT.rt_102 = condandRTmat(find(condandRTmat(:,1)==202 & blockvec == blocknum),2);
 RT.rt_103 = condandRTmat(find(condandRTmat(:,1)==203 & blockvec == blocknum),2);
 RT.rt_104 = condandRTmat(find(condandRTmat(:,1)==204 & blockvec == blocknum),2);
 RT.rt_105 = condandRTmat(find(condandRTmat(:,1)==205 & blockvec == blocknum),2);
 RT.rt_106 = condandRTmat(find(condandRTmat(:,1)==206 & blockvec == blocknum),2);
 
 RT.rt_201 = condandRTmat(find(condandRTmat(:,1)==101 & blockvec == blocknum),2);
 RT.rt_202 = condandRTmat(find(condandRTmat(:,1)==102 & blockvec == blocknum),2);
 RT.rt_203 = condandRTmat(find(condandRTmat(:,1)==103 & blockvec == blocknum),2);
 RT.rt_204 = condandRTmat(find(condandRTmat(:,1)==104 & blockvec == blocknum),2);
 RT.rt_205 = condandRTmat(find(condandRTmat(:,1)==105 & blockvec == blocknum),2);
 RT.rt_206 = condandRTmat(find(condandRTmat(:,1)==106 & blockvec == blocknum),2);
 
 errors_201 = length(RT.rt_201(RT.rt_201 > 0))/length(RT.rt_201);
 errors_202 = length(RT.rt_202(RT.rt_202 > 0))/length(RT.rt_202);
 errors_203 = length(RT.rt_203(RT.rt_203 > 0))/length(RT.rt_203);
 errors_204 = length(RT.rt_204(RT.rt_204 > 0))/length(RT.rt_204);
 errors_205 = length(RT.rt_205(RT.rt_205 > 0))/length(RT.rt_205);
 errors_206 = length(RT.rt_206(RT.rt_206 > 0))/length(RT.rt_206);
 
  rtmeanstemp = [mean(RT.rt_101) mean(RT.rt_102) mean(RT.rt_103) mean(RT.rt_104) mean(RT.rt_105) mean(RT.rt_106)];
  errorstemp = [errors_201 errors_202 errors_203 errors_204 errors_205 errors_206]; 
  rtmeansbyblock = [rtmeansbyblock rtmeanstemp]
errorsbyblock = [errorsbyblock errorstemp]
end
 
 output_all = [errorsbyblock rtmeansbyblock]
 
 fclose('all')
% 
%  eval(['save ' filepath '.con content_cond6 -ascii'])
%  eval(['save ' filepath '.rtvecsorted rtvecsorted -ascii'])
%  eval(['save ' filepath '.picsunblocksRT picunblockmatnew -ascii'])
%  eval(['save ' filepath '.RT.mat RT -mat'])
end
 