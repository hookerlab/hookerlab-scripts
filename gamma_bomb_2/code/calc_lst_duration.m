%six bytes ber given event
function [total_time,ids,last_gc]=calc_lst_duration(lst_ffile,t_mks)

fid = fopen(lst_ffile, 'r', 'l'); %Open file for reading

if nargin<2, t_mks=1000;end

%% Find first x-time marks
index=0;
test={};
t=0;
while 1
    fseek(fid, 6*index, 'bof');
    %start_event=reshape(flipud(dec2hex(fread(fid,6,'uint8')))',1,12);
    start_event=reshape(flipud(dec2hex(fread(fid,6,'uint8'),2))',1,12);
    if (strcmp(start_event(1,2),'A') && strcmp(start_event(1,3),'0')) || feof(fid)
        t=t+1;
        test{end+1,1}=start_event;
        if t==t_mks || feof(fid)
            break
        else
            index=index+1;
        end
    else
        index=index+1;
    end
end

time={};
for m=1:size(test,1)
    time{end+1,1}=hex2dec(test{m,1}(1,4:end));
end
errtest=[1;cell2mat(time(2:end))-cell2mat(time(1:end-1))];
if ~isempty(find(errtest>1))
    start_event=test{test{1}};
    stop_event=test{find(errtest>1)-1};
    start_time=hex2dec(start_event(1,4:end));
    stop_time=hex2dec(stop_event(1,4:end));
    extra_time=floor((stop_time-start_time)*200*10^(-6));
    
    start_event=test{find(errtest>1)};
else
    start_event=test{1};
    extra_time=0;
end


%% Find last x-time marks
index=1;
test2={};
t=0;
while 1
    fseek(fid, -6*index, 'eof');
    %stop_event=reshape(flipud(dec2hex(fread(fid,6,'uint8')))',1,12);
    stop_event=reshape(flipud(dec2hex(fread(fid,6,'uint8'),2))',1,12);
    if index==1 %get last_gc
        last_gc=stop_event(1,1);
    end
    if (strcmp(stop_event(1,2),'A') && strcmp(stop_event(1,3),'0')) || ~ftell(fid)
        t=t+1;
        test2{end+1,1}=stop_event;
        if t==t_mks || ~ftell(fid)
            break
        else
            index=index+1;
        end
    else
        index=index+1;
    end
end

% %% Error correction for frame end (added 05/06/2013)
% time={};
% for m=1:size(test2,1)
%     time{end+1,1}=hex2dec(test2{m,1}(1,4:end));
% end
% errtest2=[1;cell2mat(time(2:end))-cell2mat(time(1:end-1))];
% if ~isempty(find(errtest2~=-1))
%     estart_event=test2{test2{1}};
%     estop_event=test2{find(errtest2~=-1,1,'last')-1};
%     estart_time=hex2dec(estart_event(1,4:end));
%     estop_time=hex2dec(estop_event(1,4:end));
%     extra_time=extra_time+floor((estart_time-estop_time)*200*10^(-6));
%     
%     stop_event=test2{find(errtest2~=-1,1,'last')};
% else
%     stop_event=test2{1};
%     extra_time=extra_time;
% end

stop_event=test2{1};

start_time=hex2dec(start_event(1,4:end));
stop_time=hex2dec(stop_event(1,4:end));

total_time=floor((stop_time-start_time)*200*10^(-6))+extra_time;

fclose(fid);

ids=[start_time;stop_time]*200*10^(-6);
end