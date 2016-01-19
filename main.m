%% structs
global s;
s = struct('OriginalImages',{},'ResampledImages',{},'Names',{}, 'Segmentation',{}, 'BinarySegmentation', {});

global p;
p = struct('iterations',[],'delta_time',[],'gac_weight',[],'propagation_weight',...
    [],'mu',[],'resolution',{}, 'subsamplingIsOn',[], 'smoothDistanceFieldIsOn',[],...
    'gaussSize',[],'gaussSigma',[],'convergenceThreshold',[]);

p(1).iterations = 40;
p(1).delta_time = 1;
p(1).propagation_weight = 1e-6;
p(1).gac_weight = 1 - p(1).propagation_weight;
p(1).mu = 300;
p(1).subsamplingIsOn = 1;
p(1).smoothDistanceFieldIsOn = 0;
p(1).gaussSize = [10 10];
p(1).gaussSigma = 8;
p(1).convergenceThreshold = 400;

close all;

% add subfolders
addpath('loadDICOM');
addpath('AOSLevelsetSegmentationToolboxM');
addpath('imtool3D');

ResultJaccard = zeros(10,6);
ResultJaccard(:,1) = 0:9;
ResultJaccard(1,:) = 0:5;

for patient = 1:9
    %% Load Image
    % set file path by text file
    parentpath = fileread('PathToDataset.txt'); % Copy 'PathToDataset.txt.sample' to 'PathToDataset.txt' set the correct path
    dataset = strcat('p0',num2str(patient));
    scan = 't1_wk';
    filepath = strcat(parentpath,'\','Data_v2\',dataset,'\',scan);
    
    % use dialog to select folder
    % filepath = uigetdir;
    
    % load all images in filepath
    path = getAllFiles(filepath);
    [s(1).Names,s(1).ResampledImages,s(1).OriginalImages] = loadDICOM(path);
    
    
    for vertebra = 1:5
        %% Segmentation of all vertebrae
        [s(1).Segmentation{vertebra}, s(1).BinarySegmentation{vertebra}] = segmentVertebra(vertebra,s(1).ResampledImages{vertebra},s(1).OriginalImages{vertebra});

        % load ground truth images
        filepath = strcat(parentpath,'\','Data_Segmentation');
        filter = strcat(dataset,'_seg_l',num2str(vertebra),'*.png');
        groundTruthFiles = dir(fullfile(filepath,filter));
        groundTruthFiles = {groundTruthFiles.name};
        groundTruthImages = cell(numel(groundTruthFiles),1);
        groundTruthNames = cell(numel(groundTruthFiles),1);
        for i = 1:numel(groundTruthFiles)
            groundTruthNames{i} = fullfile(filepath,groundTruthFiles{i});
            groundTruthImages{i} = imread(groundTruthNames{i});
        end
        
        % calculate jaccard index for each vertebra
        sumInter = 0;
        sumUnion = 0;
        slice = 1:15;
        for i = 1:length(slice)
            groundTruth = imresize(groundTruthImages{i},size(s(1).BinarySegmentation{vertebra}(:,:,slice(i))));
            nInter = nnz(groundTruth.*s(1).BinarySegmentation{vertebra}(:,:,slice(i)));
            nUnion = nnz(groundTruth+s(1).BinarySegmentation{vertebra}(:,:,slice(i)));
            sumInter = sumInter + nInter;
            sumUnion = sumUnion + nUnion;
            %subplot(3,5,i); imshow(groundTruthImages{i},[]);
        end
        jaccardIndex = sumInter / sumUnion;
        disp('');
        disp(strcat('Jaccard Index of ',dataset,' Vertebra #',num2str(vertebra) ,':'));
        disp(jaccardIndex);
        ResultJaccard(patient+1,vertebra+1) = jaccardIndex;
        
        %plot everything
        title = strcat(dataset,' - Vertebra  ',num2str(vertebra),' - Jaccard: ',num2str(jaccardIndex));
        figure('name',title,'numbertitle','off');
        sizeIMG = size(s(1).OriginalImages{vertebra}(:,:,slice(1)));
        slice = 1:15;
        for i = 1:length(slice)
            groundTruth = imresize(groundTruthImages{i},sizeIMG);
            subplot(3,5,i);
            imshow(s(1).OriginalImages{vertebra}(:,:,slice(i)),[]);
            green = cat(3, zeros(sizeIMG),ones(sizeIMG), zeros(sizeIMG));
            red = cat(3, ones(sizeIMG),zeros(sizeIMG), zeros(sizeIMG));
            hold on;
            hg = imshow(green);
            hr = imshow(red);
            hold off;
            set(hr, 'AlphaData',0.3* s(1).BinarySegmentation{vertebra}(:,:,slice(i)))
            set(hg, 'AlphaData',0.3* groundTruth)
        end
    end
end
% clear workspace
clear all;
