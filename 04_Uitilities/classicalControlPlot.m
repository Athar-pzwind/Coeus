function classicalControlPlot(Sum_Data,filesidx,rtd_rpm)
fields=fieldnames(Sum_Data);

% n = numel(wsp);
% 
% assert( numel(lambda)==n && numel(pitch)==n && ...
%         numel(power)==n  && numel(torque)==n && ...
%         numel(rpm)==n, ...
%         'All inputs must have the same length as wsp');




%% Column vectors


%% Colors
cPitch  = [0.0 0.45 0.74];   % blue
cPower  = [0.85 0.33 0.10];  % orange
cTorque = [0.64 0.08 0.18];  % red
cRPM    = [0.47 0.67 0.19];  % green

%% Base axes
for z=1:numel(filesidx)
    current_mean = Sum_Data.(fields{filesidx(z)}).Mean;
    wsp=round(current_mean.WindHubVelX(:),1);
    pitch=current_mean.BldPitch1;
    power=current_mean.GenPwr;
    torque=current_mean.GenTq;
    rpm=current_mean.RtSpeed;
    lambda=current_mean.RtTSR;

    rgn2=find(current_mean.RtTSR >= 7.5,1,'last');
    rgn25=find(round(current_mean.GenPwr) < 5000,1,'last');
    region = assignOperatingRegion(wsp, rpm,rgn2,rgn25,rtd_rpm);

    wsp    = wsp(:);
    lambda = lambda(:);
    pitch  = pitch(:);
    power  = power(:);      % kW
    torque = torque(:);     % kN-m
    rpm    = rpm(:);

    fig=figure('NumberTitle','off','Name',"Classical Control Plot");
    ax1 = axes;
    hold(ax1,'on');
    grid(ax1,'on');
    
    
    
    %% ---- LEFT Y : Pitch ----
    yyaxis(ax1,'left')
    hPitch = plot(wsp,pitch,'-o','LineWidth',1.6,'Color',cPitch);
    ylabel('Pitch (deg)')
    ax1.YColor = cPitch;
    
    %% ---- RIGHT Y : Power ----
    yyaxis(ax1,'right')
    hPower = plot(wsp,power,'-^','LineWidth',1.6,'Color',cPower);
    ylabel('Power (kW)')
    ax1.YColor = cPower;
    
    xlabel('Wind Speed (m/s)')
    xlim([min(wsp) max(wsp)])
    
    %% ---- Separate axis for Torque (RIGHT, offset) ----
    axT = axes('Position',ax1.Position,'Color','none');
    hold(axT,'on');
    
    hTorque = plot(axT,wsp,torque,'-d','LineWidth',1.6,'Color',cTorque);
    axT.YAxisLocation = 'right';
    axT.XTick = [];
    ylabel(axT,'Torque (kN·m)')
    axT.YColor = cTorque;
    axT.YTickLabel = strcat(axT.YTickLabel,{'   '});
    
    %% ---- Separate axis for RPM (LEFT, offset) ----
    axR = axes('Position',ax1.Position,'Color','none');
    hold(axR,'on');
    
    hRPM = plot(axR,wsp,rpm,'-s','LineWidth',1.6,'Color',cRPM);
    axR.YAxisLocation = 'left';
    axR.XTick = [];
    ylabel(axR,'RPM')
    axR.YColor = cRPM;
    axR.YTickLabel = strcat(axR.YTickLabel,{'   '});
    
    % yyaxis left
    % ylim manual
    % 
    % yyaxis right
    % ylim manual
    
    % ---- Background region coloring (yyaxis-safe) ----
    ax = gca;                  % get final active axes
    axes(ax); hold(ax,'on');
    
    yl = ylim(ax);              % now this is FINAL ylim
    
    % Region color table (1–5)
    regColor = [
        1.00 0.00 0.00;   % R1
        0.00 0.45 0.74;   % R2
        0.47 0.67 0.19;   % R3
        0.00 1.00 1.00;   % R4
        1.00 1.00 0.00;   % R5
    ];
    
    % Find region change indices
    idx = [1; find(diff(region) ~= 0) + 1; length(region)+1];
    
    for k = 1:length(idx)-1
        i1 = idx(k);
        i2 = idx(k+1) - 1;
        r = region(i1);
        if r < 1 || r > 5 || isnan(r)
            continue
        end
        x1 = wsp(i1);
        x2 = wsp(i2);
    
        patch( ...
            [x1 x2 x2 x1], ...
            [yl(1) yl(1) yl(2) yl(2)], ...
            regColor(r,:), ...
            'FaceAlpha',0.18, ...
            'EdgeColor','none', ...
            'Parent',ax, ...
            'HandleVisibility','off');
    end
    
    
    
    
    %% ---- TOP X AXIS : Lambda ----
    axR.XAxisLocation = 'top';
    axR.XLim = ax1.XLim;
    axR.XTick = wsp;
    axR.XTickLabel = round(lambda,2);
    axR.XTickLabelRotation = 90;
    
    % Push patches to BACKGROUND
    uistack(findall(ax,'Type','patch'),'bottom')
    
    %% ---- Legend ----
    legend([hPitch hPower hTorque hRPM], ...
           {'Pitch','Power','Torque','RPM'}, ...
           'Location','northwest');
    
    title('Classical Control Plot')
    
end
end

%% Supporting functions
function region = assignOperatingRegion(wsp, rpm,rgn2,rgn25,rtd_rpm)

% -------- Parameters --------
% rtd_rpm = 1161.963185;
rgn05rpm = 670;                % Minimum RPM


% Ensure column vectors
wsp   = wsp(:);
rpm   = rpm(:);

n = length(wsp);
region = zeros(n,1);

% -------- Region assignment --------
for i = 1:n
    if i<=rgn2
        region(i)=2;
    elseif i>=rgn25
        region(i)=3;
    end
    % % ---- Region 1: Constant RPM ----
    % 
    % % ---- Below HWO ----
    % if round(rpm(i)+1) >= rgn2rpm && rpm(i) <= rgn25rpm
    %     region(i) = 2;   % Region 2: Variable RPM, below rated power
    % elseif round(rpm(i)+1) > rtd_rpm
    %     region(i) = 4;   % Region 4: Full load
    % elseif rpm(i) < rgn05rpm
    %     region(i) = 1;
    % end
end

end
