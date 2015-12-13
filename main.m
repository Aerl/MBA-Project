%% structs
global s;
s = struct('Images',{},'Names',{}, 'Segmentation',{});
global p;
p = struct('delta_time',[],'gac_weight',[],'propagation_weight',[],'mu',[]);
p(1).delta_time = 20;
p(1).propagation_weight = 1e-5;
p(1).gac_weight = 1;
p(1).mu = 300;

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
[s(1).Names,s(1).Images] = loadDICOM(path);

for v =1:5
    
    
    % select Vertebra
    image = s(1).Images{v};
    
    %% Hybrid 3D Levelset
    % g = ones(size(V)); % linear diffusion
    gradient_field = ac_gradient_map(image,1);
    
    margin = [8 8 15];
    % center = size(img);
    % center = round(center/2);
    center = [32 37 27];
    
    distance_field = initialize_distance_field(size(image), center, margin, 0.5);
    
    % Create the gaussian filter with hsize = [5 5] and sigma = 2
    %gauss_filter = fspecial('gaussian',[10 10],2);
    %distance_field = imfilter(distance_field,gauss_filter,'same');
    
    s(1).Segmentation{v} = levelSet( image, distance_field, gradient_field, 10 );
    
    % result = cell(size(image,3),1);
    % for i = 1:size(image,3)
    %     result{i} = contours(distance_field(:,:,i),[0,0]);
    % end
    
    figure;
    slice = [1 4:3:55 length(s(1).Segmentation{v})]; %20
    for i = 1:length(slice)
        subplot(4,5,i); imshow(image(:,:,slice(i)),[]); hold on;
        r = s(1).Segmentation{v}{slice(i)};
        if ~isempty(r)
            [h, pt] = zy_plot_contours(r,'linewidth',2);
        end
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
