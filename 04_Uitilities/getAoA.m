function [AoA_mean,AoA_max,AoA_min] = getAoA(Sum_Data,Bldnodes)
    fields = fieldnames(Sum_Data);
    current_mean = Sum_Data.(fields{1}).Mean;
    Wsp = round(current_mean.WindHubVelX(:),2);
    AoA_mean = zeros(length(Bldnodes),length(Wsp),length(fields));
    AoA_max = zeros(length(Bldnodes),length(Wsp),length(fields));
    AoA_min = zeros(length(Bldnodes),length(Wsp),length(fields));
    for i = 1:length(fields)
        % Get the AOAs at different wind speeds for all files
        f_name = fields{i};
        current_mean = Sum_Data.(f_name).Mean;
        current_max = Sum_Data.(f_name).Max;
        current_min = Sum_Data.(f_name).Min;
        for nd = 1:length(Bldnodes)
            AoA_mean(nd,:,i) = current_mean.(Bldnodes{nd});
            AoA_max(nd,:,i) = current_max.(Bldnodes{nd});
            AoA_min(nd,:,i) = current_min.(Bldnodes{nd});
        end
    end
end