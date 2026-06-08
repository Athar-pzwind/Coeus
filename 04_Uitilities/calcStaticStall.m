function static_stall = calcStaticStall(af_files)
    num_af = length(af_files);
    static_stall = zeros(num_af, 1);
    for i = 1:num_af
        % Read table and find Alpha at max Cl
        temp_data = readtable(af_files{i}, 'Range', [55 1]);
        [~, max_cl_idx] = max(temp_data.Var2);
        static_stall(i) = temp_data.Var1(max_cl_idx);
    end
end