%% structs
global s;
s = struct('OriginalImages',{},'ResampledImages',{},'Names',{}, 'Segmentation',{}, 'BinarySegmentation', {});
global p;
p = struct('iterations',[],'delta_time',[],'gac_weight',[],'propagation_weight',...
    [],'mu',[],'resolution',{}, 'subsamplingIsOn',[], 'smoothDistanceFieldIsOn',[],...
    'gaussSize',[],'gaussSigma',[]);
p(1).iterations = 20;
p(1).delta_time = 0.5;
p(1).propagation_weight = 1e-6;
p(1).gac_weight = 1 - p(1).propagation_weight;
p(1).mu = 300;
p(1).subsamplingIsOn = 1;
p(1).smoothDistanceFieldIsOn = 0;
p(1).gaussSize = [10 10];
p(1).gaussSigma = 8;

%close all;

% add subfolders
addpath('loadDICOM');
addpath('AOSLevelsetSegmentationToolboxM');
addpath('imtool3D');

%% Load Image (just for image data not for segmentation)

% set file path by text file
parentpath = fileread('PathToDataset.txt'); % Copy 'PathToDataset.txt.sample' to 'PathToDataset.txt' set the correct path
dataset = 'p03';
scan = 't1_wk';
filepath = strcat(parentpath,'\','Data_v2\',dataset,'\',scan);

% use dialog to select folder
% filepath = uigetdir;

% load all images in filepath
path = getAllFiles(filepath);
[s(1).Names,s(1).ResampledImages,s(1).OriginalImages] = loadDICOM(path);

%% Segmentation of all vertebrae
for v =1:5
    
    % select Vertebra
    if (p(1).subsamplingIsOn)
        image = s(1).ResampledImages{v};
    else
        image = s(1).OriginalImages{v};
    end
    
    % compute gradient field
    gradient_field = ac_gradient_map(image,1);
    
    % set center and margin depending on image size
    center = size(image);
    margin = center * 0.08;
    margin(3) = margin(3) * 2;
    margin = round(margin);
    center = center/2;
    center(1:2) = center(1:2)*1.1;
    center = round(center);
    
    %initialize distance field
    distance_field = initialize_distance_field(size(image), center, margin, 0.5);
    % smooth Initialization
    if (p(1).smoothDistanceFieldIsOn)
        gauss_filter = fspecial('gaussian',p(1).gaussSize,p(1).gaussSigma);  % size = [5 5] and sigma = 2
        distance_field = imfilter(distance_field,gauss_filter,'same');
    end
    
    % segment vertebra using hybrid level set
    [s(1).Segmentation{v}, s(1).BinarySegmentation{v}] = levelSet( image, distance_field, gradient_field, p(1).resolution{v} );
    
    % show segmentation
    originalImage = s(1).OriginalImages{v};
    figure;
    slice = 1:15;
    for i = 1:length(slice)
        subplot(3,5,i); imshow(originalImage(:,:,slice(i)),[]); hold on;
        r = s(1).Segmentation{v}{slice(i)};
        if ~isempty(r)
            [h, pt] = zy_plot_contours(r,'linewidth',2);
        end
    end
    
    % recalculate center of anisotropic data
    if (p(1).subsamplingIsOn)
        center = size(image);
        center = center/2;
        center(1:2) = center(1:2)*1.1;
        center = round(center);
    end
    
    % connected component analysis
    l = bwlabeln(s(1).BinarySegmentation{v});
    labelOfVertebra = l(center(1),center(2),center(3));
    binaryResult = (l==labelOfVertebra);
    
    % show binary vertebra segmentation
    figure;
    for i = 1:length(slice)
        subplot(3,5,i); imshow(binaryResult(:,:,slice(i)),[]);
    end
    
    % load ground truth images
    filepath = strcat(parentpath,'\','Data_Segmentation');
    filter = strcat(dataset,'_seg_l',num2str(v),'*.png');
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
    figure;
    for i = 1:length(slice)
        groundTruth = imresize(groundTruthImages{i},size(binaryResult(:,:,slice(i))));
        nInter = nnz(groundTruth.*binaryResult(:,:,slice(i)));
        nUnion = nnz(groundTruth+binaryResult(:,:,slice(i)));
        sumInter = sumInter + nInter;
        sumUnion = sumUnion + nUnion;
        subplot(3,5,i); imshow(groundTruthImages{i},[]);
    end
    
    jaccardIndex = sumInter / sumUnion;
    disp('');
    disp(strcat('Jaccard Index of ',dataset,' Vertebra #',num2str(v) ,':'));
    disp(jaccardIndex);
    
end

% clear workspace
clear all;
