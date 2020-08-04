%****Acknowledgment: Code was adapted from David S. Touretzky (October, 1998). Original code: www.cs.cmu.edu/afs/cs/academic/class/15883-s99/handouts/td.html**** %****For explanation of model see Suri, Neural Networks 2002.
%********Set parameters******
stimtime=5; %time of CS
rewardtime=25;
numberofbins = 30;
numberoftrials=50;
alpha=0.9; %learning rate (0 to 1).
gamma=0.99; %temporal discount factor (0 to 1). More distant rewards are weighed less. default=0.99. 
reset_learning='y'; %if not 'y', then will use final {W, delta, and V} values from the last run. 
%*****************************
stim=zeros(numberofbins,1);
reward=zeros(numberofbins,1);
stim(stimtime)=1; %defines stimulus vector (value of 1 at stimtime). For surprise reward, set this value to zero. 
reward(rewardtime)=1; %defines reward vector (value of 1 at rewardtime). For extinction, set this value to zero.

if reset_learning=='y';
W=zeros(numberofbins,1); %predictive synaptic weight of each time bin. Initially, all weights are zero but they get updated every time bin. delta=zeros(numberoftrials,numberofbins);
V=zeros(numberoftrials,numberofbins);
else %use final {W, delta, and V} values from the last run.
delta=delta(numberoftrials,:);
V=V(numberoftrials,:)
end
Vij=V(1,1); %prediction of cue x at time t. initial value=0.
for i=1:numberoftrials
x=zeros(numberofbins,1); %Initialize time-shifted stimulus vector.
for j=stimtime:numberofbins %start at j=stimtime but could also set initial j=1; result is the same.
x_prev=x; %note that the vector x is zero for j = 1 through stimtime-1, thus as expected there is no predictive value for times before stimtime. 
Vij_prev=Vij;
%Generate new time-shifted stimulus vector:
%time of US
%number of time bins. make sure this is greater than rewardtime.
%number of trials.
x(2:end)=x(1:(end-1)); %vector shifts forward by one time bin (the value 1 moves forward in time).
x(1)=stim(j); %assigns first element of x to correspond to the stimulus value at time bin j. x has the value 1 in one time bin.
R=reward(j); %R will be 1 at j=rewardtime, 0 at all other times. note that when j=rewardtime, x will have the value 1 at time rewardtime-stimtime
%TD learning rules:
Vij=sum(W.*x);
deltaij=R+gamma*Vij-Vij_prev; %prediction error at current time bin. On the first trial that R=1, deltaij=1 at j=rewardtime (strong positive +ve). 
V(i,j)=Vij;
delta(i,j)=deltaij;
%Update the synaptic weight vector for the next time bin:
W=W+alpha*deltaij*x_prev; %With successive iterations W increases with time from stimtim and reaches a peak value at t=rewardtime-stimtime.
%A key property is that W becomes nonzero for times earlier than reward (because of term x_prev).
end
end
figure(1); clf;
subplot(2,1,1)
plot(1:numberofbins,V'); xlabel(['Time bin #'], 'FontSize', 12); ylabel(['Prediction'] ,'FontSize', 12); set(gca,'FontSize',12,'TickDir','out')
subplot(2,1,2)
plot(1:numberofbins,delta'); xlabel(['Time bin #'], 'FontSize', 12); ylabel(['Prediction Error'] ,'FontSize', 12); set(gca,'FontSize',12,'TickDir','out')