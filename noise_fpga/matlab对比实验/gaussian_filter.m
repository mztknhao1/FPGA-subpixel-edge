I_noise = imread('photo2noise.bmp');
I_noise = im2double(I_noise);
[weight,high] = size(I_noise);                      %Í¼Æ¬µÄ³¤ºÍ¿í
G = zeros(weight,high);  
K = [1,2,1;2,4,2;1,2,1]./16; 
for i=2:(weight-1)
    for j = 2:(high-1)
        mask = I_noise(i-1:i+1,j-1:j+1);
        mask_I = mask.*K;
        G(i,j) = sum(sum(mask_I)).*255;
    end
end
G = G(2:319,:);

gaussian_file = 'gaussian.txt';
gaussian = textread(gaussian_file,'%s');
gaussian_dec = bin2dec(gaussian(1:162816,1));
guassian_image = reshape(gaussian_dec,512,318)';


subplot(121)
imshow(G./255)
title('matlab gaussian')

subplot(122)
imshow(guassian_image./255);
title('FPGA gaussian');



