function [AoA_mean,AoA_max] = calc_Ndstall(Sum_Data,BladeData, factor_value)
    % 1. Setup Data and Airfoils
    fields = fieldnames(Sum_Data);
    LineStyleOrder = {'-', '--', ':', '-.','-', '--', ':', '-.', '--', ':', '-.'};
    Bldnodes = cellstr(BladeData.BladeNodes);
    bldspn = cell2mat(BladeData.BladeSpan);
    static_stall = calcStaticStall(BladeData.Aerofoils);
    wsptiles=[4,6,8,10,12,14];
    [AoA_mean,AoA_max,AoA_min] = getAoA(Sum_Data,Bldnodes);

% Plot AOAs against BldSpn for each WSP
    try
        for file = 1:length(fields)
            leg1_name=string(factor_value(file));
            tit = sprintf('%s', leg1_name);
            fig = figure('NumberTitle','off','Name',tit, 'Color', 'w', 'Units', 'normalized', 'Position', [0.1 0.1 0.6 0.8]);
            tlo = tiledlayout(3, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
            title(tlo,tit);
            count=0;
            current_mean = Sum_Data.(f_name).Mean;
            Wsp = round(current_mean.WindHubVelX(:));
            for p = 1:length(Wsp)
                if ismember(round(Wsp(p)),wsptiles)
                    ax = nexttile;
                    count = count+1;
                    hold(ax, 'on'); grid(ax, 'on'); grid(ax, 'minor');
                    y_data_mean = AoA_mean(:,p,file);
                    y_data_max = AoA_max(:,p,file);
                    y_data_min = AoA_min(:,p,file);
                    plot(ax, bldspn, y_data_mean, '-+', ...
                        'Color', 'green','DisplayName','Mean','LineStyle',LineStyleOrder{1i});
                    plot(ax, bldspn, y_data_max, '-+', ...
                        'Color', 'cyan','DisplayName','Max','LineStyle',LineStyleOrder{1i});
                    plot(ax, bldspn, y_data_min, '-+', ...
                        'Color', 'blue','DisplayName','Min','LineStyle',LineStyleOrder{1i});
                    ylabel(ax, "AoA [deg]");
                    plot(ax, bldspn, static_stall, '-+', ...
                        'Color', 'red','DisplayName',"Stall Angle");
                    ylim(ax,[-10 40])
                    hold(ax,'off');
                    if p > 4
                        xlabel(ax, 'Blade span');
                        if count==6
                            lgd = legend(ax, 'Orientation', 'vertical','Location','southeast');
                        end
                        % lgd.Position('s');
                    end
                    title(ax, num2str(Wsp(p)) + " m/s");
                end
            end
        end
    catch
        fprintf('Plotting Error: %s\n', ME.message);
    end
end
