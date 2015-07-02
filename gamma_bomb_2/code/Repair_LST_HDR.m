function Repair_LST_HDR(lst_files)
%% Function To Repair Lst mode header files if missing
%% Written by Daniel Chonde
%% Req: cell of list file names
%% Output: *.lst.hdr files when missing
%% Written: 3/31/2011 Updated: 11/14/2011
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This function repairs missing .lst.hdr files which are necessary for
%gettting the timing information for reconstruction.
%%


%%Repair LST.HDR files
if size(dir('*.lst'),1)~=size(dir('*.lst.hdr'),1)
    disp('It appears that some LST header files are missing we will attempt to approximate them');
    for m=1:size(lst_files,1)
        lst_hdr_files(m,:)=strcat(lst_files(m),'.hdr');
    end
    clear m
    
    for m=1:size(lst_hdr_files,1)
        if exist(lst_hdr_files{m,:},'file')==0
            if exist(regexprep(strtrim(lst_hdr_files{m,:}),'.lst',''),'file')
                disp([regexprep(strtrim(lst_hdr_files{m,:}),'.lst','') ' found...ask Larry to make .lst.hdr files again...'])
                copyfile(regexprep(strtrim(lst_hdr_files{m,:}),'.lst',''),lst_hdr_files{m,:})
            else
                disp([lst_hdr_files{m,:} ' is missing...approximating...'])
                %figure out creation time of log file and subtract 58 seconds
                no_ext_name=regexp(lst_hdr_files{m,:},'.lst.hdr','split');
                %no_ext_name=regexp(lst_hdr_files{m-1,:},'.lst.hdr','split');
                log_file=strcat(no_ext_name{1},'.lst');
                log=dir(log_file);
                log_date=log.date;
                log_creation_date_time=regexp(log_date,' ','split');
                log_h_m_s=regexp(cell2mat(log_creation_date_time(1,2)),':','split');
                log_file_creation_time=str2double(log_h_m_s{1,1})*3600+str2double(log_h_m_s{1,2})*60+str2double(log_h_m_s{1,3});
                %lst_file_creation_time=log_file_creation_time-58;
                start=calc_lst_duration(log_file);
                lst_file_creation_time=log_file_creation_time-start;
                new_hdr_hh=num2str(floor(lst_file_creation_time/3600));
                if size(new_hdr_hh,2)==1
                    new_hdr_hh=strcat('0',new_hdr_hh);
                end
                new_hdr_mm=num2str(floor(lst_file_creation_time/60-floor((lst_file_creation_time/3600))*60));
                if size(new_hdr_mm,2)==1
                    new_hdr_mm=strcat('0',new_hdr_mm);
                end
                new_hdr_ss=num2str(lst_file_creation_time-str2num(new_hdr_mm)*60-str2num(new_hdr_hh)*3600);
                if size(new_hdr_ss,2)==1
                    new_hdr_ss=strcat('0',new_hdr_ss);
                end
                
                if m==1
                    copyfile(fullfile('D:\Users\Dan\Codes\matlab\externals','template.lst.hdr'),lst_hdr_files{m,:});
                else
                    copyfile(lst_hdr_files{m-1,:},lst_hdr_files{m,:});
                end
                fileattrib(lst_hdr_files{m,:},'+w');
                %fid=fopen(lst_hdr_files{m-1,:});
                fid=fopen(lst_hdr_files{m,:});
                F = fread(fid, '*char')';
                fclose(fid);
                C=regexp(F(1,:),'\(hh:mm:ss)\s:=','split');
                F((size(C{1},2)+15):(size(C{1},2)+16))=new_hdr_hh;
                F((size(C{1},2)+18):(size(C{1},2)+19))=new_hdr_mm;
                F((size(C{1},2)+21):(size(C{1},2)+22))=new_hdr_ss;
                fid2=fopen(lst_hdr_files{m,:},'w');
                fwrite(fid2,F);
                fclose(fid2);
                fileattrib(lst_hdr_files{m,:},'-w');
            end
        end
        clear C F fid fid2 log log_creation_date_time log_date log_file log_file_creation_time log_h_m_s lst_file_creation_time new_hdr_hh new_hdr_mm new_hdr_ss no_ext_name
    end
    clear m lst_hdr_files
end
end