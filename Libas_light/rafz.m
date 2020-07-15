function out = rafz(in)
%out = rafz(in), round away from zero
%SCd 10/26/2011
%
    out = max(abs(ceil(in)),abs(floor(in))).*sign(in);
end