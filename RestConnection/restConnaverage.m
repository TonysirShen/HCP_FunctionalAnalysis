%This ios the script to calculate a group-average whole-brain resting-state
%corraltion map
%Input: Assume all individual resting-state maps are generated using
%restConnWrapper.
studyDir = '/mnt/sml_share/HCP/derivatives/cshen2/Sm4restconn';
allSubjs = readtable('/mnt/sml_share/HCP/derivatives/cshen2/BalancedDiscoveryIDs.xlsx');
allSubjs = table2array(allSubjs(:,1));
Regions = {'handDrawnRPRCThrP6','handDrawnLPRCThrP6','handDrawnLTPThrP6','handDrawnRTPThrP6'};%,'mmpRFFA','mmpLFFA'};%,'LTP'};
index = 0;
missed_Region = [];
for j= 1:numel(Regions)
    files = {};
    for i = 1:numel(allSubjs)
        subjectDir = [studyDir,'/',allSubjs{i},'_Sm4_task-rest_space-fsLR_res-2_den-32k_funcconn'];
        try
            file =[subjectDir,'/',allSubjs{i},'_task-rest_ROI-_space-fsLR_res-2_den-32k_desc-fixdenoisedSeed',Regions{j},'workingmemoryToolsVsAllOthersSm4Top5Pct_rstat.dscalar.nii'];
            files{end + 1} = file;
        catch
            passthrough
        end
        if i == 1, disp(file);end
   
    end
    if numel(files) ~= 415 %number of subjects
        missed_Region(end + 1) = Regions{j}
    end
    disp("Getting all datas... for" + Regions(j));%%neeed to fix
    allData = cellfun(@fpp.util.readDataMatrix, files, 'UniformOutput', false);
    disp("Converting into 3D array... for" + Regions(j));
    data3D = cat(3, allData{:});
    disp("Calculating mean... for" + Regions(j))
    meandata = mean(data3D,3);
    [temp,hdr] = fpp.util.readDataMatrix(files{1});
    disp("Writing OutPut... for" + Regions(j));
    OutputDir = ['/mnt/sml_share/HCP/derivatives/cshen2/Sm4avgRestConn/',Regions{j}]
    if ~exist(OutputDir,'dir'), mkdir(OutputDir); end
    OutputPath = [OutputDir,'/HCP_task-rest_ROI-Seed',Regions{j},'ThrP6workingmemoryTool sVsAllOthersSm4Top5PctDiscovery_avgrstat.dscalar.nii'];
    fpp.util.writeDataMatrix(meandata,hdr,OutputPath)
end
