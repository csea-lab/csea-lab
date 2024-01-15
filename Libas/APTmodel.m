function [Rvec] = APTmodel(params, reinforcement)
 
BETA =  params(1); 
LAG = params(2); 

stimnum = 7; % pick an odd number so that CS+ can be in the middle

[w, delta] = rescorlaWagnerLearnMod([BETA 1], reinforcement'); % execute rescorla wagner model, get assoc. strength and pred error

delta_smooth = movmean(delta, LAG); 

for index = 1:length(reinforcement)
    
    I1 = -.1 -w(index); % lateral inhibition weights, changing with associative strength
    I2 = -1 -w(index);
    
    latvec = ones(1, stimnum); 
    latvec(1) = 2; 
    latvec(2) = I2; latvec(end) = I2; 
    latvec(3) = I1; latvec(end-1) = I1; 
    
    VM = shiftLam(latvec)'; % lateral inhibition matrix
    
    input = rand(1,stimnum)./10+gaussPro(-(stimnum-1)/2:(stimnum-1)/2, 1./(w(index).*3)) *sign(delta_smooth(index)) *w(index); % generalization to surrounding stimuli, width changes with assoc strength, magnitide with prediction error
    
    amygdala(:, index) = gaussPro(-(stimnum-1)/2:(stimnum-1)/2, 1./(w(index).*3)) *(delta(index)); 
    
    A(:, index) = input'; 
    
    R(:, index) = VM*input'; % figure(11), plot(R(:, index)), hold on, plot(input), title(num2str(reinforcement(index))), hold off

end

amygdala(:, 1:5) = 0; 

 figure(10), 
 subplot(3,1,3), colormap('jet'), contourf(R, 12), title('visual cortex'), colorbar
 subplot(3,1,2),colormap('jet'), contourf(A, 12), title('attention systems'),colorbar
 subplot(3,1,1),colormap('jet'), contourf(amygdala, 12), title('amygdala'), colorbar

Rvec = mat2vec(R); 