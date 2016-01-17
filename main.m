%% structs
global s;
s = struct('OriginalImages',{},'ResampledImages',{},'Names',{}, 'Segmentation',{}, 'BinarySegmentation', {});
global p;
p = struct('iterations',[],'delta_time',[],'gac_weight',[],'propagation_weight',[],'mu',[],'resolution',{});
p(1).iterations = 10;
p(1).delta_time = 0.5;
p(1).propagation_weight = 5e-3;
p(1).gac_weight = 1 - p(1).propagation_weight;
p(1).mu = 200;

close all;

% add subfolders
addpath('loadDICOM');
addpath('AOSLevelsetSegmentationToolboxM');
addpath('imtool3D');

%% Load Image (just for image data not for segmentation)

% set file path by text file
parentpath = fileread('PathToDataset.txt'); % Copy 'PathToDataset.txt.sample' to 'PathToDataset.txt' set the correct path
dataset = 'p06';
scan = 't1_wk';
filepath = strcat(parentpath,'\','Data_v2\',dataset,'\',scan);

% use dialog to select folder
% filepath = uigetdir;

% load all images in filepath
path = getAllFiles(filepath);
[s(1).Names,s(1).ResampledImages,s(1).OriginalImages] = loadDICOM(path);

for v =1:5
    
    
    % select Vertebra
    image = s(1).ResampledImages{v};
    
    %% Hybrid 3D Levelset
    % g = ones(size(V)); % linear diffusion
    gradient_field = ac_gradient_map(image,1);
    center = size(image);
    margin = center * 0.08;
    margin(3) = margin(3) * 2;
    margin = round(margin);
    center = center/2;
    center(1:2) = center(1:2)*1.02;
    center = round(center);
    
    distance_field = initialize_distance_field(size(image), center, margin, 0.5);
    
    % Create the gaussian filter with hsize = [5 5] and sigma = 2
    %gauss_filter = fspecial('gaussian',[10 10],2);
    %distance_field = imfilter(distance_field,gauss_filter,'same');
    
    [s(1).Segmentation{v}, s(1).BinarySegmentation{v}] = levelSet( image, distance_field, gradient_field, p(1).resolution{v} );
    
    % result = cell(size(image,3),1);
    % for i = 1:size(image,3)
    %     result{i} = contours(distance_field(:,:,i),[0,0]);
    % end
    
    image = s(1).OriginalImages{v};
    
    figure;
    slice = 1:15;
    for i = 1:length(slice)
        subplot(3,5,i); imshow(image(:,:,slice(i)),[]); hold on;
        r = s(1).Segmentation{v}{slice(i)};
        if ~isempty(r)
            [h, pt] = zy_plot_contours(r,'linewidth',2);
        end
    end

    % recalculate center of anisotropic data
    center = size(s(1).OriginalImages{v});
    center = center/2;
    center(1:2) = center(1:2)*1.02;
    center = round(center);

    % connected component analysis
    l = bwlabeln(s(1).BinarySegmentation{v});
    labelOfVertebra = l(center(1),center(2),center(3));
    
    binaryResult = (l==labelOfVertebra);
    
    figure;
    for i = 1:length(slice)
        subplot(3,5,i); imshow(binaryResult(:,:,slice(i)),[]);
    end
    
end

%% Chan Vese 3D Levelset
% smooth_weight = 3;
% image_weight = 1e-4 ;
% delta_t = 1;
%
% margin = 30;
% phi = zeros(size(img));
% phi(margin:end-margin, margin:end-margin, 5:end-5) = 1;
% phi = ac_reinit(phi-0.5);
%
% for i = 1:10
%     phi = ac_ChanVese_model(img, phi, smooth_weight, image_weight, delta_t, 1);
% end
%
% figure;
% slice = 29:41;
% for i = 1:numel(slice)
%     subplot(3,4,i); imshow(img(:,:,slice(i)),[]); hold on;
%     c = contours(phi(:,:,slice(i)),[0,0]);
%     zy_plot_contours(c,'linewidth',2);
% end


% clear workspace
clear all;
