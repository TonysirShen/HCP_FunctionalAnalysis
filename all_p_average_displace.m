%Program to filter subjets fromn The HCP S1200 dataset
%Author:Tony Chen
all_p_file = 'Path to participant ID excel'
stored_data = [cd '/AllPAverDisplacement.xlsx'] 
%REMOVE PARTICIPANTS with exclution cirteria
all_p = ciretria_remove(all_p_file);

%find the average framewise displacement fo9r all participants
all_p_average = zeros(size(all_p));
if exist(stored_data)
    all_p = readtable(stored_data);
else
    for i=1:numel(all_p)
    confoundpath = ['Path to subject task-specific confound table'];
    all_p_average(i) = aveg_movement(confoundpath);
    end
end

%exclue subjects had a higher framewise displacement than cutoff
cutoff = 0.3;
OutlierSub = find(table2array(all_p(:,2)) > cutoff);
all_p(OutlierSub,:) = [];
all_p.Properties.VariableNames = {'Participant_IDs','Aveg_Displacement'}'
writetable(all_p,'FilteredParticipants.xlsx');
