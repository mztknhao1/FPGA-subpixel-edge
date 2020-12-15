%基于局部的亚像素边缘提取
%完全理想的情况，阶跃边缘
%低噪声下高斯滤波

%% 构造理想直线边缘图
Image = imread('line20x32.bmp');
[weight,high] = size(Image);
I_source = im2double(Image) * 255;

tic
%% 求梯度图像Fx,Fy
%计算图像梯度，此时需要扩充图像
I_expan = zeros(weight+2,high+2);
for m = 2:1:weight+1
    for n = 2:1:high+1
        I_expan(m,n) = Image(m-1,n-1);
    end
end
% 设置Sobel算子x方向模板
Hx = [-1,-2,-1;0,0,0;1,2,1];
% 设置Sobel算子y方向模板
Hy = Hx';
%编程序实现x,y方向梯度计算
Fx1 = zeros(weight+2,high+2);
Fy1 = zeros(weight+2,high+2);
W = zeros(3,3);%移动窗口
for i = 1:weight
    for j = 1:high
        %模板移动窗口
        W = [I_expan(i,j),I_expan(i,j+1),I_expan(i,j+2);I_expan(i+1,j),I_expan(i+1,j+1),I_expan(i+1,j+2);I_expan(i+2,j),I_expan(i+2,j+1),I_expan(i+2,j+2)];
        Sx = Hx .* W;
        Sy = Hy .* W;
        Fx1(i+1,j+1) = sum(sum(Sx));
        Fy1(i+1,j+1) = sum(sum(Sy));
    end
end
% Fx1 = abs(Fx1);
% Fy1 = abs(Fy1);
% 将一圈扩展1个像素的图像复原
Fx = zeros(weight,high);
Fy = zeros(weight,high);
for i = 1:weight
    for j = 1:high
        Fx(i,j) = Fx1(i+1,j+1);
        Fy(i,j) = Fy1(i+1,j+1);
    end
end

%% 计算边缘点的位置
point = [];
ISobel = zeros(weight,high);
I_edge = abs(Fx) + abs(Fy);
for k = 2:(weight-1)
    for j = 2:(high-1)
        if (I_edge(k,j)>=410)
            ISobel(k,j) = 1;
            point = [point;k,j];
        else
            ISobel(k,j) = 0;
        end
    end
end
[number,l] = size(point);
%% 根据Fy,Fx得出边缘点大致方向
point_direc = zeros(number,3);
for a = 1:1:number
    if abs(Fy(point(a,1),point(a,2)))<=abs(Fx(point(a,1),point(a,2)))
        if(Fy(point(a,1),point(a,2))*Fx(point(a,1),point(a,2))>0)
                Direc = 2;      %(0,45)
        else    Direc = 1;      %(135,180)
        end
    elseif abs(Fy(point(a,1),point(a,2))) > abs(Fx(point(a,1),point(a,2)))
        if(Fy(point(a,1),point(a,2))*Fx(point(a,1),point(a,2))>0)
                Direc = 8;      %(45,90)
        else    Direc = 4;      %(90,135)
        end
    end
    point_direc(a,:) = [point(a,1),point(a,2),Direc];
end

s = [512,320];
subplot(121)
imshow(ISobel)
title('matlab仿真边缘结果')
subplot(122)
imshow(ISobel_n)
title('加噪声以后的结果')
matlab_edge_index = find(ISobel'>0);
[edgex,edgey] = ind2sub(s,matlab_edge_index);
matlab_edge(:,1) = edgey;
matlab_edge(:,2) = edgex;


%% 亚像素边缘计算
%忽略图像边缘的像素
matlab_sim = [];
Image = im2double(Image).*255;
for h = 1:number
    state = point_direc(h,3);
    cx = point_direc(h,1); cy = point_direc(h,2);
    if(cx>2 && cy>2 && cx<319 && cy<511)
        switch state
            case 2
                Window = Image(cx-2:cx+2,cy-1:cy+1);
                A = (Window(5,3)+Window(5,2)+Window(4,3))./3;
                B = (Window(1,1) + Window(1,2) + Window(2,1))./3;            
                SL = sum(Window(:,1));
                SM = sum(Window(:,2));
                SR = sum(Window(:,3));
            case 1
                Window = Image(cx-2:cx+2,cy-1:cy+1);
                A = (Window(5,1)+Window(5,2)+Window(4,1))./3;
                B = (Window(1,3) + Window(1,2) + Window(2,3))./3;            
                SL = sum(Window(:,1));
                SM = sum(Window(:,2));
                SR = sum(Window(:,3));
            case 8
                Window = Image(cx-1:cx+1,cy-2:cy+2);
                A = (Window(3,5)+Window(2,5)+Window(3,4))./3;
                B = (Window(1,1) + Window(2,1) + Window(1,2))./3;
                SL = sum(Window(1,:));
                SM = sum(Window(2,:));
                SR = sum(Window(3,:));
            case 4
                Window = Image(cx-1:cx+1,cy-2:cy+2);
                A = (Window(3,1)+Window(3,2)+Window(2,1))./3;
                B = (Window(1,5) + Window(1,4) + Window(2,5))./3;
                SL = sum(Window(1,:));
                SM = sum(Window(2,:));
                SR = sum(Window(3,:));

        end
           %a(h,:) = [cx,cy,(2*SM - 5*(A+B))/2/(A-B),state];
           %b(h,:) = [cx,cy,(SR - SL)/2/(A-B),state];
        matlab_sim = [matlab_sim;cx,cy,(2*SM - 5*(A+B))/2/(A-B),(SR - SL)/2/(A-B),state];
    end
end

toc


