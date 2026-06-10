function plot_ctr_comp(Sum_Data, factor_value)
    fields = fieldnames(Sum_Data);
    filesidx = 1:1:length(fields);
    LineStyleOrder = {'-', '--', ':', '-.','-', '--', ':', '-.', '--', ':', '-.'};
    plot_configs = {
        'GenPwr',    'Power & AEP M=7.5, K=2';
        'BldPitch1', 'Blade Pitch [deg]';
        'B1RootMxr', 'Blade Root Moment-x';
        'RotThrust', 'Rotor Thrust';
        'GenSpeed',  'Gen Speed [RPM]';
        'B1TipTDxr', 'Tip deflection';
    };
    colors   = colororder("gem");
    [Aep, Aep_rel, order] = groupedAep(Sum_Data,filesidx);
   
    tit = "Controls_Mean_Comparison";
    tlo =[];
    try
        for p = 1:size(plot_configs, 1)
            [ax, ax2, tlo, fig] = getDualAxisTile(tit, p, 3, 2,tlo);
            sensor = plot_configs{p, 1};
            y_lbl  = plot_configs{p, 2};
            sensor_missing = false;
    
            for i = 1:numel(filesidx)
                f_name = fields{filesidx(order(i))};
                current_mean = Sum_Data.(f_name).Mean;
                % 1. Local Wsp Calculation inside the loop
                [Wsp, flag] = checkWind(current_mean);
                if ~flag
                    %WSP data dosen't exist
                    continue
                end
                % 2. Sensor Availability Check
                if isfield(current_mean, sensor)
                    y_data = current_mean.(sensor)(:);
                    cols=colors(i,:);   % All set for plotting, deciding color
                    legend_name=num2str(factor_value(filesidx(order(i))));
                else
                    sensor_missing = true;
                    continue
                end
                % 3. Plotting
                if sensor=="GenPwr"
                    hold(ax2,"on");
                    plot(ax, Wsp, y_data, '-+', ...
                        'Color', cols,'DisplayName',legend_name,'LineStyle',LineStyleOrder{i});
                    ylim(ax,[0 5500])
                    ylabel(ax, "Gen Power");
                    xlim([4 14]);
                    %create new plane for plotting AEP
                    xpoint=9.5+i/1.25;
                    text2disp=num2str(round(Aep_rel(i),2)) + "%" + newline ...
                        + num2str(round(Aep(order(i)),2)) + "MWh";
                    bar(ax2,xpoint,Aep_rel(i),0.5,'FaceColor',cols);
                    text(ax2,xpoint, Aep_rel(i) + (Aep_rel(i) * 0.02), ...
                        text2disp,'HorizontalAlignment', 'center', ...
                        'VerticalAlignment', 'bottom','FontSize',7);
                    ylim(ax2,[80 160])
                    box(ax,"on");
                    ylabel(ax2, "AEP change [%]");
                    hold(ax2, 'off');
                else
                    hold(ax2, 'off');
                    legend_name=num2str(factor_value(filesidx(order(i))));
                    plot(ax, Wsp, y_data, '-+', ...
                        'Color', colors(i,:),'DisplayName',legend_name,'LineStyle',LineStyleOrder{i});
                    xlim(ax,[4 14])
                end
            end
            
            % 4. Display "Sensor Not Available" if missing
            miscChecks(sensor_missing,cols,sensor,y_lbl,ax,p)
        end
        
        lgd = legend(ax, 'Orientation', 'horizontal');
        lgd.Layout.Tile = 'south';
    catch ME
        fprintf('Plotting Error: %s\n', ME.message);
    end
end


%% Supporting Fucnctions
function [Aep, Aep_rel, order] = groupedAep(Sum_Data,filesidx)
% This function calculates AEP for all the files in Sum_Data
% then calculates relative AEP to min of all
    fields = fieldnames(Sum_Data);
    [Aep, Aep_rel, Aep_per] = deal(zeros(length(fields)));
    for i=1:length(fields)
        f_name = fields{filesidx(i)};
        current_mean = Sum_Data.(f_name).Mean;
        Aep(i) = aep(current_mean,7.5,2);
    end
    refaep = min(Aep);
    for i=1:length(Aep)
        Aep_per(i) = ((Aep(i)-refaep)/refaep)*100;
        Aep_rel(i) = 100+Aep_per(i);
    end
    [Aep_rel, order] = sort(Aep_rel,'ascend');

end

function [Wsp, flag] = checkWind(current_mean)
% This function checks whether wind data is present in the file
    flag = 1;
    if isfield(current_mean, 'Wind1VelX')
        Wsp = round(current_mean.Wind1VelX(:),2);
    elseif isfield(current_mean,'WindHubVelX')
        Wsp = round(current_mean.WindHubVelX(:),2);
    else
        warning('Wsp (WindHubVelX) missing in %s', f_name);
        flag = 0;
    end

end

function [ax1, ax2, tlo, fig] = getDualAxisTile(tit, tileIdx, rows, cols, tlo)
    % 1. Create Figure and Layout ONLY if they don't exist yet
    if nargin < 5 || isempty(tlo) || ~isvalid(tlo)
        fig = figure('NumberTitle', 'off', 'Name', tit);
        tlo = tiledlayout(rows, cols, 'TileSpacing', 'compact', 'Padding', 'compact');
    else
        fig = gcf();
    end

    % 2. Setup Primary Axis (Left)
    ax1 = nexttile(tlo, tileIdx);
    hold(ax1, 'on'); 
    grid(ax1, 'on'); 
    grid(ax1, 'minor');

    % 3. Setup Secondary Axis (Right)
    ax2 = axes(tlo);
    ax2.Layout.Tile = tileIdx;
    
    set(ax2, ...
        'Color', 'none', ...
        'XColor', 'none', ...
        'YAxisLocation', 'right', ...
        'TickDir', 'out');
    linkaxes([ax1, ax2], 'x');
end

function miscChecks(sensor_missing,cols,sensor,y_lbl,ax,p)
    if sensor_missing
        text(ax, 0.5, 0.5, ['Sensor "' sensor '" not available'], ...
            'Units', 'normalized', 'HorizontalAlignment', 'center', ...
            'Color',  cols, 'FontWeight', 'bold', 'FontSize', 8);
    end

    if ~strcmp(sensor,"GenPwr")
        ylabel(ax, y_lbl);
        title(ax, y_lbl);
    end
    if p > 4, xlabel(ax, 'Wind Speed [m/s]'); end
end