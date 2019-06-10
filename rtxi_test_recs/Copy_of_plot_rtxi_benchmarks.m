clc
clear
close all
set(0,'DefaultAxesFontSize',15)
%%
%{
h5disp('hmm_gen_decode_rec1.h5')
%[a]=h5read('hmm_gen_decode_rec1.h5',"/Trial1/Synchronous Data/001 HmmGenerator with Custom GUI 11  Spike")
[Data]=h5read('hmm_gen_decode_rec1.h5',"/Trial1/Synchronous Data/Channel Data");
%hmm_gen_decode_rec2_fr20_50_tr_p8_p4
[Data1]=h5read('hmm_gen_decode_rec2_fr20_50_tr_p8_p4.h5',"/Trial1/Synchronous Data/Channel Data");
%}


basePath = 'rt_batch2/hmm_dec_test_vm1_bl';
readFun = @(str) h5read([basePath,str,'.h5'],"/Trial1/Synchronous Data/Channel Data");

D1 = readFun('30');
D2 = readFun('94');
D3= readFun('300');
D4 = readFun('948');
D5 = readFun('3k');

DD = {D1,D2,D3,D4,D5};
bufflen = [30,94,300,948,3000];
work_loc = 'on VM';


%{
basePath = '';
readFun = @(str) h5read([basePath,str,'.h5'],"/Trial1/Synchronous Data/Channel Data");

DD = {readFun('hmm_gen_decode_rec1'),readFun('hmm_gen_decode_rec1')}
bufflen = [300,300];

work_loc = 'in TDT room';
%}

%%
XL = [0,2e4];

%base time unit: ns, 1e-9
base_time = 1e-9;
%others: us = 1e-6; ms = 1e-3;
time_unit = 'ms'; time_conv = base_time/1e-3;
%time_unit = '\mus'; time_conv = base_time/1e-6; 

comp_time_idx=4;


colors = lines(length(DD));

figure(1)
clf

hold on
i=1

D = DD{i};
dy = (D(comp_time_idx,:)*time_conv);
x = bufflen(i);
h1=plot(x, dy(1),'k.');
h2=plot(x,(mean(dy)),'o','Color',colors(i,:),'MarkerSize',15,'LineWidth',2);
h3=plot(x,max(dy),'x','Color',colors(i,:),'MarkerSize',15);


for i = 1:length(DD)
    D = DD{i};
    dy = (D(comp_time_idx,:)*time_conv);
    x = bufflen(i);
     plot(x, dy(1:5e2),'k.','HandleVisibility','off');
    plot(x,(mean(dy)),'o','Color',colors(i,:),'MarkerSize',15,'LineWidth',2,'HandleVisibility','off');
    plot(x,max(dy),'x','Color',colors(i,:),'MarkerSize',15,'HandleVisibility','off');
    

end

plot([min(bufflen)/2,max(bufflen)*2],[1,1],'k--','LineWidth',1);
set(gca,'XScale','log','Yscale','log')
ylim([1e-3,10^1.5])



legend('data','mean','max','1ms RT period','Location','southeast')

xlabel('Buffer length')
ylabel(['compute time [',time_unit,']'])
title('HMM decoder compute time as a function of buffer length','FontSize',13)

%%
figure(2)
clf
nD = length(DD);

subplot(nD,1,1)
title(work_loc)
for i=1:nD
    subplot(nD,1,i)
    D = DD{i};
    dy = (D(comp_time_idx,:)*time_conv);
    
    ti = [1:1e4];%length(dy)];
    
    
    hold on
    plot(ti,dy(ti),'Color',colors(i,:),'LineWidth',2);
    
    plot([1,max(ti)],[1,1],'k--')
    
    set(gca,'Yscale','log')
    ylim([1e-5,10^1.5])
    
    legend(sprintf('bufflen=%i',bufflen(i)),'Location','southeast')

end
xlabel('time [samples]')
ylabel(['compute time [',time_unit,']'])

%{
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

%}








