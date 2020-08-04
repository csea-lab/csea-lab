% The accompanying code is the simulation of a simplified version of a synfire chain in a cortical network,
% inspired by the ideas of Abeles (1982, 1991), Bienenstock (1995), and Diesmann et al. (1999).
% In a synfire chain groups, or pools, of neurons are connected in a feedforward arrangement.
% The neurophysiological behavior of a synfire chain is characterized by the propagation of volleys of
% nearly synchronous spikes from pool to pool. In this simulation a 10 x 10 network is used, that is,
% the network contains 10 pools, or layers, of neurons (length of network) and 10 neurons per pool
% (width of network). The neurons in the first pool are stimulated externally, using Gaussian random inputs.
% The neurons in the subsequent layers receive the combined input of all the neurons in the immediately
% preceding layer (p-1) after a variable delay (conduction time, conduction jitter). The additive generation
% of the internal inputs is somewhat variable (convergence jitter). The overall magnitude of the input can be
% modulated by means of an amplification factor. Random excitatory and inhibitory neuronal inputs
% (background noise) are present. The figures depict the behaviors of the 10 pools of neurons over time,
% the cross-correlograms of the intervals between the spikes of the first two neurons in each pool,
% and a plot of the mean latencies of the first spikes in each pool and their respective standard deviations.
% The initial potential of all neurons, the mean latencies, the standard deviations, and their correlation
% coefficient are printed.

% A dominant peak around zero is frequently found in cross-correlograms; it indicates shared (external or
% internal) inputs. Here, the main peak indicates the synchronous firing of the neurons in each pool when the
% volley reaches the pool (except, of course, for the first pool, where the peak indicates simultaneous
% external input). The spikes in each layer that occur after the volleys occurred are partially synchronized
% (in contrast to the random spikes before the volleys) because of the additive nature of the input to each
% neuron, being the scaled sum of the delayed inputs of all the neurons in the previous layer.
% This synchronization shows up as side peaks in the cross-correlograms (because it causes fixed delays
% between the firing of the neurons in a particular layer), particularly in those correlograms that incorporate
% a comparatively long stretch of post-volley time. A high membrane time constant increases the pre- and
% post-volley synchronization of spikes.

% In the case of stably propagating volleys, the correlation coefficient is high (> .99) and the relation
% between mean spike latency and standard deviation approximately linear (see figure 3). This situation is
% similar to the relation depicted in Buonomano’s (2003) figure 2. Linearity between mean latency and
% standard deviation indicates that the correspondence between spike times decreases as the mean latency of
% the first spikes / pool increases.

% The model explodes (continuous increase in number of spikes / layer) when the difference between the
% threshold and resting potential is small, the membrane time constant is high, or the difference between
% excitatory and inhibitory noise is large. Explosion results in a decrease of the correlation coefficient.
% The volley collapses/fades when the difference between the threshold and resting potential is large,
% the inhibitory background noise is high, or the amplification factor is low. Spontaneous, internally
% generated, volleys form when the conduction jitter (variability in the conduction time between pools of
% neurons) is high while the amplification factor is sufficiently high. To keep the model stable,
% a fine balance between excitatory and inhibitory (background) input is necessary.


% References:

% Abeles, M. (1982) Local Cortical Circuits: An Electrophysiological Study. Springer, Berlin.
% Abeles, M. (1991) Corticonics. Cambridge University Press, Cambridge.
% Bienenstock, E. (1995) A model of neocortex. Netw. Comp. Neur. Sys., 6: 179–224.
% Buonomano, D.V. (2003) Timing of neural responses in cortical organotypic slices. Proc. Natl. Acad. Sci. USA, 100: 4897–4902.
% Diesmann, M., M.-O. Gewaltig, and A. Aertsen (1999) Stable propagation of synchronous spiking in cortical neural networks. Nature, 402: 529–533.


% Code written by Thomas Templin (temtom@hotmail.com) using MATLAB version 6.0.0.88 release 12,
% as the final assignment for the course Computational Neuroscience (BN 168) taught by Prof. Elie Bienenstock
% at Brown University in the spring semester of 2003.



clear all
close all

P = 8;                         % length of network
N = 8;                         % width of network
epoch = .11;
bin_length = .0001;
V_rest = -.07;
V_th = -.06;
V_start = -.061                 % initial potential
tau_m = 0.01;
input_strength = .003;          % external input to set chain in motion
input_jitter = .001;
input_length = .003;            % duration of external input
excitatory_noise = .0002;       % strength of excitatory background noise
inhibitory_noise = .00016;      % strength of inhibitory background noise
excitatory_jitter = .00003;     % variability of excitatory background noise
inhibitory_jitter = .00003;     % variability of inhibitory background noise
conduction_time = .01;
conduction_jitter = .1;
convergence_jitter = .000002;
amplification_factor = .4;      % amplification of convergent input

time_axis = 0:bin_length:epoch;
bin_number = length(time_axis);
input_onset = round(bin_number/10);
input_bins = round(input_length/bin_length);            % duration of external input (bin units)
conduction_bins = round(conduction_time/bin_length);    % conduction time (bin units)
input_offset = input_onset + input_bins;

latency = [];                       % latency of first spike in pool
mean_latency = [];
standard_deviation = [];

crossco_time = [-epoch:bin_length:epoch]; 

p = 1;     % first pool (receives external input)
V = V_start*ones(N,bin_number);
excitatory_background_noise = max(0,normrnd(excitatory_noise,excitatory_jitter,N,bin_number));
inhibitory_background_noise = max(0,normrnd(inhibitory_noise,inhibitory_jitter,N,bin_number));
V = V + excitatory_background_noise - inhibitory_background_noise;


for n = 1:N    % loop for all neurons in first pool

    occurence_spike = 0;

    for bin = 2:bin_number
        
        if bin >= input_onset & bin <= input_offset
            
            input = max(0,normrnd(input_strength,input_jitter,1,1));
            
        else
            
            input = 0;
            
        end;
        
        if V(n,bin-1) < V_th
            
            V_derivative = (V_rest - V(n,bin-1))/tau_m;
            V(n,bin) = V(n,bin-1) + bin_length*V_derivative + input + excitatory_background_noise(n,bin) - inhibitory_background_noise(n,bin);   % membrane potential
            
        else
            
            V(n,bin-1) = .03;     % EPSP
            V(n,bin) = V_rest;
            
            if occurence_spike == 0
                latency = [latency bin];
            end
            
            occurence_spike = 1;
            
         end
            
     end
     
     figure(1)
     subplot(P,1,p), plot(time_axis,V), axis([0 epoch -.1 .1]), title('Membrane Potentials of Neurons in Various Pool Levels'), ylabel('V_m (V)')     % membrane potential over time (first pool)
     
end  

V_1 = V(1,:);
V_2 = V(2,:);
for bin = 1:bin_number
    if V_1(bin) == .03
        V_1(bin) = 1;
    else 
        V_1(bin) = 0;   
    end
    if V_2(bin) == .03
        V_2(bin) = 1;
    else 
        V_2(bin) = 0;
    end
end
crossco = xcov(V_1,V_2);
figure(2)
subplot(P,1,p), plot(crossco_time,crossco), axis([-epoch epoch -.5 Inf]), title('Cross Correlograms')   % cross correlogram of two first neurons of first pool
    
mean_latency = [mean_latency mean(latency)];
standard_deviation = [standard_deviation std(latency)];

level = input_offset;   % beginning of second pool

for p = 2:P     % internally driven pools
    
    clear V_1, clear V_2
    
    potential_cache(:,:) = V(:,:);     % store potential matrix (neurons, bins)

    excitatory_background_noise = max(0,normrnd(excitatory_noise,excitatory_jitter,N,bin_number));
    inhibitory_background_noise = max(0,normrnd(inhibitory_noise,inhibitory_jitter,N,bin_number));
    
    V = V_start*ones(N,bin_number);
    V = V + excitatory_background_noise - inhibitory_background_noise;
   
    input = zeros(N,bin_number);

    for n = 1:N
        
        occurence_spike = 0;
        
        for bin = level:bin_number
        
            potential_transform(n,bin) = potential_cache(n,bin-conduction_bins+round(normrnd(0,conduction_jitter,1,1)));     % introduce conduction delays and conduction jitter
            
        end
        
        for bin = level:bin_number
        
            individual_input(n,bin) = max(0,potential_transform(n,bin));
    
        end
    
        input = sum(individual_input,1);                        % add all imputs from previous pool
        amplified_input = input*amplification_factor;           % adjust (amplify) inputs (e.g., to keep model stable)
        input_rep = repmat(amplified_input,N,1);
        input_rep_var = normrnd(input_rep,convergence_jitter);

        for bin = 2:bin_number
        
            if V(n,bin-1) < V_th
            
                V_derivative = (V_rest - V(n,bin-1))/tau_m;
                
                if bin >= level

                    V(n,bin) = V(n,bin-1) + bin_length*V_derivative + input_rep_var(n,bin) + excitatory_background_noise(n,bin) - inhibitory_background_noise(n,bin);   % membrane potential (after onset of volley)    
            
                else
                    
                    V(n,bin) = V(n,bin-1) + bin_length*V_derivative + excitatory_background_noise(n,bin) - inhibitory_background_noise(n,bin);                          % membrane potential (before onset of volley)
                end
                
             else
            
                 V(n,bin-1) = .03;   % EPSP
                 V(n,bin) = V_rest;
                
                  if occurence_spike == 0
                    
                      latency = [latency bin];
                    
                  end
            
                  occurence_spike = 1;
            
             end
        
        end
   
        figure(1), subplot(P,1,p), plot(time_axis,V), axis([0 epoch -.1 .1]), ylabel('V_m (V)')    % membrane potential over time (internally driven pools)
        if p == P
        xlabel('time (s)')
        end 
    
    end
    
    mean_latency = [mean_latency mean(latency)];
    standard_deviation = [standard_deviation std(latency)];
    
    level = level + conduction_bins;   % update pool level
     
    V_1 = V(1,:);
    V_2 = V(2,:);
    for bin = 1:bin_number
        if V_1(bin) == .03
            V_1(bin) = 1;
        else 
            V_1(bin) = 0;
        end
        if V_2(bin) == .03
            V_2(bin) = 1;
        else 
            V_2(bin) = 0;
        end
    end
    crossco = xcov(V_1,V_2);
    figure(2)
    subplot(P,1,p), plot(crossco_time,crossco), axis([-epoch epoch -.5 Inf])    % cross correlograms of two first neurons of internally driven pools
    if p == P
    xlabel('time (s)')
    end

end

mean_latency        % print vector of mean latencies of first spikes of pools
standard_deviation  % print vector of standdard deviations of first spikes of pools

figure(3)
plot(mean_latency,standard_deviation,'bs','MarkerFaceColor','b','MarkerSize',6)  % standard deviation vs mean latencies of first spikes of pools
xlabel('mean latency (s)'), ylabel('standard deviation')
lsline
cc = corrcoef(mean_latency,standard_deviation);
correlation_coefficient = cc(1,2)