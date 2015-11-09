clear all;
addpath('loadDICOM');
addpath('Imshow3D');

parentpath = fileread('PathToDataset.txt'); % Copy 'PathToDataset.txt.sample' to 'PathToDataset.txt' set the correct path
dataset = 'p02';
scan = 't1';

filepath = strcat(parentpath,'\','Data_v2\',dataset,'\',scan);

path = getAllFiles(filepath);
[names,image3d] = loadDICOM(path);

figure,
imshow3D(image3d,[])
