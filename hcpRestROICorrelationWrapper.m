% Wrapper for identRestROICorrelation script. TP paper version: computes
% correlations among TP/PR/STS/IT and other social/face areas.
searchNames = {'handDrawnLTPThrP6','handDrawnRTPThrP6','handDrawnLPRCThrP6','handDrawnRPRCThrP6',...
    'mmpApexLASTS','mmpApexRASTS','mmpApexLMPC','mmpApexRMPC','mmpApexLMPFC','mmpApexRMPFC'...
    'mmpApexLSFG','mmpApexRSFG','mmpApexLTPJ','mmpApexRTPJ'...
    'mmpLFFA','mmpRFFA','mmpLOFA','mmpROFA','mmpLPSTS','mmpRPSTS'};%placeholder for all search names
Du15net = {'DNA','DNB','LANG','FPNA','FPNB','SALPMN','CGOP','dATNA',...
    'dATNB','PMPPr','SMOTA','SMOTB','AUD','VISC','VISP'};Du15net
Du15net = {}
searchNames = {'handDrawnLTPThrP6','handDrawnRTPThrP6','handDrawnLPRCThrP6',...
    'handDrawnRPRCThrP6','mmpLLOTC','mmpRLOTC','mmpLVOTC','mmpLVOTC'}; % debug,'mmpLPSTS','mmpLLOTC'...
tasks = {'workingmemory'};  
Contrasts = {'FacesVsAllOthers','FacesVsBody','BodyVsAllOthers','BodyVsFaces','BodyVsTools','BodyVsPlaces','ToolsVsAllOthers',...
    'ToolsVsFaces','ToolsVsBody','ToolsVsPlaces','PlacesVsAllOthers','PlacesVsFaces',...
    'PlacesVsBody','PlacesVsTools'};%'%placeholder for all contrasts
Contrasts = {'FacesVsAllOthers','ToolsVsAllOthers'}%debug
suffix = 'Sm4Top5Pct';
outputDesc = [suffix  'test'];
roiDescs = {};
index = 1;
for s=1:length(searchNames)
    for t=1:length(tasks)
        for c=1:length(Contrasts)
            roiDescs{index} = [searchNames{s} tasks{t} Contrasts{c} suffix];
            index = index +1;
        end
    end
end
if exist('index','var'); delete  index; end

% adding other parcellations descs to HCP's contrast

if ~ isempty(Du15net) && length(roiDescs) < (length(Du15net) +length(searchNames)*length(Contrasts))
    roilength = length(roiDescs);
for s = 1 : length(Du15net)
    index = roilength + s;
    roiDescs{index} = ['DU15NET' Du15net{s}];
end
end

hcpRestROICorrelation(roiDescs,outputDesc,'Discovery');
