function plot_time_analysis(stallLegends,maxpercentnear)
    bldspn = [10.25 18.45 22.55 30.75 38.95 43.05 51.25 57.40 60.13];
    WSP = 4:2:14;
    colors = turbo(15);
    folders = length(maxpercentnear(1,1,:));
    % Plotting
    titnear = "\bf % of Time in stall (with stall margin of 5 deg)";
    fignear = figure('NumberTitle','off','Name',titnear, 'Color', 'w', 'Units', 'normalized', 'Position', [0.1 0.1 0.6 0.8]);
    tlonear = tiledlayout(3, 2, 'TileSpacing', 'compact', 'Padding', 'compact','Tag', 'NearStallLayout');
    title(tlonear,titnear);
    for p = WSP(1):(WSP(2)-WSP(1)):WSP(end)
            ax = nexttile(tlonear);
            for i = 1:folders
                if i>length(stallLegends)
                    leg = 'Legend';
                else
                    leg = stallLegends(i);
                end
                hold(ax, 'on');
                y_data_max_near = maxpercentnear(p,:,i);
                b2 = stairs(ax, bldspn, y_data_max_near,'DisplayName',leg,'Color',colors(i,:),'LineWidth',1.5); 
            end
            if p > 4
                    xlabel(ax, 'Blade span');
            end
            if p == 1
                legend('Orientation', 'vertical','Location','southeast');
            end
            grid(ax,"on"); grid(ax,"minor");
            ylabel("Time in Stall [%]")
            ylim(ax,[0 40]);
            title(ax, num2str(2*(p+1)) + " m/s");
        hold(ax,'off');
        savefig(fignear,"figures\NearStallAnalysis.fig");
    end
end

    