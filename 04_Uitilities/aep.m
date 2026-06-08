function [AEP_MWh, Energy,Hours] = aep(current_mean, M, k)
    if isfield(current_mean, 'Wind1VelX')
        Wsp = round(current_mean.Wind1VelX(:),1);
    elseif isfield(current_mean,'WindHubVelX')
        Wsp = round(current_mean.WindHubVelX(:),1);
    else
        warning('Wsp (WindHubVelX) missing in %s', f_name);
    end
    P=current_mean.GenPwr;
    Hours = weibull_hours(Wsp, M, k);    % Annual hours distribution (based on weibull) for each WSP intervals
    MeanP    = zeros(length(Hours),1);
    
    for i = 1:length(MeanP)
        MeanP(i)       = (P(i+1)+P(i))/2;
    end
    Energy             = MeanP.*Hours/1000; % Annual energy(MWh) distribution for each WSP interval
    AEP_MWh            = sum(Energy)/1000;
end

function hours = weibull_hours(WSP, M, k) % Weibull hours per year
    A                  = M/(gamma(1+1/k));
    CDF                = 1-exp(-(WSP/A).^k);
    hours = zeros(length(CDF)-1,1);
    for i = 1:length(CDF)-1
        hours(i)       = CDF(i+1)-CDF(i);
    end
    hours = hours*8760; % Distribution of hours corresponding to 1 full year
end