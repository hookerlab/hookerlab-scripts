function [head_curve,head_curve_trues]=generate_head_curve(file,Series_Duration)

acq_timing_error=0;

head_curve_full = csvread(file, 1, 0);
if head_curve_full(1,1)~=1000
    warndlg(sprintf('Head curve file was found to start at a time~=1 sec. \n I''m going to attempt to fix this.'));
    time_offset=head_curve_full(1,1);
    head_curve_full(:,1)=head_curve_full(:,1)-head_curve_full(1,1)+1000;
    acq_timing_error=1;
end

if nargin<2, Series_Duration(1,1:size(head_curve_full,1))=1;end

head_curve_reduced=head_curve_full(:,1:2);
head_curve_reduced(:,1)=floor(head_curve_reduced(:,1)/1000);

% compute trues as ERS_prompts - ERS_delays
head_curve_true_reduced=[head_curve_full(:,1) head_curve_full(:,10)-head_curve_full(:,11)];
head_curve_true_reduced(head_curve_true_reduced<0)=NaN;

head_curve_true_reduced(:,1)=floor(head_curve_true_reduced(:,1)/1000);
head_curve=Series_Duration';
head_curve_trues=Series_Duration';

%%align Head Curve to Number Line
for m=1:size(head_curve_reduced,1);
    if head_curve_reduced(m,1)<size(head_curve,1) && (head_curve(head_curve_reduced(m,1),1)==1 || head_curve(head_curve_reduced(m,1),1)==0) ;
        head_curve(head_curve_reduced(m,1),1)=head_curve_reduced(m,2).*head_curve(head_curve_reduced(m,1),1);
    else
    end
end
clear m

%%align Treus to Number Line
for m=1:size(head_curve_true_reduced,1);
    if head_curve_true_reduced(m,1)<size(head_curve_trues,1) && (head_curve_trues(head_curve_true_reduced(m,1),1)==1 || head_curve_trues(head_curve_true_reduced(m,1),1)==0) ;
        head_curve_trues(head_curve_true_reduced(m,1),1)=head_curve_true_reduced(m,2).*head_curve_trues(head_curve_true_reduced(m,1),1);
    else
    end
end
clear m

%%Head Curve Correction for Error Flags
if sum(head_curve_full(:,13))~=0
    %fprintf('%d Error Flags Spotted in Head Curve...correcting.\n', max(head_curve_full(:,13)));
    fprintf('%d Error Flags Spotted in Head Curve...correcting.\n', length(unique(head_curve_full(:,13)))-1);
    head_curve_uncorr=head_curve;
    error_index=find(head_curve==1);
    for m=1:size(error_index,1)
        head_curve(error_index(m,1),1)=head_curve(error_index(m,1)-1,1);
    end
    clear m
end

end