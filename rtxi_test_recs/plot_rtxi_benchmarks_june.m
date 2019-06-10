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


%basePath = 'rt_batch2/hmm_dec_test_vm1_bl';

basePath='~/Documents/Research/Data/plds_char_june5/stac_plds_x'
midPath = '_bufflen';

readFun = @(num1,num2) h5read([basePath,num2str(num1),midPath,num2str(num2),'.h5'],"/Trial1/Synchronous Data/Channel Data");
readFun2 = @(num1,num2) h5read([basePath,num2str(num1),midPath,num2str(num2),'_reboot.h5'],"/Trial1/Synchronous Data/Channel Data");

channelKey = {'plant.x',...
    'ref',...
    'hmm1',...
    'hmm2',...
    'decode state',...
    'X_{est}',...
    'comp',...
    'rt per'};
    

xlens = [2,3,4,5,6,7,8];
bufflen = [100,300,1000,2000];
modifier = {'','_reboot'};

%{

D1 = readFun(2,100);
D2 = readFun2(2,300);
D3 = readFun(2,1000);
D4 = readFun(2,2000);
DD = {D1,D2,D3,D4};
sweep_vec = bufflen;
sweep_str = 'buffer length';

YL1 = 10.^[-1.5,0.5]
YL2= 10.^[-1.5,0.5];

%}


DD = {};
for i=xlens
    DD{end+1} = readFun(i,1000);
end
sweep_vec = xlens;
sweep_str = 'size(X-LDS)'



%YL1= 10.^[-.5,-.15];
YL2= 10.^[-.5,0.5];
YL1=YL2;
%{
%}


work_loc = '';%used as title 

%%
stat_idx=11;


XL = [0,2e4];
npts_distr = 5e2;
maxt = 1e4;

%base time unit: ns, 1e-9
base_time = 1e-9;
%others: us = 1e-6; ms = 1e-3;
time_unit = 'ms'; time_conv = base_time/1e-3;
%time_unit = '\mus'; time_conv = base_time/1e-6; 


colors = lines(length(DD));

figure(1)
clf

hold on
i=1

D = DD{i};
dy = (D(end-1,:)*time_conv);
x = sweep_vec(i);
h1=plot(x, dy(1),'k.');
h2=plot(x,(mean(dy)),'o','Color',colors(i,:),'MarkerSize',15,'LineWidth',2);
h3=plot(x,max(dy),'x','Color',colors(i,:),'MarkerSize',15);


for i = 1:length(DD)
    D = DD{i};
    dy = (D(end-1,:)*time_conv); %stat_idx
    x = sweep_vec(i);
    plot(x, dy(1:npts_distr),'k.','HandleVisibility','off');
    plot(x,(mean(dy)),'o','Color',colors(i,:),'MarkerSize',15,'LineWidth',2,'HandleVisibility','off');
    plot(x,max(dy),'x','Color',colors(i,:),'MarkerSize',15,'HandleVisibility','off');
    

end

plot([min(sweep_vec)/2,max(sweep_vec)*2],[1,1],'k--','LineWidth',1);
set(gca,'XScale','log','Yscale','log')
%ylim([1e-3,10^1.5])
ylim(YL1)

set(gcf,'Position',[   262   471   359   332]);


legend('data','mean','max','1ms RT period','Location','southeast')

xlabel(sweep_str)
ylabel(['compute time [',time_unit,']'])
title(['StAC compute time as a function of ',sweep_str],'FontSize',13)

%%
figure(2)
clf
nD = length(DD);

%subplot(nD,1,1)
title(work_loc)
for i=1:nD
    %subplot(nD,1,i)
    D = DD{i};
    dy = (D(end-1,:)*time_conv);
    
    ti = [1:maxt];%length(dy)];
    
    
    hold on
    plot(ti,dy(ti),'Color',colors(i,:),'LineWidth',2);
    
    plot([1,max(ti)],[1,1],'k--')
    
    set(gca,'Yscale','log')
    ylim(YL2)
    
   % legend(sprintf('bufflen=%i',sweep_vec(i)),'Location','southeast')

end
%legend(sweep_vec);%,'Location','southeast')
xlabel('time [samples]')
ylabel(['compute time [',time_unit,']'])

set(gcf,'Position',[    621   474   788   327]);





