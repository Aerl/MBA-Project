% clear workspace
clear all;
% add subfolders
addpath('loadDICOM');
addpath('imtool3D');

%% Load Image

% set file path by text file
parentpath = fileread('PathToDataset.txt'); % Copy 'PathToDataset.txt.sample' to 'PathToDataset.txt' set the correct path
dataset = 'p02';
scan = 't1_wk';
filepath = strcat(parentpath,'\','Data_v2\',dataset,'\',scan);

% use dialog to select folder
% filepath = uigetdir;

% load all images in filepath
path = getAllFiles(filepath);
[names,images] = loadDICOM(path);

img = double(cell2mat(images(3)));
 
imtool3D(img);
