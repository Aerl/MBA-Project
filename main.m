%% structs
global s;
s = struct('Images',{},'Names',{});
global p;
p = struct('delta_time',[],'gac_weight',[],'propagation_weight',[],'mu',[]);
p(1).delta_time = 1;
p(1).propagation_weight = 1e-4; 
p(1).gac_weight = 1; 
p(1).mu = 200;

% clear workspace
% clear all;
close all;
% add subfolders
addpath('loadDICOM');
addpath('AOSLevelsetSegmentationToolboxM');
addpath('imtool3D');

%% Load Image (just for image data not for segmentation)

% set file path by text file
% parentpath = fileread('PathToDataset.txt'); % Copy 'PathToDataset.txt.sample' to 'PathToDataset.txt' set the correct path
% dataset = 'p01';
% scan = 't1_wk';
% filepath = strcat(parentpath,'\','Data_v2\',dataset,'\',scan);

% use dialog to select folder
filepath = uigetdir;

% load all images in filepath
path = getAllFiles(filepath);
[s(1).Name,s(1).Images] = loadDICOM(path);

% select Vertebra
image = s(1).Images{4};

%% Hybrid 3D Levelset
% g = ones(size(V)); % linear diffusion 
gradient_field = ac_gradient_map(image,1); 

margin = [8 8 16]; 
% center = size(img);
% center = round(center/2); 
center = [32 37 8*4];
 
distance_field = initialize_distance_field(size(image), center, margin);

% Create the gaussian filter with hsize = [5 5] and sigma = 2
gauss_filter = fspecial('gaussian',[5 5],2);
distance_field = imfilter(distance_field,gauss_filter,'same');

result = levelSet( image, distance_field, gradient_field, 10 );


figure;
slice = [2,3,4,5,6,7,8,9,10,11,12,13];
slice = slice*4;
for i = 1:length(slice)
    subplot(3,4,i); imshow(image(:,:,slice(i)),[]); hold on; 
    r = result{slice};
    zy_plot_contours(r,'linewidth',2);
end


%
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
% slice = [2,3,4,5,6,7,8,9,10,11,12,13];
% for i = 1:numel(slice)
%     subplot(3,4,i); imshow(img(:,:,slice(i)),[]); hold on; 
%     c = contours(phi(:,:,slice(i)),[0,0]);
%     zy_plot_contours(c,'linewidth',2);
% end
