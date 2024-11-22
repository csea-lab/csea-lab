function [U,mu,ct] = MCC_SVD(X,eps,Corr_sig_t)

% MCC SVD
% KEY: For zero mean bases, force mu_t to be zero EVERYTIME

% figure
% scatter(X(1,:),X(2,:))
% hold on

fl = 0;
mr = 1;                             % Number of principal components to estimate
[U_t,~,~] = svds(X,mr);
%Ut = [1; 0];
mu_t = mean(X,2);
[~,n] = size(X);
ct_max = 50;

mu_t = zeros(size(mu_t));

%plot([-10*abs(U_t(1)) 0 10*abs(U_t(1))], [-10*abs(U_t(2)) 0 10*abs(U_t(2))], 'r', 'Linewidth',2)

if nargin == 2
    ct = 1;
    while fl == 0
        % Kernel width calculation
        X_cent_t = bsxfun(@minus,X,mu_t);
%         tic
%         aux1 = (diag(X_cent_t'*X_cent_t) - (diag(X_cent_t'*(U_t*U_t')*X_cent_t)))';
%         toc
      
        aux = (X_cent_t - (U_t*U_t')*X_cent_t);
        X_d_t = sum(aux.^2,1);
        sig_e_t = std(X_d_t);
        R_t = iqr(X_d_t);
        Corr_sig_t = 1.06*min([sig_e_t R_t/1.34])*n^(-1/5);
    
        % Correntropy and Updates
        Corr_arg_t = X_d_t;
        p_t = -exp(-Corr_arg_t/(2*Corr_sig_t));
    
        mu_t = (1/sum(p_t))*(sum(bsxfun(@times,p_t,X),2));
        
        mu_t = zeros(size(mu_t));
        
        X_cent_t = bsxfun(@minus,X,mu_t);
        P_M_t = diag(-p_t);
        PCA_param = X_cent_t*P_M_t*(X_cent_t)';
        
        if mean(isnan(PCA_param(:))) ~= 0
            display('NaN Warning')
        end     
        
        if mean(isinf(PCA_param(:))) ~= 0
            display('Inf Warning')
        end
        
        %[U_t1,~] = eigs(PCA_param,mr);
        [V,D] = eig(PCA_param);
        [~,idx] = sort(diag(D),'descend');
        V = V(:,idx);
        U_t1 = V(:,1:mr);

        norm_diff = norm(abs(U_t) - abs(U_t1));
        
        if ct == ct_max
            fl = 1;
        end

        if mean(PCA_param(:)) == 0
            [U_t1,~,~] = svds(X,mr);
            fl = 1;
        end
        
        if norm_diff < eps
            fl = 1;
        end
        
        if fl == 1
            U = U_t1;
            mu = mu_t;
        else
            U_t = U_t1;
            ct = ct + 1;
        end
    end  
elseif nargin == 3
    ct = 1;
    while fl == 0

%         % Kernel width calculation
%         X_cent_t = bsxfun(@minus,X,mu_t);
%         aux = (X_cent_t - (Ut*Ut')*X_cent_t);
%         X_d_t = sum(aux.^2,1);
%         sig_e_t = std(X_d_t);
%         R_t = iqr(X_d_t);
%         Corr_sig_t = 1.06*min([sig_e_t R_t/1.34])*n^(-1/5);
        
        X_cent_t = bsxfun(@minus,X,mu_t);
        % Correntropy and Updates

        Corr_arg_t = (diag(X_cent_t'*X_cent_t) - (diag(X_cent_t'*(U_t*U_t')*X_cent_t)))';
        p_t = -exp(-Corr_arg_t/(2*Corr_sig_t));
    
        mu_t = (1/sum(p_t))*(sum(bsxfun(@times,p_t,X),2));
        X_cent_t = bsxfun(@minus,X,mu_t);
        %size(X_cent_t)
        [U_t1,~,~] = svds(X_cent_t,mr);
        norm_diff = norm(U_t - U_t1);
        if norm_diff < eps
            fl = 1;
            U = U_t1;
            mu = mu_t;
        else
            U_t = U_t1;
            ct = ct + 1;
        end
    end  
    
end
end