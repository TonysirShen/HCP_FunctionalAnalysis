% GET ALL ARTICIPANTS id
all_p_file = '/mnt/local_share/HCP/derivatives/cshen2/hcpParticipantIds_resttest_completeList.xlsx'
stored_data = [cd '/AllPAverDisplacement.xlsx'] 
%REMOVE PARTICIPANTS with exclution cirteria
all_p = ciretria_remove(all_p_file);

%find the average framewise displacement fo9r all participants
all_p_average = zeros(size(all_p));
if exist(stored_data)
    all_p = readtable(stored_data);
else
    for i=1:numel(all_p)
    confoundpath = ['/mnt/local_share/HCP/derivatives/fpp/',all_p{i},'/func/',all_p{i},'_task-workingmemory_run-01_confounds.tsv'];
    all_p_average(i) = aveg_movement(confoundpath);
    end
end

%exclue subjects had a higher F_D than cutoff
cutoff = 0.3;
OutlierSub = find(table2array(all_p(:,2)) > cutoff);
all_p(OutlierSub,:) = [];
all_p.Properties.VariableNames = {'Participant_IDs','Aveg_Displacement'}'
writetable(all_p,'FilteredParticipants.xlsx');