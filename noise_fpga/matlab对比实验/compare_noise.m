clear;clc
% 原带噪声图
subplot(131)
I_dir = 'medi_noise.bmp';
imshow(I_dir);
title('原噪声图')

%% matlab仿真结果
[matlab_sim_noise,matlab_sobel] = noiseLine2(I_dir,400);
subplot(132)
imshow(matlab_sobel)
title('matlab仿真边缘')

%% FPGA仿真结果
%读入仿真数据
a_file = 'medinoise_a.txt';
b_file = 'medinoise_b.txt';
state_file = 'medinoise_state.txt';
%获得state的数据，将state不为0的下标存入state_sub
state = textread(state_file,'%s');
state_dec = bin2dec(state);
state_index = find(state_dec>0);
s = [512,318];
[l,o] = ind2sub(s,state_index+1540-13);                    %3*512+5=1541     matlab的下标从1开始，仿真输出从0开使计算        
state_sub(:,1) = o;
state_sub(:,2) = l;
[len,~] = size(state_sub);


%接下来转化a,b的格式，存入a_float和b_float
a_FPGA = textread(a_file,'%s');
a_dec = hex2dec(a_FPGA(14:159751,1));
a_float = typecast(uint32(a_dec),'single');

b_FPGA = textread(b_file,'%s');
b_dec = hex2dec(b_FPGA(14:159751,1));
b_float = typecast(uint32(b_dec),'single');


FPGA_sim_noise = [];
FPGA_image = zeros(318,512);
FPGA_edge = [];
for i=1:len
    a_temp_dist = state_sub(i,1);
    b_temp_dist = state_sub(i,2);
      if(a_temp_dist>9 && b_temp_dist>9 && a_temp_dist<311 && b_temp_dist<503)
        indtemp = (a_temp_dist-1)*512+b_temp_dist-1540;           
        statetemp = state_dec(indtemp+13,1);
        FPGA_edge = [FPGA_edge;a_temp_dist,b_temp_dist,statetemp];
        FPGA_image(a_temp_dist,b_temp_dist) = 1;  
        atemp = a_float(indtemp,1);                   %p11~p55-> state(6周期） -> SL,SM,SR和A，B(3周期） -> 分子，分母（3周期）
        btemp = b_float(indtemp,1);                   %-> 除法器(9周期），matlab下标从1开始：3+3+9 = 15
        FPGA_sim_noise = [FPGA_sim_noise;a_temp_dist,b_temp_dist,atemp,btemp,statetemp];
     end
   
end
subplot(133)
imshow(FPGA_image)
title('FPGA仿真边缘')

[a_dist,b_dist,~] = err(matlab_sim_noise,FPGA_sim_noise);