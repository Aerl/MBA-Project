
%list_of_files=dir(fullfile('', '*.dat'));

filePath = './data/Data_v2/p01/t1/p01_t1_tse_00001.dcm';
info = dicominfo(filename);
image = dicomread(info);
figure,
imshow(image,[]);
