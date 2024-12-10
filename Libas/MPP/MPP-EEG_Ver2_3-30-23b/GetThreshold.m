function th = GetThreshold(X,M,ar,bw)

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
    
    pts = find(X_temp1);
    pt1 = [pts(1) pts(find(diff(pts)>1)+1)];
    pt2 = [pts(find(diff(pts)>1)) pts(end)];
    
    for k = 1:length(pt2)
        snippet = X_temp2(pt1(k):pt2(k));
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

VN = vecnorm(X_M);
pts = linspace(min(VN),max(VN),1000);
[f,xc] = ksdensity(VN,pts,'Bandwidth',bw);
for i = 3:length(xc)-2
    ar_f(i) = trapz(xc(1:i-1),f(1:i-1));
end
[~,ind] = min(abs(ar - ar_f));
th = xc(ind);
end