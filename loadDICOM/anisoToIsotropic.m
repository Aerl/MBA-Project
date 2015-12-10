function [ isotropicVolume ] = anisoToIsotropic( anisotropicVolume, xRes, yRes, zRes) 
    %get volume dimensions
    [axDim, ayDim, azDim] = size(anisotropicVolume);
    %get finest resolution
    minDim = min([xRes,yRes, zRes]);
    %get sample ratios per dim
    Div = minDim./[xRes, yRes, zRes];
    %get points where to sample
    samplesX = (1:Div(1):axDim);
    samplesY = (1:Div(2):ayDim);
    samplesZ = (1:Div(3):azDim);
    %get all combinations
    [Sx, Sy, Sz] = meshgrid(samplesX,samplesY, samplesZ);
    
    isotropicVolume = interp3(anisotropicVolume, Sx, Sy, Sz, 'cubic');

end

