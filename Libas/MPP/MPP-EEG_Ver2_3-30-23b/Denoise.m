function [th,ar,bw] = Denoise(X,M,mul)
% Function to isolate putative neuromodulatory events from background noise
% Uses a hierarchical detection scheme and a correntropic similarity
% measure to detect PUTATIVE events
% X - NX1 cells/struct comprising of trial signals
% M - maximum length of neuromodulation
% mul - multiplicative factor for Silverman's rule
% USES CORRENTROPY AND STANDARD DEVIATION 

n_tr = size(X,1);

% check if X is a structure and convert if not
if ~isstruct(X)
    X = squeeze(X);
    n_tr = size(X,1);
    X = cell2struct(X,'Trial',n_tr);
end


f2 = [];
f1 = [];
X_M = [];
idtr = [];
for i = 1:n_tr
    X_temp1 = X(i).Trial;
    X_temp2 = X_temp1;
    
    env = abs(hilbert(X_temp1));
    spn = round(round(M/2)/2)-1;
    sm = smooth(env,spn);
    
    [~,pk_loc] = findpeaks(sm,'MinPeakDistance',M);
    N = length(X_temp1);
    
    for j = 1:length(pk_loc)
        if (pk_loc(j) - M/2 > 0 && pk_loc(j) + M/2 - 1 <= N)
            t = round(pk_loc(j) - M/2:pk_loc(j) + M/2 - 1);
            X_M = [X_M; X_temp1(t)];
            X_temp1(t) = 0;
            f2 = [f2; t(end)];
            f1 = [f1; t(1)];
            idtr = [idtr i];
        end
    end
    
    clear pts
    pts(1,:) = find(X_temp1);
    pt1 = [pts(1) pts(find(diff(pts)>1)+1)];
    pt2 = [pts(find(diff(pts)>1)) pts(end)];
    
    for k = 1:length(pt2)
        clear snippet
        snippet(1,:) = X_temp2(pt1(k):pt2(k));
        L = length(snippet);
        x = [];
        if (L >= M/2)
            if (L <= M && pt2(k) + (M-L) <= N)
                x = [snippet X_temp2(pt2(k)+1:pt2(k)+ (M-L))];
                X_M = [X_M; x];
                f2 = [f2; pt2(k)];
                f1 = [f1; pt1(k)];
                idtr = [idtr i];
            else
                m = floor(L/M);
                for j = 1:m
                    x = [x; snippet(1 +(j-1)*M:M+ (j-1)*M)];
                    f2 = [f2; pt1(k)+(j-1)*M + M-1];
                    f1 = [f1; pt1(k)+(j-1)*M];
                    idtr = [idtr i];
                end
                if (pt2(k)+(m+1)*M-L <= N && (L - m*M) >= M/2)
                    x = [x; X_temp2(pt1(k)+ m*M:pt2(k)+(m+1)*M-L)];
                    f2 = [f2; pt2(k)-1];
                    f1 = [f1; pt1(k) + m*M];
                    idtr = [idtr i];
                end
                X_M = [X_M; x];
            end
        end
    end
end
X_M = X_M';
[rows,cols] = size(X_M);
x_m_norm = norm(X_M(:));
X_M = X_M./ x_m_norm;

P_vec = zeros(1,cols);
sig_e = std(X_M(:));
sig = (1.06 * sig_e * (N)^(-0.2))*mul;

parfor i = 1:cols
    for j = 1:cols
        if (i ~= j)
            t = (1/M) * sum((1/(sqrt(2*pi)*sig))*exp((-(X_M(:,i) - X_M(:,j)).^2)/(2*sig^2)));
            P_vec(i) = t + P_vec(i);
        end
    end
end

P_vec = (1/cols)*P_vec;
[P_vec,I] = sort(P_vec,'descend');

X_M = X_M*x_m_norm;

prc_v = 8:0.5:15;
s_v = zeros(1,length(prc_v));

for i = 1:length(prc_v)
    idx = find(P_vec > prctile(P_vec,prc_v(i)));
    X_lr = X_M(:,I(idx));
    s_v(i) = skewness(X_lr(:));
    clear X_lr X_sp P_lr
end

[~, idx_min] = min(abs(s_v));        % Skewness value closest to zero
p_val = prctile(P_vec,prc_v(idx_min));
ID = find(P_vec < p_val);

idx_lr = I(find(P_vec >= p_val));
idx_sp = I(find(P_vec < p_val));

if isempty(ID)
    ID = find(P_vec <= p_val);
    idx_lr = I(find(P_vec > p_val));
    idx_sp = I(find(P_vec <= p_val));
end

mv = mean(sqrt(movvar(vecnorm(X_M(:,I)),10)));

th = min(vecnorm(X_M(:,idx_sp)));
VN = vecnorm(X_M);

pts = linspace(min(VN),max(VN),1000);
[f,xc,bw] = ksdensity(VN,pts);
[~,ind] = min(abs(xc - th));

if length(xc(1:ind-1)) > 1 %Jourdan Edit: When entire kurtosis series passes threshold, size of Y in trapz(X,Y) is passed as a 
    ar = trapz(xc(1:ind-1),f(1:ind-1));  %'dimension' argument despite being a float. If-else statements added to prevent this. 
else
    ar = xc(1:ind-1)*trapz(f(1:ind-1));  %Per trapz() documentation, when X is a scalar, X*trapz(Y) is equivalent to trapz(X,Y).
end                                      %In effect, the integral is taken for only one point in the distribution if X is a scalar.

end


