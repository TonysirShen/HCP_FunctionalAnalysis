

function fixedSubjs = ciretria_remove(IDtablepath)
participant_table = IDtablepath;
allSubjs_data = readtable(participant_table);
exclude = table2cell(allSubjs_data(:,3));
allSubjs = table2cell(allSubjs_data(:,1));
excludeIDs = find(ismember(allSubjs,exclude));
allSubjs(excludeIDs,:) = []; 
fixedSubjs = allSubjs;
