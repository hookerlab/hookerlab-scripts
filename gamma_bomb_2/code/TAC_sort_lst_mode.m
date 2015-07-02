function [Scanner_Duration, Series_Duration, frame_start_time, frame_stop_time, acquisition_start, lst_files, lst_files_whole]=TAC_sort_lst_mode(refpath,calc_t_rez)

if nargin<2, calc_t_rez=1000;end

cd(refpath)
lst_files=dir('*.lst');
lst_files_whole=dir('*.lst');
%order Frames
for m=1:size(lst_files,1)
    File{m,1}=lst_files(m).name;
end
clear m
for p=1:size(File,1)
    order(p,:)=regexp(cell2mat(File(p)),'.lst','split');
    order1(p,:)=mat2cell(order{p,1},size(order{p,1},1),size(order{p,1},2));
    order2(p,:)=regexp(order1{p,1},'Frame','split');
    if size(order2,2)==2
        order3(p,:)=[str2double(order2{p,2}) p];
    else
        order3(p,:)=[str2double(order2{p,1}) p];
    end
end
File_unsor=File;
clear File
sortorder=sortrows(order3,1);
File=File_unsor(sortorder(:,2));
lst_files_whole=lst_files_whole(sortorder(:,2));
clear p
clear File_unsor
lst_files=File;
clear File

%% Determine end time from file time information
%%%%%This code is the old way of determining time information, from reading
%%%%%frame time information and hdr file.  A faster implementation is to
%%%%%just read the first frame time information and then the time marks.
% for m=1:size(lst_files_whole,1)
% frame_date{m,1}=lst_files_whole(m).date;
% frame_end_date_time(m,:)=regexp(cell2mat(frame_date(m)),' ','split');
% h_m_s(m,:)=regexp(cell2mat(frame_end_date_time(m,2)),':','split');
% frame_stop_time(m,1)=str2double(h_m_s{m,1})*3600+str2double(h_m_s{m,2})*60+str2double(h_m_s{m,3});
% end
% clear m
% 
% %%Determine start time from lst.hdr information
 Repair_LST_HDR(lst_files)
% for m=1:size(lst_files_whole,1)
% fid = fopen(strcat(lst_files_whole(m).name,'.hdr'), 'r'); %Open file for reading
% for k=1:15
%     tline=fgetl(fid);
%     if k==5
%         strscantime=textscan(tline,'%s %s %s %s %s');
%         H_M_S=regexp(cell2mat(strscantime{5}),':','split');
%         frame_start_time(m,1)=str2double(H_M_S(1))*3600+str2double(H_M_S(2))*60+str2double(H_M_S(3));
%     else
%     end
%     clear tline
% end
% fclose(fid);
% clear k
% end
% clear m
for m=1:size(lst_files_whole,1)
    if m==1
        fid = fopen(strcat(lst_files_whole(m).name,'.hdr'), 'r'); %Open file for reading
        for k=1:15
            tline=fgetl(fid);
            if k==5
                strscantime=textscan(tline,'%s %s %s %s %s');
                H_M_S=regexp(cell2mat(strscantime{5}),':','split');
                world_clock=str2double(H_M_S(1))*3600+str2double(H_M_S(2))*60+str2double(H_M_S(3));
            else
            end
            clear tline
        end
        fclose(fid);
    end
    [duration,ids]=calc_lst_duration(lst_files_whole(m).name,calc_t_rez);
    frame_start_time(m,1)=ids(1);
    frame_stop_time(m,1)=ids(2);
end
tdiff=frame_start_time(1,1)-world_clock;
frame_start_time=floor(frame_start_time-tdiff);
frame_stop_time=floor(frame_stop_time-tdiff);
acquisition_start=frame_start_time(1,1);

%%Set start time and stop time relative to Series Start Time
frame_start_time_true=frame_start_time;
frame_stop_time_true=frame_stop_time;
frame_start_time=frame_start_time_true-frame_start_time_true(1,1);
frame_stop_time=frame_stop_time_true-frame_start_time_true(1,1);

%%Build Time Line (1 if data was collect during that second, 0 if no data
%%was present)
Scanner_Duration((frame_start_time(1)+1):(frame_stop_time(size(frame_stop_time,1))))=0;
for m=1:(size(frame_start_time,1))
    Scanner_Duration((frame_start_time(m)+1):(frame_stop_time(m)))=1;
end
clear m
%Remove short breaks due to framing data
Series_Duration=Scanner_Duration;
System_off=find(Series_Duration==0)';
for m=1:size(System_off,1)
    if Scanner_Duration(System_off(m))==0 && Series_Duration(System_off(m))==0
        if Series_Duration(System_off(m)-1)==1 && Series_Duration(System_off(m)+10)==1
            Series_Duration(System_off(m):System_off(m)+10)=1;
        end
    else
    end
end
% for m=1:size(System_off,1)
%     if sum(Series_Duration((System_off(m)-5):(System_off(m))))~=0 && sum(Series_Duration((System_off(m)):(System_off(m)+5)))~=0
%         Series_Duration(System_off(m))=1;
%     else
%     end
% end
clear m

end
%important variables
%%Scanner_Duration Series_Duration frame_start_time frame_stop_time
%%lst_files lst_files_whole