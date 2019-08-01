clc
clear
close all
set(0,'DefaultAxesFontSize',15)
%%

basePath='~/Documents/Research/Data/rtxi_spike_mb/';
endPath = 'OP1_3715_b3_CL1';

readFun = @() h5read( [basePath,endPath,'.h5'], "/Trial1/Synchronous Data/Channel Data");

%ignore channel key for OP1_3715 etc.
channelKey = {'plant.x',...
    'ref',...
    'hmm1',...
    'hmm2',...
    'decode state',...
    'X_{est}',...
    'comp',...
    'rt per'};
    

%%
D=readFun();
spks=D(7,:); %check this!


%ad-hoc way to map 0-.5-1 data to 0-1
spks_clipped = double(spks>.4);


figure(1)
clf
plot(spks_clipped,'LineWidth',1)
xlim([0,5e5])

% guess params
n_states = 2;
ptr0 = 1e-3;
pfr = 1e-6;
pfr2 = 1e-3;

EYE = eye(n_states);

To = (1-EYE)*ptr0 + EYE*(1-ptr0*n_states);
Eo = zeros(n_states,2);
Eo(1,:) = [1-pfr, pfr];
Eo(2,:) = [1-pfr2, pfr2];


dt_ID = 1e-3;
dt_Decode = 1e-3;
cFactor = dt_ID / dt_Decode; %20?


spkc = compressSpks(spks_clipped,10);%cFactor


%commented section is for fitting from 
%{ 
[Te,Ee] = hmmtrain(spks+1,To,Eo);
qp_guess = hmmdecode(spks+1,Te,Ee);
q_guess = hmmviterbi(spks+1,Te,Ee);
%}

[Te,Ee] = hmmtrain(spkc+1,To,Eo);
qp_guess = hmmdecode(spkc+1,Te,Ee);
q_guess = hmmviterbi(spkc+1,Te,Ee);
%
%%

figure(1)
clf
hold on
plot(spkc,'k','LineWidth',1)
plot(q_guess-.8,'g','LineWidth',2)
plot(qp_guess(2,:),'m','LineWidth',2)
xlim([0,1e4])

hold off
