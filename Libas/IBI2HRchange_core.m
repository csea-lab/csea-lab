function [BPMvec]  = IBI2HRchange_core(Rwavestamps, NBins); 

if Rwavestamps(1) <= 0; 
    Rwavestamps(1) = 0.01
end


IBIvec = diff(Rwavestamps);
%secbins = [Rwavestamps(1):Rwavestamps(end)+0.02]-0.01
secbins = [0:NBins]; 
   
    leftfornext = 0; 
    BPMvec = zeros(1,length(secbins)-1);
    
     for bin_index = 1:length(secbins)-1 
          RindicesInBin1= find(Rwavestamps > secbins(bin_index));
            RindicesInBin2 = min(find(Rwavestamps > secbins(bin_index +1)));
            RindicesInBin = min(RindicesInBin1) : RindicesInBin2 -1; %pause

            if ~isempty(RindicesInBin); 
            maxbincurrent = max(RindicesInBin);            
            end

            % first bin
            if bin_index == 1; 
                
                        if length(RindicesInBin) == 2, % if there are two Rwaves in this segment, the basevalue is always 1 beat, and more may be added

                            basebeatnum = 1; % there is no leftfornext as this is the first bin

                                %  identify remaining time and determine proportion of next IBI that belongs to this
                                % segment
                             proportion =  (secbins(bin_index +1) - Rwavestamps(max(RindicesInBin)))./IBIvec(max(RindicesInBin));

                            leftfornext = 1-proportion;

                        elseif length(RindicesInBin) == 1,% if there is one Rwave in this segment, the basevalue is what remained from the previous beat, and more may be added

                            basebeatnum = 0;

                            % then identify remaining time and determine proportion of next IBI that belongs to this
                            % segment
                             proportion = 1./IBIvec(1);
                             
                             proportiondummy =  (secbins(bin_index +1) - Rwavestamps(1))./IBIvec(1);

                              leftfornext = 1-proportiondummy;
                       

                        else % if there is no beat in this segment
                
                            basebeatnum = 1;
                           
                            proportion =  (secbins(bin_index +1) - Rwavestamps(1))./IBIvec(1);                          

                            leftfornext = 0;

                        end               
                
            else
            
          
                %%%subsequent bins
                if length(RindicesInBin) == 2, % if there are two Rwaves in this segment, the basevalue is always 1 beat, and more may be added

                        basebeatnum = 1+leftfornext;

                         %  identify remaining time and determine proportion of next IBI that belongs to this
                         % segment
                          proportion =  (secbins(bin_index +1) - Rwavestamps(max(RindicesInBin)))./IBIvec(max(RindicesInBin));

                          leftfornext = 1-proportion;

                elseif length(RindicesInBin) == 1,% if there is one Rwave in this segment, the basevalue is what remained from the previous beat, and more may be added

                        basebeatnum = leftfornext;

                         % then identify remaining time and determine proportion of next IBI that belongs to this
                         % segment
                           proportion =  (secbins(bin_index +1) - Rwavestamps(max(RindicesInBin)))./IBIvec(max(RindicesInBin));

                           leftfornext = 1-proportion;

                else % if there is no beat in this segment

                    basebeatnum = leftfornext;

                        proportion = 0;             

                     leftfornext = abs(proportion);

                end
            end
            

         BPMvec(bin_index) = (basebeatnum+proportion) .* 60;

    end

end

