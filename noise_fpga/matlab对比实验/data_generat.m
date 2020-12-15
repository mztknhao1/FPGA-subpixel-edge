clear;clc
I_dir = 'medi';
var = 0.001;
I_source = imread(strcat(I_dir,'.bmp'));
I_source = im2double(I_source);
I_noise = imnoise(I_source,'gaussian',0,var);        %加入高斯噪声的图像
I_n = I_noise.*255;
imwrite(I_noise,strcat(I_dir,'_noise.bmp'));
I = imread(strcat(I_dir,'_noise.bmp'));
subplot(121)
imshow(I_source);
title('I source')
subplot(122)
imshow(I_noise);
title('I noise')
I_bin = dec2bin(I');
fp = fopen(strcat(I_dir,'noise.txt'),'w');
for j = 1:1:163840
   fprintf(fp,'%s\n',I_bin(j,:));
end
fclose(fp);