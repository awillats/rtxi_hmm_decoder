clc
clear
close all
set(0,'DefaultAxesFontSize',15)
%%

h5disp('hmm_gen_decode_rec1.h5')
%[a]=h5read('hmm_gen_decode_rec1.h5',"/Trial1/Synchronous Data/001 HmmGenerator with Custom GUI 11  Spike")
[Data]=h5read('hmm_gen_decode_rec1.h5',"/Trial1/Synchronous Data/Channel Data");
%hmm_gen_decode_rec2_fr20_50_tr_p8_p4
[Data1]=h5read('hmm_gen_decode_rec2_fr20_50_tr_p8_p4.h5',"/Trial1/Synchronous Data/Channel Data");


%%
XL = [0,2e4];

%base time unit: ns, 1e-9
base_time = 1e-9;
%others: us = 1e-6; ms = 1e-3;
time_unit = 'ms'; time_conv = base_time/1e-3;
time_unit = '\mus'; time_conv = base_time/1e-6; 


compt = Data(4,:)*time_conv;
compt1 = Data1(4,:)*time_conv;


%f = @(x) log10(x); fi = @(y) 10.^y; ftxt1 = 'log10('; ftxt2 = ')';
f = @(x) (x); fi = @(y) y; ftxt1 = ''; ftxt2 = '';


figure(1)
clf
subplot(2,1,1)
hold on
plot(Data(1,:),'k')
plot(Data(2,:),'g','LineWidth',2)
plot(Data(3,:)-.1,'b','LineWidth',2)

plot(Data(2,:),'g','LineWidth',2)
plot(Data(1,:),'k')
hold off

xlim(XL);
legend('spikes','true state','decoded state')


subplot(2,1,2)
hold on

plot(f(compt1),'LineWidth',3) %Comp time in ns
plot(f(compt),'LineWidth',3) %Comp time in ns

%plot(Data(5,:),'LineWidth',3) %peak RT period
ylim(f([0,2e2*1e3*time_conv]))
legend('trial 1','trial 2')
hold off
xlim(XL);


ylabel(['compute time [',ftxt1,time_unit,ftxt2,']'])

set(gcf,'Position',[         312         528        1006         270]);


%xlim(XL);


figure(2)



clf

[~,edges] = histcounts(log10(compt));
hold on
histogram((compt), 10.^(edges))
histogram((compt1), 10.^(edges))
hold off

xlabel(['compute time [',time_unit,']'])

%xlim([5,5.5]+log10(time_conv))


xlim( ([power(10,5),power(10,5.5)]*time_conv))
title('Compute time distribution')

set(gca,'XScale','log')

set(gcf,'Position',[         312         240        1006         214]);










