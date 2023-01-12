function [t, p] = corr2t(r, n)

t = (r*sqrt(n-2))./sqrt(1-r.^2);

p = tpdf(t,(n-2));

end
