function aif=lin_3exp_model_aif(A1,L1,A2,L2,A3,L3,C,ts,tp,t)
%%Model of AIF bolus based on Feng et al. Int J Biomed Comput (1993)
%   Y(t)=0,                                                    t<ts
%   Y(t)=A1*(t-ts)                                             t>=ts & t<ts+tp
%   Y(t)=(A1*tp-A2-A3)*exp(-L1*(t-tp))+A2*exp(-L2*(t-tp))+A3*exp(-L3*(t-tp))
%
%   [A1]=uCi/ml/sec
%   [A2]=[A3]=uCi/ml
%   [t]=sec
%   [tau]=sec
%   [L1]=[L1]=[L1]=1/sec

aif=zeros(size(t));

pre= t<ts;
inc= t>=ts & t<ts+tp;
post= t>=ts+tp;

aif(pre)=0;
aif(inc)=A1*(t(inc)-ts);
aif(post)=(A1*(tp)+A2+A3-C)/3*exp(-L1*(t(post)-(ts+tp)))+(A1*(tp)-A2-C)/3*exp(-L2*(t(post)-(ts+tp)))+(A1*(tp)-A3-C)/3*exp(-L3*(t(post)-(ts+tp)))+C;


end