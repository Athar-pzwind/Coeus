function Inputs = readmainfile()
    tic
    mainfile = 'Dependencies.txt';
    if ~exist(mainfile, 'file')
        error('The specified file does not exist: %s', mainfile);
    end
    allLines = readlines(mainfile);
    validLinesMask = ~startsWith(allLines, "!");
    allLines = allLines(validLinesMask);
    isHeader = ~cellfun(@isempty, regexp(allLines, '^##[^#]'));
    isSubHeader = ~cellfun(@isempty, regexp(allLines, '^###[^#]'));
    HeaderlineNumbers = find(isHeader);
    headerContents = allLines(isHeader);
    SubHeaderlineNumbers = find(isSubHeader);
    SubheaderContents = strsplit(allLines(isSubHeader));
    for i = 1:length(HeaderlineNumbers)
        if strcmp("##SumFileFolder",headerContents{i})
            SumFolder = allLines(HeaderlineNumbers(i)+1);
        elseif strcmp("##OutFileFolder",headerContents{i})
            outFolders = allLines(HeaderlineNumbers(i)+1:(HeaderlineNumbers(i+1)-1));
        elseif strcmp("##Blade",headerContents{i})
            bladedata = allLines(HeaderlineNumbers(i)+2:HeaderlineNumbers(i+1)-1);
        elseif strcmp("##Sensors",headerContents{i})
            OutSensors = allLines(HeaderlineNumbers(i)+1:length(allLines));
        end
    end
    constrcNewInput = 0;
    if exist('04_Data\Inputs.mat','file')
        fprintf("Old data has been detected\nComparing datasets\n");
        files = dir(fullfile(SumFolder, '*.txt'));
        Suminfo = h5info("04_Data\Inputs.mat", '/Sum_Data');
        SumFolders = {Suminfo.Groups.Name};
        Outinfo = h5info("04_Data\Inputs.mat", '/Out_Data');
        OutFolders = {Outinfo.Groups.Name};
        Bladeinfo = h5info("04_Data\Inputs.mat", '/BladeData');
        BladeChars = {Bladeinfo.Datasets.Name};
        if length(SumFolders)~=length(files)
            fprintf("Summary Folder has been changed\n");
            constrcNewInput = 1;
        elseif length(OutFolders)~=length(outFolders)
            fprintf("Outdata Folders has been changed\n");
            constrcNewInput = 1;
        elseif length(BladeChars)~=length(SubheaderContents)
            fprintf("Blade Data has been changed\n");
            constrcNewInput = 1;
        end
    else
        fprintf("Old data not found\n")
        constrcNewInput = 1;
    end
    if constrcNewInput
        fprintf("reading new data\n")
        Inputs = struct;
        fprintf("reading Sum data\n")
        Inputs.Sum_Data = SumFileread(SumFolder);
        fprintf("reading Out data\n")
        Inputs.Out_Data = OutDataread(outFolders,OutSensors);
        fprintf("reading Blade data\n")
        Inputs.BladeData = getBladeData(bladedata,SubheaderContents);
        if ~exist('04_Data','dir')
            mkdir('04_Data')          
        end
        save('04_Data\Inputs.mat','-struct','Inputs','-v7.3');
    end
    Inputs = load("04_Data\Inputs.mat");
    time2 = toc;
    disp("Operation Completed in "+ num2str(time2)+ "s")
end
%% Support Functions
function [Sum_Data] = SumFileread(sumFolder)
    try
        if ~exist(sumFolder, 'dir'), error('Summary folder not found: %s', sumFolder); end
        [Sum_Data] = read_sum_file(sumFolder);
        fprintf('Successfully loaded Summary Data.\n');
    catch ME
        fprintf('Error loading Summary Data: %s\n', ME.message);
        return; % Exit script if primary data fails
    end
end

function [Out_Data] = OutDataread(outFolders,sensors)
    for i = 1:length(outFolders)
        currentPath = string(outFolders{i});
        try
            if ~exist(currentPath, 'dir')
                warning('Output folder missing, skipping: %s', currentPath);
                continue;
            end
            % Extract a valid field name from the folder path
            pathParts = split(currentPath, filesep);
            rawName = string(pathParts(end-1))+string(pathParts(end));
            safeFieldName = matlab.lang.makeValidName(rawName);
            Out_Data.(safeFieldName) = read_out_file(currentPath,sensors);
        catch ME
            fprintf('Failed to process %s: %s\n', currentPath, ME.message);
        end
    end
end

function [BladeData] = getBladeData(bladedata,SubheaderContents)
    temp = cell(length(bladedata),length(SubheaderContents));
    for n = 1:length(bladedata)
        temp(n,:) = (strsplit(bladedata{n}));
    end
    bladedata = temp;
    for n = 1:length(SubheaderContents)
        validName = regexprep(SubheaderContents{n}, '^###\s*', '');
        validName = matlab.lang.makeValidName(validName);
        if any(~isnan(str2double(string(bladedata(:,n)))))
            bladedata(:,n) = num2cell(str2double(string(bladedata(:,n))));
        end
        BladeData.(validName) = bladedata(:,n);
    end
end