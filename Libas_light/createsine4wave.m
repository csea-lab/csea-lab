function testoscil=createsine4wave(targetf,trials,channum,snrat,duration,samprat)
%duration in sek

testoscil=zeros(channum,duration*samprat,trials);

for chanind=1:channum
    for trialind=1:trials
        testoscil(chanind,:,trialind)=snrat*sin(2*pi*targetf/samprat*[0:(samprat*duration)-1])+randn(1,samprat*duration);
    end %trialind
end %chanind

