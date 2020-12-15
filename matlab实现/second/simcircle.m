function [I,coor_per360] = simcircle( N,R,A,B)     %m,n-图片大小，r-半径，圆心在图片中间往下0.5个像素  A-背景灰度，B-目标灰度
% N=100;R=sqrt(60);
%  A=50; B=250;
 ccx=(N+1)/2;ccy=(N+1)/2;
I=zeros(N,N);
coorlabel=[];
for i=1:N
    for j=1:N
        d1=sqrt((i+0.5-ccx)^2+(j-0.5-ccy)^2);
        d2=sqrt((i+0.5-ccx)^2+(j+0.5-ccy)^2);
        d3=sqrt((i-0.5-ccx)^2+(j+0.5-ccy)^2);
        d4=sqrt((i-0.5-ccx)^2+(j-0.5-ccy)^2); 
        if d1>=R && d2>=R && d3>=R && d4>=R 
            I(i,j)=A;
        elseif d1<=R && d2<=R && d3<=R && d4<=R
           I(i,j)=B;
        else
            I(i,j)=(A+B)/2;
            d=[d1-R,d2-R,d3-R,d4-R];
            for ii=1:1:4
                if d(ii)>0
                    d(ii)=1;
                elseif d(ii)==0
                    d(ii)=0;
                else
                    d(ii)=-1;
                end
            end
            coorlabel=[coorlabel;i,j,d];
        end
    end
end

[m,~]=size(coorlabel);
coorlabel_one=[]; %m*6
coorlabel_tsf=[]; %m*2
for i=1:m
    if coorlabel(i,1)<=ccx && coorlabel(i,2)>=ccy
        coorlabel_one=[coorlabel_one;coorlabel(i,:)]; %第一象限的边缘坐标
    else
        coorlabel_tsf=[coorlabel_tsf;coorlabel(i,1:2)]; %第2,3,4象限的边缘坐标
    end
end
coorlabelxy=coorlabel_one;
coorlabelxy(:,1)=coorlabel_one(:,2)-ccy;
coorlabelxy(:,2)=ccx-coorlabel_one(:,1);
[mm,~]=size(coorlabelxy);
AreaPer=[];
for iii=1:1:round((mm+1)/2)
    if coorlabelxy(iii,3)==-1 && coorlabelxy(iii,4)==-1 && coorlabelxy(iii,5)==1 && coorlabelxy(iii,6)==1   %1
        x1=coorlabelxy(iii,1)-0.5;   x2=coorlabelxy(iii,1)+0.5;
        s1=0.5*(x2*sqrt(R*R-x2*x2)-x1*sqrt(R*R-x1*x1))+R*R/2*(asin(x2/R)-asin(x1/R));
        s2=coorlabelxy(iii,2)-0.5;
        s=s1-s2;
    elseif coorlabelxy(iii,3)==-1 && coorlabelxy(iii,4)==0 && coorlabelxy(iii,5)==1 && coorlabelxy(iii,6)==0    %2
        x1=coorlabelxy(iii,1)-0.5;   x2=coorlabelxy(iii,1)+0.5;
        s1=0.5*(x2*sqrt(R*R-x2*x2)-x1*sqrt(R*R-x1*x1))+R*R/2*(asin(x2/R)-asin(x1/R));
        s2=coorlabelxy(iii,2)-0.5;
        s=s1-s2; 
    elseif coorlabelxy(iii,3)==-1 && coorlabelxy(iii,4)==-1 && coorlabelxy(iii,5)==1 && coorlabelxy(iii,6)==0   %3
        x1=coorlabelxy(iii,1)-0.5;   x2=coorlabelxy(iii,1)+0.5;
        s1=0.5*(x2*sqrt(R*R-x2*x2)-x1*sqrt(R*R-x1*x1))+R*R/2*(asin(x2/R)-asin(x1/R));
        s2=coorlabelxy(iii,2)-0.5;
        s=s1-s2;
    elseif coorlabelxy(iii,3)==-1 && coorlabelxy(iii,4)==0 && coorlabelxy(iii,5)==1 && coorlabelxy(iii,6)==1   %4
        x1=coorlabelxy(iii,1)-0.5;   x2=coorlabelxy(iii,1)+0.5;
        s1=0.5*(x2*sqrt(R*R-x2*x2)-x1*sqrt(R*R-x1*x1))+R*R/2*(asin(x2/R)-asin(x1/R));
        s2=coorlabelxy(iii,2)-0.5;
        s=s1-s2;
    elseif coorlabelxy(iii,3)==0 && coorlabelxy(iii,4)==0 && coorlabelxy(iii,5)==1 && coorlabelxy(iii,6)==1    %5
        x1=coorlabelxy(iii,1)-0.5;   x2=coorlabelxy(iii,1)+0.5;
        s1=0.5*(x2*sqrt(R*R-x2*x2)-x1*sqrt(R*R-x1*x1))+R*R/2*(asin(x2/R)-asin(x1/R));
        s2=coorlabelxy(iii,2)-0.5;
        s=s1-s2;
    elseif coorlabelxy(iii,3)==-1 && coorlabelxy(iii,4)==1 && coorlabelxy(iii,5)==1 && coorlabelxy(iii,6)==-1   %6
        x1=sqrt(R*R-(coorlabelxy(iii,2)+0.5)^2);   x2=sqrt(R*R-(coorlabelxy(iii,2)-0.5)^2);
        s1=0.5*(x2*sqrt(R*R-x2*x2)-x1*sqrt(R*R-x1*x1))+R*R/2*(asin(x2/R)-asin(x1/R));
        s2=abs((x1-x2)*(coorlabelxy(iii,2)-0.5));
        s3=x1-(coorlabelxy(iii,1)-0.5);
        s=s1-s2+s3;  
    elseif coorlabelxy(iii,3)==-1 && coorlabelxy(iii,4)==0 && coorlabelxy(iii,5)==1 && coorlabelxy(iii,6)==-1    %7
        x1=sqrt(R*R-(coorlabelxy(iii,2)+0.5)^2);   x2=coorlabelxy(iii,1)+0.5;
        s1=0.5*(x2*sqrt(R*R-x2*x2)-x1*sqrt(R*R-x1*x1))+R*R/2*(asin(x2/R)-asin(x1/R));
        s2=abs((x1-x2)*(coorlabelxy(iii,2)-0.5));
        s3=x1-(coorlabelxy(iii,1)-0.5);
        s=s1-s2+s3;  
    elseif coorlabelxy(iii,3)==-1 && coorlabelxy(iii,4)==-1 && coorlabelxy(iii,5)==1 && coorlabelxy(iii,6)==-1   %8
        x1=sqrt(R*R-(coorlabelxy(iii,2)+0.5)^2);   x2=coorlabelxy(iii,1)+0.5;
        s1=0.5*(x2*sqrt(R*R-x2*x2)-x1*sqrt(R*R-x1*x1))+R*R/2*(asin(x2/R)-asin(x1/R));
        s2=abs((x1-x2)*(coorlabelxy(iii,2)-0.5));
        s3=x1-(coorlabelxy(iii,1)-0.5);
        s=s1-s2+s3;    
    elseif coorlabelxy(iii,3)==-1 && coorlabelxy(iii,4)==1 && coorlabelxy(iii,5)==1 && coorlabelxy(iii,6)==1   %9
        x1=coorlabelxy(iii,1)-0.5;x2=sqrt(R*R-(coorlabelxy(iii,2)-0.5)^2);   
        s1=0.5*(x2*sqrt(R*R-x2*x2)-x1*sqrt(R*R-x1*x1))+R*R/2*(asin(x2/R)-asin(x1/R));
        s2=abs((x1-x2)*(coorlabelxy(iii,2)-0.5));
        s=s1-s2;
    end
    AreaPer=[AreaPer;s];
end
coor_per4590=[coorlabel_one(1:round((mm+1)/2),1:2),AreaPer];
coor_per0045=[];
for i=1:1:round((mm+1)/2)
    for j=round((mm+1)/2):1:mm
        if coor_per4590(i,1)+coorlabel_one(j,1)+coor_per4590(i,2)+coorlabel_one(j,2)==(ccx+ccy)*2
            coor_per0045=[coor_per0045;coorlabel_one(j,1:2),coor_per4590(i,3)];
        end
    end
end
coor_per0090=[coor_per0045;coor_per4590];
[h,l]=size(coor_per0090);
[hh,ll]=size(coorlabel_tsf);
coor_per360=[];
for i=1:1:h
    for j=1:1:hh
        if coorlabel_tsf(j,1)+coor_per0090(i,1)==ccx*2 && coorlabel_tsf(j,2)==coor_per0090(i,2)  % 4象限
            coor_per360=[coor_per360;coorlabel_tsf(j,1),coorlabel_tsf(j,2),coor_per0090(i,3)];
        elseif coorlabel_tsf(j,1)==coor_per0090(i,1) && coorlabel_tsf(j,2)+coor_per0090(i,2)==2*ccy %2象限
            coor_per360=[coor_per360;coorlabel_tsf(j,1),coorlabel_tsf(j,2),coor_per0090(i,3)];
        elseif coorlabel_tsf(j,1)+coor_per0090(i,1)==ccx*2 && coorlabel_tsf(j,2)+coor_per0090(i,2)==2*ccy % 3象限
              coor_per360=[coor_per360;coorlabel_tsf(j,1),coorlabel_tsf(j,2),coor_per0090(i,3)];
        end
    end
end
coor_per360=unique([coor_per360;coor_per0090],'rows');
for i=1:1:m
    I(coor_per360(i,1),coor_per360(i,2))=A*(1-coor_per360(i,3))+B*coor_per360(i,3);
end
II=I./255;
imwrite(II,'simcircle2.bmp','bmp');
end

