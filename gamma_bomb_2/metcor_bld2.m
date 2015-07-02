%% MODIFIED by Tom Morin (05/01/2015) from script by Daniel Chonde

function type = metcor_bld2(blood_ffile,met_ffile,fit_source,batoffset,iteration,figrows,figcols)
    % This creates the various metabolite correction bld files & BAT
    % correction bld files.
    % INPUT:
    % - blood_ffile = File containing fitted TAC blood data (i.e plasma_art_Feng.bld)
    % - met_ffile = File containing Parent Fraction data (i.e. parent_fraction_hill.bld)
    % - fit_source = name of the Parent Fraction fit (i.e. hill, exp, etc.)
    % - batoffset = Bolus Arrival Time offset in seconds (calculated previously)
    % - Iteration, figrows, & figcols, were all used to organize the
    % aesthetics of the subplots/figures.  These are no longer needed in
    % the final report, so they are no longer produced.
    % OUTPUT:
    % - bld files for the met correction & BAT correction of each model fit
    % - type = A name describing the model fit & its met correciton (i.e. Feng_Hill, L3Exp_Power, etc.)
    
    
    % Read in data & create necessary matrices
    raw_data=dlmread('plasma_art.bld','\t',1,0);
    plasma_art=dlmread(blood_ffile,'\t',1,0);
    parentfraction=dlmread(met_ffile,'\t',1,0);
    
    %This method for finding sigfigs doesn't work when the last value is a
    %whole number
%     teststr=num2str(plasma_art(find(plasma_art(:,2)>0,1,'last'),2));
%     splits=regexp(teststr,'\.','split');
%     sf=size(splits{2},2);
    fid=fopen(blood_ffile,'r');
    fgetl(fid);
    teststr=fgetl(fid);
    splits=regexp(teststr,'\.','split');
    sf=length(splits{end});
    fclose(fid);

    if length(plasma_art(:,1))==length(parentfraction(:,1))
        plasma_art_metcor(:,1)=plasma_art(:,1);
        plasma_art_metcor(:,2)=plasma_art(:,2).*parentfraction(:,2);
    else 
        error('Dimensions do not match');
    end
    
    % Set file name
    name = regexprep(blood_ffile, '.bld', '_metcor');
    name = strcat(name, '_', fit_source);
    type = regexprep(name, 'plasma_art_', '');
    type = regexprep(type, strcat('_metcor_', fit_source), '');
    
% * * The Plots generated below are no longer used in the final report. * *
% =========================================================================
%     % Plot some shit
%     if iteration == 1
%         figure
%     end
%     subplot(figrows.*2,figcols./2,((iteration.*2)-1));plot(plasma_art(:,1),plasma_art(:,2));hold on;
%     plot(plasma_art_metcor(:,1),plasma_art_metcor(:,2),'r');
%     %plot(raw_data(:,1),raw_data(:,2),'xk');
%     set(gca,'XScale','log', 'FontSize', 7);
%     
%     ylabel('kBq/ml', 'FontSize', 7);
%     if iteration == 1
%         legend({'uncorrected','met corrected'}, 'Location', 'NorthEast', 'FontSize', 6, 'Orientation', 'vertical')
%         title(strcat(type, ' Fits'), 'FontSize', 12, 'FontWeight', 'bold')
%     else
%         legend('off');
%     end
%     subplot(figrows.*2,figcols./2,(iteration.*2));plot(parentfraction(:,1),parentfraction(:,2), 'm')
%     title(strcat(upper(fit_source), ' Fit Parent-Fraction'), 'FontSize', 9, 'FontWeight', 'bold');
%     ylabel('Fraction', 'FontSize', 7);
%     xlabel('Time (s)', 'FontSize', 7);
%     set(gca, 'FontSize', 7);
%     %hold off;
%     
%     set(gcf, 'Position', [50 50 750 800]);
% =========================================================================
% * * The Plots generated above are no longer used in the final report. * *

    % Save JPG image of graph
    % saveas(gcf,fullfile(pwd,strcat(name, '.bmp')));
    % set(gca,'XScale','log');
    
    % Save BLD file with fit data
    names=textread(blood_ffile,'%s',1,'delimiter','\n');
    hdrnames=regexp(names,'\t','split');
    print_list(hdrnames{:},plasma_art_metcor,strcat(name, '.bld'),sf);
    
    % Apply BAT Offset & Save BLD file
    A=zeros(batoffset,2);
    [len,~]=size(A);
    for m=1:len-1
        A(m,1) = m;
    end
    for m=1:length(plasma_art_metcor)
        plasma_art_metcor(m,1) = plasma_art_metcor(m,1) + batoffset;
    end
    bat_cor = cat(1, A, plasma_art_metcor);
    print_list(hdrnames{:},bat_cor,strcat(name, '_BATcor.bld'),sf);
end

