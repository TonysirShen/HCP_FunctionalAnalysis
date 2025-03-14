% Wrapper for identRestROICorrelation script. TP paper version: computes
% correlations among TP/PR/STS/IT and other social/face areas.

group = 'Replication';
searchNames = {'handDrawnLTPThrP6','handDrawnRTPThrP6','handDrawnLPRCThrP6','handDrawnRPRCThrP6',...
    'mmpApexLASTS','mmpApexRASTS','mmpApexLMPC','mmpApexRMPC','mmpApexLMPFC','mmpApexRMPFC'...
    'mmpApexLSFG','mmpApexRSFG','mmpApexLTPJ','mmpApexRTPJ'...
    'mmpLFFA','mmpRFFA','mmpLOFA','mmpROFA','mmpLPSTS','mmpRPSTS'};
Du15net = {'DN-A','DN-B','VIS-C','VIS-P','CG-OP','SMOT-A','SMOT-B','AUD','PM-PPr','dATN-A','dATN-B',...
    'LANG','FPN-A','FPN-B','SALPMN'};
searchNames = {'handDrawnLTPThrP6','handDrawnRTPThrP6','handDrawnLPRCThrP6',...
    'handDrawnRPRCThrP6'};%debug,'mmpLPSTS'
tasks = {'workingmemory'};  
Contrasts = {'FacesVsAllOthers','FacesVsBody','BodyVsAllOthers','BodyVsFaces','BodyVsTools','BodyVsPlaces','ToolsVsAllOthers',...
    'ToolsVsFaces','ToolsVsBody','ToolsVsPlaces','PlacesVsAllOthers','PlacesVsFaces',...
    'PlacesVsBody','PlacesVsTools'};%'Faces vs Places Faces vs Tools
Contrasts = {'FacesVsAllOthers'}%debug
suffix = 'Sm4Top5Pct';
roiDescs = {};
for s=1:length(searchNames)
    for t=1:length(tasks)
        for c=1:length(Contrasts)
            roiDescs{s} = [searchNames{s} tasks{t} Contrasts{c} suffix];
        end
    end
end

if ~ isempty(Du15net) && length(roiDescs) < length(Du15net)
    roilength = length(roiDescs);
for s = 1 : length(Du15net)
    index = roilength + s;
    roiDescs{index} = ['DU15NET' Du15net{s}];
end
end
outputDesc = [suffix Contrasts{1} 'DU15NET' group];
hcpIdentRestROICorrelation(roiDescs,outputDesc);
