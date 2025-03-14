roiDataFolder = '/mnt/sml_share/HCP/derivatives/fpp/DiscoveryResults/TPContrasts'
if ~exist(roiDataFolder);mkdir(roiDataFolder);end
contrast_names = {
    'FacesVsTools','FacesVsPlaces','BodyVsFaces','BodyVsTools','BodyVsPlaces','BodyVsAllOthers'...
    'ToolsVsAllOthers','ToolsVsFaces','ToolsVsBody','ToolsVsPlaces','PlacesVsAllOthers','PlacesVsFaces',...
    'PlacesVsBody','PlacesVsTools'};%,'handDrawnLPRCThrP6','handDrawnRPRCThrP6'};%1/4
contrast_names = {'Faces','Tools','Places','Body'}
searchNames = {'RTP','LTP'};
for i = 1:numel(contrast_names)
    contrast = contrast_names{i};
    for j = 1:numel(searchNames)
        searchName = searchNames{j};
        roiDataPath = [roiDataFolder '/space-fsLR_res-2_den-32k_desc-handDrawn' searchName 'ThrP6workingmemory' contrast 'VsAllOthersTop5PctN415Sm4Discovery_roiData.mat'];
        HCPSm4WmTaskComparisionBarGraph(roiDataPath,roiDataFolder)
        title([searchName ' ' contrast ' ']);
        outputFigurePath = [roiDataFolder '/' fpp.bids.checkNameValue(roiDataPath,'desc') '.png']
        saveas(gcf,outputFigurePath);
    end
end

