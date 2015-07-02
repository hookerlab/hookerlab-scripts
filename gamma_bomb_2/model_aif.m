function mu=model_aif(a,b,c,b1,b2,t)
%%Model of AIF bolus for extraction of bolus arrival time (BAT)
%   MU=c,                   t<a
%   MU=c+b1(t-a)            a<=t<=a+b
%   MU=c+b1(b)+b2(t-b-a)    t>a+b
%% at some point I need to come back to this and change the equation so b is the amount of time where the first line is used
%since b must always be greater than a.  This can be enforced by writing
%the equation such that a<=t<=a+b, or essentially replacing b by (b+a)

mu=zeros(size(t));

pre= a>=t;
low_side= (a<t) & (t <= (a+b));
high_side= ((a+b)<t);

mu(pre)=c;
mu(low_side)=(t(low_side)-a)*b1+c;
mu(high_side)=(t(high_side)-b-a)*b2+c+b1*(b);

end