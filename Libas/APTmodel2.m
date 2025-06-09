function [Rvec, anterior_emotional,  A, R] = APTmodel2(params, reinforcement)
 
BETA =  params(1); 
width_normali = params(1); 


stimnum = 7; % pick an odd number so that CS+ can be in the middle

[w, delta] = rescorlaWagnerLearnMod([BETA 1], reinforcement'); % execute rescorla wagner model, get assoc. strength and pred error

for index = 1:length(reinforcement)
    
    I1 = -.01 -w(index); % lateral inhibition weights, changing with associative strength
    I2 = -.01 -w(index);
    
    latvec = ones(1, stimnum); 
    latvec(1) = 2; 
    latvec(2) = I2; latvec(end) = I2; 
    latvec(3) = I1; latvec(end-1) = I1; 
    
    VM = shiftLam(latvec)'; % lateral inhibition matrix

    divisive_norm = w(index).*gaussPro(-(stimnum-1)/2:(stimnum-1)/2, 1./(w(index))); % generalization to surrounding stimuli, width changes with assoc strength, magnitide with prediction error

    % plot(divisive_norm), title(num2str(w(index))); pause

  %  divisive_norm = ones(1,stimnum)./10+gaussPro(-(stimnum-1)/2:(stimnum-1)/2, 1./(w(index).*3)) *sign(delta(index)) *w(index); % generalization to surrounding stimuli, width changes with assoc strength, magnitide with prediction error

    anterior_emotional(:, index) = gaussPro(-(stimnum-1)/2:(stimnum-1)/2, 1./(w(index).*3)) *(delta(index)); 
    
   % amygdala(:, index) = gaussPro(-(stimnum-1)/2:(stimnum-1)/2, 1./(w(index).*3)) *(delta(index)); 
    
    A(:, index) = divisive_norm'; 
    
    R(:, index) = VM*divisive_norm'; % figure(11), plot(R(:, index)), hold on, plot(divisive_norm), title(num2str(reinforcement(index))), hold off

    R(isnan(R)) = 0; 

end

anterior_emotional(:, 1:5) = 0; 

 figure, 
 subplot(3,1,3), colormap('jet'), contourf(R, 12), title('visual cortex'), caxis([max(max(R)).*-1 max(max(R))]); colorbar
 subplot(3,1,2),colormap('jet'), contourf(A, 12), title('attention systems'),caxis([max(max(A)).*-1 max(max(A))]); colorbar
 subplot(3,1,1),colormap('jet'), contourf(anterior_emotional, 12), title('anterior emotion-modulated structures'), caxis([max(max(anterior_emotional)).*-1 max(max(anterior_emotional))]); colorbar

Rvec = mat2vec(R(4:end,:)')';
