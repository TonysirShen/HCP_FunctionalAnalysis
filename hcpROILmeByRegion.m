
% Script to run condition x hemisphere mixed effects ANOVA for each region
% using functional ROIs from TP and PR.

regions = {{{'handDrawnLTPThrP6','FacesVsAllOthers'},{'handDrawnRTPThrP6','FacesVsAllOthers'}},...
    {{'handDrawnLPRCThrP6','FacesVsAllOthers'},{'handDrawnRPRCThrP6','FacesVsAllOthers'}},...
    {{'handDrawnLPRCThrP6','ToolsVsAllOthers'},{'handDrawnRPRCThrP6','ToolsVsAllOthers'}}};
ReplicationDir = '/mnt/sml_share/HCP/derivatives/fpp/ReplicationResults';
hemisphere = [1,2]; %left = 1 right =2
condition= 1:4; % Face, body, tool, place

for re = 1:length(regions) % TP face, PR face, PR tool

    % Load PSC for hemispheres and conditions
    pscByRegion = [];
    for i = 1:length(regions{re})
        mask = regions{re}{i}{1};
        contrast = regions{re}{i}{2};
        if contains(mask,'RTP') || contains(mask,'LTP')
            ResponseDir = fullfile(ReplicationDir,'TPContrasts');
        else
            ResponseDir = fullfile(ReplicationDir,'PRCContrasts');
        end
        responseMat = load(fullfile(ResponseDir,['space-fsLR_res-2_den-32k_desc-' mask 'workingmemory' contrast 'Top5PctN415Sm4Replication_roiData.mat']));
        %extract working memeory data
        newpscbySub = responseMat.pscBySub(:,7:end);
        %average across two runs
        averagepsc = (newpscbySub(:,1:4) + newpscbySub(:,5:end))/2;
        newSD = std(averagepsc)/sqrt(size(averagepsc,1));
        pscByRegion = [pscByRegion {averagepsc}];
    end
    
    % Create LME table
    conditionID = [];
    subjID = [];
    pscValue = [];
    hemisID = [];
    for r = 1:length(pscByRegion)
        psc = pscByRegion{r};
        for cond = condition
            for subj = 1:size(psc,1)
                conditionID = [conditionID; cond];
                subjID = [subjID;subj];
                hemisID = [hemisID;hemisphere(r)];
                pscValue = [pscValue;psc(subj,cond)];
            end
        end
    end
    
    dataTable{re} = table(pscValue, conditionID,hemisID,subjID, ...
        'VariableNames', {'y', 'Condition','Hemisphere','Subj'});
    dataTable{re}.Condition = categorical(dataTable{re}.Condition);
    dataTable{re}.Hemisphere = categorical(dataTable{re}.Hemisphere);
    dataTable{re}.Subj = categorical(dataTable{re}.Subj);
    
    % LME analysis
    lmFormula{re} = 'y~Condition*Hemisphere+(1|Subj)';
    lmeResult{re} = fitlme(dataTable{re}, lmFormula{re});
    ANOVA{re} = anova(lmeResult{re});

end