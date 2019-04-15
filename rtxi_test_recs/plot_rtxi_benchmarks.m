clc
clear
close all
%%

h5disp('hmm_gen_decode_rec1.h5')
%[a]=h5read('hmm_gen_decode_rec1.h5',"/Trial1/Synchronous Data/001 HmmGenerator with Custom GUI 11  Spike")
%[Data]=h5read('hmm_gen_decode_rec1.h5',"/Trial1/Synchronous Data/Channel Data");
%hmm_gen_decode_rec2_fr20_50_tr_p8_p4
[Data]=h5read('hmm_gen_decode_rec2_fr20_50_tr_p8_p4.h5',"/Trial1/Synchronous Data/Channel Data");


%%
%XL = NaN;%[0,2e4];

%base time unit: ns, 1e-9
base_time = 1e-9;
%others: us = 1e-6; ms = 1e-3;
time_unit = 'ms'; time_conv = base_time/1e-3;
time_unit = 'us'; time_conv = base_time/1e-6;




figure(1)
clf
subplot(3,1,1)
hold on
plot(Data(3,:)-.1,'b','LineWidth',2)
plot(Data(2,:),'g','LineWidth',2)
plot(Data(1,:),'k')
%xlim(XL);


hold off
subplot(3,1,2)
hold on

plot(log10(Data(4,:)*time_conv),'LineWidth',3) %Comp time in ns
%plot(Data(5,:),'LineWidth',3) %peak RT period
%ylim([0,200])
hold off
%xlim(XL);
ylabel('compute time [\mus]')

subplot(3,1,3)


%xlim(XL);


figure(2)
clf
histogram(log10(Data(4,:))-3)