function [ matlab_sim_ideal,ISobel ] = idealLine( I_dir,threshold )
%���ھֲ��������ر�Ե��ȡ
%��ȫ������������Ծ��Ե
%�������¸�˹�˲�

%% ��������ֱ�߱�Եͼ
Image = imread(I_dir);
[weight,high] = size(Image);

%% ���ݶ�ͼ��Fx,Fy
%����ͼ���ݶȣ���ʱ��Ҫ����ͼ��
I_expan = zeros(weight+2,high+2);
for m = 2:1:weight+1
    for n = 2:1:high+1
        I_expan(m,n) = Image(m-1,n-1);
    end
end
% ����Sobel����x����ģ��
Hx = [-1,-2,-1;0,0,0;1,2,1];
% ����Sobel����y����ģ��
Hy = Hx';
%�����ʵ��x,y�����ݶȼ���
Fx1 = zeros(weight+2,high+2);
Fy1 = zeros(weight+2,high+2);
% W = zeros(3,3);%�ƶ�����
for i = 1:weight
    for j = 1:high
        %ģ���ƶ�����
        W = [I_expan(i,j),I_expan(i,j+1),I_expan(i,j+2);I_expan(i+1,j),I_expan(i+1,j+1),I_expan(i+1,j+2);I_expan(i+2,j),I_expan(i+2,j+1),I_expan(i+2,j+2)];
        Sx = Hx .* W;
        Sy = Hy .* W;
        Fx1(i+1,j+1) = sum(sum(Sx));
        Fy1(i+1,j+1) = sum(sum(Sy));
    end
end
% Fx1 = abs(Fx1);
% Fy1 = abs(Fy1);
% ��һȦ��չ1�����ص�ͼ��ԭ
Fx = zeros(weight,high);
Fy = zeros(weight,high);
for i = 1:weight
    for j = 1:high
        Fx(i,j) = Fx1(i+1,j+1);
        Fy(i,j) = Fy1(i+1,j+1);
    end
end

%% �����Ե���λ��
point = [];
ISobel = zeros(weight,high);
I_edge = abs(Fx) + abs(Fy);
for k = 2:(weight-1)
    for j = 2:(high-1)
        if (I_edge(k,j)>=threshold)
            ISobel(k,j) = 1;
            point = [point;k,j];
        else
            ISobel(k,j) = 0;
        end
    end
end
[number,~] = size(point);
%% ����Fy,Fx�ó���Ե����·���
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

%% �����ر�Ե����
%����ͼ���Ե������
matlab_sim_ideal = [];
Image = im2double(Image).*255;
for h = 1:number
    state = point_direc(h,3);
    cx = point_direc(h,1); cy = point_direc(h,2);
    if(cx>4 && cy>4 && cx<(weight-4) && cy<(high-4))
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
        if(A~=B)
            atemp = (2*SM - 5*(A+B))/2/(A-B);
            btemp = (SR - SL)/2/(A-B);
        else
            atemp = 0;
            btemp = 0;
        end
        matlab_sim_ideal = [matlab_sim_ideal;cx,cy,atemp,btemp,state];
    end
end
end

