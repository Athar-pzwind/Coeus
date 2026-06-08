%% Data Visualization Pipeline
% Purpose: Processes summary and output files to analyze Turbine characteristics.
% Author: Athar Siddiqui
% Date: 08th June 2026

%% 1. Configuration & Constants
addpath("04_Uitilities"); close all;
% Reading Data
Inputs = readmainfile(); % Data saved in 04_Data\Inputs.mat as a -struc file
% Plotting Preferences
studyLegends = ["Steady", "Turbulent-16Iref", "RTDT Baseline 16% 2pit", "RTDT Baseline 15% 2pit"];
stallLegends = "RTDT Baseline Iref 12";


%% 3. Processing & Plotting
% Generate Comparison Plots
plot_ctr_comp(Inputs.Sum_Data, studyLegends);
calc_Ndstall(Inputs.Sum_Data, Inputs.BladeData, studyLegends);
%%
try
    [stallData] = calculatestalltime(Inputs.Out_Data,Inputs.BladeData,0);
    plot_time_analysis(stallLegends,maxpercentnear);
catch ME
    fprintf('Error in time analysis for %s: %s\n', fieldName, ME.message);
end
%%
plotlinestallmax(stallData.meanperctnear,stallData.maxpercentnear,stallData.minpercentnear)
fprintf('Pipeline completed successfully.\n');

%% Temp
pitch = [0,1,1.5,2,3];
figure(); tlo = tiledlayout(3,1,"TileSpacing","compact");
ax = nexttile; hold on
for i = 1:5
plot(4:1:20,AeroCoeffs.dP(:,5,i),'Displayname',"12Iref Pitch " +num2str(pitch(i)));
end
hold off; xlabel(ax,"Wind Speed"); ylabel(ax,"Power [W]"); title(ax,"segmental power at node 5");
ax = nexttile; hold on;
for i = 1:5
plot(4:1:20,AeroCoeffs.dT(:,5,i),'Displayname',"12Iref Pitch " +num2str(pitch(i)));
end
hold off; xlabel(ax,"Wind Speed"); ylabel(ax,"Thrust [N]"); title(ax,"segmental Thrust at node 5");
ax = nexttile; hold on;
for i = 1:5
plot(4:1:20,AeroCoeffs.dQ(:,5,i),'Displayname',"12Iref Pitch " +num2str(pitch(i)));
end
hold off; xlabel(ax,"Wind Speed"); ylabel(ax,"Torque [N-m]"); title(ax,"segmental Torque at node 5");