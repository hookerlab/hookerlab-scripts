function convertshc(hc_file,hp_hc)

fid=fopen(hc_file);
t_hc_line=[];
while 1
    hc_line=fgetl(fid);
    if hc_line==-1,break;end %EOF
    if strcmpi(hc_line(1:10), 'Head Curve')
        t_hc_line(end+1,:)=sscanf(hc_line,'Head Curve %i %i %i %i %i %i %i %i %i %i %i ET=%f gcerrors=%i')';
    end
end
fclose(fid);


if nargin>1
    t_hc_line2=csvread(hp_hc, 1, 0);
    %%make sure HistPET is always increasing
    for m=2:size(t_hc_line2,1);
        if t_hc_line2(m,1)<t_hc_line2(m-1,1)
           t_hc_line2(m,1)=t_hc_line2(m-1,1)+1000; 
        end
    end
    if size(t_hc_line,1)>size(t_hc_line2,1) %% HistPET version has fewer times...lets just assume they increase by 1 sec as one might assume.
        offset=size(t_hc_line,1)-size(t_hc_line2,1);
        t_hc_line2=[t_hc_line2;[[1:offset]'*1000,zeros(offset,12)]];
    end    
    t_hc_line(:,1)=t_hc_line2(1:size(t_hc_line,1),1);
end


if ~isempty(t_hc_line)
    fid1=fopen(hc_file, 'wt');
    fprintf(fid1,'Time(msec),CFD,StoredXY,QualEvent,RIO_Singles,Delays,RIO_Delay,Prompts,RIO_Prompt,ERS_Prompt,ERS_Delays,ERS_Singles,SyncErrCnt\n\r');
    for m=1:size(t_hc_line,1)
        fprintf(fid1,[sprintf('%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i',t_hc_line(m,:)) '\n\r']);
    end
    fclose(fid1);
end

end