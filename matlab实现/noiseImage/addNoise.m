function [ noiseImage ] = addNoise( idealImageDir, var )
%UNTITLED4 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
idealImage = imread(idealImageDir);
idealImage = im2double(idealImage);
noiseImage = imnoise(idealImage,'gaussian',0,var);        %�����˹������ͼ��
imwrite(noiseImage,'medi_noise.bmp');
end

