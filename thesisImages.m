% group distrubution bar plot
group1 = readtable('/mnt/sml_share/HCP/derivatives/cshen2/BalancedDiscoveryIDs.xlsx');
group2 = readtable('/mnt/sml_share/HCP/derivatives/cshen2/BalancedReplicationIDs.xlsx');

%% group distrubution bar plot
% Define age ranges
ages = unique([group1.Age_in_Yrs; group2.Age_in_Yrs]);

% Group 1: Males and Females
male_group1 = group1(strcmp(group1.Gender, 'M'), :);
female_group1 = group1(strcmp(group1.Gender, 'F'), :);

% Group 2: Males and Females
male_group2 = group2(strcmp(group2.Gender, 'M'), :);
female_group2 = group2(strcmp(group2.Gender, 'F'), :);

% Create figures for age distributions


% Male Age Distribution - Group 1
%subplot(2,2,1);
figure
histogram(male_group1.Age_in_Yrs, 'BinEdges', min(ages):1:max(ages), 'FaceAlpha', 0.7);
title('Male Age Distribution - Discovery');
xlabel('Age (Years)');
ylabel('Amount');
xticks(min(ages):1:max(ages));

% Female Age Distribution - Group 1
%subplot(2,2,2);
figure
histogram(female_group1.Age_in_Yrs, 'BinEdges', min(ages):1:max(ages), 'FaceAlpha', 0.7);
title('Female Age Distribution - Discovery');
xlabel('Age (Years)');
ylabel('Amount');
xticks(min(ages):1:max(ages));

% Male Age Distribution - Group 2
%subplot(2,2,3);
figure
histogram(male_group2.Age_in_Yrs, 'BinEdges', min(ages):1:max(ages), 'FaceAlpha', 0.7);
title('Male Age Distribution - Replication');
xlabel('Age (Years)');
ylabel('Amount');
xticks(min(ages):1:max(ages));

% Female Age Distribution - Group 2
%subplot(2,2,4);
figure
histogram(female_group2.Age_in_Yrs, 'BinEdges', min(ages):1:max(ages), 'FaceAlpha', 0.7);
title('Female Age Distribution - Replication');
xlabel('Age (Years)');
ylabel('Amount');
xticks(min(ages):1:max(ages));

% Adjust layout
%sgtitle('Population Age Distribution by Gender and Group');

%% Gender distrubution
num_male_group1 = sum(strcmp(group1.Gender, 'M'));
num_female_group1 = sum(strcmp(group1.Gender, 'F'));
num_male_group2 = sum(strcmp(group2.Gender, 'M'));
num_female_group2 = sum(strcmp(group2.Gender, 'F'));

% Define categories
categories = {'Discovery\_Male','Discovery\_Female', 'Replication\_Male','Replication\_Female'};

% Define values for males and females separately
values = [num_male_group1, num_female_group1, num_male_group2, num_female_group2];

% Define colors
male_color = [0 0.447 0.741];  % Blue for males
female_color = [0.850 0.325 0.098]; % Red for females
color_array = [{male_color},{female_color},{male_color},{female_color}];
fpp.util.barColor(values,color_array)
% Create bar plot
hold on;

% Set x-axis labels
set(gca,'FontSize',12);
set(gca, 'XTick', 1:4, 'XTickLabel', categories);
xtickangle(30); % Rotate labels for better visibility
ylabel('Number of Subjects');
title('Sex Distribution in Both Groups');
grid on;

% Add legend with correct colors

hold off;

%% mean and SD of subje tpopulation
% mean(male_group1.Age_in_Yrs)
% mean(female_group1.Age_in_Yrs)
% mean(male_group2.Age_in_Yrs)
% mean(female_group2.Age_in_Yrs)
% std(male_group1.Age_in_Yrs)
% std(female_group1.Age_in_Yrs)
% std(male_group2.Age_in_Yrs)
% std(female_group2.Age_in_Yrs)
meanage1 = mean(group1.Age_in_Yrs)
meanage2 = mean(group2.Age_in_Yrs)
stdage1 = std(group1.Age_in_Yrs)
stdage2 = std(group2.Age_in_Yrs)
fpp.util.barColor([meanage1,meanage2],[{male_color},{female_color}],[stdage1,stdage2])

%% Merge Different ROI responses of the same region
Faces = load('/mnt/sml_share/HCP/derivatives/fpp/DiscoveryResults/TPContrasts/space-fsLR_res-2_den-32k_desc-handDrawnRTPThrP6workingmemoryFacesVsAllOthersTop5PctN415Sm4Discovery_roiData.mat');
Bodies = load('/mnt/sml_share/HCP/derivatives/fpp/DiscoveryResults/TPContrasts/space-fsLR_res-2_den-32k_desc-handDrawnRTPThrP6workingmemoryBodyVsAllOthersTop5PctN415Sm4Discovery_roiData.mat');
Tools = load('/mnt/sml_share/HCP/derivatives/fpp/DiscoveryResults/TPContrasts/space-fsLR_res-2_den-32k_desc-handDrawnRTPThrP6workingmemoryToolsVsAllOthersTop5PctN415Sm4Discovery_roiData.mat');
Places = load('/mnt/sml_share/HCP/derivatives/fpp/DiscoveryResults/TPContrasts/space-fsLR_res-2_den-32k_desc-handDrawnRTPThrP6workingmemoryPlacesVsAllOthersTop5PctN415Sm4Discovery_roiData.mat');

