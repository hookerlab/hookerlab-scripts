function aif=feng_model_aif(A1,L1,A2,L2,A3,L3,tau,t)
%%Model of AIF bolus based on Feng et al. Int J Biomed Comput (1993)
%   Y(t)=0,                                                    t<tau
%   Y(t)=(A1*(t-tau)-A2-A3).*exp(L1*(t-tau))+...
%           A2*exp(L2*(t-tau))+A3*exp(L3*(t-tau));             t>=tau
%
%   [A1]=uCi/ml/sec
%   [A2]=[A3]=uCi/ml
%   [t]=sec
%   [tau]=sec
%   [L1]=[L1]=[L1]=1/sec

aif=zeros(size(t));

pre= t<tau;
post= t>=tau;

aif(pre)=0;
aif(post)=(A1*(t(post)-tau)-A2-A3).*exp(L1*(t(post)-tau))+...
    A2*exp(L2*(t(post)-tau))+A3*exp(L3*(t(post)-tau));

end