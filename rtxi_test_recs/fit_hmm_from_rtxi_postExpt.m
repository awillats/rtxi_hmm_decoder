clc
clear
close all
set(0,'DefaultAxesFontSize',15)
%%


%verify decoded state against RTXI's 

%%
%average FR usually 5-10 spks/s

basePath='~/Documents/Research/Data/rtxi_spike_mb/';
%endPath = 'testing123_take2';channelID = 5; overTransition=true;

%endPath = 'OP1_2935_C2_nW_hmmTrain';channelID = 7; stateID=9; overTransition=false;
endPath = 'OP1_2935_C2_nW_hmmTest';channelID = 7; stateID=9; overTransition=false;

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

cMod = 1; % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %


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
n_states = 4;

pmu = mean(spkc)


%%


fRatio = 3;%6;%3; % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

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

if n_states>2
    for i = 3:n_states
        pfr_ = rand()/20;
        Eo(i,:) = [1-pfr_,pfr_];
    end
end


sprintf('Guess: FR1 = %.3f/sec,  FR2 = %.3f/sec , TR1 = %.3f/sec ,  TR2 = %.3f/sec', Eo(1,2)*1e3/cMod, Eo(2,2)*1e3/cMod, To(1,2)*1e3/cMod, To(2,1)*1e3/cMod)

tic
[Te,Ee] = hmmtrain(spkc+1,To,Eo);
qp_guess = hmmdecode(spkc+1,Te,Ee);
q_guess = hmmviterbi(spkc+1,Te,Ee);
toc
%
if n_states==2
    
Te_train = [,...
    0.9998    0.0002
    0.0005    0.9995];
Ee_train = [0.9839    0.0161
            0.9731    0.0269];
else
    Te_train=[0.9998    0.0001    0.0002    0.0000
    0.0001    0.9995    0.0000    0.0004
    0.0006    0.0000    0.9994    0.0000
    0.0071    0.0027    0.0000    0.9901];
    Ee_train=[    0.9801    0.0199
    0.9711    0.0289
    0.9891    0.0109
    0.9103    0.0897];
q_guess_fromtrain = hmmviterbi(spkc+1,Te_train,Ee_train);
end
%}

%f

%%
fr_guess = 0*q_guess;
fr_guess_train = 0*q_guess;

for i = 1:length(q_guess)
    fr_guess(i) = Ee(q_guess(i),2)/1e3;
    fr_guess_train(i) = Ee_train(q_guess_fromtrain(i),2)/1e3;

end

figure(1)
clf
hold on
plot(spkc,'k','LineWidth',1)
%plot(q_guess-.8,'g','LineWidth',3)
plot(2*fr_guess./max(fr_guess_train),'g','LineWidth',3)
plot(2*fr_guess_train./max(fr_guess_train),'b:','LineWidth',3)

%plot(q_guess_fromtrain-.7,'b:','LineWidth',3)

rt_guess = D(stateID,:);
%plot(rt_guess+.1,'r','LineWidth',3)

%plot(qp_guess(2,:),'m','LineWidth',2)
xlim([0,1e5]+0*1.4e5)

hold off
set(gcf,'Position',[          64         225        1349         188]);
titleStr = sprintf('FR1 = %.3f/sec,  FR2 = %.3f/sec , TR1 = %.3f/sec ,  TR2 = %.3f/sec', Ee(1,2)*1e3/cMod, Ee(2,2)*1e3/cMod, Te(1,2)*1e3/cMod, Te(2,1)*1e3/cMod)
title(titleStr)
legend('spikes','test-hmm state','train-hmm state');%,'rtxi state')
return
%%

[Tee,Eee] = hmmestimate(spkc+1, q_guess);
q_guess2 = hmmviterbi(spkc+1,Tee,Eee);
figure(1)
hold on
plot(q_guess2-.7,'c:','LineWidth',2)
hold off
