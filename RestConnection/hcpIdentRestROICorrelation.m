
% Function to compute resting-state correlations between a set of ROIs in
% IDENT data.
%
% Arguments:
% - roiDescs (cell array): BIDS descriptions of ROIs to correlation
% - outputDesc (string): BIDS description for output file
%  Optional
% - isMSHBM (bool): whether use MSHBM ROIs(networks)
function hcpIdentRestROICorrelation(roiDescs,outputDesc)

studyDir = '/mnt/sml_share/HCP';
fppDir = [studyDir '/derivatives/fpp'];
allSubj = readtable([studyDir '/derivatives/cshen2/BalancedReplicationIDs.xlsx']);
subjects = table2array(allSubj(:,1));
%subjects = subjects(1:3);
nRuns = 2;
%nVols = 300;
spaceStr = 'fsLR_den-32k';
nROIs = length(roiDescs);
inputDesc = 'fixdenoised_bold';
outputPath = [fppDir '/group/space-' spaceStr '_desc-' outputDesc 'N' int2str(length(subjects)) '_ROICorrelationDataReplication.mat'];
corrMat = zeros(nROIs,nROIs,length(subjects));
%loading all roi file pathes
roiPaths = cell(nROIs, length(subjects));
parfor s = 1:length(subjects)
    subject = subjects{s};
    %if subject == 'sub-hcp205826', continue;end
    subjDir = [fppDir '/' subject];
    roiDir = [subjDir '/roi'];
    MSHBMDir = [subjDir '/anat/MSHBMmasks'];
    du15Dir = [subjDir '/anat/DU15NETmasks']
    for r = 1:nROIs
        roiPath = [roiDir '/' subject '_space-' spaceStr '_desc-' roiDescs{r} '_mask.dscalar.nii'];
        if ~exist(roiPath,'file')
            roiPath2 = [du15Dir '/' subject '_space-individual_den-32k_desc-' roiDescs{r} '_mask.dscalar.nii'];  
            if ~exist(roiPath2,'file'), error([subject roiDescs{r} '  roi misssing  PATH: \n' roiPath2]);end
            roiPath = roiPath2
        end
        roiPaths{r, s} = roiPath
    end
end

parfor s=1:length(subjects)
    spaceStr = 'fsLR_den-32k';
    % Define paths
    subject = subjects{s};
    
    subjDir = [fppDir '/' subject];
    roiDir = [subjDir '/roi'];
    funcDir = [subjDir '/func'];
    
    % Load ROIs
    roiMat = [];
    roiAvgMat = [];
    for r=1:nROIs
        roiMat(:,r) = fpp.util.readDataMatrix(roiPaths{r, s});
        roiAvgMat(:,r) = roiMat(:,r)/sum(roiMat(:,r)); % Dot product with this vector = mean across ROI
    end
    
    for r=1:nRuns
        %read rest data
        spaceStr = 'fsLR_res-2_den-32k';
        restPath = [funcDir '/' subject '_task-rest_run-' fpp.util.numPad(r,2)...
            '_space-' spaceStr '_desc-' inputDesc '.dtseries.nii'];
        if ~exist(restPath,'file') %% for subjects without resting run2
            if r == 2
            logtxt = fopen([studyDir '/derivatives/cshen2/logs/ROICorrlog.txt'],'a')
            fprintf(logtxt,[subject fpp.util.numPad(r,2) 'second rest file not exist Error occured at:   ' datestr(now) '\n']);
            corrMat(:,:,s) = corrMat(:,:,s) + corrMat(:,:,s);
            continue
            end
            if r == 1
                error([subject 'had no rest file'])
            end
        end
        [restMat,hdr] = fpp.util.readDataMatrix(restPath);
        spaceStr = 'fsLR_den-32k';
        % Define outlier volumes
        restMat = restMat(1:59412,:);
        %confoundPath = fpp.bids.changeName(restPath,'desc','','confounds','.tsv');
        %utlierPath = fpp.bids.changeName(restPath,{'space','res','den','desc'},{'','','',''},'outliers','.tsv');
        %outlierInd = fpp.util.readOutlierTSV(outlierPath);
        %goodInd = setdiff(1:nVols,outlierInd);
        
        % Load resting data
        %restMat = fpp.util.readDataMatrix(restPath);
        %restMat = restMat(:,goodInd);
        
        % Compute ROI-averaged time series
        roiAvgSeries = restMat'*roiAvgMat;  % Time point by ROI matrix of time series
        
        % Compute correlations
        corrMat(:,:,s) = corrMat(:,:,s) + corr(roiAvgSeries)/nRuns;
        
        disp(['Computed correlation matrix for ' subject ', run ' int2str(r)]);
    end
end

save(outputPath,'corrMat','roiDescs');
% Plot
Labels = {'LTP','RTP','LPRC','RPRC','DN-A','DN-B','VIS-C','VIS-P','CG-OP','SMOT-A','SMOT-B','AUD','PM-PPr','dATN-A','dATN-B',...
    'LANG','FPN-A','FPN-B','SALPMN'};;
figure;
imagesc(squeeze(mean(corrMat,3)),[-1 1]);
colorbar;
set(gcf,'Color',[1 1 1]);
a = gca;
a.XTick = [1:nROIs];
a.XTickLabel = Labels;
a.YTick = [1:nROIs];
a.YTickLabel = Labels;
a.FontSize = 8;
colorCond = {[100, 49, 73]/255, [205, 61, 77]/255, [119, 17, 133]/255, [170, 70, 125]/255,...
    [184, 89, 251]/255, [73, 145, 175]/255, [27, 179, 242]/255, [231, 215, 165]/255,...
    [66, 231, 206]/255, [10, 112, 33]/255, [98, 206, 61]/255, [11, 47, 255]/255,...
    [240, 147, 33]/255, [228, 228, 0]/255, [254, 188, 235]/255};
network_results = mean(corrMat,3);
network_results = network_results(1:4,5:end);
for i = 1:size(network_results,1)
    figure('Position',[200 200 1200 600]);
    [b,e] = fpp.util.barColor(network_results(i,:),colorCond);
    a = gca;
    a.XTick = [1:15];
    a.XTickLabel = Labels(5:end);
    a.XColor = [0,0,0];
    a.FontSize = 8;
    clear title
    tit = title(Labels{i});
    set(tit, 'FontSize', 16)
    saveas(gcf,[fppDir '/group/space-' spaceStr '_desc-' outputDesc 'N' int2str(length(subjects)) Labels{i} '.png'])
end



end