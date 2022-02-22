function downsample4d(filemat, stepsize, freq, outname)
%this downsamples single trial wavelets by time and truncates the frequency range if you want
% this is set up for 4-d files that are channels x time x frequency x trial

for x = 1:size(filemat,1)

    a = matfile(filemat(x,:)); %get size of the data 
    sizeMyVara = size(a,'outmat4d1');
    
if isempty(freq) %if you don't have a frequency/3rd dimension size preference, just load everything in that 3rd dimension
    sizeMyVara(3) = sizeMyVara(3);
else
    sizeMyVara(3) = freq;
end

    temp = a.outmat4d1(1:sizeMyVara(1), 1:stepsize:sizeMyVara(2), 1:sizeMyVara(3), 1:sizeMyVara(4));
       % if you say temp = a.outmat4d1(1:end ....) instead of sizeMyVara then matlab has to load the file to know what end is
eval(['save ' outname 'downsample.mat temp -v7.3']) % saves new file

fprintf('-_'), if x/10 == round(x/10), disp(x), end % marker for how many files you've done so far
        
end