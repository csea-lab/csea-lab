function [convec] = getcon_konio(datfilepath)
% This little piece of code opens a dat file form the 2024 konio study with
% gratings, reads it, outputs a condition vector - should be 160 elements

temp = load(datfilepath);

convec = temp(:, 2)*10 + temp(:, 6);

if length(convec) ~= 160
    disp('warning: not 160')
end

end