function plotStallWeibull(stallData)
    WSP = 4:2:14;
    bldspn = [10.25 18.45 22.55 30.75 38.95 43.05 51.25 57.40 60.13];
    pitch = [0 1 1.5 2 3];
    numNodes = length(stallData(1,:,1));
    numFolders = length(stallData(1,1,:));
    for folder = 1:numFolders
        for i = 1:numNodes
            [AnualWeibulHours_Stall(i,folder),WindStall(:,i,folder)] = stalldistribution(WSP,stallData(:,i,folder),7.5,2);
        end
    end
    figure()
    tlo = tiledlayout(3,2,"TileSpacing","compact");
    leg = "Iref12";
    leg2 = "Iref14";
    leg3 = "Iref16";
    for i = 1:5
        ax = nexttile(tlo);
        grid on
        yyaxis left
        hold on
        stairs(ax, bldspn, AnualWeibulHours_Stall(:, i),'r-', 'DisplayName', leg)
        stairs(ax, bldspn, AnualWeibulHours_Stall(:, 5+i),'b-', 'DisplayName', leg2)
        stairs(ax, bldspn, AnualWeibulHours_Stall(:, 10+i),'g-', 'DisplayName', leg3)
        hold off
        xlabel("Blade Span [m]")
        ylabel("Annual Time in Stall [Hours]")
        title(ax, "Annual Time in stall for Pitch " + num2str(pitch(i)))
        ylim([0 205])
        left_limits = ylim(ax);
        % --- Configure the Right Axis (Without Plotting) ---
        yyaxis right
        ylabel("Annual Time in Stall [%]")       
        % Sync the right limits to the left limits scaled to percentage
        ylim(ax, left_limits / 87.6);
        ax.YAxis(2).Color = 'black';
        ax.YAxis(1).Color = 'black';
    end
        title(tlo,"Annual Time in stall Along Blade Span")

    figure()
    tlo = tiledlayout(3,2,"TileSpacing","compact");
    leg = "Iref12";
    leg2 = "Iref14";
    leg3 = "Iref16";
    WSPmean = (WSP(1:end-1) + WSP(2:end)) / 2;
    for i = 1:5
        ax = nexttile(tlo);
        grid on
        yyaxis left
        hold on
        plot(ax, WSPmean, WindStall(:,4, i),'r-', 'DisplayName', leg + " Node4")
        plot(ax, WSPmean, WindStall(:,4, 5+i),'b-', 'DisplayName', leg2 + " Node4")
        plot(ax, WSPmean, WindStall(:,4, 10+i),'g-', 'DisplayName', leg3 + " Node4")
        plot(ax, WSPmean, WindStall(:,5, i),'r--', 'DisplayName', leg + " Node5")
        plot(ax, WSPmean, WindStall(:,5, 5+i),'b--', 'DisplayName', leg2 + " Node5")
        plot(ax, WSPmean, WindStall(:,5, 10+i),'g--', 'DisplayName', leg3 + " Node5")
        hold off
        xlabel("Wind Speed [m/s]")
        ylabel("Annual Time in Stall [Hours]")
        title(ax, "Annual Time in stall for Pitch " + num2str(pitch(i)))
        ylim([0 70])
        left_limits = ylim(ax);
        % --- Configure the Right Axis (Without Plotting) ---
        yyaxis right
        ylabel("Annual Time in Stall [%]")       
        % Sync the right limits to the left limits scaled to percentage
        ylim(ax, left_limits / 87.6);
        ax.YAxis(2).Color = 'black';
        ax.YAxis(1).Color = 'black';
    end
        title(tlo,"Annual Time in stall for different wind speeds")

end