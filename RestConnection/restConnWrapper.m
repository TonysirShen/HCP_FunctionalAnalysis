%name = '/mnt/sml_share/HCP/derivatives/fpp/sub-hcp100206/roi/sub-hcp100206_space-fsLR_den-32k_desc-handDrawnLTPThrP6workingmemoryFacesVsAllOthersSm4Top5Pct_mask.dscalar.nii';
%This is  the Warpper to call fpprestConn, which calculates individual
%whole-brain resting-state correlation maps

studyDir = '/mnt/sml_share/HCP';
testDir = [studyDir '/derivatives/fpp'];%change to '/derivatives/fpp' 
allSubj = readtable([studyDir  '/derivatives/cshen2/FilteredParticipants.xlsx']);
subjects = table2array(allSubj(:,1));
subjets = subjects(1:3);
task = 'workingmemory';
contrast = 'FacesVsAllOthers';
searchNames = {'handDrawnLPRCThrP6','handDrawnRPRCThrP6','handDrawnLTPThrP6','handDrawnRTPThrP6'};%'LTP','RTP'
index = 0;
missi_num = 0;
allfiles = [];
% change the iterable object of the for loop with different tasks
for i = 1:length(subjects)
   for j = 1:length(searchNames)            
       file =[testDir '/'  subjects{i} '/roi/' subjects{i} '_space-fsLR_den-32k_desc-' searchNames{j} task contrast 'Sm4Top5Pct_mask.dscalar.nii'];
            index = index + 1;
            allfiles{index} = file;
   end
end

for i = 1: length(allfiles)
    if ~ exist(allfiles{i},'file')
       logtext = fopen([studyDir '/derivatives/cshen2/logs/Sm4RestConnlog.txt' ],'a');
       fprintf(logtext, '%s Not exist\n', allfiles{i});
       file = (allfiles{i});
    else
        fpprestConn(allfiles{i});
    end
end
