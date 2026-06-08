function [Sum_Data] = read_sum_file(folder)
    files = dir(fullfile(folder, '*.txt'));
    Sum_Data = struct();

    for z=1:numel(files)
        baseFileName = files(z).name;
        fullFileName = fullfile(files(z).folder, baseFileName);
        file_name=['File', num2str(z)];

        [filebyline, n_lines] = read_file(fullFileName);
    
        header_row_ids = [];
        for i=1:n_lines
            if strncmpi('-',filebyline{i},1)
                header_row_ids(end+1) = i;
            end
        end
        no_h = length(header_row_ids);
        header_titles = cell(1,no_h);
        for i=1:no_h
            splitted=split(strtrim(filebyline{header_row_ids(i)}));
            header_titles{i} = splitted{2};
        end

        data = struct();
        
        for i=1:length(header_titles)
            stats = struct();
            headers = strsplit(strtrim(filebyline{header_row_ids(i)+2}));

            removeMask = contains(headers, '(') | contains(headers, 'Method');
            headers(removeMask) = [];
            keepIdx=find(~removeMask);
            if i<length(header_titles)
                nRows = header_row_ids(i+1) - header_row_ids(i) - 4;
            end
            data_bld = zeros(nRows,length(headers));
            for j=1:nRows
                tline = strsplit(strtrim(filebyline{header_row_ids(i)+j+2}));
                for p=1:length(headers)
                    data_bld(j,p) = str2double(tline{p});
                end
            end
            for p = 1:length(headers)
                validName = matlab.lang.makeValidName(headers{p});
                stats.(validName) = data_bld(:,p);
            end
            validTitle = matlab.lang.makeValidName(header_titles{i});
            data.(validTitle)=stats;
        end
        tmp = data;
        Sum_Data.(file_name) = tmp;
        clear tmp
        % clear file_name
    end
end

%% Supporting functions
function [file_by_line, n_lines] = read_file(file)
    content = readlines(file);
    n_lines=length(content);
    file_by_line = cell(n_lines,1);
    for i=1:n_lines
        file_by_line{i,1} = content(i);
    end
end