function [fitobject, fit_metric, models]=feng_fit3(bld_ffile,endtime,met_fit,exclude_from,sf,options)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SCRIPT TO FIT BLOOD DATA WITH FENG & L3 MODELS
%% Written by Daniel Chonde
%% Req:blood file (*.bld)
%% Output: blood file (*_feng.bld)
%% Written: 08/12/2012 Updated:
% Will also now return statistical gof data (goodness of fit)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script reads in a .bld file and fits Feng's model to the blood data.
%
% example:
% feng_fit(bld_ffile,endtime)
%   bld_ffile=path to a .bld file
%   endtime=time to interpolate model to in seconds
%   sf=number of decimal places to write to file
%
% feng_fit(bld_ffile) fits the model and interpolates the data to the
% last timepoint in the bld file
%
% feng_fit(bld_ffile,endtime) fit the model and interpolate the data to
% an arbitrary timepoint given by endtime, where endtime is in seconds.
%
fit_metric = zeros(0,1);

if nargin<4, exclude_from='';end

A=dlmread(bld_ffile,'\t',1,0);
if A(1,1)~=0, A=[0 0;A];end %add t=0 activity=0, if not already present

if exclude_from
    A(find(A(:,1)>exclude_from,1,'first'):end,:)=[];
end

if nargin<5 || isempty(sf) %%Figure out how many decmal places are used
    %fid=fopen(bld_ffile,'r')
    %test=textscan(fid,'%s')
    %fclose(fid)
    teststr=num2str(A(end,2));
    splits=regexp(teststr,'\.','split');
    sf=size(splits{2},2);
end
names=textread(bld_ffile,'%s',1,'delimiter','\n');
hdrnames=regexp(names,'\t','split');

time=A(:,1);plasma=A(:,2);
num_points = length(time);
assignin('base','num_points',num_points);
if nargin<2, endtime=max(time);end
if nargin<3, met_fit=fit([1:10]',ones(1,10)','poly1');end % if not met data, construct a straight line
%% Remove points after 5 minutes that go up greater than 5%
cutofft=find(time>300,1,'first');
iter=1;
num_outliers = 0;
while 1
    kvals=[zeros(cutofft-1,1);(plasma(cutofft:end).*met_fit(time(cutofft:end))-plasma(cutofft-1:end-1).*met_fit(time(cutofft-1:end-1)))./(plasma(cutofft-1:end-1).*met_fit(time(cutofft-1:end-1)))>0.05];
    if iter==1
        ktime=time(find(kvals));
        kplasma=plasma(find(kvals));
    else
        ktime=[ktime;time(find(kvals))];
        kplasma=[kplasma;plasma(find(kvals))];
    end
    num_outliers = length(kvals);
    time(find(kvals))=[];
    plasma(find(kvals))=[];
    iter=iter+1;
    if ~any(kvals)
        num_outliers = 0;
        break;
    end
end
assignin('base', 'num_outliers', num_outliers);

%%Quick Linear interpolation so we can have that file (used by Jean Logan)
plasma_linear=interp1(time,plasma,time(1):endtime,'linear','extrap');
plasma_linear(plasma_linear<0)=0;


%% Fit Models
models={'feng_model_aif(a,b,c,d,e,f,g,x)','Feng'
    'lin_3exp_model_aif(a,b,c,d,e,f,g,h,jj,x)','L3Exp'};

%Check if there is an options.Choice--this is my workaround to allow you to
%select a single fit model
if exist('options','var') && isfield(options,'Choice'),models(:,~cellfun(@(x) strcmpi(options.Choice,x),models(:,2)))=[];end

for ppp=1:size(models,1)
    ffun=fittype(models{ppp,1});
    if nargin<6
        options=fitoptions(ffun);
        options.MaxIter=1000;
        options.MaxFunEvals=1000;
        switch models{ppp,2}
            case 'Feng'
                options.Lower=[0 -1 0 -1 0 -1 0];
                options.Upper=[500 0 500 0 500 0 time(find(plasma==max(plasma)))+30];
                %options.Weights=sqrt(plasma)/sum(sqrt(plasma));
            case 'L3Exp'
                options.MaxFunEvals=1000;options.Lower=[0 0 0 0 0 0 0 0 0 ];
                options.Upper=[1000 1 1000 1 1000 1 30 time(find(plasma==max(plasma))) 30]; 
        end
    end
    
    for m=1:2
        if m==1
            switch models{ppp,2}
                case 'Feng'
                    if isempty(options.StartPoint),options.StartPoint=[251/60,-2.1/60,5.8,-0.0104/60,1.879,-0.219/60,time(find(plasma==max(plasma)))-20];end
                case 'L3Exp'
                    if isempty(options.StartPoint),object.StartPoint=[60 .1 90 11 138 .02 10 1 1];end
            end
        else
            switch models{ppp,2}
                case 'Feng'            
            options.StartPoint=[fitobject.a,fitobject.b,fitobject.c,fitobject.d,fitobject.e,fitobject.f,fitobject.g];
                case 'L3Exp'
            options.StartPoint=[fitobject.a,fitobject.b,fitobject.c,fitobject.d,fitobject.e,fitobject.f,fitobject.g,fitobject.h,fitobject.jj];        
            end
        end
        
        [fitobject,gof]=fit(time,plasma,ffun,options);
        display(['Iteration ' num2str(m)])
        display(gof)
        display(fitobject)
    end
    
    fplasma=fitobject(time(1):endtime); 
    
    
    
    % ***SUBPLOT #1*** Plot data on Log Scale x-axis
    assignin('base', 'kplasma', kplasma);
    figure; subplot(2,2,1);
    if(size(kplasma)>0)
        plot(time,plasma,'xb');hold on;plot(ktime,kplasma,'*g');fplot(fitobject,[time(1) endtime],0.0001,'r');set(gca,'XScale','log');
        legend('Data','Outliers','Fitted Curve');
        legend off;
    else
        plot(time,plasma,'xb');hold on;plot(ktime,kplasma,'*g');plot(fitobject);title(strcat(models{ppp,2},' Model Fit'));
    end
    title(strcat(models{ppp,2},' Model Fit (Log Scale)'));
    xlabel('Time (s)','FontSize',7);ylabel('kBq/ml','FontSize',7);
    
    
    
    % ***SUBPLOT #2*** Plot data on regular x-axis
    subplot(2,2,2);
    if ~isempty(kplasma)
        plot(time,plasma,'xb');hold on;plot(ktime,kplasma,'*g');plot(fitobject);title(strcat(models{ppp,2},' Model Fit'))
        legend('Data','Outliers','Fitted Curve');
    else
        plot(time,plasma,'xb');hold on;plot(fitobject);
        legend('Data', 'Fitted Curve', 'Location', 'best');
    end
    xlabel('Time (s)','FontSize',7);ylabel('kBq/ml','FontSize',7);
    
    

    % Calculate integral for raw data (Crude approximation on graph)
    int_of_raw = zeros(length(time),1);
    raw_data = cat(2, time, plasma);
    for m=1:length(int_of_raw)
        if m==1
            int_of_raw(m,1) = (raw_data(m,1)).*(raw_data(m,2));
        else
            int_of_raw(m,1) = ((raw_data(m,1)-raw_data(m-1,1)).*(raw_data(m,2))) + int_of_raw(m-1,1);
        end
        assignin('base', 'int_of_raw', int_of_raw);
%         int_of_raw(m,1) = trapz(raw_data(1:m,2));
    end
    % Calculate integral for fitted data
    fit_data = zeros(length(fplasma),2);
    for m=0:length(fplasma)-1
        fit_data(m+1,1) = m;
        fit_data(m+1,2) = fplasma(m+1,1);
    end
    int_of_fit = zeros(length(fplasma),1);
    for m=1:length(int_of_fit)
        int_of_fit(m,1) = trapz(fit_data(1:m,2));
    end
    
    
    % ***SUBPLOT #3*** Plot the integral of the fit compared to the 
    % integral of the raw data
    subplot(2,2,3);
    hold on;
    plot(fit_data(:,1),int_of_fit(:,1),'r');
    plot(time,int_of_raw,'b');
    % Adjust Plot Format
    title('Integral of Fit vs. Crude Approximation', 'FontSize', 9, 'FontWeight', 'bold');
    %legend('Integral of Fit', 'Crude Approximation', 'Location', 'best');
    xlabel('Time (s)', 'FontSize', 7); ylabel('Integral', 'FontSize', 7);
    set(gca, 'FontSize', 7, 'XScale', 'log');
    
    
    
    % ***SUBPLOT #4*** Integrals on linear x-scale
    subplot(2,2,4);
    plot(fit_data(:,1),int_of_fit(:,1),'r');
    hold on;
    plot(time,int_of_raw,'b');
    title('Integral of Fit vs. Crude Approximation', 'FontSize', 9, 'FontWeight', 'bold');
    legend('Integral of Fit', 'Crude Approximation', 'Location', 'SouthEast');
    xlabel('Time (s)', 'FontSize', 7); ylabel('Integral', 'FontSize', 7);
    set(gca, 'FontSize', 7);
    
    fit_metric(end+1) = evaluate_fit(int_of_fit,int_of_raw);
    
    
    
    
    % Create textbox to display "fit metric"
    annotation(gcf,'textbox',...
        [0.841619718309864 0.00418410041840576 0.147112676056338 0.0719487425300029],...
        'String',{'Fit Metric: ' num2str(fit_metric(1, ppp))},...
        'FontWeight','bold',...
        'FitBoxToText','on',...
        'BackgroundColor',[1 1 1]);
    
    % Save the graph as an image
    drawnow;
    set(gcf, 'Position', [50 50 840 630]);
    saveas(gcf,fullfile(pwd,regexprep(bld_ffile,'\.bld',['_' models{ppp,2} '.bmp'])))

    % Save the BLD files
    [bldpath,bldname,bldext]=fileparts(bld_ffile);
    print_list(hdrnames{:},[[time(1):endtime]', fplasma],fullfile(bldpath,strcat(bldname,['_' models{ppp,2}],bldext)),sf);
end
    print_list(hdrnames{:},[[time(1):endtime]', plasma_linear'],fullfile(bldpath,strcat(bldname,'_linear',bldext)),sf);
    disp(fit_metric);
end
    
    
    
function fit_metric = evaluate_fit(int_of_fit,int_of_raw)
fit_metric = nan;
% Compares the integral of the fit data and the integral of the raw data to
% determine goodness of fit.
% Returns a "fit metric"

% Calculate integral for the fit data
fit_metric = log10(abs(int_of_raw(end,1) - int_of_fit(end,1)));
disp 'FIT METRIC';
disp(fit_metric);
end