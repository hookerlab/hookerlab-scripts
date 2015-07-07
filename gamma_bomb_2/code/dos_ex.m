function dos_ex(dos_string)
%%I'm not sure why, but the dos/system function crashes when it is using
%%lmsort, but seems to be okay with !.  Let's make an easy function to do
%%this


evalin('base',[strcat('!',dos_string)])

end