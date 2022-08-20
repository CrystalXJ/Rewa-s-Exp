function pC = getPC_SAT_Color(SAT_params,t_grid,funcForm)

% alpha = SAT_params(1);
% beta = SAT_params(2);
%

if funcForm==1
    delta = SAT_params(1);
    lambda = SAT_params(2);
elseif funcForm==2
    beta = SAT_params(1);
    delta = SAT_params(2);
    lambda = SAT_params(3);
elseif funcForm==3
    % From Britten et al. (1992)
    delta=SAT_params(1);    %asymptotic %correct.
    alpha=SAT_params(2);    %time at 82% correct
    beta=SAT_params(3);     %slope of the SAT.
end

% compute the SAT function
%pC = 1-(1-0.5)*exp(-(t./alpha).^beta);
nt =length(t_grid);
pC = zeros(1,nt);
% i=1;
% while pC(i)<1
for i=1:nt
    if t_grid(i)<delta
        pC(i)=0.5;
    else
        %pC(i)=beta*(1-exp(-(t(i)-delta)./lambda));
        if funcForm==1
            pC(i)=0.5+(1-0.5)*(1-exp(-(t_grid(i)-delta)./lambda));
        elseif funcForm==2
            pC(i)=0.5+(1-0.5)*beta*(1-exp(-(t_grid(i)-delta)./lambda));
        elseif funcForm==3
            pC(i)=delta-(delta-0.5).*exp(-((t_grid(i)./alpha).^beta));
        end
        
        %pC(i)=1-exp(-(t(i)./lambda))^delta;
    end
    %     if pC(i) ==1
    %         break
end
% i=i+1;
end


%plot(t_grid,pC);