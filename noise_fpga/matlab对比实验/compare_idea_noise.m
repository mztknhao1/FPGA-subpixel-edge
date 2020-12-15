clear;
clc;
I_ideal_dir = 'medi.bmp';
I_noise_dir = 'medi_noise.bmp';                 %var = 0.001
[matlab_sim_ideal,matlab_ideal_sobel] = idealLine(I_ideal_dir,400);
[matlab_sim_noise,matlab_noise_sobel] = noiseLine2(I_noise_dir,400);
[a_dist,b_dist,number] = compare(matlab_sim_ideal,matlab_sim_noise);
subplot(221)
imshow('medi.bmp');
title('理想图片')
subplot(222)
imshow('medi_noise.bmp');
title('带噪声图片');
subplot(223)
imshow(matlab_ideal_sobel);
title('理想图片边缘')
subplot(224)
imshow(matlab_noise_sobel);
title('带噪声经过高斯处理后的边缘');
