function homedir=home_dir(s_path)

if nargin<1
twig=strcat(pwd,'\');
s_path=pwd;
else
    if ~strcmp(s_path(end),'\')
    twig=strcat(s_path,'\');
    else
    twig=s_path;    
    end
end

test=regexpi(twig,{'\\PET\\','\\MR_PET\\','\\MR\\','\\BLOOD\\'},'match');
n=find([isempty(test{1}) isempty(test{2}) isempty(test{3}) isempty(test{4})]==0);
if isempty(n)
  homedir=strcat(s_path,'\'); %you're in the home dir.  
else
split_limb=regexpi(twig,['\' cell2mat(test{n}) '\'],'split');
homedir=strcat(split_limb{1:end-1});
end

end