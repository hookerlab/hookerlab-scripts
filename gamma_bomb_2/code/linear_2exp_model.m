function aif=linear_2exp_model(A1,A2,A3,tau,lambda1,lambda2,t)
%%
%Y(t)=A1*t+A2                                    0<t<tau
%Y(t)=(A1*tau+A2+A3)/2*exp(-lambda1*(t-tau))+(A1*tau+A2-A3)/2*exp(-lambda2*(t-tau)) ;            t<tau


aif=zeros(size(t));

pre= t<tau;
post= t>=tau;

aif(pre)=A1*t(pre)+A2;
aif(post)=(A1*tau+A2+A3)/2*exp(-lambda1*(t(post)-tau))+(A1*tau+A2-A3)/2*exp(-lambda2*(t(post)-tau)) ;

end