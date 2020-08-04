function [ parameters ] = annalena_fit(filemat, grandmeanPCA)
%fits a Naka Rushton function for sweep-ssvep

% requires user to do PCA on grand mean 
%  a = ReadAvgFile('grand mean at file name here');
% COEFF = pca(a'); weights = COEFF(:,1);   grandmeanPCA = weights' * a;

% Naka-Rushton equation: p(1) = a = response amplitude parameter
% (multiplicative), p(2) = b = baseline response level, p(3) = n = exponent
% determining the slope of the contrast response function, p(4) = C50 =
% semisaturation constant

 modelFun = @(p,x) ( p(1).*( (x.^p(3))./(x.^p(3) + p(4).^p(3)) ) ) + p(2);
 option = statset('MaxIter', 100000, 'TolFun', 0.0001,  'Robust', 'off')

% temp = (1:22).*0.05; 


for file = 1:size(filemat, 1)
    
                a = ReadAvgFile(deblank(filemat(file,:)));
               

                COEFF = pca(a');
                weights = COEFF(:,1);
                out1 = weights' * a;
                
                out = (out1+grandmeanPCA)./2;
                           
                    test = out(200:1851);
                    vec = [ test(400:50:end-100) ];
                    
              %     vec = vec.*temp; 
                    
                    size(vec)
                    
                        figure(11), plot(vec)
                        
                         startingVals = [ max(vec) min(vec) 4 15]
                    
                    [parameters,r,J,Sigma,mse]  = nlinfit((1:24)', vec', modelFun, startingVals', option);
    
                xgrid = linspace(0,24,200);
               
                figure(12), hold off,  line(xgrid, modelFun(parameters, xgrid)); 
                hold on
                plot(test(400:50:end-100), 'r')
                hold off
                
                 parameters(4) = parameters(4).*100; 
                pause(.3), mse
          
                
                outvec  = [parameters' mse]; 
                              
               eval(['save ' deblank(filemat(file,:)) '.para.mat outvec -mat'])
               
               eval(['save ' deblank(filemat(file,:)) '.PCA.mat out1 -mat'])
           
end

