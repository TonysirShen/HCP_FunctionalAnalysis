%a workspace for onetime use/draft scripts, not intened to run as a whole script

allSubjs = readtable('/mnt/sml_share/HCP/derivatives/cshen2/FilteredParticipants.xlsx');
folderPath = '/mnt/sml_share/HCP/derivatives/cshen2/working_Sm4'
allSubjs = table2array(allSubjs(:,1));
studyDir = '/mnt/sml_share/HCP';
fppDir = [studyDir '/derivatives/fpp'];
%h = waitbar(0,'Progress');
searchNames = {'mmpApexLSFG'};
tasks = {'FacesVsAllOthers'};%,'ToolsVsFaces','PlacesVsTools'};
missed_Participants= {};

for s= 1:4
    
end
searchNames = {'handDrawnLTPThrP6','handDrawnRTPThrP6','handDrawnLPRCThrP6','handDrawnRPRCThrP6',...
    'mmpApexLASTS','mmpApexRASTS','mmpApexLMPC','mmpApexRMPC','mmpApexLMPFC','mmpApexRMPFC'...
    'mmpApexLSFG','mmpApexRSFG','mmpApexLTH','mmpApexRTH','mmpApexLTPJ','mmpApexRTPJ'...
    'mmpLFFA','mmpRFFA','mmpLOFA','mmpROFA','mmpLPSTS','mmpRPSTS'};
len = numel(allSubjs);
%% search paritcipants file
for s = 1:length(searchNames)
    for t = 1:length(tasks)
    task = tasks{t};
    searchName = searchNames{s};
    h = waitbar(0,[searchName task '  Progress']);
for i = 1:length(allSubjs)
    subj = allSubjs{i};
    subjDir = [fppDir '/' subj];
    roiDir = [subjDir '/roi'];
    file = [roiDir '/' subj '_space-fsLR_den-32k_desc-' searchName 'workingmemory' task 'Sm4Top5Pct_mask.dscalar.nii'];
    %inputfile = [folderPath,'/',file];
    %targetfolder = ['/mnt/local_share/HCP/derivatives/fpp/',allSubjs{i},'/func']
    if exist(file,'file')
        waitbar(i/len,h)
       % movefile(file,[roiDir '/' subj '_space-fsLR_den-32k_desc-' searchName 'workingmemoryFacesVsBodySm4Top5Pct_mask.dscalar.nii'])
        continue
    else

        %missed_Participants{end +1} = subj;
        %waitbar(i/len,h)
       error([subj searchName '   roi file noT exist   PATH:' file])
    end
end
    end
end

%% check group file 
groupDir = [fppDir '/group' ];
for i = 1:length(All_searchNames)
    file = [groupDir '/'];
end
%%
for s=1:length(subjects)
     subject = subjects{s};
    subjDir = [fppDir '/' subject];
    wmmodelDir = [subjDir '/analysis'];
    wmmodelDir = [subjDir '/analysis/' subject '_task-workingmemory_space-fsLR_res-2_den-32k_model2arma'];
    filePath =[wmmodelDir '/' subject '_task-workingmemory_space-fsLR_res-2_den-32k_desc-FacesVsAllOthersFDR0p05_zstat.dscalar.nii']
    matrix = fpp.util.readDataMatrix(filePath);
    matrix = -1 * matrix;
    outPath = [wmmodelDir '/' subject '_task-workingmemory_space-fsLR_res-2_den-32k_desc-AllOthersVsFacesFDR0p05_zstat.dscalar.nii'];
    fpp.util.writeDataMatrix(matrix,hdr,outPath);
end

%%
temp = [0 0 0];
colorcat = nan(30492,17);
colorindex = ones(1,17);
num_color = 0;
for c = 1:length(colors)
    if temp ~= colors(c,:)
        num_color = num_color + 1;
        temp = colors(c,:);
    end
    colorcat(colorindex,num_color)
end
for c = 1:length(colors)
    current = c
    color = colors(c,:);
    fid = fopen(labeltxtPath,'a');
    fprintf(fid,'MSHBMP_%d\n',c);
    fprintf(fid,'%d %d %d %d %d\n',[c color 255]);
    fclose(fid);
end
%%
allzstat = []
parfor s = 1:length(allSubjs)
        subject = allSubjs{s};
        subjDir = [fppDir '/' subject];
        anasDir = [subjDir '/analysis'];
        roiDir = [subjDir '/roi'];
        subjzstat = []
        for r = 1:nrun
            modelarDir = [anasDir '/' subject '_task-workingmemory_run-' fpp.util.numPad(r,2) '_space-fsLR_res-2_den-32k_modelarma'];
            zstatfile = [modelarDir '/' subject '_task-workingmemory_run-' fpp.util.numPad(r,2) '_space-fsLR_res-2_den-32k_desc-' contrast_name '_zstat.dscalar.nii'];
            if~exist(zstatfile,'file');error([subject ' zstat file not exist']);end
            subjzstat = [subjzstat fpp.util.readDataMatrix(zstatfile)]
        end
        subjzstat = mean(subjzstat,2);
        allzstat = [allzstat subjzstat ]
        disp(['finish ' subject])
end
meanzstat = mean(allzstat,2);

