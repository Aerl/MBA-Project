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
[names,images] = loadDICOM(path);

% select Vertebra
img = images{4};

%% Hybrid 3D Levelset
propagation_weight = 1e-4; 
GAC_weight = 1; 
% g = ones(size(V)); % linear diffusion 
g = ac_gradient_map(img,1); 
delta_t = 2; 
mu = 200; 

margin = 8; 
% center = size(img);
% center = round(center/2); 
center = [32 37 8*4];
phi = zeros(size(img)); 
phi(center(1)-margin:center(1)+margin,...
    center(2)-margin:center(2)+margin,...
    center(3)-(4*4):center(3)+(4*4)) = 1; 

for i = 1:5
    phi = ac_hybrid_model(img-mu, phi-.5, propagation_weight, GAC_weight, g, ...
        delta_t, 1); 
end

figure;
slice = [2,3,4,5,6,7,8,9,10,11,12,13];
slice = slice*4;
for i = 1:numel(slice)
    subplot(3,4,i); imshow(img(:,:,slice(i)),[]); hold on; 
    c = contours(phi(:,:,slice(i)),[0,0]);
    zy_plot_contours(c,'linewidth',2);
end


%% Region Growing
% figure, imshow(img(:,:,8),[]);
% p = ginput(1);
% poly = regionGrowing(squeeze(img), [round(p(2)),round(p(1)),8], 100, 25, [], true, false);
%     
% 
% figure;
% slice = [2,3,4,5,6,7,8,9,10,11,12,13];
% for i = 1:numel(slice)
%     subplot(3,4,i); imshow(img(:,:,slice(i)),[]); hold on; 
%     p = find(poly(:,3)==slice(i));
%     plot(poly(p,1), poly(p,2), 'LineWidth', 2);
% end

% figure, imshow(img(:,:,8), []), hold all;
% poly = regionGrowing(img(:,:,8), [], 120);
% plot(poly(:,1), poly(:,2), 'LineWidth', 2);



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
