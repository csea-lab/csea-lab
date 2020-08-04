function kappa = kappaneg(mat); 

%assumes that positive agreement is in the bottom right cell of the mat
% this is a playground for trying out different ratios!!! do not use
% blindly! 

% pa = (mat(2,2))./(sum(mat(2,:))+sum(mat(:,2)));
% pe = (sum(mat(1,:))./sum(sum(mat))).*(sum(mat(:,1))./sum(sum(mat))); %+ (sum(mat(1,:))./sum(sum(mat))).*(sum(mat(:,1))./sum(sum(mat)));
% kappa=(pa-pe)./(1-pe);

kappa = (mat(2,2)-mat(1,1))./sum(sum(mat));
 


