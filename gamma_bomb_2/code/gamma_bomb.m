%  patient_AIF_gamma_read.m
%  Author: Spencer Bowen
%  Lab Group: Catana
%  Date: 09-06-12
%  Read automatic gamma counter data for AIF arterial and venous whole blood and plasma samples and
%  sort into a readable format.
%  inputs:   template_file = name of csv file with automatic gamma counter sample information
%	     csv_file      = name, including directory, of the csv file with the first set of
%			     sample measurements (assumes csv files numeric with sequential values)
%	     csv_out       = name of the csv file to write the compiled data to
%
%
%  Modified By Tom Morin 
%  5/01/15 - Modified to print results to a single html/PDF file
%  5/20/15 - Added Power, Exponential, & Hill Fits to Parent Fraciton Data
%  5/21/15 - Now displays BAT Offset (Bolus Arrival Time) in final report
%               and accounts for BAT in .bld output files
%  5/22/15 - More aesthetically pleasing final reports
%  5/27/15 - Delete points that prematurely approach zero in TAC
%  6/2/15  - Added histograms to show origin of parent fraction data
%  6/3/15  - Display integrals with Fit/L3Exp Fits & calculate custom metric
%  6/4/15  - State which fits/models are best in the final report.

function  gamma_bomb(template_file, csv_path, tracer, met_correct, dose_info, report_format, population_pf, bk_cps_value)
%% Check to see if a Final Report has already been created
exit_gamma_bomb = 0;
exit_gamma_bomb = check_overwrite(csv_path, population_pf);
if(exit_gamma_bomb == 1)
    disp('Exiting Gamma Bomb 2.0');
    return;
end

assignin('base', 'population_bool', population_pf);
assignin('base', 'tracer', tracer);

%% Define Constants
switch lower(tracer)
    case {'f-18'} %F-18
        half_life=60*120;
    case {'c-11'} %c-11
        half_life=20.38*60;
    otherwise
        error('unknown tracer.  Contact Ciprian')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define constants
% number of positions in the gamma counter racks
pos_num = 10;
max_samp= 10000;
csv_dat_str = '%d%s%s%d%d%d%d%d%f%s%f%f%f%s';
pa_col  = 1;
wa_col  = 2;
pv_col  = 3;
wv_col  = 4;
out_str = '%d,%d,%d,%s,%f,%d';
num_out_col = 6;
% strings describing output columns
out_hdr_str = {'Run ID','Rack','Pos','Measurement Time',...
    'Duration (sec)','F-18 350-600 keV Counts'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load parameters
current_dir = pwd;cd(csv_path);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Read in Template File
h = waitbar(0, 'Reading in Template Files - 0%');
[~,tube_code_mx,~]=xlsread(template_file,1);
[col_time_mx,~,~]=xlsread(template_file,2);
[tube_vol_mx,~,~]=xlsread(template_file,3);
[TOI,~,~]=xlsread(template_file,4);
toi_vec=datevec(TOI);
assignin('base', 'TOI', TOI);
toi_time=toi_vec(4)*3600+toi_vec(5)*60+toi_vec(6);
%assignin('base', 'toi_vec', toi_vec);
assignin('base', 'toi_time', toi_time);
InjectionStart=0;
update_waitbar(0.05, h, 'Calculating BAT (This may take a few minutes.)');
if exist(fullfile(home_dir,'PET','Frame1.lst.hdr'),'file')
    if exist(fullfile(home_dir,'PET','Sum','TAC_workspace.mat'),'file')
        display('using TAC to determine the start time and align the data to the PET')
        load(fullfile(home_dir,'PET','Sum','TAC_workspace.mat'),'InjectionStart');
        load(fullfile(home_dir,'PET','Sum','TAC_workspace.mat'),'Series_Duration');
    else
        display('No TAC workspace found--Reconstrucing Frame1.lst to get injection Start')
        c_dir=pwd;
        cd(fullfile(home_dir,'PET'));
        [Scanner_Duration, Series_Duration, frame_start_time, ...
            frame_stop_time, acquisition_start, lst_files, ...
            lst_files_whole]=TAC_sort_lst_mode(fullfile(home_dir,'PET'));
        TAC_process_data('Frame1');
        update_waitbar(0.1, h, 'Generating Head Curve...');
        file=fullfile(pwd, strcat('Frame1','_head_curve.s.hc')); %build fullfile name
        [head_curve,head_curve_trues]=generate_head_curve(file,Series_Duration);
        update_waitbar(0.2, h, 'Determining Injection Start Time');
        
        assignin('base', 'head_curve_trues', head_curve_trues);
        
        InjectionStart=find_BAT(head_curve_trues);
        update_waitbar(0.22, h, 'Deleting Frames');
        delete('Frame1*.lor*','Frame1*.s*')
        update_waitbar(0.24, h,'Changing Directory');
        cd(c_dir)
    end
    update_waitbar(0.26, h, 'Dipslaying Injection Start & Series Duration');
    display(['Injection Start: ' num2str(InjectionStart)]);
    display(['Series Duration: ' num2str(length(Series_Duration))]);
    update_waitbar(0.28, h, 'Determining extrap_time');
    extrap_time=length(Series_Duration);
    update_waitbar(0.3, h, 'Crunching some more numbers...');
    lst_hdr=read_i_hdr(fullfile(home_dir,'PET','Frame1.lst.hdr'));
    lst_startvec=datevec(lst_hdr.StudyTimeHhMmSs);
    lst_start=lst_startvec(4)*3600+lst_startvec(5)*60+lst_startvec(6);
    batoffset=(lst_start+InjectionStart)-toi_time;
    toi_time=toi_time+batoffset;
    assignin('base','InjectionStart', InjectionStart);
    assignin('base', 'lst_start', lst_start);
    assignin('base', 'batoffset', batoffset);
    assignin('base', 'toi_time', toi_time);
end
col_time_mx(1,:)=[];
tube_vol_mx(1,:)=[];
tot_samps=size(unique(find(~strcmpi(tube_code_mx,'E'))),1); %total number of non E
datev=datevec(col_time_mx);
secv=datev(1:end,4)*3600+datev(1:end,5)*60+datev(1:end,6);
col_time_mx=reshape(secv,size(col_time_mx))-toi_time;
%%

csv_files=ls(fullfile(csv_path,'*.csv'));
[~,csv_name,~]=fileparts(csv_files(1,:));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% open and read in csv files (filenames should end in consecutive numbers)
update_waitbar(0.35, h, 'Reading in CSV files');
csv_tot       = 0;
csv_start_num = str2num(csv_name);
csv_samp_tot  = 0;
fail=0;
readon = 1;
while readon
    csv_cur= fullfile(csv_path,[num2str(csv_start_num+csv_tot,'%06.0f') '.csv']);
    
    if ~exist(csv_cur,'file');
        fail=fail+1;
        if fail==2;
            break
        end
    else
        
        fid_in = fopen(csv_cur,'r');
        csv_dat= textscan(fid_in,csv_dat_str,'delimiter',',','HeaderLines',1,'EndOfLine','\n');
        fclose(fid_in);
        csv_samp_tot = csv_samp_tot + length(csv_dat{1});
        if csv_tot==0
            csv_comp_dat = csv_dat;
        else
            rack_offset=csv_comp_dat{6}(end);
            for cnti=1:14
                if cnti==6
                    csv_comp_dat{cnti} = [csv_comp_dat{cnti}; csv_dat{cnti}+rack_offset];
                else
                    csv_comp_dat{cnti} = [csv_comp_dat{cnti}; csv_dat{cnti}];
                end
            end
        end
    end
    
    if csv_samp_tot>=tot_samps
        readon=0;
    else
        csv_tot= csv_tot+1;
    end
    
end
assignin('base', 'csv_comp_dat', csv_comp_dat);

%% Construct other necessary matrices 
%(Take csv data and format it to tables that are the same dimensions as the one in the template file)
%Rack=row
%Pos=col
update_waitbar(0.4, h, 'Constructing matrices');
count_time_mx=zeros(size(tube_code_mx));
count_dur_mx=zeros(size(tube_code_mx));
t_counts_mx=zeros(size(tube_code_mx));
dev_cpm_mx=zeros(size(tube_code_mx));
t_counts_error_mx=zeros(size(tube_code_mx));

for m=1:size(csv_comp_dat{1},1)
    dv=datevec(csv_comp_dat{3}(m));
    count_time_mx(csv_comp_dat{6}(m),csv_comp_dat{8}(m))=dv(4)*3600+dv(5)*60+dv(6);
    count_dur_mx(csv_comp_dat{6}(m),csv_comp_dat{8}(m))=csv_comp_dat{9}(m);
    t_counts_mx(csv_comp_dat{6}(m),csv_comp_dat{8}(m))=csv_comp_dat{11}(m);
    dev_cpm_mx(csv_comp_dat{6}(m),csv_comp_dat{8}(m))=csv_comp_dat{12}(m);
    t_counts_error_mx(csv_comp_dat{6}(m),csv_comp_dat{8}(m))=csv_comp_dat{13}(m);
end

%% Construct blank scan matrix
Bpos=find(strcmpi(tube_code_mx','B'));
display(nargin)
if nargin==8
    bk_mx=ones(size(count_time_mx))*bk_cps_value;
elseif ~isempty(Bpos)
    blanks=zeros(size(tube_code_mx))';
    start_pos=1;
    t_counts_mx_p=(t_counts_mx./count_dur_mx)';
    for m=1:length(Bpos)
        blanks(start_pos:Bpos(m))=t_counts_mx_p(Bpos(m));
        start_pos=Bpos(m)+1;
    end
    %finish rest of positions
    blanks(blanks==0)=t_counts_mx_p(Bpos(end));
    bk_mx=blanks';
else
    bk_mx=zeros(size(count_time_mx));
end

%% Decay Correct Data
update_waitbar(0.45, h, 'Decaying Data');
elapsed_t_mx=count_time_mx-toi_time;
cps_dkc_mx=(t_counts_mx./count_dur_mx-bk_mx).*exp(log(2).*elapsed_t_mx/half_life);
kbq_ml_dkc_mx=cps_dkc_mx./tube_vol_mx*60/40;
%% Breakdown for Metabolite Correction
%
final_labels={};
file_name={};
if ~met_correct
    [tube_struct,t_labels]=sort_tube_codes(tube_code_mx,col_time_mx,kbq_ml_dkc_mx);
else
    kbq_ml_dkc_met_mx=kbq_ml_dkc_mx;
    kbq_ml_dkc_met_mx(find(strcmpi(tube_code_mx,'M')|strcmpi(tube_code_mx,'P')))=kbq_ml_dkc_mx(strcmpi(tube_code_mx,'M')|strcmpi(tube_code_mx,'P')).*tube_vol_mx(strcmpi(tube_code_mx,'M')|strcmpi(tube_code_mx,'P'));
    [tube_struct,t_labels]=sort_tube_codes(tube_code_mx,col_time_mx,kbq_ml_dkc_met_mx);
    % Metabolite Correction
    u_times=unique(tube_struct.M(:,1));
    for m=1:size(u_times,1)
        mets(m,1)=sum(tube_struct.M(find(tube_struct.M(:,1)==u_times(m)),2));
        parent(m,1)=sum(tube_struct.P(find(tube_struct.P(:,1)==u_times(m)),2));
        if isfield(tube_struct,'PA')
            plasma(m,1)=tube_struct.PA(find(tube_struct.PA(:,1)==u_times(m)),2);
        elseif isfield(tube_struct,'PV')
            plasma(m,1)=tube_struct.PV(find(tube_struct.PV(:,1)==u_times(m)),2);
        else
            error('For Metabolite correction either arterial or venous samples must be drawn. Contact Ciprian');
        end
    end
    total=mets+parent;
    met_ratio=parent./total;
    tube_struct.M=[0 1;u_times met_ratio];
    tube_struct=rmfield(tube_struct,'P');
    t_labels(cellfun(@(x) strcmpi(x,'P'),t_labels))=[];
end

update_waitbar(0.5, h, 'Generating TAC Data...');
for m=1:size(t_labels,1)
    switch lower(t_labels{m})
        case 'pa'
            final_labels=[final_labels,{'sample-time[seconds]';'plasma[kBq/cc]'}];
            file_name=[file_name,{'plasma_art.bld'}];
        case 'pv'
            final_labels=[final_labels,{'sample-time[seconds]';'plasma[kBq/cc]'}];
            file_name=[file_name,{'plasma_ven.bld'}];
        case 'wa'
            final_labels=[final_labels,{'sample-time[seconds]';'whole-blood[kBq/cc]'}];
            file_name=[file_name,{'whole-blood_art.bld'}];
        case 'wv'
            final_labels=[final_labels,{'sample-time[seconds]';'whole-blood[kBq/cc]'}];
            file_name=[file_name,{'whole-blood_ven.bld'}];
        case 'm'
            final_labels=[final_labels,{'sample-time[seconds]';'parent-fraction[1/1]'}];
            file_name=[file_name,{'parentfraction.bld'}];
        otherwise
    end
end

if (exist(fullfile(pwd,'parentfraction.bld'),'file') || ~met_correct) && (exist(fullfile(pwd,'whole-blood_ven.bld'),'file') || exist(fullfile(pwd,'whole-blood_art.bld'),'file') || exist(fullfile(pwd,'plasma_ven.bld'),'file') || exist(fullfile(pwd,'plasma_art.bld'),'file'))
    qans=questdlg('Parent-Fraction and Blood .bld files present. Overwrite?','Blood GUI','Yes','No','No');
else
    qans='yes';
end

if strcmpi(qans,'yes')
    % Delete points that approach zero prematurely
    [num_deleted, temp] = check_decreasing(tube_struct.PA);
    tube_struct.PA = [];
    tube_struct.PA = temp;
    % Print Preliminary Data to BLD files
    for m=1:size(t_labels,1)
        if ~(population_pf && strcmp(file_name{m},'parentfraction.bld'))    % Check to see if Population Parent Fraction has already been created
            print_list(final_labels(:,m), tube_struct.(t_labels{m}), fullfile(pwd,file_name{m}), 4);
            figure;
            if ~strcmpi(t_labels{m},'m') && tube_struct.(t_labels{m})(1,1)~=0 && tube_struct.(t_labels{m})(1,2)~=0
                tube_struct.(t_labels{m})=[0 0;tube_struct.(t_labels{m})];
            end
            
            % PCHIP Fit of Parent Fraction Data
            p_cfit=fit(tube_struct.(t_labels{m})(:,1),tube_struct.(t_labels{m})(:,2),'pchipinterp');
            subplot(2,1,1);
            plot(tube_struct.(t_labels{m})(:,1),tube_struct.(t_labels{m})(:,2),'r*');
            hold on;
            fplot(p_cfit,xlim,.00001);
            title(['PCHIP-interp of ' regexprep(file_name{m},'_','\\_')]);
            legend('data','interpolant');
            
            subplot(2,1,2);
            plot(tube_struct.(t_labels{m})(:,1),tube_struct.(t_labels{m})(:,2),'r*');
            plot(p_cfit,'integral');
            title(['Integral of ' regexprep(file_name{m},'_','\\_')])
        end
    end
else
end
assignin('base', 'u_times', u_times);
assignin('base', 'kbq_ml_dkc_mx', kbq_ml_dkc_mx);
assignin('base', 'tube_code_mx', tube_code_mx);

%% Construct Histograms for extra analysis
if (~population_pf)
    make_histograms(u_times, kbq_ml_dkc_mx, tube_code_mx);
end

%% Fit data
pos_wksp_file=ls(fullfile(home_dir,'PET','Sum','*_workspace.mat'));
if ~isempty(pos_wksp_file) && exist(fullfile(home_dir,'PET','Frame1.lst.hdr'),'file')
    wkspfil=fullfile(home_dir,'PET','Sum',deblank(pos_wksp_file(1,:)));
    load(deblank(wkspfil(1,:)),'Series_Duration');
    if length(Series_Duration)>tube_struct.(t_labels{m})(end,1);
        extrap_time=length(Series_Duration);
    else
        extrap_time=tube_struct.(t_labels{m})(end,1);
    end
else
    extrap_time=tube_struct.(t_labels{m})(end,1);
end

% Fit Parent Fraction according to four different models
[met_fit, GOF_TABLE, fits] = pf_fit('parentfraction.bld','',extrap_time, 4);
assignin('base', 'GOF_TABLE', GOF_TABLE);
assignin('base', 'pf_fits', fits);
set(gcf, 'Position', [50 50 840 630]);
saveas(gcf, 'parentfraction_fits.bmp');

% Fit the raw data
update_waitbar(0.7, h, 'Fitting Raw Data (This may take a minute.)');
raw_bld_file={'plasma_art.bld','plasma_ven.bld','whole-blood_art.bld','whole-blood_ven.bld'};
for m=1:4
    if exist(fullfile(pwd,raw_bld_file{m}),'file'),
        test=dlmread(raw_bld_file{m},'\t',1,0);
        if test(1,1)<200 %test(1,1)<60 %only fit data that looks like the peak was captured.
            if exist(fullfile(pwd,'parentfraction.bld'),'file')
            % feng_fit3 fits data according to Feng & L3Exp models
            [bld_fit, models_gof, models]=feng_fit3(raw_bld_file{m},extrap_time,met_fit);  
            else
            [bld_fit, models_gof, models]=feng_fit3(raw_bld_file{m},extrap_time);
            end
            if exist(fullfile(pwd,'parentfraction_fit.bld'),'file') %%metabolite correction
                corr_bld_crv=met_fit.*bld_fit;
            end
        end
    end
end
assignin('base', 'models_gof', models_gof);

update_waitbar(0.8, h, 'Generating Additional Figures');
% Use Parent Fraction Fit to apply Met correction (if metcor was selected)
disp 'FENG & LIN3EXP FITS via Lin2Exp Met Correction';
if exist(fullfile(pwd,'parentfraction_lin2exp.bld'),'file')
    bld_fls=cellstr(ls('*.bld'));
    bld_fls(cellfun(@(x) ~isempty(x),regexp(bld_fls,'parentfraction','match')))=[];
    bld_fls(cellfun(@(x) ~isempty(x),regexp(bld_fls,'plasma_art.bld','match')))=[];
    bld_fls(cellfun(@(x) ~isempty(x),regexp(bld_fls,'plasma_ven.bld','match')))=[];
    bld_fls(cellfun(@(x) ~isempty(x),regexp(bld_fls,'whole-blood_art.bld','match')))=[];
    bld_fls(cellfun(@(x) ~isempty(x),regexp(bld_fls,'whole-blood_ven.bld','match')))=[];
    bld_fls(cellfun(@(x) ~isempty(x),regexp(bld_fls,'_metcor','match')))=[];

 PFfit_fls=cellstr(ls('*.bld'));
    PFfit_fls(cellfun(@(x) ~isempty(x),regexp(PFfit_fls,'Feng','match')))=[];
    PFfit_fls(cellfun(@(x) ~isempty(x),regexp(PFfit_fls,'L3','match')))=[];
    PFfit_fls(cellfun(@(x) ~isempty(x),regexp(PFfit_fls,'parentfraction.bld','match')))=[];
    PFfit_fls(cellfun(@(x) ~isempty(x),regexp(PFfit_fls,'plasma_art.bld','match')))=[];
    PFfit_fls(cellfun(@(x) ~isempty(x),regexp(PFfit_fls,'plasma_ven.bld','match')))=[];
    PFfit_fls(cellfun(@(x) ~isempty(x),regexp(PFfit_fls,'whole-blood_art.bld','match')))=[];
    PFfit_fls(cellfun(@(x) ~isempty(x),regexp(PFfit_fls,'whole-blood_ven.bld','match')))=[];
    PFfit_fls(cellfun(@(x) ~isempty(x),regexp(PFfit_fls,'linear','match')))=[];
    
    iteration = 1;
    if ~isempty(bld_fls)
        for m=1:size(bld_fls,1)
            for i=1:size(PFfit_fls,1)
                switch PFfit_fls{i}
                    case {'parentfraction_hill.bld'}
                        fname = 'hill';
                    case {'parentfraction_exp.bld'}
                        fname = 'exp';
                    case {'parentfraction_power.bld'}
                        fname = 'power';
                    case {'parentfraction_lin2exp.bld'}
                        fname = 'lin2exp';
                    otherwise
                        error ('Fit model not known to this program.')
                end
                %iteration = (((m.*size(PFfit_fls,1)) + i) - size(PFfit_fls,1));
                type = metcor_bld2(bld_fls{m},PFfit_fls{i},fname,batoffset,iteration,(size(bld_fls,1)),(size(PFfit_fls,1)));
                %metcor_bld3(bld_fls{m},PFfit_fls{i},fname,batoffset);
                %metcor_bld4(bld_fls{m},PFfit_fls{i},fname,batoffset);end
                if iteration < size(PFfit_fls,1)
                    iteration = iteration + 1;
                else
                    iteration = 1;
                    saveas(gcf, fullfile(pwd,strcat('metcor_graphs_',type,'.bmp')));
                end
            end
        end
    end
end

%% Write header
fid1=fopen(fullfile(csv_path,'blood.hdr'), 'w');
fprintf(fid1,['TemplateFile:=' regexprep(template_file,'\\','\\\\'), '\r']);
fprintf(fid1,['CSVPath:=' regexprep(csv_path,'\\','\\\\'), '\r']);
fprintf(fid1,['Injection Start:=' num2str(InjectionStart), '\r']);
fprintf(fid1,['BAT Offset:=' num2str(batoffset), '\r']);
fprintf(fid1,['Tracer:=' num2str(tracer), '\r']);
fprintf(fid1,['MetCorrection:=' num2str(met_correct), '\r']);
fprintf(fid1,['Duration:=' num2str(extrap_time), '\r']);
fprintf(fid1,['Reconstruction Date:=' datestr(now), '\r']);
fclose(fid1);

update_waitbar(0.9, h, 'Creating the Final Report');
%% Create Final Report (final_report.pdf)
% Assign necessary variables to workspace
assignin('base', 'participant', template_file);
assignin('base', 'dose_info', dose_info);
assignin('base', 'csv_path', csv_path);
assignin('base', 'batoffset', batoffset);
assignin('base', 'num_deleted', num_deleted);
assignin('base', 'models', models);

if strcmp(report_format, 'pdf')
    publish('final_report.m', 'showCode', false, 'maxHeight', 100, 'maxWidth', 100 ...
        , 'imageFormat', 'jpg', 'format', 'pdf', 'outputDir', csv_path);
elseif strcmp(report_format, 'html')
    publish('final_report.m', 'showCode', false, 'maxHeight', 100, 'maxWidth', 100 ...
        , 'imageFormat', 'jpg', 'format', 'html', 'outputDir', csv_path);
elseif strcmp(report_format, 'both')
    publish('final_report.m', 'showCode', false, 'maxHeight', 100, 'maxWidth', 100 ...
        , 'imageFormat', 'jpg', 'format', 'html', 'outputDir', csv_path);
    publish('final_report.m', 'showCode', false, 'maxHeight', 100, 'maxWidth', 100 ...
        , 'imageFormat', 'jpg', 'format', 'pdf', 'outputDir', csv_path);
end

%% Clean Up
update_waitbar(0.95, h, 'Cleaning Up');
% Put HTML report, BMP Images, & PNG Images into a separate folder
mkdir 'images_and_html';
if strcmp(report_format, 'html') || strcmp(report_format, 'both')
    copyfile('final_report.html', 'images_and_html');
    delete('final_report.html');
end
bmps = ls('*.bmp');
for m=1:size(bmps)
    file = regexprep(bmps(m,:), ' ', '');
    %disp( [file, '.']);
    copyfile(file, 'images_and_html');
    delete(file);
end
pngs = ls('*.png');
for m=1:size(pngs)
    file = regexprep(pngs(m,:), ' ', '');
    %disp( [file, '.']);
    copyfile(file, 'images_and_html');
    delete(file);
end
addpath('images_and_html');

% Put BLD files into a separate folder
mkdir 'bld_files';
blds = ls('*.bld');
for m=1:size(blds)
    file = regexprep(blds(m,:), ' ', '');
    %disp( [file, '.']);
    copyfile(file, 'bld_files');
    delete(file);
end
addpath('bld_files');

update_waitbar(1, h, 'Analysis Complete!');

% Clear Workspace Variables
clear;

disp ' *****ANALYSIS COMPLETE***** ';
close all;
end



%% =======================================================================
function [tube_struct,t_labels]=sort_tube_codes(tube_code_mx,col_time_mx,kbq_ml_dkc_mx)
% count_time_mx
% count_dur_mx
% t_counts_mx
% dev_cpm_mx
% t_counts_error_mx
% counts_dkc_mx
%% First, sort tubes by label then time
t_labels=unique(tube_code_mx(:));
t_labels(cellfun(@(x) any(strcmpi(x,{'B','E','K'})),t_labels))=[]; %remove B and E
tube_struct=struct;
for m=1:size(t_labels,1)
    lab_pos=find(strcmpi(tube_code_mx,t_labels{m}));
    [time,lab_pos_ind]=sort(col_time_mx(lab_pos));
    ordered_data=kbq_ml_dkc_mx(lab_pos(lab_pos_ind));
    tube_struct.(t_labels{m})=[time, ordered_data];
    tube_struct.(t_labels{m})(tube_struct.(t_labels{m})(:,1)<0,:)=[]; %remove negative times
    tube_struct.(t_labels{m})(tube_struct.(t_labels{m})(:,2)<0,:)=[]; %remove negative numbers
end
end



%% =======================================================================
function exit_gamma_bomb = check_overwrite(csv_path, population_pf)
% Input: the directory of csv_files
% Output: Checks to make sure a final report has not already been generated 
% for this data.  If a final report is found:
%   - Delete existing final report
%   - Delete any exisiting image files/graphs that were generated before
%   - Delete any existing bld files that were generated beforeif (exist(fullfile(csv_path,'final_report.html'),'file'))
    images=ls(fullfile(csv_path,'*.bmp'));
    disp(images);
    [num_imgs,~] = size(images);
    
    overwrite_warning = 'Empty';
    if ( exist([csv_path '\final_report.pdf'], 'file') || exist([csv_path '\final_report.html'], 'file') || (num_imgs>0) ||...
           exist([csv_path '\bld_files'], 'dir') || exist([csv_path '\images_and_html'], 'dir') )
        overwrite_warning = questdlg(...
        'Final Report or images already generated for this participant. Overwrite? (All existing final reports, bld files, and bitmap images will be deleted.)'...
        ,'Overwrite Warning','Yes','No','No');
    end
    if strcmp(overwrite_warning, 'No')
        disp 'Program Terminated.';
        exit_gamma_bomb = 1;
    elseif strcmp(overwrite_warning, 'Empty')
        exit_gamma_bomb = 0;
        return;
    else
        if exist(fullfile(csv_path,'final_report.html'),'file')
            delete(fullfile(csv_path,'final_report.html'),'file');
        end
        if exist(fullfile(csv_path,'final_report.pdf'),'file')
            delete(fullfile(csv_path,'final_report.pdf'),'file');
        end
        if exist([csv_path '\bld_files'], 'dir')
            rmdir('bld_files', 's');
        end
        if exist([csv_path '\images_and_html'], 'dir')
            rmdir('images_and_html', 's');
        end
        images=ls(fullfile(csv_path,'*.bmp'));
        pngs = ls(fullfile(csv_path,'*.png'));
        images = cat(1, images, pngs);
        [num_img,~] = size(images);
        disp(num_img);
        if (num_img > 0)
            for m=1:num_img
                delete(strcat(csv_path,'\',images(m,:)));
            end
        end
        
        % Don't delete bld files if you're using a population parent
        % fraction!
        if (~population_pf)
            builds=ls(fullfile(csv_path,'*.bld'));
        
            [num_bld,~] = size(builds);
            disp(num_bld);
            if (num_bld > 0)
                for m=1:num_bld
                    delete(strcat(csv_path,'\',builds(m,:)));
                end
            end
        end
        
        
        clear images builds
        exit_gamma_bomb = 0;
        %delete(images);
        %delete(builds);
    end
end


%% ========================================================================
function update_waitbar(val, h, message)
% Updates the waitbar to show program's progress
if val == 0
    h = waitbar(0, [message, ' - ', num2str(val*100), '%']);
elseif val > 1
    return;
elseif val == 1
    close(h);
else
    waitbar(val, h, [message, ' - ', num2str(val*100), '%']);
end  
end

