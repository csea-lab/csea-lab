function [trl, event] = trialfun_maeve(cfg)
%The configuration structure will contain the fields cfg.dataset, cfg.headerfile and cfg.datafile. 
%plus the sub-structure cfg.trialdef.pre and .post, in seconds.  
%The second output argument of the trialfun is optional, 
%it will be added to the configuration if present (i.e. for later reference).

% read the header information and the events from the data
hdr   = ft_read_header(cfg.dataset);
event = ft_read_event(cfg.dataset);

% search for DIN3 marker events
sample = [event(find(strcmp('DIN4', {event.value}))).sample]';

% determine the number of samples before and after the trigger
pretrig  = -round(cfg.trialdef.pre  * hdr.Fs);
posttrig =  round(cfg.trialdef.post * hdr.Fs);

% make trl structure for each trial
trl = [];
for j = 1:(length(sample))
  trlbegin = sample(j) + pretrig;
  trlend   = sample(j) + posttrig;
  offset   = pretrig;
  newtrl   = [trlbegin trlend offset];
  trl      = [trl; newtrl];
end
