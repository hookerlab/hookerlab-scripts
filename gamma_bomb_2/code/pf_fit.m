function [best_fit, GOF_TABLE, fits] = pf_fit(met_ffile,end_lin_time,extrap_time,sf)
%% Written by Tom Morin
% Fit Parent Fraction data according to four models: hill, lin2exp, exp, &
% power

% INPUT: 
% met_ffile: a bld file containing parent fraction data
% end_lin_time: the time where the curve switches from lin to exp in the
%               lin2exp model
% extrap_time: the end time for the data
% sf: # significant figures to report in the output bld files
% fit_type: the type of model used to fit the PF data

% OUTPUT:
% - 4 plots for containing the four separate fits
% - 4 bld files with fit data
% - A table summarizing the goodness of fit

%% DEFINED CONSTANTS
std_cutoff = 1.5; % Outliers are classified as any point outside of std_cutoff standard deviations from the fit

%% Read in the data file & create x,y matrix of data (time = x, met = y)
A=dlmread(met_ffile,'\t',1,0);
if nargin<2 || isempty(end_lin_time)
    end_lin_time=A(2,1); % This is the time at which the curve will switch from linear to expontential
end

if nargin<4 %Figure out how many decimal places are used
    teststr=num2str(A(2,2));
    splits=regexp(teststr,'\.','split');
    sf=size(splits{2},2);
end
names=textread(met_ffile,'%s',1,'delimiter','\n');
hdrnames=regexp(names,'\t','split');

time=A(:,1);met=A(:,2);

if nargin<3 || isempty(extrap_time)
extrap_time=time(end);
end

%% Plot the Data, Fit the Curve, Denote GOF, & Save Output BLD file
figure('Name', 'Parent Fraction Fits');
fits = {'hill'; 'lin2exp'; 'exp'; 'power'};
for m=1:size(fits)
    fit_type = fits{m};
    % Set options depending on fit_type
    switch fit_type
        case 'hill'
            final_read = A(end, 2);
            c = 1 - final_read;
            equation = strcat('1 - ((', num2str(c), '*(x^a))/(b+(x^a)))');
            ffun = fittype(equation);
            
            options = fitoptions( ffun );
            options.Display = 'Off';
            options.Lower = [1 0];
            options.StartPoint = [0.64306354724818 0.506030011368413];
            iter = 1;
        case 'lin2exp'
            %Y(t)=A1*t+A2                                    0<t<tau
            %Y(t)=(A1*tau+A2+A3)/2*exp(-lambda1*(t-tau))+(A1*tau+A2-A3)/2*exp(-lambda2*(t-tau)) ;            t<tau
            ffun=fittype(['linear_2exp_model(A1,1,A3,' num2str(end_lin_time) ',lambda1,lambda2,x)']);
            
            options=fitoptions(ffun);
            options.StartPoint=[(0.5486-1)/589 0 0.007367 0.0003396];
            options.MaxIter=1000;
            options.MaxFunEvals=1000;
            options.Lower=[-Inf 0 0 0];
            options.Upper=[0 Inf Inf Inf];
            iter = 2;
        case 'exp'
            equation = '(a.*exp(b.*x))+((1-a).*exp(d.*x))';
            ffun = fittype(equation);
            
            options = fitoptions( ffun );
            options.Display = 'Off';
            options.Lower = [0 -Inf -Inf];
            options.StartPoint = [0 0 0];
            options.Upper = [Inf Inf Inf];
            iter = 3;
        case 'power'
            ffun = fittype( '1./((1+(a.*(x.^b))).^c)' );
            options = fitoptions( ffun );
            options.Display = 'Off';
            options.Lower = [0 0 0];
            options.StartPoint = [0.228976968716819 0.91333736150167 0.152378018969223];
            options.Upper = [Inf Inf Inf];
            iter = 4;
    end
    
    % Fit the data
    [fit1,gof1]=fit(time,met,ffun,options);
    
    % Adjust for Outliers (data outside 1.5 stdevs of the fitted curve)
    fdata = feval(fit1,time);
    I = abs(fdata - met) > std_cutoff*std(met);
    outliers = excludedata(time,met,'indices',I);
    options.Exclude=outliers;
    [fit2,gof2] = fit(time,met,ffun,options);
    
    % Plot the data
    subplot(2,2,iter);
    if sum(outliers) > 0
        plot(fit2,'r-', time, met, '.b',outliers,'r*');
    else
        plot(fit2, 'r-', time, met, '.b');
    end
    hold on;
    %plot(fit1, 'b:');  % This is the original fit, before outliers deleted
    
    % Set up Legend
    if iter == 1 && sum(outliers) > 0
        legend('Data', 'Oultiers', 'Fit', 'Location', 'NorthEast' );
    elseif iter == 1
        legend('Data', 'Fit', 'Location', 'NorthEast');
    else
        legend 'off';
    end
    
    % Label axes
    xlabel('Time (s)', 'FontSize', 7);
    ylabel('Parent Fraction', 'FontSize', 7');
    set(gca, 'FontSize', 7);
    title([upper(fit_type) ' Fit of Parent Fraction'], 'FontSize', 10, 'FontWeight', 'bold');
    
    % Denote Goodness of Fit Data
    GOF_TABLE(iter,1) = gof2.rsquare;
    GOF_TABLE(iter,2) = gof2.adjrsquare;
    GOF_TABLE(iter,3) = gof2.dfe;
    
    % Determine Best Fit & Pass it back for met correction
    if iter == 1
        best_fit = fit2;
    elseif abs(GOF_TABLE(iter,1)-1) < abs(GOF_TABLE(iter-1,1)-1)
        best_fit = fit2;
    end
    
    % Save the fitted data to a bld file
    fmet=fit2(time(1):extrap_time);
    [metpath,metname,metext]=fileparts(met_ffile);
    print_list(hdrnames{:},[[time(1):extrap_time]', fmet],fullfile(metpath,strcat(metname,'_',fit_type,metext)),sf);
end
end