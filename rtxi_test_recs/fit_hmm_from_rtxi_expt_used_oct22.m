clc
clear
close all
set(0,'DefaultAxesFontSize',15)
%%


%verify decoded state against RTXI's 

%%
%average FR usually 5-10 spks/s

basePath='~/Documents/Research/Data/rtxi_spike_mb/aug5_2019/';

%nb: dont have test data fro 2975
endPath = 'OP1_2935_C2_nW_hmmTrain';channelID = 7; stateID=9; overTransition=false;


%no compression + viterbi training works!, OR
%5x compression + BW training


doSubsample = true;
clipLength = -1;%-1;%3e4;% (set to -1 to not clip)

readFun = @() h5read( [basePath,endPath,'.h5'], "/Trial1/Synchronous Data/Channel Data");

%ignore channel key for OP1_3715 etc.
channelKey = {'loops',...
    'trig0',...
    'trg1',...
    'trig2',...
    'ugalvo',...
    'uopto',...
    'n_spikes',...
    'isCountAvg',...
    'decode state',...
    'FR1',...
        'FR2',...
    'TR1',...
    'FR2'};
    

%%


D=readFun();
if clipLength>0
    spks=D(channelID,1:clipLength); %check this!
else
    spks=D(channelID,:);
end
%states=D(6,:);
%plot(D(channelID,:),'r','LineWidth',2);
%return

%%
cMod = 1; %1 is default, 2,5,10 are also good
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %


%ad-hoc way to map 0-.5-1 data to 0-1
spks_clipped = double(spks>.4);

if doSubsample
    %represents subsampling, @MB
    spks_clipped(1:2:end) = 0; 
end

dt_ID = 1e-3;
dt_Decode = (1e-3)/cMod;
cFactor = floor(dt_ID / dt_Decode); %20?

spkc = compressSpks(spks_clipped,cFactor);%cFactor

figure(1)
clf
plot(spks_clipped,'LineWidth',1)
xlim([0,5e5])

% guess params
n_states = 2;

pmu = mean(spkc)


%%

%fRatio doesn't seem to matter much
fRatio = 6;%6, %3; % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%set firing rates by geometric mean
f1 = sqrt(pmu^2 / fRatio)
f2 = fRatio*f1
pfr = f1;
pfr2 = f2;

%
%{
%set firing rates by arithmetic mean
fRatio = 6;
fsum = 1+fRatio;
f1 = (2*fRatio)/fsum;
f2 = 2/fsum;
pfr = pmu*f1;
pfr2 = pmu*f2;
%}

%%

%for "bad" datasets, set transition probability very high
if overTransition
    ptr0  = pmu*10; %this is a hack
else
    ptr0 =  pmu/10;%10 for rou . % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

end
EYE = eye(n_states);

To = (1-EYE)*ptr0 + EYE*(1-ptr0*(n_states-1));
Eo = zeros(n_states,2);
Eo(1,:) = [1-pfr, pfr];
Eo(2,:) = [1-pfr2, pfr2];


fr1 = Eo(1,2)*1e3/cMod;
fr2 =  Eo(2,2)*1e3/cMod;
tr1 = To(1,2)*1e3/cMod;
tr2 = To(2,1)*1e3/cMod;

sprintf('Guess: FR1 = %.3f/sec,  FR2 = %.3f/sec , TR1 = %.3f/sec ,  TR2 = %.3f/sec', fr1, fr2, tr1, tr2)

tic
[Te,Ee] = hmmtrain(spkc+1,To,Eo);
qp_guess = hmmdecode(spkc+1,Te,Ee);
q_guess = hmmviterbi(spkc+1,Te,Ee);
toc
%
%%

figure(1)
clf
hold on
plot(spkc,'k','LineWidth',1)
plot(q_guess-.8,'g','LineWidth',2)

%plot(D(stateID,:)-.9+1,'m','LineWidth',3)%%plots online-decoded state

%plot(qp_guess(2,:),'m','LineWidth',2)
%xlim([0,1e5]+1e4)

hold off
set(gcf,'Position',[          64         225        1349         188]);
fr1 = Ee(1,2)*1e3/cMod;
fr2 =  Ee(2,2)*1e3/cMod;
tr1 = Te(1,2)*1e3/cMod;
tr2 = Te(2,1)*1e3/cMod;

mu = (fr1+fr2)/2;
sigma=fr2-mu;
tau = 1/(mean([tr1,tr2]));
decodability=tau*sigma*sigma/mu

titleStr = sprintf('FR1 = %.3f/sec,  FR2 = %.3f/sec , TR1 = %.3f/sec ,  TR2 = %.3f/sec. logDecodability = %.3f', fr1,fr2,tr1,tr2,log10(decodability))
title(titleStr)
return
%%

[Tee,Eee] = hmmestimate(spkc+1, q_guess);
q_guess2 = hmmviterbi(spkc+1,Tee,Eee);
figure(1)
hold on
plot(q_guess2-.7,'c:','LineWidth',2)
hold off
