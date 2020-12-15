%clc;clear all;clc;

% 参数设置
pi=3.141593; N=80; R=20; n=7; 
c1=(n+1)/2;  
c2=(n-1)/2;
A=10;B=250; 
ccx=(N+1)/2;
ccy=(N+1)/2;
% 构造理想圆
[I1,~] = simcircle( N,R,A,B);  %I1为理想阶跃边缘
%高斯去噪求边缘
% noise=0.1;
% J=imnoise(I1./255,'gaussian',0,noise);
% g=fspecial('gaussian',3);       %创建3*3的高斯滤波算子矩阵
% GL=imfilter(J,g,'same');
% GLJ=conv2(J,g) ;
% GL=GLJ(2:N-1,2:N-1);
ISobel=edge(I1./255,'sobel');
 ISobelCoor=[];
for s=1:1:N
    for t=1:1:N
        if ISobel(s,t)==1
            ISobelCoor=[ISobelCoor;s,t];
        end
    end
end

%计算角度：排点的顺序
% coor=coor_per360(:,1:2);
coor=ISobelCoor;
[h,l]=size(coor);
Coor=[];
for i=1:1:h
    if coor(i,2)-ccy>=0
       angle(i)=atan((ccx-coor(i,1))/(coor(i,2)-ccy))*180/pi;
    elseif coor(i,2)-ccy<0
       angle(i)=atan((ccx-coor(i,1))/(coor(i,2)-ccy))*180/pi+180;
    end
    Coor=[Coor;coor(i,1),coor(i,2),angle(i)];
end
Coor=sortrows(Coor,3);

% 迭代去噪
%denoise1= IterateDenoise( GL, 1000, Coor,c1 );
I=I1;
%I=GL;
% I=denoise1;

% figure(1);
% subplot(321),imshow(I1./255),title('阶跃圆图');
% subplot(322),imshow(J),title('噪声图');
% subplot(323),imshow(GL),title('高斯滤波图');
%subplot(324),imshow(denoise1),title('迭代去噪效果');

%具体算法 
abc=[];rerr=[];
for ii=1:1:h
% ii=56;
    if Coor(ii,3)>45 && Coor(ii,3)<90
        M1=I(Coor(ii,1)-c1:Coor(ii,1)+c1,Coor(ii,2)-c1:Coor(ii,2)+c1);
        M1=M1(:,c1:c1+2);
        AA=(M1(n+2,1)+M1(n+2,2)+M1(n+1,1))/3; BB=(M1(1,3)+M1(1,2)+M1(2,3))/3;
        m=1; SL=sum(M1(1:n,1));SM=sum(M1(2:n+1,2)); SR=sum(M1(3:n+2,3));
        
    elseif Coor(ii,3)>90 && Coor(ii,3)<135
        M1=I(Coor(ii,1)-c1:Coor(ii,1)+c1,Coor(ii,2)-c1:Coor(ii,2)+c1);
        M1=M1(:,c1:c1+2);
        AA=(M1(n+2,3)+M1(n+2,2)+M1(n+1,3))/3; BB=(M1(1,2)+M1(1,2)+M1(2,1))/3;
        m=-1; SL=sum(M1(3:n+2,1));SM=sum(M1(2:n+1,2)); SR=sum(M1(1:n,3));
    elseif Coor(ii,3)>-90 && Coor(ii,3)<-45  
        M1=I(Coor(ii,1)-c1:Coor(ii,1)+c1,Coor(ii,2)-c1:Coor(ii,2)+c1);
        M1=M1(:,c1:c1+2);
       AA=(M1(n+2,3)+M1(n+2,2)+M1(n+1,3))/3; BB=(M1(1,2)+M1(1,2)+M1(2,1))/3;
        m=-1; SL=sum(M1(3:n+2,1));SM=sum(M1(2:n+1,2)); SR=sum(M1(1:n,3));
     elseif Coor(ii,3)>225 && Coor(ii,3)<270    
         M1=I(Coor(ii,1)-c1:Coor(ii,1)+c1,Coor(ii,2)-c1:Coor(ii,2)+c1);
        M1=M1(:,c1:c1+2);
        AA=(M1(n+2,1)+M1(n+2,2)+M1(n+1,1))/3; BB=(M1(1,3)+M1(1,2)+M1(2,3))/3;
        m=1; SL=sum(M1(1:n,1));SM=sum(M1(2:n+1,2)); SR=sum(M1(3:n+2,3));
        
      elseif Coor(ii,3)>-45 && Coor(ii,3)<0   
         M1=I(Coor(ii,1)-c1:Coor(ii,1)+c1,Coor(ii,2)-c1:Coor(ii,2)+c1);
         M1=rot90(M1);  M1=M1(:,c1:c1+2);
        AA=(M1(n+2,1)+M1(n+2,2)+M1(n+1,1))/3; BB=(M1(1,3)+M1(1,2)+M1(2,3))/3;
        m=1; SL=sum(M1(1:n,1));SM=sum(M1(2:n+1,2)); SR=sum(M1(3:n+2,3));
        
       elseif Coor(ii,3)>0 && Coor(ii,3)<45   
         M1=I(Coor(ii,1)-c1:Coor(ii,1)+c1,Coor(ii,2)-c1:Coor(ii,2)+c1);
         M1=rot90(M1);  M1=M1(:,c1:c1+2);
         AA=(M1(n+2,3)+M1(n+2,2)+M1(n+1,3))/3; BB=(M1(1,2)+M1(1,2)+M1(2,1))/3;
        m=-1; SL=sum(M1(3:n+2,1));SM=sum(M1(2:n+1,2)); SR=sum(M1(1:n,3));    
        
     elseif Coor(ii,3)>135 && Coor(ii,3)<180
         M1=I(Coor(ii,1)-c1:Coor(ii,1)+c1,Coor(ii,2)-c1:Coor(ii,2)+c1);
         M1=rot90(M1);  M1=M1(:,c1:c1+2);
         AA=(M1(n+2,1)+M1(n+2,2)+M1(n+1,1))/3; BB=(M1(1,3)+M1(1,2)+M1(2,3))/3;
        m=1; SL=sum(M1(1:n,1));SM=sum(M1(2:n+1,2)); SR=sum(M1(3:n+2,3));
     elseif Coor(ii,3)>180 && Coor(ii,3)<225
         M1=I(Coor(ii,1)-c1:Coor(ii,1)+c1,Coor(ii,2)-c1:Coor(ii,2)+c1);
         M1=rot90(M1);  M1=M1(:,c1:c1+2);
         AA=(M1(n+2,3)+M1(n+2,2)+M1(n+1,3))/3; BB=(M1(1,2)+M1(1,2)+M1(2,1))/3;
        m=-1; SL=sum(M1(3:n+2,1));SM=sum(M1(2:n+1,2)); SR=sum(M1(1:n,3));
    end
    
           c=(SL+SR-2*SM)/2/(AA-BB);
           b = (SR-SL)/2/(AA-BB);
           %b=(SR-SL)/2/(AA-BB)+m;
           a=(2*SM-n*(AA+BB))/(AA-BB)/2-c/12;
           %a=(2*SM-n*(AA+BB))/(AA-BB)/2-(1+24*g(1,2)+48*g(1,1))*c/12;
           abc=[abc;a,b,c];
           if Coor(ii,3)>45 && Coor(ii,3)<135
               r1=sqrt((Coor(ii,1)-a-ccx)^2+(Coor(ii,2)-ccy)^2);
               r2=r1-R;
               sub_x=Coor(ii,1)-a;
               xq=sqrt(R*R-(Coor(ii,2)-ccy)^2);
               r3=ccx-sub_x-xq;
           elseif Coor(ii,3)>225 && Coor(ii,3)<270
               r1=sqrt((Coor(ii,1)-a-ccx)^2+(Coor(ii,2)-ccy)^2);
               r2=r1-R;
               sub_x=Coor(ii,1)-a;
               xq=sqrt(R*R-(Coor(ii,2)-ccx)^2);
               r3=sub_x-ccx-xq;
           elseif Coor(ii,3)>-90 && Coor(ii,3)<-45
               r1=sqrt((Coor(ii,1)-a-ccx)^2+(Coor(ii,2)-ccy)^2);
               r2=r1-R;
               sub_x=Coor(ii,1)-a;
               xq=sqrt(R*R-(Coor(ii,2)-ccx)^2);
               r3=sub_x-ccx-xq;
           elseif Coor(ii,3)>-45 && Coor(ii,3)<45
               r1=sqrt((Coor(ii,1)-ccx)^2+(Coor(ii,2)+a-ccy)^2);
               r2=r1-R;
               sub_y=Coor(ii,2)+a;
               yq=sqrt(R*R-(Coor(ii,1)-ccy)^2);
               r3=sub_y-ccy-yq;
           elseif Coor(ii,3)>135 && Coor(ii,3)<225
               r1=sqrt((Coor(ii,1)-ccx)^2+(Coor(ii,2)-a-ccy)^2);
               r2=r1-R;
               sub_y=Coor(ii,2)+a;
               yq=sqrt(R*R-(Coor(ii,1)-ccy)^2);
               r3=ccx-sub_y-yq;
           end         
           rerr=[rerr;r2,r3];
end
% Eup=[]; Edown=[]; Eright=[];
%         for z=1:1:h
%             if rerr(z)>=0.1
%                 Eup=[Eup;Coor(z,:),rerr(z)];
%             elseif rerr(z)<=-0.1
%                 Edown=[Edown;Coor(z,:),rerr(z)];
%             else
%                 Eright=[Eright;Coor(z,:),rerr(z)];
%             end
%         end
        
Err=mean(abs(abc(:,1)))
% Err1=mean((abc(:,1)))
Err2=mean(abs(rerr)),Err3=mean((rerr))
RMS= sqrt(sum(rerr.^2)/length(rerr))