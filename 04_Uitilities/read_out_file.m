function [Out_Data] = read_out_file(folder, selectedVars)
    % Find all target files
    files = dir(fullfile(folder, '*.out'));
    numFiles = numel(files);
    Out_Data = struct();
    
    if numFiles == 0
        return;
    end
    parquetFolder = fullfile(folder, "ParquetFiles");
    if ~exist(parquetFolder,"dir")
        mkdir(parquetFolder)
    else
        return;
    end

    %% 1. Preallocate Arrays for Parallel Processing
    mainNames    = cell(numFiles, 1);
    seedNames    = cell(numFiles, 1);
    dataTables   = cell(numFiles, 1);
    parquetPaths = cell(numFiles, 1);

    %% 2. Parallel File Reading Loop
    parfor z = 1:numFiles
        baseFileName = files(z).name;
        fullFileName = fullfile(files(z).folder, baseFileName);
        
        fileID = fopen(fullFileName, 'r');
        if fileID == -1, continue; end
        
        % Skip the first 6 header lines
        for k = 1:6
            fgetl(fileID);
        end
        
        % Row 7: Read Variable Names
        varLine = fgetl(fileID);
        varNames = regexp(strtrim(varLine), '\s+', 'split');
        
        % Row 8: Skip Units line
        fgetl(fileID);
        
        % Filter columns to save memory
        keepIdx = ismember(varNames, selectedVars);
        
        % Create format specifier: %f for kept, %*f to skip completely
        formatSpec = repmat("%*f", 1, numel(varNames)); 
        formatSpec(keepIdx) = "%f";                    
        formatStr = join(formatSpec, " ");
        
        % Read numerical data directly
        dataCells = textscan(fileID, formatStr, 'CollectOutput', true);
        fclose(fileID);
        
        % Fast string parsing for hierarchy mapping
        splitted = split(baseFileName, '_');
        mainNames{z}  = matlab.lang.makeValidName(splitted{2});
        
        % Drop the ".out" extension to make it a valid key
        [~, cleanSeedName, ~] = fileparts(baseFileName);
        seedNames{z}  = matlab.lang.makeValidName(cleanSeedName);
        
        % Store temporarily as an optimized Table
        keptVarNames = varNames(keepIdx);
        dataTables{z} = array2table(dataCells{1}, 'VariableNames', keptVarNames);
        
        % Prepare the output Parquet file path destination
        
        parquetPaths{z} = fullfile(parquetFolder, [cleanSeedName, '.parquet']);
    end

    %% 3. Sequential Assembly: Write Parquet & Create a Lightweight Path Map
    % Instead of keeping gigabytes of tables alive in RAM, we write them to disk
    % and return a struct of text strings mapping their file paths.
    for z = 1:numFiles
        if isempty(dataTables{z}), continue; end
        
        % A. Save the table directly to disk as a highly compressed columnar Parquet file
        % (This completely clears it from the active pipeline memory stream)
        parquetwrite(parquetPaths{z}, dataTables{z});
        
        % B. Save ONLY the path string to your structure output (takes up virtually 0 bytes of RAM)
        Out_Data.(mainNames{z}).(seedNames{z}) = parquetPaths{z};
        
        % C. Force immediate memory reclamation of the table variable block
        dataTables{z} = []; 
    end
end

% function [Out_Data] = read_out_file(folder,selectedVars)
%     % Find all target files
%     files = dir(fullfile(folder, '*.out'));
%     numFiles = numel(files);
%     Out_Data = struct();
% 
%     if numFiles == 0
%         return;
%     end
% 
%    %% 1. Optimize Import Setup (Do this once)
%     % Read the first file's metadata to create a reusable blueprint
%     % firstFile = fullfile(files(1).folder, files(1).name);
%     % opts = detectImportOptions(firstFile, "FileType", "text");
%     % 
%     % % Explicitly define OpenFAST's file anatomy
%     % opts.VariableNamesLine = 7; % Row 7 contains the names
%     % opts.VariableUnitsLine = 8; % Row 8 contains the units
%     % opts.DataLines         = [9, Inf]; % Actual data starts on Row 9
%     % 
%     % % Preserve column names exactly as they are written in the file
%     % opts.VariableNamingRule = 'preserve';
% 
%     %% 2. Preallocate Arrays for Parallel Processing
%     % parfor cannot directly build nested dynamic structures.
%     % Instead, we store data in temporary flat cell arrays.
%     mainNames  = cell(numFiles, 1);
%     seedNames  = cell(numFiles, 1);
%     dataTables = cell(numFiles, 1);
% 
%     %% 3. Parallel File Reading Loop
%     % Change 'for' to 'parfor' to use all available CPU cores
%     parfor z = 1:numFiles
%         baseFileName = files(z).name;
%         fullFileName = fullfile(files(z).folder, baseFileName);
%         fileID = fopen(fullFileName, 'r');
%         for k = 1:6
%             fgetl(fileID);
%         end
%         varLine = fgetl(fileID);
%         varNames = regexp(strtrim(varLine), '\s+', 'split');
%         fgetl(fileID);
%         keepIdx = ismember(varNames, selectedVars);
%         formatSpec = repmat("%*f", 1, numel(varNames)); 
%         formatSpec(keepIdx) = "%f";                    
%         formatStr = join(formatSpec, " ");
%         dataCells = textscan(fileID, formatStr, 'CollectOutput', true);
%         fclose(fileID);
%         % Fast string parsing
%         splitted = split(baseFileName, '_');
% 
%         % Store structural keys and read data using the template
%         mainNames{z}  = matlab.lang.makeValidName(splitted{2});
%         seedNames{z}  = matlab.lang.makeValidName(baseFileName);
%         % dataTables{z} = readtable(fullFileName, opts);
%         keptVarNames = varNames(keepIdx);
%         dataTables{z} = array2table(dataCells{1}, 'VariableNames', keptVarNames);
%     end
% 
%     %% 4. Sequential Structure Assembly
%     % Combining the data arrays into your target struct format.
%     % This loop happens purely in RAM and is extremely fast.
%     for z = 1:numFiles
%         datastruct = table2struct(dataTables{z});
%         Out_Data.(mainNames{z}).(seedNames{z}) = datastruct;
%         dataTables{z} = [];
%     end
% end

% function [Out_Data] = read_out_file(folder)
%     files = dir(fullfile(folder, '*.out'));
%     Out_Data = struct();
% 
%     for z=1:numel(files)
%         baseFileName = files(z).name;
%         fullFileName = fullfile(files(z).folder, baseFileName);
%         file_name=['File', num2str(z)];
%         data = readtable(fullFileName,"FileType","text","Range",[7 1]);
%         validseedName = matlab.lang.makeValidName(baseFileName);
%         splitted=split(baseFileName,'_');
%         validmainName = matlab.lang.makeValidName(splitted{2});
%         Out_Data.(validmainName).(validseedName)=data;
%     end
% end