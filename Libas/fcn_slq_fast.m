function [s] = fcn_slq_fast(data,params)
%FCN_SL_FAST        synchronization likelihood
%
%   S = FCN_SL_FAST(DATA,LAG,M,W1,W2,NREF);
%
%   Computes the synchronization likelihood (SL) for the recording series
%   in array, DATA (time x channel).
%
%   Inputs:     data,       recording series
%             params,       structure containing the following
%                lag,       lag parameter
%                  m,       embedding dimension
%                 w1,       starting window
%                 w2,       ending window
%               nref,       number of recurrences in windows
%
%   Outputs:       s,       SL matrix of dimensions time x channel pairings
%
%   Notes: this parameterization differs slightly from the traditional
%   parameterization of SL in that in does away with the PREF parameter.
%   The parameters pref, nref, and w2 are all interrelated. Specifying any
%   pair of the two forces the remaining free parameter to be set.
%   Specifically, they are related in the following way:
%
%   (w2 - w1 - 1)*pref = nref;
%
%   This parameterization permits the function to perform somewhat faster.
%
%   References: Stam & van Dijk, (2002) doi: 10.1016/S0167-2789(01)00386-4.
%               Montez et al (2006) doi: 10.1016/j.neuroimage.2006.06.066.
%
%   Richard Betzel, Indiana University, 2012

%modification history
% 01.03.2012 - original version

lag  = params.lag;
m    = params.m;
w1   = params.w1;
w2   = params.w2;
nref = params.nref;
pref = params.pref;

[npts,nchs]  = size(data);
nptsadj      = npts - lag*(m - 1);
t            = 1:nptsadj;
winsz        = (w2 - w1)*2 - 2;
nsl          = length(w2:(nptsadj - w2 + 1));
masks        = find(triu(ones(nchs),1));
nmasks       = length(masks);

dummyadj         = zeros(nchs);
dummyx           = 1:(nchs^2);
dummyadj(dummyx) = dummyx;
dummyadj90       = rot90(dummyadj);
maskt            = dummyadj90(masks);

s            = zeros(nsl,nmasks);
embed        = zeros(m,nchs,nptsadj);

for ipt = 1:nptsadj
    embed(:,:,ipt) = data(ipt:lag:(ipt + lag*(m-1)),:);
end
clear data;

embed = permute(embed,[3,2,1]);
ind1  = ones(winsz,1);
ind2  = ones(1,1,29);
nkeep = nref*2 + 1;

count = 0;
for i = w2:(nptsadj-w2+1);
    count = count + 1;
    eucd  = sum(bsxfun(@minus,embed(abs(i-t) > w1 & abs(i-t) < w2,:,:),embed(i,:,:)).^2,3).^0.5;
    p     = sort(eucd);
    p     = p(nkeep,:);
    p     = p(ind1,:);
    h     = eucd - p < 0;
    h     = h(:,:,ind2);
    h1    = h(:,masks);
    h2    = h(:,maskt);
    s(count,:) = sum(h1.*h2);
end
s = s./(2*nref);