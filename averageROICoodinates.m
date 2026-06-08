% Function used to calculate and analysis ROI coordination for specific ROIs
%%%%%%%%%%%%%%%%%%%%%%%%%
%%Part1 Calculate Coorinate datas for ROIs
%%%%%%%%%%%%%%%%%%%%%%%%%

studyDir = '/mnt/sml_share/HCP';
fppDir = [studyDir '/derivatives/fpp'];
contrast_names = {'FacesVsAllOthers','ToolsVsAllOthers'};
allSubjs = readtable('/mnt/sml_share/HCP/derivatives/cshen2/BalancedReplicationIDs.xlsx');
allSubjs = table2array(allSubjs(:,1));
searchNames = {'mmpLLOTC','mmpRLOTC','mmpLVOTC','mmpRVOTC',...
    'handDrawnLPRCThrP6','handDrawnRPRCThrP6','mmpLLOTC'};
ConvertPath= '/mnt/sml_share/HCP/derivatives/cshen2/32492_to_59412.mat';
load(ConvertPath);
for c = 1:numel(contrast_names)
    contrast_name = contrast_names{c};
for n= 1:numel(searchNames)
    searchName = searchNames{n};
    roiDatas = [];
    disp(['Collect' contrast_name 'rois location'])
    for s = 1:length(allSubjs)
        subject = allSubjs{s};
        subjDir = [fppDir '/' subject];
        anatDir = [subjDir '/anat'];
        roiDir = [subjDir '/roi'];
        subjLPath = [anatDir '/' subject '_hemi-L_space-individual_den-32k_midthickness.surf.gii'];
        subjRPath = [anatDir '/' subject '_hemi-R_space-individual_den-32k_midthickness.surf.gii'];
        if ~exist(subjLPath,"file"),error(['no surface file ' subjLPath]);end
        if ~exist(subjRPath,"file"),error(['no surface file ' subjRPath]);end
        subjLdata = gifti(subjLPath).vertices;
        subjRdata = gifti(subjRPath).vertices;
        subjData = [subjLdata;subjRdata];
        if size(subjData,1)== 64984; subjData(logical(ConvertMatrix),:);
        elseif size(subjData,1)==59412;
        else; error('Unexpected surface size!!! Expected 64984 or 59412');
        end
        roiPath = [roiDir '/' subject '_space-fsLR_den-32k_desc-' searchName 'workingmemory' contrast_name 'Sm4Top5PctLORO01_mask.dscalar.nii'];
        if ~exist(roiPath,"file"),error(['no roi file ' roiPath]);end
        roimap = fpp.util.readDataMatrix(roiPath);
        roiData = subjData(logical(roimap),:);
        roiData = mean(roiData);
        roiDatas = [roiDatas; roiData]; 
        disp(['finish ' subject])
    end
    save(['/mnt/sml_share/HCP/derivatives/cshen2/' searchName contrast_name '5PctROIlocationdata.mat'],"roiDatas")
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%
%% Part2 ROI location Analysis
%%%%%%%%%%%%%%%%%%%%%%%%%

%ROI searchname and contrast used in all folowing steros
ROIs = {{'mmpLVOTC','FacesVsAllOthers'},{'mmpLVOTC','ToolsVsAllOthers'},...
    {'mmpRVOTC','FacesVsAllOthers'},{'mmpRVOTC','ToolsVsAllOthers'}};

%%load data and calculate mean and SD
for r = ROIs
    region = r{1}{1};
    contrast = r{1}{2};
    roiDatas = load(['/mnt/sml_share/HCP/derivatives/cshen2/' region contrast '5PctROIlocationdata.mat']).roiDatas
    means = mean(roiDatas,1);
    SDs = std(roiDatas,1);
    SDM = SDs/sqrt(size(roiDatas,1)-1)
    figure()
    boxplot(roiDatas,'widths',1)
    % plot the errorbar
    a = gca;
    a.FontSize = 12;
    a.XTickLabel = {'X','Y','Z'};
    a.LineWidth = 1;
    title([region ' ' contrast])
%     saveas(gcf,['/mnt/sml_share/HCP/derivatives/cshen2/' region contrast 'ROICoorinidates.png'])
end

%% get Face,Tool difference
C1 = {ROIs(1),ROIs(2)}
Facedata = load(['/mnt/sml_share/HCP/derivatives/cshen2/' C1{1}{1}{1} C1{1}{1}{2} '5PctROIlocationdata.mat']).roiDatas;
Tooldata = load(['/mnt/sml_share/HCP/derivatives/cshen2/' C1{2}{1}{1} C1{2}{1}{2} '5PctROIlocationdata.mat']).roiDatas;
diff = Facedata - Tooldata;
figure()
boxplot(diff)
a = gca;
a.XTickLabel = {'X','Y','Z'};
[h,p,ci,stats] = ttest(diff);
title([C1{1}{1}{1} ' Face - Tool corrdination difference']);

C2 = {ROIs(3),ROIs(4)}
Facedata = load(['/mnt/sml_share/HCP/derivatives/cshen2/' C2{1}{1}{1} C2{1}{1}{2} '5PctROIlocationdata.mat']).roiDatas;
Tooldata = load(['/mnt/sml_share/HCP/derivatives/cshen2/' C2{2}{1}{1} C2{2}{1}{2} '5PctROIlocationdata.mat']).roiDatas;
diff = Facedata - Tooldata;
figure()
boxplot(diff)
a = gca;
a.XTickLabel = {'X','Y','Z'};
[h,p,ci,stats] = ttest(diff);
title([R{1}{1}{1} ' Face - Tool corrdination difference']);

%% violin plot
addpath(fullfile(cd,'violin'));
C1 = {ROIs(1),ROIs(2)}
Facedata = load(['/mnt/sml_share/HCP/derivatives/cshen2/' C1{1}{1}{1} C1{1}{1}{2} '5PctROIlocationdata.mat']).roiDatas;
Tooldata = load(['/mnt/sml_share/HCP/derivatives/cshen2/' C1{2}{1}{1} C1{2}{1}{2} '5PctROIlocationdata.mat']).roiDatas;
diff = Facedata - Tooldata;
figure('Position', [500, 500, 800, 624])
[~,~,~,MED,~] = violin(diff,'xlabel',{'X','Y','Z'},'mc',[],'medc','k','facecolor','w','plotlegend',0);
set(gcf,'Color',[1 1 1]);
set(gca,'FontSize',24,'LineWidth',2);
set(gca,'YLim',[-40,40]);
set(gca,'YTick',[-40,-20,0,20,40])
[h,p,ci,stats] = ttest(diff);
disp([C1{1}{1}{1}]);
disp(['P = ' num2str(p) newline 'T= ' num2str(stats.tstat) newline 'DOF= ' num2str(stats.df)]);
Cohend = mean(diff) ./ std(diff);
disp(['Cohen D = ' num2str(Cohend)])

% for i = 1:size(p,2)
%  if p(i) < 0.001
%      star = '***';
%  elseif p(i) < 0.01
%      star = '**';
%  elseif p(i) < 0.05
%      star = '*';
%  else 
%      star = 'n.s.';
%  end
%  text(i, MED(i) + 3, star, 'HorizontalAlignment', 'center', 'FontSize', 14)
% end
% Add text annotation
title([C1{1}{1}{1}]);

C2 = {ROIs(3),ROIs(4)}
Facedata = load(['/mnt/sml_share/HCP/derivatives/cshen2/' C2{1}{1}{1} C2{1}{1}{2} '5PctROIlocationdata.mat']).roiDatas;
Tooldata = load(['/mnt/sml_share/HCP/derivatives/cshen2/' C2{2}{1}{1} C2{2}{1}{2} '5PctROIlocationdata.mat']).roiDatas;
diff = Facedata - Tooldata;
figure('Position', [500, 500, 800, 624])
[~,~,~,MED,~] =  violin(diff,'xlabel',{'X','Y','Z'},'mc',[],'medc','k','facecolor','w','plotlegend',0);
a = gca;
set(gcf,'Color',[1 1 1]);
set(gca,'FontSize',24,'LineWidth',2);
set(gca,'YLim',[-40,40]);
set(gca,'YTick',[-40,-20,0,20,40])
[h,p,ci,stats] = ttest(diff);
disp([C2{1}{1}{1}]);
disp(['P = ' num2str(p) newline 'T= ' num2str(stats.tstat) newline 'DOF= ' num2str(stats.df)]);
Cohend = mean(diff) ./ std(diff);
disp(['Cohen D = ' num2str(Cohend)])

% for i = 1:size(p,2)
%  if p(i) < 0.001
%      star = '***';
%  elseif p(i) < 0.01
%      star = '**';
%  elseif p(i) < 0.05
%      star = '*';
%  else
%      star = 'n.s.';
%  end
%  text(i, MED(i) + 3, star, 'HorizontalAlignment', 'center', 'FontSize', 14)
% end
title([C2{1}{1}{1} ' F-T diff']);


