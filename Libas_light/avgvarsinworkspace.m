mat = who('h*')
for x = 1:size(mat,1)
x, if x == 1; eval(['tempsum =' mat{1}]), else, eval(['tempsum = tempsum + ' mat{x}]); end
end
tempavg = tempsum./size(mat,1)
