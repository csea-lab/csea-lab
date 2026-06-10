function [hitRate, FARate] = getaccuracy_c1p1(conditionfile, targettimefile, presstimefile);

hitRate = [];
FARate = [];

Pressfid = fopen(presstimefile);

convec = getcon_C1P1(conditionfile);
test = reshape(convec, 80, 60);
blocks = round(mean(test)./10); % 2 = attend left; 1 = attend right

targettimes = load(targettimefile);
targettimesinSec = targettimes(:, 4:11);

for rowIndex = 1:length(blocks)

    % first find the correct target times
    if blocks(rowIndex) == 1; % attend right
        targettimesinBlock = targettimesinSec(rowIndex, 5:8);
    elseif blocks(rowIndex) == 2; % attend left
        targettimesinBlock = targettimesinSec(rowIndex, 1:4);
    end

    % now gwet this blocks responses
    charstringresp = fgetl(Pressfid);
    temp = str2num(charstringresp);
    RTsinBlock = temp(4:end)

    % now the fun part
    landingzone = [];
    correcthitsvec = [];

    for targetindex = 1:4
        landingzone = [landingzone targettimesinBlock(targetindex)+.2:0.0001:targettimesinBlock(targetindex)+1];
    end

    for responseindex = 1:length(RTsinBlock)
        correcthitsvec(responseindex) = ismember(RTsinBlock(responseindex), landingzone);
    end

    hitRate(rowIndex) = min(1, sum(correcthitsvec)./4); 
    FARate(rowIndex) =  length(find(correcthitsvec==0))./length(correcthitsvec); 

end % over rows/blocks


