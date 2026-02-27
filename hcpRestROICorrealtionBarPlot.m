
%Function used to draw Bar plots based on the corrlation Matrix calculated by hcpRestROICorrelation
%Parameters
%     -corrMat: the corrlation Matrix calculated by hcpRestROICorrelation
%     -matIndex: a 1*2 cell that specify the {rows,columns} of the corrleationMatrix to extracted from.
%                this function will generated N(rows) figures with
%                N(column) bars
%     -titles: char cells contain titles for individual bar plots, N(cell) = N(rows)
%     -colorCond: cells contain RGB values(range: 0~1) for bars N(cells) = N(column)
     
%Varargin
%  -group: char of group names add as a suffix of the image descs
%  -outputDesc: char or list of chars used as descprpton of images, added after the title
%  -xLabels: labels for  N(column) bars
%  -columnPairs: grouping for  N(column), Index assume the original corrMat is already reshaped based on matIdex
%                   N(bars) will change based on the amount of group
%                   provided;
%  -costumBars: boolean value to allow costume modification on bar edgecolor or facecolor, default: 0
%           -faceColors: cells contain RGB values(range: 0~1) for bars N(cells) = N(column)
%           -edgeColors: cells contain RGB values(range: 0~1) for bar edges N(cells) = N(column)

%Output:  outputDir/title+outputdesc+group.png

%Use Example:
% matIndex = {[1:2],[3:8]};
% titles = {'1','2'}
% colorCond = {[255,255,255]/255,[1,1,1],[0,0,0]}
% outputDir = 'path/to'outputDir'
% group = 'testgroup'
% outputDesc = {'outputDescs'}
% xLabels = {'bar1','bar2,'bar3'} 
% columnPairs = [1,4;2,5;3,6];
% faceColors = colorCond;
% edgeColors = colorCond;
% hcpRestROICorrealtionBarPlot(corrMat,matIndex,titles,colorCond,outputDir,'group',group,'outputDesc',outputDesc,'xLabels',xLabels,'columnPairs',columnPairs,'costumBars',1,'faceColors',faceColors,'edgeColors',edgeColors);


function hcpRestROICorrealtionBarPlot(corrMat,matIndex,titles,colorCond,outputDir,varargin)
%input manager
p = inputParser;
addParameter(p, 'group', '', @(x) ischar(x) || isstring(x));
addParameter(p, 'outputDesc', {}, @(x) ischar(x) || isstring(x) || iscellstr(x));
addParameter(p, 'xLabels', [], @iscellstr);
addParameter(p, 'columnPairs', [], @isnumeric);
addParameter(p, 'costumBars',0, @isnumeric);
addParameter(p, 'faceColors', [], @iscell);
addParameter(p,'edgeColors',[],@iscell);
parse(p, varargin{:});
group = p.Results.group;
outputDesc = p.Results.outputDesc;
if isempty(outputDesc);outputDescs = cell(1,numel(titles));outputDescs(:) = {''};
elseif numel(outputDesc)==1;outputDescs = cell(1,numel(titles));outputDescs(:) = {outputDesc(1)};
elseif ischar(outputDesc)||isstring(outputDesc);outputDescs = cell(1,numel(titles));outputDescs(:) = {outputDesc};
xLabels = p.Results.xLabels;
columnPairs = p.Results.columnPairs;
costumBars = p.Results.costumBars;
faceColors = p.Results.faceColors;
edgeColors = p.Results.edgeColors;

% studyDir = '/mnt/sml_share/HCP'
% suffix = 'Sm4Top5Pct';
% fppDir = [studyDir '/derivatives/fpp'];
% subjNum = size(corrMat,3);
% titles = {'LTPFace','RTPFace','LPRCFace','RPRCFace','LTPTool','RTPTool','LPRCTool','RPRCTool'};
% xLabels = {'DN-A','DN-B','LANG','FPN-A','FPN-B','SALPMN','CG-OP',...
%     'dATN-A','dATN-B','PM-PPr','SMOT-A','SMOT-B','AUD','VIS-C','VIS-P'};%DU15NET Labels
% Labels = {'LTP Faces','RTP Faces','LPRC Faces','LPRC Tools','RPRC Faces','RPRC Tools','LOTC Faces','LOTC Tools','VOTC Faces','VOTC Tools'};%simplified roiDescs
subjNum = size(corrMat,3);
if isempty(colorCond)
    colorCond = {[100 49 73]/255,[205 61 77]/255,[11 47 255]/255,[240 147 33]/255,[228 228 0]/255,...
    [254 188 232]/255,[184 89 251]/255,[10 112 33]/255,[98 206 61]/255,[66 231 206]/255,[73 145 175]/255,...
    [27 179 242]/255,[231 215 165]/255,[119 17 133]/255,[170 70 125]/255};
end
if class(matIndex) ~= 'cell' 
    error('Matindex cell should be a 1*2 cell representing [Xindex,Yindex] for the correlation Matrix');
elseif size(matIndex) ~= [1,2]
    error('Matindex cell should be a 1*2 cell representing [Xindex,Yindex] for the correlation Matrix');
end

% network_results = mean(corrMat,3);
% SD = std(corrMat,0,[3])/sqrt(size(corrMat,3));
% SD = SD(matIndex{1},matIndex{2});%modify index based on matrix design
network_results = corrMat(matIndex{1},matIndex{2},:);

% in case of average columns
if ~isempty(columnPairs)
 average_results = zeros(size(network_results,1),length(columnPairs),(size(network_results,3)));
 for i = 1:size(columnPairs,1)
     average_results(:, i,:) = mean(network_results(:, columnPairs(i,:),:), 2);  % average across rows
 end
network_results = average_results;
end

%Statstics
SD = std(network_results,0,[3])/sqrt(size(network_results,3));

 %group t-test
 starp  = zeros(size(network_results,1),2);
 ts = zeros(size(network_results,1),2)
 dfs = zeros(size(network_results,1),2)
 for i = 1:size(network_results,1)
    g1 = squeeze(network_results(i,1,:));
    g2 = squeeze(network_results(i,2,:));
    g3 = squeeze(network_results(i,3,:));
    g4 = squeeze(network_results(i,4,:));
    [h1,p1,~,stat1] =  ttest(g1,g2);
    ts(i,1) = stat1.tstat
    dfs(i,1) = stat1.df
    [h2,p2,~,stat2] = ttest(g3,g4);
    ts(i,2)= stat2.tstat
    dfs(i,2) = stat2.df
    starp(i,1)  = p1/6;%
    starp(i,2)  = p2/6;
 end


% plot
network_results = mean(network_results,3);
for i = 1:size(network_results,1)
    figure('Position',[200 200 1200 600]);
    if costumBars == 0;[b,e] = fpp.util.barColor(network_results(i,:),colorCond,SD(i,:));
    else
        hold on
        for j= 1:size(network_results,2)
            meandata = network_results(i,:);
            b = bar(j, meandata(j), ...
            'FaceColor', faceColors{j}, ...
            'EdgeColor', edgeColors{j}, ...
            'BarWidth', 0.75, ...
            'LineWidth', 4);
            set(b.BaseLine,'LineWidth',2)
            set(b.BaseLine,'Color',[0,0,0])
        end
        e = errorbar(meandata,SD(i,:),'.k');
        set(e,'LineWidth',2)
        hold off
        a = gca;
        box off;
        set(gcf,'Color',[1 1 1]);
        set(gca,'LineWidth',2,'FontSize',24,'XTick',[]);
        ylim = get(gca,'YLim');
        ylim = get(gca,'XLim');
        if ylim(1)<0    % Remove horizontal line beneath 0
         set(gca,'XColor',[1 1 1]);
        end 
    end
%     a.XTick = [1:15];
%     a.XTickLabel = Xlabels(5:end);
    a.XColor = [0,0,0];
%     a.YTick = ytickVals
    a.FontSize = 36;
    clear title
    tit = title(titles{i});
    starGroups = {[1,2],[3,4]};
    indKeep = find(starp(i,:)<(0.05/6));
    starGroups = starGroups(indKeep);
    H = identSigStarSmallPlot(starGroups,starp(i,indKeep));
    for j = 1:size(H,1);set(H(j,2),'FontSize',24);end
%     set(tit, 'FontSize', 16)
    saveas(gcf,[outputDir '/' titles{i} outputDescs{i} 'N' int2str(subjNum) group '.png'])
    disp(titles{i})
    disp('T=')
    disp(ts(i,:))
    disp('P=')
    disp(starp(i,:))
    disp('DOF=')
    disp(dfs(i,:))
end
end
