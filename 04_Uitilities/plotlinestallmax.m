function plotlinestallmax(meanpercentnear,maxpercentnear,minpercentnear)
    pitch = [0, 1, 1.5, 2, 3];
    WSP = 4:2:14;
    folders = length(meanpercentnear(1,1,:));
    for i = 1:folders
        stallTimemean = meanpercentnear(1:2:11,:,i);
        stallTimemax = zeros(size(meanpercentnear(1:2:11,:,i)));
        stallTimemin = zeros(size(meanpercentnear(1:2:11,:,i)));
        if nargin>1
            stallTimemax = maxpercentnear(1:2:11,:,i);
        end
        if nargin>2
            stallTimemin = minpercentnear(1:2:11,:,i);
        end
        if i>10
            [ydatamean(i-10,3), ~] = max(stallTimemean, [], 'all');
            [ydatamax(i-10,3), idx] = max(stallTimemax, [], 'all');
            [ydatamin(i-10,3), ~] = max(stallTimemin, [], 'all');
            stallData = max(stallTimemean, [], 2);
            ydataAnnual(i-10,3) = stalldistribution(WSP,stallData,7.5,2)*100/8760;
        elseif i>5
            [ydatamean(i-5,2), ~] = max(stallTimemean, [], 'all');
            [ydatamax(i-5,2), idx] = max(stallTimemax, [], 'all');
            [ydatamin(i-5,2), ~] = max(stallTimemin, [], 'all');
            stallData = max(stallTimemean, [], 2);
            ydataAnnual(i-5,2) = stalldistribution(WSP,stallData,7.5,2)*100/8760;
        else
            [ydatamean(i,1), ~] = max(stallTimemean, [], 'all');
            [ydatamax(i,1), idx] = max(stallTimemax, [], 'all');
            [ydatamin(i,1), ~] = max(stallTimemin, [], 'all');
            stallData = max(stallTimemean, [], 2);
            ydataAnnual(i,1) = stalldistribution(WSP,stallData,7.5,2)*100/8760;
        end
    end
    tit = "Statistics of Time in Stall";
    figure()
    hold on;
    grid minor;
    plot(pitch,ydatamean(:,3),'g-o','DisplayName','16% Iref mean')
    plot(pitch,ydatamean(:,2),'b-o','DisplayName','14% Iref mean')
    plot(pitch,ydatamean(:,1),'r-o','DisplayName','12% Iref mean')
    plot(pitch,ydatamax(:,3),'g--*','DisplayName','16% Iref max')
    plot(pitch,ydatamax(:,2),'b--*','DisplayName','14% Iref max')
    plot(pitch,ydatamax(:,1),'r--*','DisplayName','12% Iref max')
    plot(pitch,ydatamin(:,3),'g-.+','DisplayName','16% Iref min')
    plot(pitch,ydatamin(:,2),'b-.+','DisplayName','14% Iref min')
    plot(pitch,ydatamin(:,1),'r-.+','DisplayName','12% Iref min')
    ylim([0,50]);
    title(tit)
    xlabel("Pitch-Setting")
    ylabel("% Time in Stall")
    hold off;
    figure()
    hold on;
    grid minor;
    plot(pitch,ydataAnnual(:,3),'g-o','DisplayName','16% Iref Anuall Stall')
    plot(pitch,ydataAnnual(:,2),'b-o','DisplayName','14% Iref Anuall Stall')
    plot(pitch,ydataAnnual(:,1),'r-o','DisplayName','12% Iref Anuall Stall')
    xlabel("Pitch-Setting")
    ylabel("Annual Time in Stall [%]")
    title("Annual Time spent in Stall [Percent]")
    hold off;
end
