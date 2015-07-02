function V=read_i_hdr(fullf)


if nargin<1
[file,path,~]=uigetfile('*.i.hdr', 'Pick one of the DICOM files');
fullf=fullfile(path,file);
end

[path,filename,ext]=fileparts(fullf);
switch ext
    case '.i'
file=strcat(filename,ext,'.hdr');
    case '.hdr'
file=strcat(filename,ext);
%     case ''
% file=strcat(filename,'i.hdr');
    otherwise
error('File does not have .i or .i.hdr')        
end
if isempty(path)
    path=pwd;
end

fid = fopen(fullfile(path,file), 'r'); %Open file for reading
m=1;
while 1
tline=fgetl(fid);
if tline==-1;break;end
oldhdr{m,1} = tline;
clear tline
m=m+1;
end
fclose(fid);
clear m

V=struct;
spoldhdr=cell(1);
for m=1:size(oldhdr,1)
    if size(regexp(oldhdr{m},':=','split'),2)>size(spoldhdr,2); spoldhdr{:,end+1}='';end
    spoldhdr(m,:)=regexp(oldhdr{m},':=','split');
    spoldhdr{m,1}=strtrim(regexprep(spoldhdr{m,1},'(\<[a-z])','${upper($1)}'));
    spoldhdr{m,1}=regexprep(spoldhdr{m,1},' ','');
    spoldhdr{m,1}=regexprep(spoldhdr{m,1},'[\!,[,],/,(,),\%,:]','');
end
clear m

for m=1:size(spoldhdr,1)
    V.(spoldhdr{m,1})=strtrim(spoldhdr{m,2});
end

end