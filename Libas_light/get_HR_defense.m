%get_HR_defense
function [HRmat, HRmatbins] = get_HR_defense(infilepath)

a = load(infilepath, '-ascii'); 

HRmatbins = [];

a(:,3) = interp_outliers_HR(a(:,3));

trigindex = find(a(:,2) < -4)

HRvec1 = interp_outliers_HR(a(trigindex(1)-400:trigindex(1)+12000,3));
HRvec2 = interp_outliers_HR(a(trigindex(2)-400:trigindex(2)+12000,3));

HRmat = [HRvec1'; HRvec2']; 

taxis2 = -2:0.005:60;

 plot(taxis2, HRmat')
 
 binvec = 1:100:12300; 
 
 for x = 1 : length(binvec); 
    HRmatbins =  [HRmatbins mean(HRmat(:, binvec(x):binvec(x)+99),2)]; 
 end


figure
taxis = -1.5:.5:59.5
plot(taxis, HRmatbins')


save([infilepath '.HRbin'], 'HRmatbins', '-ascii')