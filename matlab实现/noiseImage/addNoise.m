function [ noiseImage ] = addNoise( idealImageDir, var )
%UNTITLED4 此处显示有关此函数的摘要
%   此处显示详细说明
idealImage = imread(idealImageDir);
idealImage = im2double(idealImage);
noiseImage = imnoise(idealImage,'gaussian',0,var);        %加入高斯噪声的图像
imwrite(noiseImage,'medi_noise.bmp');
end

