%% Gamma Bomb! 2.0 Blood Data Report
%% Participant Information
% This section displays important demographic information about the 
% participant and gives some generic information about the present study.
%%
[~,~,chart] = xlsread(dose_info);
assignin('base', 'chart', chart);
name = '';
start=regexp(participant, ligand, 'start');
for m=start(1,1):(start(1,1)+11) 
    name = strcat(name, participant(m));
end
disp(strcat('Participant #:.......',name));
disp(strcat('Dose Info Sheet:.....',dose_info));
hour = floor(toi_time./3600);
minute = floor(mod(toi_time,3600) ./ 60);
second = floor(mod(mod(toi_time,3600),60));
t_hour = num2str(hour);
t_minute = num2str(minute);
t_second = num2str(second);
if hour < 10
    t_hour = strcat('0',num2str(hour));
end
if minute < 10
    t_minute = strcat('0',num2str(minute));
end
if second < 10
    t_second = strcat('0',num2str(second));
end
disp(' ');
disp(strcat('TOI:.........................',t_hour,':',t_minute,':',t_second));
disp(strcat('BAT Offset...................', num2str(batoffset), ' sec'));
if isnan(chart{16,3})
    radiotracer = tracer;
else
    radiotracer = chart{16,3};
end
disp(['Radioligand:.................' radiotracer '- ' ligand]);
disp(' ');
if isnan(chart{2,10})
    weight = 'Unavailable';
else
    weight = [num2str(chart{2,10}) ' lbs'];
end
disp(strcat('Participant Weight...........', weight));
if isnan(chart{5,10})
    height = 'Unavailable';
else
    height = [num2str(chart{5,10}) ' in'];
end
disp(strcat('Participant Height...........', height));
if isnan(chart{8,10})
    sex = 'Unavailable';
else
    sex = upper(chart{8,10});
end
disp(strcat('Participant Sex..............', sex));
if isnan(chart{11,10})
    byear = 'Unavailable';
else
    byear = num2str(chart{11,10});
end
disp(strcat('Participant Birth Year.......', byear));
disp(' ');

best = min(abs(models_gof));
best_model_i = nan;
for m=1:length(models_gof)
    if models_gof(m) == best
        best_model_i = m;
    end
end
best_model = models(best_model_i, 2);
disp(strcat('Best TAC Model...............', best_model));
best_fit_i = nan;
best = max(abs(GOF_TABLE(:,1)));
for m=1:length(GOF_TABLE)
    if GOF_TABLE(m) == best
        best_fit_i = m;
    end
end
best_fit = upper(pf_fits(best_fit_i,1));
disp(strcat('Best Parent Fraction Fit.....', best_fit));
%% 
% --------------------------------------------------------------------------------------------------------------------------
%% Blood Time Activity Curve (TAC) Fits
% _Current analysis uses two kinetic models to interpolate the Time Activity
% Curve:_ 
%
% # Feng Fit 
% # Linear to 3-Exponential (L3Exp) Fit
%
% _During this analysis, outliers were removed prior to curve-fitting.  Outliers are
% classified as any point after 5 minutes that increased greater than 5
% percent OR as any point that prematurely approaches zero._
%
%%
disp(['Number of Outliers: ' num2str(num_outliers+num_deleted)]);
disp(['Number of Points Used in Analysis: ' num2str(num_points)]);
for m=1:3
    disp(' ');
end
%%
%
% *Goodness of Fit*
%
% The table below summarizes the goodness of fit of the two TAC Models.
% The fit metric represents the space between the fitted curve and the raw
% data.  It is calculated according to the equation:
%
%%
%
% $M = \log ( |\int_{0}^{t} x dx - \int_{0}^{t} x' dx |)$
%
% _where:_ 
%
% * $M$ = _goodness of fit_
% * $t$ = _duration of the blood data (s)_
% * $x$ = _raw data points_ 
% * $x'$ = _fitted data_
%
% _According to the metric, a perfect fit would yeild M = 0.  The "best fit"
% will have a value M closest to 0._
%
%%
hdrs = '';
types = models(:,2);
for m=1:size(types)
    if m==1
        hdrs = [types(1)];
    else
        hdrs = [hdrs ' ' types(m)];
    end
end
printmat(models_gof, 'Model Goodness of Fit', 'Fit_Metric', 'Feng_Fit L3Exp_Fit');
disp(' ');
disp(['Best TAC Model: ' best_model]);

%%
% *Feng Model*
%
% <<plasma_art_Feng.bmp>>
%
% *L3Exp Model*
%
% <<plasma_art_L3Exp.bmp>>
%
%% 
% --------------------------------------------------------------------------------------------------------------------------
%% Summary of Parent Fraction Fit Statistics
% _The Parent Fraction has been fitted to four different curves:_
% Hill Fit, Linear to Exponential Fit (Lin2Exp), Exponential Fit (Exp), and
% Power Fit.
%
%%
printmat(GOF_TABLE, 'Parent Fraction Fit Stats', 'Hill_Fit Lin2Exp_Fit Exponential_Fit Power_Fit',...
 'Rsquare Adj_RSquare DFE');
disp(' ');
disp(['Best Parent Fraction Fit: ' best_fit]);
cd (csv_path);
%% Parent Fraction Fits
%
% <<parentfraction_fits.bmp>>
%
%% Histograms for Parent Fraction Data Points
% _Each histogram below represents the blood data for single the Parent
% Fraction Data Point indicated by the graph's title.  Red bars show
% metabolite data and blue bars show the parent data._
%
% <<histograms_1.bmp>>
%
% <<histograms_2.bmp>>
%
%%
if population_bool
    disp('Parent Fraction calculated from Population data.  Histograms unavailable.');
end

%%
% GammaBomb! 2.0 - Developed at the Hooker Research Group - MGH Martinos Center - Boston, MA