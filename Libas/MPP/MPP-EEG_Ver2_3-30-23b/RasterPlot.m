function RasterPlot(spikes,times,c,varargin)
N = size(spikes,2);
l = 1;
for i = 1:N
    hold all;
    pos = times(find(spikes(:,i)));
    %if(~isempty(pos))
        for SpCount = 1:length(pos)
            % plot([pos(SpCount)/(Fs*60) pos(SpCount)/(Fs*60)],[i-0.4 i+0.4],'k','LineWidth',1.25);
            if(nargin == 2)
                plot([pos(SpCount) pos(SpCount)],[l-0.4 l+0.4],'k','LineWidth',1.25);
            else
                if (length(c) == 1)
                    plot([pos(SpCount) pos(SpCount)],[l-0.4 l+0.4],c,'LineWidth',1.25);
                else
                    plot([pos(SpCount) pos(SpCount)],[l-0.4 l+0.4],c(i),'LineWidth',1.25);
                end
            end
        end
        l = l+1;
   % end
end
ylim([0 l+1]);
hold off
end