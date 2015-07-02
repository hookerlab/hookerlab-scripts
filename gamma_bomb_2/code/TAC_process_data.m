function TAC_process_data(Sum_Output_name)
if ~exist(fullfile(pwd,'TAC_process_data.bat'),'file')
    copyfile('D:\Users\Dan\Codes\bat\TAC_process_data.bat')
end
if ~exist(fullfile(pwd,'TAC_process_data_cleanup.bat'),'file')
    copyfile('D:\Users\Dan\Codes\bat\TAC_process_data_cleanup.bat')
end

dos(['hist_PET -l ' Sum_Output_name '.lst -s ' Sum_Output_name '.s -L ' Sum_Output_name '.lor -A c:\bin\lorlookup_p256.dat -C 19,128']);
copyfile(strcat(Sum_Output_name,'.s.hc'),strcat(Sum_Output_name,'_hp.s.hc'),'f');
delete(strcat(Sum_Output_name,'_p.lor*'),strcat(Sum_Output_name,'_d.lor*'),strcat(Sum_Output_name,'.s*'),strcat(Sum_Output_name,'_*r*.s*'),strcat(Sum_Output_name,'.*map'))
process_data_command_line=['TAC_process_data ' Sum_Output_name];
dos_ex(process_data_command_line);
process_data_cleanup_command_line=['TAC_process_data_cleanup ' Sum_Output_name];
dos(process_data_cleanup_command_line);
convertshc(strcat(Sum_Output_name,'.s.hc'),strcat(Sum_Output_name,'_hp.s.hc'))
copyfile(strcat(Sum_Output_name,'.s.hc'),strcat(Sum_Output_name,'_head_curve.s.hc'),'f');
end