
% Function to plot results of identRestROICorrelation.
% Author:Ben Deen, Tony Shen 
% Note: generated plot on Macbook pro 13.3in 2560x1600 display.
% TODO get a 22*22*864 dataset; get N864roi data for RTPJ
        

fppDir = '/mnt/sml_share/HCP/derivatives/fpp';
matPath = [fppDir '/group/space-fsLR_den-32k_desc-' ...
     'Sm4SocialVsVisualFaceVsAllOthersROIsTop5PctnoTHN863_ROICorrelationData'];
 load(matPath);
for i = 1:863
  if corrMat(1,1,i) ~= 1
     corrMat(:,:,i) = corrMat(:,:,i) + corrMat(:,:,i);
  end
end
corrMatMean = mean(corrMat,3);
%corrMatMean([13,14],:) = [];use to exclude TH
%corrMatMean(:,[13,14]) = [];
regions = {'LTP','RTP','LPR','RPR','LASTS','RASTS',...
    'LMPC','RMPC','LMPFC','RMPFC','LSFG','RSFG','LTPJ','RTPJ',...
    'LFFA','RFFA','LOFA','ROFA','LPSTS','RPSTS'};
nRegions = length(regions);
colors = zeros(nRegions,3);
for r=1:nRegions
    if ismember(r,1:2)
        %colors(r,:) = [170 68 153];    % Insufficiently distinct from wine
        colors(r,:) = [194 77 175];
    elseif ismember(r,3:4)
        colors(r,:) = [136 204 238];
    elseif ismember(r,5:6)
        %colors(r,:) = [221 204 119];    % Too light for text on white bg
        colors(r,:) = [203 188 109];
    elseif ismember(r,7:8)
        colors(r,:) = [153 153 51];
    elseif ismember(r,9:14)
        colors(r,:) = [204 102 119];
    else
        colors(r,:) = [136 34 85];
    end
end
colors = colors/255;



%% Multidimensional scaling on functional connectivity
nConds = 14;
corrDist = 1-corrMatMean;
corrDist = (corrDist+corrDist')/2;
Y = -mdscale(corrDist,2);
% Plot MDS
figure('Position',[200 200 400 400]);
scatter(Y(:,1),Y(:,2),[],colors,'filled');
set(gcf,'Color',[1 1 1]);
pbaspect([1 1 1]);
box;
ylim([-.5 .45]);
set(gca,'YTick',[],'XTick',[],'LineWidth',2);
dx = 0.02*ones(nRegions,1); dy = 0.02*ones(nRegions,1); % displacement so the text does not overlay the data points
dx(15) = .01;
dx(16) = -.18;
dx(18) = .01;
dy(2) = 0;
dy(5) = .02;
dy(6) = 0;
dy(7) = 0;
dy(12) = -.02;
dy(16) = -.03;
dy(17) = -.01;
dy(18) = -.03;
dy(21) = 0;
for r=1:nRegions
    text(Y(r,1)+dx(r),Y(r,2)+dy(r),regions{r},'FontSize',9,'Color',colors(r,:));
end



%% MDS on ROI responses --TODO
searchNames = {'handDrawnLTPThrP6','handDrawnRTPThrP6','handDrawnLPRCThrP6','handDrawnRPRCThrP6',...
    'mmpApexLASTS','mmpApexRASTS','mmpApexLMPC','mmpApexRMPC','mmpApexLMPFC','mmpApexRMPFC'...
    'mmpApexLSFG','mmpApexRSFG','mmpApexLTH','mmpApexRTH','mmpApexLTPJ','mmpApexRTPJ'...
    'mmpLFFA','mmpRFFA','mmpLOFA','mmpROFA','mmpLPSTS','mmpRPSTS'}; 

nConds = 14;%16;    % Omit language localizer (conditions 17-18) - not used in this paper
roiResp = zeros(nConds,nRegions);
for r=1:nRegions
    roiData = load([fppDir '/group/space-fsLR_res-2_den-32k_desc-'...
        searchNames{r} 'workingmemoryFacesVsBodyTop5PctN864_roiData.mat']);
    roiResp(:,r) = mean(roiData.pscBySub(:,1:nConds))';
end
respCorrDist = 1-corr(roiResp);
respCorrDist = (respCorrDist+respCorrDist')/2;
Y2 = mdscale(respCorrDist,2);
% Plot MDS
figure('Position',[200 200 400 400]);
scatter(Y2(:,1),Y2(:,2),[],colors,'filled');
set(gcf,'Color',[1 1 1]);
pbaspect([1 1 1]);
box;
xlim([-.5 .58]); ylim([-.3 .72]);
set(gca,'YTick',[],'XTick',[],'LineWidth',2);
dx = 0.02*ones(nRegions,1); dy = 0.02*ones(nRegions,1); % displacement so the text does not overlay the data points
dy(3) = -.01;
dy(4) = .01;
dy(10) = -.01;
dy(12) = -.02;
dy(15) = -.01;
dy(16) = -.03;
dy(18) = -.03;
dy(20) = -.02;
dy(24) = -.03;
dx(2) = .01;
dx(8) = -.1;
dx(16) = .01;
dx(18) = -.11;
dx(24) = -.12;
for r=1:nRegions
    text(Y2(r,1)+dx(r),Y2(r,2)+dy(r),regions{r},'FontSize',11,'Color',colors(r,:));
end



%% Social versus visual response axis
socialVisualContrast = [-1/4 -1/4 1/6 1/6 1/6 1/2 -1/4 -1/4 1/2 -1/4 -1/4 -1/2 1/4 1/4 0 0];
nConds = 14;    % Omit language localizer (conditions 17-18) - not used in this paper
socialVisualValue = zeros(1,nRegions);
for r=1:length(searchNames)
    roiData = load([fppDir '/group/space-fsLR_res-2_den-32k_desc-'...
        searchNames{r} 'workingmemoryFacesVsAllOthersTop5PctN864_roiData.mat']);
    roiResp = mean(roiData.pscBySub(:,1:nConds));
    socialVisualValue(r) = socialVisualContrast*roiResp'/range(roiResp);
end
xPos(1:8) = 1.25; xPos(9:nRegions) = .75;
figure('Position',[200 200 200 400]);
scatter(xPos,socialVisualValue,[],colors,'filled');
set(gcf,'Color',[1 1 1]);
xlim([.5 1.5]);
% pbaspect([1 1 1]);
set(gca,'YTick',-.8:.4:.4,'XTick',[.75 1.25],'XTickLabel',{'Hyp','Exp'},...
    'FontSize',16,'LineWidth',2);
dx = 0.03*ones(nRegions,1); dy = 0.02*ones(nRegions,1); % displacement so the text does not overlay the data points
dy(4) = -.02;
dy(7) = 0;
dy(9) = -.02;
dy(10) = .005;
dy(11) = -.005;
dy(12) = .03;
dy(13) = -.014;
dy(14) = -.022;
dy(15) = -.01;
dy(16) = -.01;
dy(17) = 0.01;
dy(19) = -.02;
dy(23) = .023;
dy(24) = -.025;
for r=1:nRegions
    text(xPos(r)+dx(r),socialVisualValue(r)+dy(r),regions{r},'FontSize',11,'Color',colors(r,:));
end



%% Compare social and visual network correlations with TP/PR/ASTS/AIT
% HCP data: 22*22 matrix, 5:16 dmn 17:end visual
% Correlation types:
% 1) TP-Social, 2) TP-Visual
% 3) PR-Social, 4) PR-Visual
% 5) ASTS-Social, 6) ASTS-Visual
% 7) AIT-Social, 8) AIT-Visual
% 9) Social-Social, 10) Visual-Visual, 11) Social-Visual
nSocial = 20;   % Number of ROI-ROI correlations, bilateral exptl region to social areas (HCP 10 DMN areas)
nVisual = 12;   % Number of ROI-ROI correlations, bilateral exptl region to visual areas(HCP 6 face areas)
%masks for within,between analysis
withinVisual = tril(ones(20),-1);
withinVisual(:,1:14) = 0;
withinSocial = tril(ones(20),-1);
withinSocial(:,1:4) = 0;
withinSocial(:,15:end) = 0;
withinSocial(15:end,:) = 0;
between = zeros(22);
between(15:end,5:16) = 1;
corrByType = nan(72,11);
corrByType(1:nSocial,1) = reshape(corrMatMean(1:2,5:14),[nSocial 1]);
corrByType(1:nVisual,2) = reshape(corrMatMean(1:2,15:end),[nVisual 1]);
corrByType(1:nSocial,3) = reshape(corrMatMean(3:4,5:14),[nSocial 1]);
corrByType(1:nVisual,4) = reshape(corrMatMean(3:4,15:end),[nVisual 1]);
% corrByType(1:nSocial,5) = reshape(corrMatMean(5:6,15:end),[nSocial 1]);
% corrByType(1:nVisual,6) = reshape(corrMatMean(5:6,9:14),[nVisual 1]);
% corrByType(1:nSocial,7) = reshape(corrMatMean(7:8,15:end),[nSocial 1]);
% corrByType(1:nVisual,8) = reshape(corrMatMean(7:8,9:14),[nVisual 1]);
corrByType(1:sum(sum(withinSocial==1)),5) = corrMatMean(withinSocial==1);
corrByType(1:sum(sum(withinVisual==1)),6) = corrMatMean(withinVisual==1);
corrByType(1:60,7) = reshape(corrMatMean(5:14,15:end),[60 1]);

% Permutation test to compare social vs visual correlations.
% Build null distribution for mean correlation difference.
% corrDiffs: Row 1 TP, Row 2 PR, Row 3 ASTS, Row 4 AIT
iters = 10000;
corrDiffs = [];
for i=1:iters
    areaPerm = [1:4 4+randperm(16)];%(4 + randperm(x))  = number of mean matrix dimention
    
    % Social vs visual(HCP:DMN VS Face)
    corrMatMeanPerm = corrMatMean(areaPerm,areaPerm);
    corrDiffs(i,1) = mean(mean(corrMatMeanPerm(1:2,5:14))) -...
        mean(mean(corrMatMeanPerm(1:2,15:end)));
    corrDiffs(i,2) = mean(mean(corrMatMeanPerm(3:4,5:14))) -...
        mean(mean(corrMatMeanPerm(3:4,15:end)));
   % corrDiffs(i,3) = mean(mean(corrMatMeanPerm(5:6,15:end))) -...
       % mean(mean(corrMatMeanPerm(5:6,9:14)));
   % corrDiffs(i,4) = mean(mean(corrMatMeanPerm(7:8,15:end))) -...
       % mean(mean(corrMatMeanPerm(7:8,9:14)));
    
    % Within vs between network
    corrDiffs(i,3) = mean(corrMatMeanPerm(withinSocial==1)) -...
        mean(corrMatMeanPerm(between==1));
    corrDiffs(i,4) = mean(corrMatMeanPerm(withinVisual==1)) -...
        mean(corrMatMeanPerm(between==1));
    
    if mod(i,100)==0, disp(i); end
end
for r=1:4
    corrDiffs(:,r) = sort(corrDiffs(:,r));
end

% Determine two-tailed p-values
ind1 = min(find(corrDiffs(:,1)>.1599));
ind2 = max(find(corrDiffs(:,2)<-.0489));
ind3 = min(find(corrDiffs(:,3)>.2321));
ind4 = min(find(corrDiffs(:,4)>.1551));
% ind5 = min(find(corrDiffs(:,5)>.3780));
% ind6 = min(find(corrDiffs(:,6)>.2093));

% Two-tailed tests, P-value = 2*(# values larger or smaller)/iters
% TP difference: .1599
% - Larger than any of the permuted values. P < .0001.
% PR difference: -.0489
% - Only 18/10000 permuted values are smaller. P = .0036 < .0125
% ASTS difference: .2321
% - Larger than any of the permuted values. P < .0001.
% AIT difference: 1551
% - Larger than any of the permuted values. P < .0001.

% One-tailed tests, P-value = (# values larger or smaller)/iters
% Social vs between difference: .3780
% - Larger than any of the permuted values. P < .0001.
% Visual vs between difference: .2093
% - 179/10000 permuted values are larger. P = .0179 < .05


% Bar plot of TP social/visual correlations
barGraphLW = 3;     % Linewidth
barGraphFS = 28;    % Font size
figure('Position',[200 200 280 350]);
[b,e] = fpp.util.barColor(corrByType(:,1:2),{[136 34 85]/255,[204 102 119]/255},1,[],0);
% Sig star
groups = {[1 2]};
stats = 0;
h = identSigStarBigPlot(groups,stats);
% Fig props
%set(gca,'LineWidth',barGraphLW,'FontSize',barGraphFS);
set(b,'LineWidth',barGraphLW);
set(b.BaseLine,'LineWidth',barGraphLW);
set(e,'LineWidth',barGraphLW);
set(h,'LineWidth',2);

% Bar plot of PR social/visual correlations
figure('Position',[200 200 280 350]);
[b,e] = fpp.util.barColor(corrByType(:,3:4),{[136 34 85]/255,[204 102 119]/255},1,[],0);
% Sig star
groups = {[1 2]};
stats = .0036;
h = identSigStarBigPlot(groups,stats);
% Fig props
set(gca,'LineWidth',barGraphLW,'FontSize',barGraphFS);
set(b,'LineWidth',barGraphLW);
set(b.BaseLine,'LineWidth',barGraphLW);
set(e,'LineWidth',barGraphLW);
set(h,'LineWidth',2);

% % Bar plot of ASTS social/visual correlations
% figure('Position',[200 200 280 350]);
% [b,e] = fpp.util.barColor(corrByType(:,5:6),{[136 34 85]/255,[204 102 119]/255},1,[],0);
% % Sig star
% groups = {[1 2]};
% stats = 0;
% h = identSigStarBigPlot(groups,stats);
% % Fig props
% set(gca,'LineWidth',barGraphLW,'FontSize',barGraphFS,'YTick',[0:.2:.4]);
% set(b,'LineWidth',barGraphLW);
% set(b.BaseLine,'LineWidth',barGraphLW);
% set(e,'LineWidth',barGraphLW);
% set(h,'LineWidth',2);

% % Bar plot of AIT social/visual correlations
% figure('Position',[200 200 280 350]);
% [b,e] = fpp.util.barColor(corrByType(:,7:8),{[136 34 85]/255,[204 102 119]/255},1,[],0);
% % Sig star
% groups = {[1 2]};
% stats = 0;
% h = identSigStarBigPlot(groups,stats);
% % Fig props
% set(gca,'LineWidth',barGraphLW,'FontSize',barGraphFS);
% set(b,'LineWidth',barGraphLW);
% set(b.BaseLine,'LineWidth',barGraphLW);
% set(e,'LineWidth',barGraphLW);
% set(h,'LineWidth',2);

% Bar plot of within- and between-network correlations
figure('Position',[200 200 280 500]);
[b,e] = fpp.util.barColor(corrByType(:,5:7),{[136 34 85]/255,[204 102 119]/255,[1 1 1]},1,[],0);
% Sig star info
groups = {[1 3],[2 3]};
stats = [0 .0179];
%ylim([-.15 .69]);
h = identTPSigStarBigPlot(groups,stats);
set(gca,'LineWidth',barGraphLW,'FontSize',barGraphFS);
set(b,'LineWidth',barGraphLW);
set(b.BaseLine,'LineWidth',barGraphLW);
set(e,'LineWidth',barGraphLW);
set(h,'LineWidth',2);


%%
%Social vs Visual for MSHBM
% HCP data: 22*22 matrix, 5:16 dmn 17:end visual,
% MSHBM data 21*21matrix 5~7 DMN19:end visual
% Correlation types:
% 1) TP-Social, 2) TP-Visual
% 3) PR-Social, 4) PR-Visual
% 5) ASTS-Social, 6) ASTS-Visual
% 7) AIT-Social, 8) AIT-Visual
% 9) Social-Social, 10) Visual-Visual, 11) Social-Visual
nSocial = 6;   % Number of ROI-ROI correlations, bilateral exptl region to social areas (MSHBM 3 DMN areas)
nVisual = 6;   % Number of ROI-ROI correlations, bilateral exptl region to visual areas(MSHBM, 3 face areas)
%masks for within,between analysis
corrByType = nan(6,4);
corrByType(1:nSocial,1) = reshape(corrMatMean(1:2,5:7),[nSocial 1]);
corrByType(1:nVisual,2) = reshape(corrMatMean(1:2,19:end),[nVisual 1]);
corrByType(1:nSocial,3) = reshape(corrMatMean(3:4,5:7),[nSocial 1]);
corrByType(1:nVisual,4) = reshape(corrMatMean(3:4,19:end),[nVisual 1]);

% Permutation test to compare social vs visual correlations.
% Build null distribution for mean correlation difference.
% corrDiffs: Row 1 TP, Row 2 PR, Row 3 ASTS, Row 4 AIT
iters = 10000;
corrDiffs = [];
for i=1:iters
    areaPerm = [1:4 4+randperm(17)];%(4 + randperm(x))  = number of mean matrix dimention
    
    % Social vs visual(HCP:DMN VS Face)
    corrMatMeanPerm = corrMatMean(areaPerm,areaPerm);
    corrDiffs(i,1) = mean(mean(corrMatMeanPerm(1:2,5:14))) -...
        mean(mean(corrMatMeanPerm(1:2,15:end)));
    corrDiffs(i,2) = mean(mean(corrMatMeanPerm(3:4,5:14))) -...
        mean(mean(corrMatMeanPerm(3:4,15:end)));
   % corrDiffs(i,3) = mean(mean(corrMatMeanPerm(5:6,15:end))) -...
       % mean(mean(corrMatMeanPerm(5:6,9:14)));
   % corrDiffs(i,4) = mean(mean(corrMatMeanPerm(7:8,15:end))) -...
       % mean(mean(corrMatMeanPerm(7:8,9:14)));
    
    if mod(i,100)==0, disp(i); end
end
for r=1:2
    corrDiffs(:,r) = sort(corrDiffs(:,r));
end

% Determine two-tailed p-values
ind1 = min(find(corrDiffs(:,1)>.1599));
ind2 = max(find(corrDiffs(:,2)<-.0489));
% ind5 = min(find(corrDiffs(:,5)>.3780));
% ind6 = min(find(corrDiffs(:,6)>.2093));

% Two-tailed tests, P-value = 2*(# values larger or smaller)/iters
% TP difference: .1599
% - Larger than any of the permuted values. P < .0001.
% PR difference: -.0489
% - Only 18/10000 permuted values are smaller. P = .0036 < .0125
% ASTS difference: .2321
% - Larger than any of the permuted values. P < .0001.
% AIT difference: 1551
% - Larger than any of the permuted values. P < .0001.

% One-tailed tests, P-value = (# values larger or smaller)/iters
% Social vs between difference: .3780
% - Larger than any of the permuted values. P < .0001.
% Visual vs between difference: .2093
% - 179/10000 permuted values are larger. P = .0179 < .05


% Bar plot of TP social/visual correlations
barGraphLW = 3;     % Linewidth
barGraphFS = 28;    % Font size
figure('Position',[200 200 280 350]);
[b,e] = fpp.util.barColor(corrByType(:,1:2),{[136 34 85]/255,[204 102 119]/255},1,[],0);
% Sig star
groups = {[1 2]};
stats = 0;
h = identSigStarBigPlot(groups,stats);
set(gca,)
% Fig props
%set(gca,'LineWidth',barGraphLW,'FontSize',barGraphFS);
set(b,'LineWidth',barGraphLW);
set(b.BaseLine,'LineWidth',barGraphLW);
set(e,'LineWidth',barGraphLW);
set(h,'LineWidth',2);

% Bar plot of PR social/visual correlations
figure('Position',[200 200 280 350]);
[b,e] = fpp.util.barColor(corrByType(:,3:4),{[136 34 85]/255,[204 102 119]/255},1,[],0);
% Sig star
groups = {[1 2]};
stats = .0036;
h = identSigStarBigPlot(groups,stats);
% Fig props
set(gca,'LineWidth',barGraphLW,'FontSize',barGraphFS);
set(b,'LineWidth',barGraphLW);
set(b.BaseLine,'LineWidth',barGraphLW);
set(e,'LineWidth',barGraphLW);
set(h,'LineWidth',2);



% Bar plot of within- and between-network correlations
figure('Position',[200 200 280 500]);
[b,e] = fpp.util.barColor(corrByType(:,5:7),{[136 34 85]/255,[204 102 119]/255,[1 1 1]},1,[],0);
% Sig star info
groups = {[1 3],[2 3]};
stats = [0 .0179];
%ylim([-.15 .69]);
h = identTPSigStarBigPlot(groups,stats);
set(gca,'LineWidth',barGraphLW,'FontSize',barGraphFS);
set(b,'LineWidth',barGraphLW);
set(b.BaseLine,'LineWidth',barGraphLW);
set(e,'LineWidth',barGraphLW);
set(h,'LineWidth',2);
