function initialFunction(~, ~)

direction = uigetdir;
new_folder_name = strcat(direction);
path = getAllFiles(new_folder_name);
[names,image3d] = loadDICOM(path);

end

