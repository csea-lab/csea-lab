% script for age_operant

M = csvread('FILENAME');

% corrects for rotation to other side, difference cannot exceed 90 degrees
for x = 1:size(a,2);
   if a(x)>90, a(x) = 180-a(x);  end, 
end
plot(a)


