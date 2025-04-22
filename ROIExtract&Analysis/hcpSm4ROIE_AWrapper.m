%% Wrapper for Sm4hcpROIExtract, across specific search spaces and defrast_nameining contrasts.
% TODO: trouble shooting 3 extra comparsion matrix.
%% Working Memory - Temporal Pole
%Extract temporal pole responses in working memory task, regions defined with
%workingmemory FacesVsAllOthers
contrast_names= {'FacesVsAllOthers'};
searchNames = {'handDrawnLTPThrP6','handDrawnRTPThrP6','handDrawnLPRCThrP6','handDrawnRPRCThrP6',...
    'mmpApexLASTS','mmpApexRASTS','mmpApexLMPC','mmpApexRMPC','mmpApexLMPFC','mmpApexRMPFC'...
    'mmpApexLSFG','mmpApexRSFG','mmpApexLTPJ','mmpApexRTPJ'...
    'mmpLFFA','mmpRFFA','mmpLOFA','mmpROFA','mmpLPSTS','mmpRPSTS'};%contrast,'handDrawnLPRCThrP6','handDrawnRPRCThrP6'};%1/4
allSubj = readtable(['/mnt/sml_share/HCP/derivatives/cshen2/FilteredParticipants.xlsx']);
%contrasts = contrasts(1:2)
for s=1:length(searchNames)
    searchName = searchNames{s};
    for t = 1:length(contrast_names)
    task = contrast_names{t};
    disp(['Start extracting for   ' searchName,task])
    hcpSm4ROIExtract_Analysis('workingmemory',task,searchName,1);
    end
end

%% Working Memory - Perirhinal Cortex 
%Extract perirhinal cortex responses in working memory task, regions defined with
%workingmemory FacesVsAllOthers
contrast_names=  {'FacesVsAllOthers'};
searchNames = {'mmpApexLSFG'};
for s=1:length(searchNames)
    searchName = searchNames{s};
    for t = 1:length(contrast_names)
    task = contrast_names{t};
    disp(['Start extracting for   ' searchName,task])
    hcpSm4ROIExtract_Analysis('workingmemory',task,searchName,1);
    end
end
%%
contrast_names =  {'PlacesVsTools'};
searchNames = {'handDrawnLPRCThrP6'};
for s=1:length(searchNames)
    searchName = searchNames{s};
    for t = 1:length(contrast_names)
    task = contrast_names{t};
    disp(['Start extracting for   ' searchName,task])
    hcpSm4ROIExtract_Analysis('workingmemory',task,searchName,1);
    end
end

% %% DMN area - ASTS 
% searchNames = {'mmpApexRASTS'};%,'mmpApexLMPC','mmpApexLMPFC','mmpApexLSFG',...
%      %'mmpApexLTH','mmpApexLTPJ'}
% for s=1:length(searchNames)
%     disp(['Start extracting for   ' searchNames{s}])
%     hcpSm4ROIExtract_Analysis('workingmemory','FacesVsBody',searchNames{s},1);
%  end

% %% DMN areas - MPC 
% searchNames = {'mmpApexRMPC','mmpApexLMPC'};
% for s=1:length(searchNames)
%     disp(['Start extracting for   ' searchNames{s}])
%     hcpSm4ROIExtract_Analysis('workingmemory','FacesVsBody',searchNames{s},1);
% end

% %% DMN areas - MPFC 
% searchNames = {'mmpApexLMPFC','mmpApexRMPFC'}
% for s=1:length(searchNames)
%     disp(['Start extracting for   ' searchNames{s}])
%     hcpSm4ROIExtract_Analysis('workingmemory','FacesVsBody',searchNames{s},1);
% end

% %% DMN areas - SFG 
% searchNames = {'mmpApexLSFG','mmpApexRSFG'};
% for s=1:length(searchNames)
%     disp(['Start extracting for   ' searchNames{s}])
%     hcpSm4ROIExtract_Analysis('workingmemory','FacesVsBody',searchNames{s},1);
% end

% %% DMN areas - TH 
% searchNames = {'mmpApexRTH','mmpApexLTH'};
% for s=1:length(searchNames)
%     disp(['Start extracting for   ' searchNames{s}])
%     hcpSm4ROIExtract_Analysis('workingmemory','FacesVsBody',searchNames{s},1);
% end

%% DMN areas - TPJ - working
searchNames = {'mmpApexRTPJ'}
contrast = 'ToolsVsAllOthers'
for s=1:length(searchNames) 
    disp(['Start extracting for   ' searchNames{s}])
    hcpSm4ROIExtract_Analysis('workingmemory',contrast,searchNames{s},1);
end

%% Face processing network - FFA 
searchNames = {'mmpRFFA','mmpLFFA'}
contrast = 'ToolsVsAllOthers'
for s=1:length(searchNames)
    disp(['Start extracting for   ' searchNames{s}])
    hcpSm4ROIExtract_Analysis('workingmemory',contrast,searchNames{s},1);
end

%% Face processing network - OFA 
searchNames = {'mmpLOFA','mmpROFA'}
contrast = 'ToolsVsAllOthers'
for s=1:length(searchNames)
    disp(['Start extracting for   ' searchNames{s}])
    hcpSm4ROIExtract_Analysis('workingmemory',contrast,searchNames{s},1);
end

%% Face processing network - PSTS
searchNames = {'mmpLPSTS'}
contrast = 'ToolsVsAllOthers'
for s=1:length(searchNames)
    disp(['Start extracting for   ' searchNames{s}])
    hcpSm4ROIExtract_Analysis('workingmemory',contrast,searchNames{s},1);
end 
% %% Emotion
% % Extract ROI responses in emotion network, regions defined with emotion
% % FearVsNeut
% searchNames = {'handDrawnLPRCThrP6','handDrawnLTPThrP6','handDrawnRPRCThrP6','handDrawnRTPThrP6'};
% for s=1:length(searchNames)
%     hcpROIExtract('emotion','FearVsNeut',searchNames{s},1,'inputSuffix');
% end
% 
% %% Emotion
% % Extract ROI responses in emotion network, regions defined with emotion
% % NeutVsFear
% searchNames = {'handDrawnLPRCThrP6','handDrawnLTPThrP6','handDrawnRPRCThrP6','handDrawnRTPThrP6'};
% for s=1:length(searchNames)
%     hcpROIExtract('emotion','NeutVsFear',searchNames{s},1,'inputSuffix');
% end
% 
% %% Language
% % Extract ROI responses in language network, regions defined with language
% % StoryVsMath
% searchNames = {'handDrawnLPRCThrP6','handDrawnLTPThrP6','handDrawnRPRCThrP6','handDrawnRTPThrP6'};
% for s=1:length(searchNames)
%     hcpROIExtract('language','StoryVsMath',searchNames{s},1,'inputSuffix');
% end
% 
% %% Language
% % Extract ROI responses in language network, regions defined with language
% % MathVsStory
% searchNames = {'handDrawnLPRCThrP6','handDrawnLTPThrP6','handDrawnRPRCThrP6','handDrawnRTPThrP6'};
% for s=1:length(searchNames)
%     hcpROIExtract('language','MathVsStory',searchNames{s},1,'inputSuffix');
% end
% 
% %% Social
% % Extract ROI responses in social network, regions defined with social
% % MentalVsRnd
% searchNames = {'handDrawnLPRCThrP6','handDrawnLTPThrP6','handDrawnRPRCThrP6','handDrawnRTPThrP6'};
% for s=1:length(searchNames)
%     hcpROIExtract('social','MentalVsRnd',searchNames{s},1,'inputSuffix');
% end
% 
% %% Social
% % Extract ROI responses in language network, regions defined with language
% % RndVsMental
% searchNames = {'handDrawnLPRCThrP6','handDrawnLTPThrP6','handDrawnRPRCThrP6','handDrawnRTPThrP6'};
% for s=1:length(searchNames)
%     hcpROIExtract('social','RndVsMental',searchNames{s},1,'inputSuffix');
% end
% 
% %% Working Memory
% % Extract ROI responses in working memory network, regions defined with
% % workingmemory FacesVsAllOthers
% searchNames = {'handDrawnLPRCThrP6','handDrawnLTPThrP6','handDrawnRPRCThrP6','handDrawnRTPThrP6'};
% for s=1:length(searchNames)
%     hcpROIExtract('workingmemory','FacesVsAllOthers',searchNames{s},1,'inputSuffix');
% end
% 
% %% Working Memory
% % Extract ROI responses in working memory network, regions defined with
% % workingmemory FacesVsBody
% searchNames = {'handDrawnLPRCThrP6','handDrawnLTPThrP6','handDrawnRPRCThrP6','handDrawnRTPThrP6'};
% for s=1:length(searchNames)
%     hcpROIExtract('workingmemory','FacesVsBody',searchNames{s},1,'inputSuffix');
% end
% 
% %% Working Memory
% % Extract ROI responses in working memory network, regions defined with
% % workingmemory FacesVsTools
% searchNames = {'handDrawnLPRCThrP6','handDrawnLTPThrP6','handDrawnRPRCThrP6','handDrawnRTPThrP6'};
% for s=1:length(searchNames)
%     hcpROIExtract('workingmemory','FacesVsTools',searchNames{s},1,'inputSuffix');
% end
% 
% %% Working Memory
% % Extract ROI responses in working memory network, regions defined with
% % workingmemory FacesVsPlaces
% searchNames = {'handDrawnLPRCThrP6','handDrawnLTPThrP6','handDrawnRPRCThrP6','handDrawnRTPThrP6'};
% for s=1:length(searchNames)
%     hcpROIExtract('workingmemory','FacesVsPlaces',searchNames{s},1,'inputSuffix');
% end
% 
% %% Working Memory
% % Extract ROI responses in working memory network, regions defined with
% % workingmemory BodyVsAllOthers
% searchNames = {'handDrawnLPRCThrP6','handDrawnLTPThrP6','handDrawnRPRCThrP6','handDrawnRTPThrP6'};
% for s=1:length(searchNames)
%     hcpROIExtract('workingmemory','BodyVsAllOthers',searchNames{s},1,'inputSuffix');
% end
% 
% %% Working Memory
% % Extract ROI responses in working memory network, regions defined with
% % workingmemory BodyVsFaces
% searchNames = {'handDrawnLPRCThrP6','handDrawnLTPThrP6','handDrawnRPRCThrP6','handDrawnRTPThrP6'};
% for s=1:length(searchNames)
%     hcpROIExtract('workingmemory','BodyVsFaces',searchNames{s},1,'inputSuffix');
% end
% 
% %% Working Memory
% % Extract ROI responses in working memory network, regions defined with
% % workingmemory BodyVsTools
% searchNames = {'handDrawnLPRCThrP6','handDrawnLTPThrP6','handDrawnRPRCThrP6','handDrawnRTPThrP6'};
% for s=1:length(searchNames)
%     hcpROIExtract('workingmemory','BodyVsTools',searchNames{s},1,'inputSuffix');
% end
% 
% %% Working Memory
% % Extract ROI responses in working memory network, regions defined with
% % workingmemory BodyVsPlaces
% searchNames = {'handDrawnLPRCThrP6','handDrawnLTPThrP6','handDrawnRPRCThrP6','handDrawnRTPThrP6'};
% for s=1:length(searchNames)
%     hcpROIExtract('workingmemory','BodyVsPlaces',searchNames{s},1,'inputSuffix');
% end
% 
% %% Working Memory
% % Extract ROI responses in working memory network, regions defined with
% % workingmemory ToolsVsAllOthers
% searchNames = {'handDrawnLPRCThrP6','handDrawnLTPThrP6','handDrawnRPRCThrP6','handDrawnRTPThrP6'};
% for s=1:length(searchNames)
%     hcpROIExtract('workingmemory','ToolsVsAllOthers',searchNames{s},1,'inputSuffix');
% end
% 
% %% Working Memory
% % Extract ROI responses in working memory network, regions defined with
% % workingmemory ToolsVsFaces
% searchNames = {'handDrawnLPRCThrP6','handDrawnLTPThrP6','handDrawnRPRCThrP6','handDrawnRTPThrP6'};
% for s=1:length(searchNames)
%     hcpROIExtract('workingmemory','ToolsVsFaces',searchNames{s},1,'inputSuffix');
% end
% 
% %% Working Memory
% % Extract ROI responses in working memory network, regions defined with
% % workingmemory ToolsVsBody
% searchNames = {'handDrawnLPRCThrP6','handDrawnLTPThrP6','handDrawnRPRCThrP6','handDrawnRTPThrP6'};
% for s=1:length(searchNames)
%     hcpROIExtract('workingmemory','ToolsVsBody',searchNames{s},1,'inputSuffix');
% end
% 
% %% Working Memory
% % Extract ROI responses in working memory network, regions defined with
% % workingmemory ToolsVsPlaces
% searchNames = {'handDrawnLPRCThrP6','handDrawnLTPThrP6','handDrawnRPRCThrP6','handDrawnRTPThrP6'};
% for s=1:length(searchNames)
%     hcpROIExtract('workingmemory','ToolsVsPlaces',searchNames{s},1,'inputSuffix');
% end
% 
% %% Working Memory
% % Extract ROI responses in working memory network, regions defined with
% % workingmemory PlacesVsAllOthers
% searchNames = {'handDrawnLPRCThrP6','handDrawnLTPThrP6','handDrawnRPRCThrP6','handDrawnRTPThrP6'};
% for s=1:length(searchNames)
%     hcpROIExtract('workingmemory','PlacesVsAllOthers',searchNames{s},1,'inputSuffix');
% end
% 
% %% Working Memory
% % Extract ROI responses in working memory network, regions defined with
% % workingmemory PlacesVsFaces
% searchNames = {'handDrawnLPRCThrP6','handDrawnLTPThrP6','handDrawnRPRCThrP6','handDrawnRTPThrP6'};
% for s=1:length(searchNames)
%     hcpROIExtract('workingmemory','PlacesVsFaces',searchNames{s},1,'inputSuffix');
% end
% 
% %% Working Memory
% % Extract ROI responses in working memory network, regions defined with
% % workingmemory PlacesVsBody
% searchNames = {'handDrawnLPRCThrP6','handDrawnLTPThrP6','handDrawnRPRCThrP6','handDrawnRTPThrP6'};
% for s=1:length(searchNames)
%     hcpROIExtract('workingmemory','PlacesVsBody',searchNames{s},1,'inputSuffix');
% end
% 
% %% Working Memory
% % Extract ROI responses in working memory network, regions defined with
% % workingmemory PlacesVsTools
% searchNames = {'handDrawnLPRCThrP6','handDrawnLTPThrP6','handDrawnRPRCThrP6','handDrawnRTPThrP6'};
% for s=1:length(searchNames)
%     hcpROIExtract('workingmemory','PlacesVsTools',searchNames{s},1,'inputSuffix');
% end
% 
% %% Working Memory
% % Extract ROI responses in working memory network, regions defined with
% % workingmemory 2bkVs0bk
% searchNames = {'handDrawnLPRCThrP6','handDrawnLTPThrP6','handDrawnRPRCThrP6','handDrawnRTPThrP6'};
% for s=1:length(searchNames)
%     hcpROIExtract('workingmemory','2bkVs0bk',searchNames{s},1,'inputSuffix');
% end
% 
% %% Working Memory
% % Extract ROI responses in working memory network, regions defined with
% % workingmemory 0bkVs2bk
% searchNames = {'handDrawnLPRCThrP6','handDrawnLTPThrP6','handDrawnRPRCThrP6','handDrawnRTPThrP6'};
% for s=1:length(searchNames)
%     hcpROIExtract('workingmemory','0bkVs2bk',searchNames{s},1,'inputSuffix');
% end


% %% Social/spatial, bilateral
% % Extract ROI responses in apex network, regions defined with famsemantic
% % PersonVsPlace contrast and inverse, across both hemispheres.
% searchNames = {};
% for s=1:length(searchNames)
%     hcpROIExtract('famsemantic','PersonVsPlace',['mmpApex' searchNames{s}],1,'inputSuffix');
%     hcpROIExtract('famsemantic','PersonVsPlace',['mmpApex' searchNames{s}],1,'invertStats',1,'inputSuffix');
% end

% %% Social/spatial, unilateral
% % Extract ROI responses in apex network, regions defined with famsemantic
% % PersonVsPlace contrast and inverse, unilaterally.
% searchNames = {};
% for s=1:length(searchNames)
%     hcpROIExtract('famsemantic','PersonVsPlace',['mmpApex' searchNames{s}],1,'inputSuffix');
%     hcpROIExtract('famsemantic','PersonVsPlace',['mmpApex' searchNames{s}],1,'invertStats',1,'inputSuffix');
% end

% %% Social/spatial, hand-drawn
% % Extract ROI responses in hand-drawn areas, regions defined with
% % famsemantic PersonVsPlace contrast and inverse
% 
% hcpROIExtract('famsemantic','PersonVsPlace','handDrawnTP',1,'inputSuffix');
% hcpROIExtract('famsemantic','PersonVsPlace','handDrawnLTP',1,'inputSuffix');
% hcpROIExtract('famsemantic','PersonVsPlace','handDrawnRTP',1,'inputSuffix');
% hcpROIExtract('famsemantic','PersonVsPlace','handDrawnPHC',1,'invertStats',1,'inputSuffix');
% hcpROIExtract('famsemantic','PersonVsPlace','handDrawnLPHC',1,'invertStats',1,'inputSuffix');
% hcpROIExtract('famsemantic','PersonVsPlace','handDrawnRPHC',1,'invertStats',1,'inputSuffix');
% 
% %% Object, bilateral
% % Extract ROI responses in object network, regions defined with famsemantic
% % PlaceVsObjectInverted contrast, across both hemispheres.
% searchNames = {'IFS','Premotor','PF','PHT'};
% for s=1:length(searchNames)
%     hcpROIExtract('famsemantic','PlaceVsObject',['mmpObject' searchNames{s}],1,'invertStats',1,'inputSuffix');
% end
% 
% %% Object, unilateral
% % Extract ROI responses in object network, regions defined with famsemantic
% % PlaceVsObjectInverted contrast, across both hemispheres.
% searchNames = {'LIFS','LPremotor','LPF','LPHT','RIFS','RPremotor','RPF','RPHT'};
% for s=1:length(searchNames)
%     hcpROIExtract('famsemantic','PlaceVsObject',['mmpObject' searchNames{s}],1,'invertStats',1,'inputSuffix');
% end
% 
% %% ToMLoc, bilateral
% % Extract ROI responses in apex network, regions defined with tomloc2
% % BeliefVsPhoto
% searchNames = {'TPJ','TH','TP','ASTS','MPC','MPFC','IFG','SFG','OFC'};
% for s=1:length(searchNames)
%     hcpROIExtract('tomloc2','BeliefVsPhoto',['mmpApex' searchNames{s}],1,'inputSuffix');
% end
% 
% %% ToMLoc, unilateral
% % Extract ROI responses in apex network, regions defined with tomloc2
% % BeliefVsPhoto
% searchNames = {'LTPJ','LTH','LTP','LASTS','LMPC','LMPFC','LIFG','LSFG','LOFC',...
%     'RTPJ','RTH','RTP','RASTS','RMPC','RMPFC','RIFG','RSFG','ROFC'};
% for s=1:length(searchNames)
%     hcpROIExtract('tomloc2','BeliefVsPhoto',['mmpApex' searchNames{s}],1,'inputSuffix');
% end
% 
% %% LangLoc
% % Extract ROI responses in language network, regions defined with langloc
% % SentencesVsNonwords
% searchNames = {'mmpApexLTPJ','mmpLngLPostTemp','mmpLngLAntTemp','mmpLngLMFG','mmpLngLIFG'};
% for s=1:length(searchNames)
%     hcpROIExtract('langloc','SentencesVsNonwords',searchNames{s},1,'inputSuffix');
% end
% 
% %% Social/spatial, entorhinal cortex
% % Extract ROI responses in entorhinal cortex, regions defined with
% % semantic PersonVsPlace contrast and inverse, across both hemispheres.
% searchNames = {'ashsLERC','ashsRERC'};
% for s=1:length(searchNames)
%     hcpROIExtract('famsemantic','PersonVsPlace',searchNames{s},0);
%     hcpROIExtract('famsemantic','PersonVsPlace',searchNames{s},0,'invertStats',1);
% end
% 
% %% Social/spatial, bilateral subcortical
% % Extract ROI responses in subcortex, regions defined with famsemantic
% % PersonVsPlace contrast and inverse, across both hemispheres.
% searchNames = {'Cerebellum','Thalamus','BasalGanglia','Hippocampus','Amygdala'};
% for s=1:length(searchNames)
%     hcpROIExtract('famsemantic','PersonVsPlace',searchNames{s},1,'inputSuffix');
%     hcpROIExtract('famsemantic','PersonVsPlace',searchNames{s},1,'invertStats',1,'inputSuffix');
% end
% 
% %% Social/spatial, bilateral HC subfields
% % Extract ROI responses in HC subfields, regions defined with famsemantic
% % PersonVsPlace contrast and inverse, across both hemispheres.
% searchNames = {'ashsCA1','ashsCA23DG','ashsSub'};
% for s=1:length(searchNames)
%     hcpROIExtract('famsemantic','PersonVsPlace',searchNames{s},0);
%     hcpROIExtract('famsemantic','PersonVsPlace',searchNames{s},0,'invertStats',1);
% end
% 
% %% LangLoc, bilateral hippocampus
% % Extract ROI responses in hippocampus, regions defined with langloc
% % SentencesVsNonwords
% searchNames = {'Hippocampus'};
% for s=1:length(searchNames)
%     hcpROIExtract('langloc','SentencesVsNonwords',searchNames{s},1,'inputSuffix');
% end
% 
% %% Perirhinal face response, bilateral
% % Extract ROI responses in perirhinal cortex, regions defined with
% % famvisual PersonVsPlace contrast, across both hemispheres.
% searchNames = {'mmpPeEc'};
% for s=1:length(searchNames)
%     hcpROIExtract('famvisual','PersonVsPlace',searchNames{s},1,'inputSuffix');
% end

%% ALL comparision - PRC
contrast_names = {
    'FacesVsTools','FacesVsPlaces','BodyVsFaces','BodyVsTools','BodyVsPlaces','ToolsVsAllOthers',...
    'ToolsVsFaces','ToolsVsBody','ToolsVsPlaces','PlacesVsAllOthers','PlacesVsFaces',...
    'PlacesVsBody','PlacesVsTools'};%,'handDrawnLPRCThrP6','handDrawnRPRCThrP6'};%1/4
contrast_names = {'FacesVsAllOthers','ToolsVsAllOthers'};
searchNames = {'handDrawnLPRCThrP6','handDrawnRPRCThrP6'}
for s=1:length(searchNames)
    searchName = searchNames{s};
    parfor t = 1:length(contrast_names)
    task = contrast_names{t};
    disp(['Start extracting for   ' searchName,task])
    hcpSm4ROIExtract_Analysis('workingmemory',task,searchName,1);
    end
end

%% ALL comparision - TP
contrast_names = {
    'FacesVsTools','FacesVsPlaces','BodyVsFaces','BodyVsTools','BodyVsPlaces','BodyVsAllOthers','ToolsVsAllOthers',...
    'ToolsVsFaces','ToolsVsBody','ToolsVsPlaces','PlacesVsAllOthers','PlacesVsFaces',...
    'PlacesVsBody','PlacesVsTools'};%,'handDrawnLPRCThrP6','handDrawnRPRCThrP6'};%1/4
contrast_names = {'FacesVsAllOthers'};
searchNames = {'handDrawnLTPThrP6','handDrawnRTPThrP6'};
for s=1:length(searchNames)
    searchName = searchNames{s};
    for t = 1:length(contrast_names)
    task = contrast_names{t};
    disp(['Start extracting for   ' searchName,task])
    hcpSm4ROIExtract_Analysis('workingmemory',task,searchName,1);%'invertStats',1
    end
end


