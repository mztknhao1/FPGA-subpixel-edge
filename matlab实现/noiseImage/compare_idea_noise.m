clear;
clc;
I_ideal_dir = 'medi.bmp';
[~] = addNoise(I_ideal_dir, 0.0001);
I_noise_dir = 'medi_noise.bmp';                
[matlab_sim_ideal,matlab_ideal_sobel] = idealLine(I_ideal_dir,200);
[matlab_sim_noise1,matlab_noise_sobel1] = noiseLine(I_noise_dir,200);   %9x9
[matlab_sim_noise2,matlab_noise_sobel2] = noiseLine2(I_noise_dir,200);   %7x7
[a_dist1,b_dist1,number1] = compare(matlab_sim_ideal,matlab_sim_noise1);
[a_dist2,b_dist2,number2] = compare(matlab_sim_ideal,matlab_sim_noise2);
subplot(221)
imshow('medi.bmp');
title('����ͼƬ')
subplot(222)
imshow('medi_noise.bmp');
title('������ͼƬ');
subplot(223)
imshow(matlab_ideal_sobel);
title('����ͼƬ��Ե')
subplot(224)
imshow(matlab_noise_sobel1);
title('������������˹�����ı�Ե');
