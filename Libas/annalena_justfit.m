function [ paramat, parameters ] = annalena_justfit(inmat)


%fits a Naka Rushton function for sweep-ssvep
% Naka-Rushton function:
 modelFun = @(p,x) ( p(1).*( (x.^p(3))./(x.^p(3) + p(4).^p(3)) ) ) + p(2);
 
 option = statset('MaxIter', 1000000, 'TolFun', 0.001,  'Robust', 'off'); 

 paramat = []; 

 for index = 1:size(inmat, 1) 
     
                    test = inmat(index,500:1851); % everything after baseline
                    
                   test = mean([test; mean(inmat(:,500:1851))]); 
                                                    
                    % if ismember(index, [74 81 82]); test = mean(inmat(:,600:1851)); end 
                    
                     % if ismember(index, [ 65 100]); test = mean(inmat(:,500:1851));  end 
                                       
                    vec = resample(test, 25, 1352); 
                    
                    vec = vec(2:end); 
                    
                    vec = movingavg_as(vec, 5); 
                    
                    figure(11)
                   
                   clf(11), figure(11), subplot(2,1,1), plot(vec), hold off, 
                        
                         % change starting values [amplitude, baseline,
                         % slope, c50]
                         startingVals = [ max(vec) min(vec) 4 15];
                    
                       % nlinfit depends on size of vec
                      [parameters,r,J,Sigma,mse]  = nlinfit((1:24)', vec', modelFun, startingVals', option);
                
                    
                % plot    
                xgrid = linspace(0,24,200);
               
                figure(11), subplot(2,1,2),  hold off,  line(xgrid, modelFun(parameters, xgrid)); pause(0.1)
                hold on
                plot(vec, 'r')
                hold off
                
                % change c50 parameter to ms
                 parameters(4) = parameters(4).*100; 
                pause(.3), mse, index
          
                
               outvec  = [real(parameters)' mse]; 
               
               paramat = [paramat; outvec]; 
                       
               
end

