function [Ms]=Point2Ms(Point,Domain,SampRate,TrigPoint,NPoints)
	
	if Domain<3 | Domain==6 | Domain==7	| Domain==8	%Time, Std, Wavelet
		Ms=round((Point-TrigPoint).*1000./SampRate);
	elseif Domain>2 & Domain<5	%Frequency
		Ms=(Point-TrigPoint).*(NPoints+1).*(SampRate./2)./NPoints.^2;
	elseif Domain==5			%ICA; PCA
		Ms=round(Point)-TrigPoint+1;
	end
return