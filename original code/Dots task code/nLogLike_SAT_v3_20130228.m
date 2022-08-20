function nll=nLogLike_SAT_v3_20130228(params,data,funcForm)
%
% compute sum of negative log likelihood given data and
% parameter value for the cumulative Weibull distribution.
%
% SWU.11.

% Functional form for the SAT was chosen from Dean et al. (2007).
% alpha=params(1);
% beta=params(2);
% 

mu_RT = data(:,1);
c=data(:,2);
n=data(:,3);

pCorrect_hat = getPC_SAT_Color(params,mu_RT,funcForm)';

%pCorrect_hat=(1-(1-0.5)*exp(-(mu_RT-delta)./lambda));
%pCorrect_hat=1-(1-0.5)*exp(-(mu_RT./alpha).^beta);

logLike = c.*mylog(pCorrect_hat) + (n-c).*mylog(1-pCorrect_hat);

if funcForm==1
    delta = params(1);
    lambda = params(2);
elseif funcForm==2
    beta = params(1);
    delta = params(2);
    lambda = params(3);
end

% if beta>1 || delta>0.35 || delta<0.2 || lambda<10^(-3)
%     nll=10^20;
% else
%     nll = -sum(logLike);
% end
% if beta>1 || delta>min_RT || delta<0.2 || lambda<10^(-3)
%     nll=10^20;
% else
%     nll = -sum(logLike);
% end

if funcForm==1||funcForm==2
    if delta<0.2 || lambda<10^(-3)
        %if delta>min_RT || delta<0.2 || lambda<10^(-3)
        nll=10^20;
    else
        nll = -sum(logLike);
    end
    if funcForm==2
        if beta>1
            nll=10^20;
        end
    end

else
    nll = -sum(logLike);
end