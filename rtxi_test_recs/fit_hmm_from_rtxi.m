clc
clear
close all
set(0,'DefaultAxesFontSize',15)
%%

basePath='~/Documents/Research/Data/plds_char_june5/stac_plds_x'
midPath = '_bufflen';

readFun = @(num1,num2) h5read([basePath,num2str(num1),midPath,num2str(num2),'.h5'],"/Trial1/Synchronous Data/Channel Data");

channelKey = {'plant.x',...
    'ref',...
    'hmm1',...
    'hmm2',...
    'decode state',...
    'X_{est}',...
    'comp',...
    'rt per'};
    

DD = {};
xlens = 2:8
for i=xlens
    DD{end+1} = readFun(i,1000);
end


%%
D=DD{1};
spks=D(4,:);
figure(1)
clf
plot(spks)


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


[Te,Ee] = hmmtrain(spks+1,To,Eo);
qp_guess = hmmdecode(spks+1,Te,Ee);
q_guess = hmmviterbi(spks+1,Te,Ee);

%


figure(1)
clf
hold on
plot(spks)
plot(qp_guess(2,:),'k','LineWidth',1)
plot(q_guess-.8,'g','LineWidth',2)
hold off
