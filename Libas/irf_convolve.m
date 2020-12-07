function [outvec] = irf_convolve(heightvec, inputs)

% kernel is a vector (often around 5-20 elements long) of the expected IRF shape
% onsetvec is a vector with zeros for each TR in the BOLD time series, and
% the number 1 at those TRs where there is a stimulus onset
% heightvec is a vector, corresponding to magnitudes of each IRF, for each event. Must have the same length as onsetsvec(onsetvec==1);  

kernel = inputs.kernel;
onsetvec = inputs.onsetvec;

onsetvec(onsetvec==1) = heightvec; % this is only necessary so that heights are a separate variable for use with nlinfit

outvec = conv(onsetvec, kernel, 'full'); % the convolution. Needs to be 'full', or timing is off

outvec  = outvec(1:length(onsetvec)); %the convolution adds extra points at the end. cut those off. 