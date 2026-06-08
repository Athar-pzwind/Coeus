function [stallData] = calculatestalltime(Out_DataAll,BladeData,filterflag)
    % CALCULATESTALLTIME Computes aerodynamic stall time percentages across 
    % folders, wind configurations (outfields), seeds, and blade nodes.
    %
    % Inputs:
    %   Out_DataAll  - Nested structure containing aerodynamic simulation tables
    %   BladeData - Nested structure containing blade's data
    %   filterflag - a flag to check if filtering is rquired or not

    %% 1. Configuration & Constants
    Outfolders = fieldnames(Out_DataAll);
    numFolders = length(fieldnames(Out_DataAll));
    static_stall = calcStaticStall(BladeData.Aerofoils);
    % Primary and secondary sensor channel names
    Bldnodes = BladeData.BladeNodes;
    Sensor = (Bldnodes + "Alpha")';
    numNodes = length(Bldnodes);
    maxExpectedSeeds = 100; 
    % Safely query outfields from the first folder to preallocate output matrix
    WSP = fieldnames(Out_DataAll.(Outfolders{1}));
    numWSP = length(WSP);
    % Preallocate final 3D output matrix
    meanperctnear = zeros(numWSP, numNodes, numFolders);
    maxpercentnear = zeros(numWSP, numNodes, numFolders);
    minpercentnear = zeros(numWSP, numNodes, numFolders);
    toll = 5;
    simtime = 599.85;
    dt = 0.15;
    %% 2. Data Processing Pipeline
    for foldernum = 1:numFolders
        % Preallocate metrics tracking arrays for the current folder
        sdpercent     = NaN(maxExpectedSeeds, numNodes, numWSP);
        sdpercentnear = NaN(maxExpectedSeeds, numNodes, numWSP);
        meanperctnearLocal = zeros(numWSP, numNodes);
        maxpercentnearLocal = zeros(numWSP, numNodes);
        minpercentnearLocal = zeros(numWSP, numNodes);
        for i = 1:numWSP
            currentWSP = Out_DataAll.(Outfolders{foldernum}).(WSP{i});
            seeds = fieldnames(currentWSP);
            for s = 1:length(seeds)
                SeedData = currentWSP.(seeds{s});
                % Select appropriate channel and time step
                % Extract Angle of Attack profile safely as a column vector
                current_AoA = parquetread(SeedData,"SelectedVariableNames",Sensor);
                if isempty(current_AoA)
                    continue; 
                end
                % Threshold calculations
                AbvThrOcc_count  = table2array(sum(current_AoA > static_stall(nds),1));
                nearThrOcc_count = table2array(sum(current_AoA > (static_stall(nds) - toll),1));
                % Convert to timeline percentages
                sdpercent(s, :, i)     = ((dt .* AbvThrOcc_count) ./ simtime) * 100;
                sdpercentnear(s, :, i) = ((dt .* nearThrOcc_count) ./ simtime) * 100;
            end
        end
        
        %% 3. Statistical Aggregation
        for i = 1:numWSP
            for nds = 1:numNodes
                % Extract the distribution vector across all seeds
                seedsDistribution = sdpercentnear(:, nds, i);
                % Compute maximums omitting placeholder NaNs
                meanperctnearLocal(i,nds) = mean(seedsDistribution, 'omitnan');
                maxVal = max(seedsDistribution, [], 'omitnan');
                maxpercentnearLocal(i, nds) = maxVal;
                minVal = min(seedsDistribution,[],'omitnan');
                minpercentnearLocal(i, nds) = minVal;
                if filterflag
                    flag = IQRFilter(seedsDistribution,maxVal);
                    temp = seedsDistribution;
                    while flag
                        temp(temp == max(temp, [], 'all', 'omitnan')) = NaN;
                        maxVal = max(temp, [], 'omitnan');
                        flag = IQRFilter(temp,maxVal);                        
                    end
                    maxpercentnearLocal(i, nds) = maxVal;
                end
            end
        end

        % Assign local block data to final output slice
        meanperctnear(:, :, foldernum) = meanperctnearLocal;
        maxpercentnear(:, :, foldernum) = maxpercentnearLocal;
        minpercentnear(:, :, foldernum) = minpercentnearLocal;
        sddata = sdpercentnear(:,5,:);
    end
    stallData.meanperctnear = meanperctnear;
    stallData.maxpercentnear = maxpercentnear;
    stallData.minpercentnear = minpercentnear;
end

%% Support Functions
function flag = IQRFilter(dataset,value)
    sortedset = sort(dataset);
    Q1 = prctile(sortedset,0.25);
    Q3 = prctile(sortedset,0.75);
    IQR = Q3-Q1;
    LowerBound = Q1 - (1.5*IQR);
    UpperBound = Q3 + (1.5*IQR);
    flag = 0;
    if value>UpperBound || value<LowerBound
        flag = 1;
    end
end
