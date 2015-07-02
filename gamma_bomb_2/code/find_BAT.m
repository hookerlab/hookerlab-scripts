function InjectionStart=find_BAT(head_curve1,crop_counts,save_img)
if nargin<2
    %crop_counts=300;
    crop_counts=300;
end
if nargin<3,save_img=1;end
if length(head_curve1)>crop_counts
head_curve=head_curve1(1:crop_counts);
else
    head_curve=head_curve1;
end
%% Clean up the head curve so we can estimate the injection time
signoise=nanmean(head_curve(1:5));
if isnan(signoise), signoise=0;end
head_curve=head_curve-signoise; %consider the first 5 points as noise
head_curve(head_curve<0)=NaN;
head_curve=pchip(1:size(head_curve,1),head_curve,[1:size(head_curve,1)]');
%Quick moving average filter to remove the noise
b=ones(1,16)/16;
a=1;
filteredData=filter(b,a,head_curve);
dtest=(filteredData(2:end)-filteredData(1:end-1))./(filteredData(2:end)+filteredData(1:end-1));
fdtest=filter(ones(1,5)/5,a,dtest);
sfdtest=fdtest;sfdtest(filteredData<1000)=0;
[~,I]=max(sfdtest);
assignin('base', 'a', a);
assignin('base', 'b', b);
%g=@(a,b,c,d,e,x) model_aif(a,b,c,d,e,x);
%ffun=fittype(g);
ffun=fittype('model_aif(a,b,c,d,e,x)');

assignin('base', 'a_after', a);
assignin('base', 'ffun', ffun);

options=fitoptions(ffun);

assignin('base', 'options', options);

%options.StartPoint=[1,30,min(head_curve(head_curve>0)),(max(head_curve(head_curve>0 &head_curve<Inf))-min(head_curve(head_curve>0)))/10,(head_curve(ceil(length(head_curve)*1/2))-head_curve(end))/length(head_curve)];
x_val=[0:size(head_curve,1)-1]';
x_val_fit=x_val(head_curve>=0 &head_curve<Inf);
head_curve_fit=head_curve(head_curve>=0 &head_curve<Inf);
%options.StartPoint=[1,70,min(head_curve_fit),(max(head_curve_fit)-min(head_curve_fit))/10,(head_curve_fit(end)-head_curve_fit(find(x_val_fit<ceil(x_val_fit(end)*1/2),1,'last')))/x_val_fit(end)];
options.StartPoint=[I,10,min(head_curve_fit),(max(head_curve_fit)-min(head_curve_fit))/10,(head_curve_fit(end)-head_curve_fit(find(x_val_fit<ceil(x_val_fit(end)*1/2),1,'last')))/x_val_fit(end)];
options.MaxIter=1000;
options.MaxFunEvals=1000;
%options.Lower=[0 0 -Inf -Inf -Inf];
options.Lower=[0 0 0 -(max(head_curve_fit)-min(head_curve_fit)) -(max(head_curve_fit)-min(head_curve_fit))];
%options.Upper=[length(head_curve) length(head_curve) Inf Inf Inf];
options.Upper=[300 300 max(head_curve_fit) (max(head_curve_fit)-min(head_curve_fit)) (max(head_curve_fit)-min(head_curve_fit))];
options.Robust='LAR';
%% Force start time to be point where trues>1000
%options.Lower=[x_val_fit(find(head_curve_fit>=100,1,'first'))-.1 0 min(head_curve_fit) -(max(head_curve_fit)-min(head_curve_fit)) -(max(head_curve_fit)-min(head_curve_fit))];
%options.Upper=[x_val_fit(find(head_curve_fit>=100,1,'first')) 300 max(head_curve_fit) (max(head_curve_fit)-min(head_curve_fit)) (max(head_curve_fit)-min(head_curve_fit))];

%%
[fitobject,gof]=fit(x_val_fit,head_curve_fit,ffun,options);

assignin('base', 'head_curve_fit', head_curve_fit);
assignin('base', 'x_val_fit', x_val_fit);
assignin('base', 'fitobject', fitobject);
assignin('base', 'a_fitobject', fitobject.a);

if fitobject.a>0 && fitobject.d>0
InjectionStart=ceil(fitobject.a);
else
InjectionStart=0;    
end
if save_img
figure('Position',[680   558   560*2   420]);%figure;
for gg=1:2
subplot(1,2,gg);plot(0:length(head_curve)-1,head_curve);
hold on
fplot(fitobject,[0,length(head_curve)-1],'r');
set(get(gca,'XLabel'),'String','Time (sec)')
set(get(gca,'YLabel'),'String','Counts')
set(get(gca,'Title'),'String',['Bolus Arrival Time Pick-off T=' num2str(InjectionStart)])
if fitobject.a>0 && fitobject.d>0 && gg==1
xlim([0,300])
else
    xlim([0,20+fitobject.a])
end
end
legend('head curve','fit','Location','NorthWest');
%saveas(gcf,'BAT.pdf');
set(gcf,'PaperPositionMode','auto','PaperOrientation','landscape');print(gcf,'-dpdf','BAT.pdf')
end

end