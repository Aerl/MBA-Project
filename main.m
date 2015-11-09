clear all;
homedirectory = pwd;
parentpath = cd(cd('..'));
dataset = 'p02';
scan = 't1';

filepath = strcat(parentpath,'/','Data_v2/',dataset,'/',scan);

listOfFiles = dir(filepath);

%structSize = length(listOfFiles(name));
for i = 1:numel(listOfFiles)
    filename = listOfFiles(i).name;
    if ~strcmp(filename,'.') && ~strcmp(filename,'..')
        info = dicominfo(strcat(filepath,'/',filename));
        image = dicomread(info);
        figure,
        imshow(image,[]);
    end
        
end
    


