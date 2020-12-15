function [ matlab_sim_noise,ISobel] = noiseLine2( I_dir,threshold )
%UNTITLED2 此处显示有关此函数的摘要
%   此处显示详细说明
I_noise = imread(I_dir);
I_noise = im2double(I_noise);
[weight1,high1] = size(I_noise);                      %图片的长和宽
G = I_noise;  
tic
K = [1,2,1;2,4,2;1,2,1]./16; 
for i=2:(weight1-1)
    for j = 2:(high1-1)
        mask = I_noise(i-1:i+1,j-1:j+1);
        mask_I = mask.*K;
        G(i,j) = sum(sum(mask_I)).*255;
    end
end
G = G(2:319,:);
[weight,high] = size(G);
%% ---------------------滤波后，sobel算子计算粗边缘------------------%
% 求梯度图像Fx,Fy                          
%计算图像梯度，此时需要扩充图像
I_expan = zeros(weight+2,high+2);                   %扩充后的图像
for m = 2:1:weight+1
    for n = 2:1:high+1
        I_expan(m,n) = G(m-1,n-1);
    end
end
% 设置Sobel算子x方向模板，y方向模板
Hx = [-1,-2,-1;0,0,0;1,2,1];
Hy = Hx';
%编程序实现x,y方向梯度计算
Fx1 = zeros(weight+2,high+2);
Fy1 = zeros(weight+2,high+2);
W = zeros(3,3);%移动窗口
for i = 1:weight
    for j = 1:high
        %模板移动窗口
        W = [I_expan(i,j),I_expan(i,j+1),I_expan(i,j+2); ...
             I_expan(i+1,j),I_expan(i+1,j+1),I_expan(i+1,j+2); ...
             I_expan(i+2,j),I_expan(i+2,j+1),I_expan(i+2,j+2)];
        Sx = Hx .* W;
        Sy = Hy .* W;
        Fx1(i+1,j+1) = sum(sum(Sx));
        Fy1(i+1,j+1) = sum(sum(Sy));
    end
end
% 将一圈扩展1个像素的图像复原
Fx = zeros(weight,high);
Fy = zeros(weight,high);
for i = 1:weight
    for j = 1:high
        Fx(i,j) = Fx1(i+1,j+1);
        Fy(i,j) = Fy1(i+1,j+1);
    end
end

point = [];                                         %边缘点位置
ISobel = zeros(weight,high);                        %边缘图像
I_edge = abs(Fx) + abs(Fy);
for k = 2:(weight-1)
    for j = 2:(high-1)
        if (I_edge(k,j)>=threshold)
            ISobel(k,j) = 1;
            point = [point;k,j];                    %边缘点的位置
        else
            ISobel(k,j) = 0;
        end
    end
end
[number,~] = size(point);                           %像素级边缘点的个数
point_direc = zeros(number,3);                      %边缘点处斜率范围
for a = 1:1:number
    if abs(Fy(point(a,1),point(a,2)))<=abs(Fx(point(a,1),point(a,2)))
        if(Fy(point(a,1),point(a,2))*Fx(point(a,1),point(a,2))>0)
                Direc = 2;                          %(0,45)
        else    Direc = 1;                           %(135,180)
        end
    elseif abs(Fy(point(a,1),point(a,2))) > abs(Fx(point(a,1),point(a,2)))
        if(Fy(point(a,1),point(a,2))*Fx(point(a,1),point(a,2))>0)
                Direc = 8;      %(45,90)
        else    Direc = 4;      %(90,135)
        end
    end
    point_direc(a,:) = [point(a,1),point(a,2),Direc];
end

%% 亚像素边缘计算
%忽略图像边缘的像素
matlab_sim_noise = [];
for h = 1:number
    state = point_direc(h,3);
    cx = point_direc(h,1); cy = point_direc(h,2);
    if(cx>3 && cy>3 && cx<(weight-3) && cy<(high-3))
        switch state
            case 2                                              %（0，45）
                Window = G(cx-3:cx+3,cy-1:cy+1);
                A = (Window(7,3)+Window(7,2)/2+Window(6,3)/2)/2;
                B = (Window(1,1) + Window(1,2)/2 + Window(2,1)/2)/2;            
                SL = sum(Window(3:7,1));
                SM = sum(Window(2:6,2));
                SR = sum(Window(1:5,3));
                m = 1;
            case 1                                             %（135，180）
                Window = G(cx-3:cx+3,cy-1:cy+1);
                A = (Window(7,1)+Window(7,2)/2+Window(6,1)/2)/2;
                B = (Window(1,3) + Window(1,2)/2 + Window(2,3)/2)/2;            
                SL = sum(Window(1:5,1));
                SM = sum(Window(2:6,2));
                SR = sum(Window(3:7,3));
                m = -1;
            case 8                                             %（45，90）
                Window = G(cx-1:cx+1,cy-3:cy+3);
                A = (Window(3,7)+Window(2,7)/2+Window(3,6)/2)/2;
                B = (Window(1,1) + Window(2,1)/2 + Window(1,2)/2)/2;
                SL = sum(Window(1,3:7));
                SM = sum(Window(2,2:6));
                SR = sum(Window(3,1:5));
                m = 1;
            case 4                                              %(90,135)
                Window = G(cx-1:cx+1,cy-3:cy+3);
                A = (Window(3,1)+Window(3,2)/2+Window(2,1)/2)/2;
                B = (Window(1,7) + Window(1,6)/2 + Window(2,7)/2)/2;
                SL = sum(Window(1,1:5));
                SM = sum(Window(2,2:6));
                SR = sum(Window(3,3:7));
                m = -1;
        end
        if(A ~= B)
            atemp = (2*SM - 5*(A+B))/(2*(A-B));
            btemp = m + (SR-SL)/(2*(A-B));
        else
            atemp = 0;
            btemp = 0;
        end
        matlab_sim_noise = [matlab_sim_noise;cx,cy,atemp,btemp,state];
    end
end
toc
end


