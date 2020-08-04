function [removed] = rm1overf(invec)

% fits a polyfit to a spectrum and gets rif of 1/f
    
        [beta] = polyfit(1:length(invec),invec,2);
       
        [expmod] = abs(polyval(beta, 1:length(invec)));
        
        removed  = invec ./ expmod; 
        
   
   % figure, plot(invec), hold on, plot (expmod), plot(removed), hold off
    


