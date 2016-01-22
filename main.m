%% structs
global s;
s = struct('OriginalImages',{},'ResampledImages',{},'Names',{}, 'Segmentation',{}, 'BinarySegmentation', {});
global p;
p = struct('iterations',[],'delta_time',[],'gac_weight',[],'propagation_weight',...
    [],'mu',[],'resolution',{}, 'subsamplingIsOn',[], 'smoothDistanceFieldIsOn',[],...
    'gaussSize',[],'gaussSigma',[]);
p(1).iterations = 40;
p(1).delta_time = 1;
p(1).propagation_weight = 1e-6;
p(1).gac_weight = 1 - p(1).propagation_weight;
p(1).mu = 300;
p(1).subsamplingIsOn = 1;
p(1).smoothDistanceFieldIsOn = 0;
p(1).gaussSize = [10 10];
p(1).gaussSigma = 8;

close all;

% add subfolders
addpath('loadDICOM');
addpath('AOSLevelsetSegmentationToolboxM');
addpath('imtool3D');

%% Load Image (just for image data not for segmentation)
formatOut = 'dd.mm.yyyy-HH.MM.SS';

tic

for patient = 1:9
    %% Load Image
    % set file path by text file
    parentpath = fileread('PathToDataset.txt'); % Copy 'PathToDataset.txt.sample' to 'PathToDataset.txt' set the correct path
    dataset = strcat('p0',num2str(patient));
    disp(dataset);
    scan = 't1_wk';
    filepath = strcat(parentpath,'/','Data_v2/',dataset,'/',scan);
    
    % use dialog to select folder
    % filepath = uigetdir;
    
    % load all images in filepath
    path = getAllFiles(filepath);
    [s(1).Names,s(1).ResampledImages,s(1).OriginalImages] = loadDICOM(path);
    
    for vertebra = 1:5
        %% Segmentation of all vertebrae
        disp(strcat('-v',num2str(vertebra)));
        [s(1).Segmentation{vertebra}, s(1).BinarySegmentation{vertebra}] = segmentVertebra(vertebra,s(1).ResampledImages{vertebra},s(1).OriginalImages{vertebra});

        % load ground truth images
        filepath = strcat(parentpath,'/','Data_Segmentation');
        filter = strcat(dataset,'_seg_l',num2str(vertebra),'*.png');
        groundTruthFiles = dir(fullfile(filepath,filter));
        groundTruthFiles = {groundTruthFiles.name};
        
        groundTruthImages = cell(numel(groundTruthFiles),1);
        groundTruthNames = cell(numel(groundTruthFiles),1);
        for i = 1:numel(groundTruthFiles)
            groundTruthNames{i} = fullfile(filepath,groundTruthFiles{i});
            groundTruthImages{i} = imread(groundTruthNames{i});
        end
        
        %plot everything
        title = strcat(dataset,' - Vertebra  ',num2str(vertebra));
        figure('name',title,'numbertitle','off');
        sizeIMG = size(s(1).OriginalImages{vertebra}(:,:,1));
        for i = 1:15
            groundTruth = imresize(groundTruthImages{i},sizeIMG);
            subplot(3,5,i);
            imshow(s(1).OriginalImages{vertebra}(:,:,i),[]);
            green = cat(3, zeros(sizeIMG),ones(sizeIMG), zeros(sizeIMG));
            red = cat(3, ones(sizeIMG),zeros(sizeIMG), zeros(sizeIMG));
            hold on;
            hg = imshow(green);
            hr = imshow(red);
            hold off;
            set(hr, 'AlphaData',0.3* s(1).BinarySegmentation{vertebra}(:,:,i))
            set(hr, 'AlphaData',0.3* s(1).BinarySegmentation{vertebra}(:,:,i))
            set(hg, 'AlphaData',0.3* groundTruth)
        end
        
        % calculate jaccard and dice index
        [jaccardIndex, diceIndex] = similarity(s(1).BinarySegmentation{vertebra},groundTruthImages,sizeIMG);
        disp('');
        disp(strcat('Jaccard Index of ',dataset,' Vertebra #',num2str(vertebra) ,':'));
        disp(jaccardIndex);
        disp(strcat('Dice Index of ',dataset,' Vertebra #',num2str(vertebra) ,':'));
        disp(diceIndex);
        
    end
    
end
toc

filename = strcat('Jaccard-Subsampling(',num2str(p(1).subsamplingIsOn),...
    ')-Smoothing(',num2str(p(1).smoothDistanceFieldIsOn),')-',...
    datestr(clock, formatOut),'.mat');
save(filename,'ResultJaccard');

% clear workspace
clear all;
