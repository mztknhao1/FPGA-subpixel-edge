%����ͼƬ��СΪ200x320��ֱ��б��Ϊ1/4����ԭ�㣬A=200,B=100,���ݼ�����F(i,j)=100(1+Pij)��
%����ʾ��ͼ��������Pij=0.125,0.375,�Լ�������0.625,0.875
%��������ֱ�߱�Ե��
IdealLine = zeros(200,320);
A = 200; B = 100;
centorx = 200/2; centory = 320/2;
for i = 1:1:200
    for j = 1:1:320
        %����任
        x = j - floor(centory + 1);
        y = -i + floor(centorx + 1);
        if abs(y-x/4)<=0.5          %˵��ֱ�߾���������
            if x >= 0
                m = mod(x,4);
                switch m
                    case(0) 
                        IdealLine(i,j) = 112.5;
                    case(1)
                        IdealLine(i,j) = 137.5;
                    case(2)
                        IdealLine(i,j) = 162.5;
                    case(3)
                        IdealLine(i,j) = 187.5;
                end
            elseif x < 0
                x = -x;
                m = mod(x,4);
                switch m
                    case(0) 
                        IdealLine(i,j) = 187.5;
                    case(1)
                        IdealLine(i,j) = 162.5;
                    case(2)
                        IdealLine(i,j) = 137.5;
                    case(3)
                        IdealLine(i,j) = 112.5;  
                end
            end
        elseif (y-x/4) > 0.5
            IdealLine(i,j) = 100;
        elseif (y-x/4)< -0.5
            IdealLine(i,j) = 200;
        end
    end
end

Image = IdealLine./255;
imshow(Image);
imwrite(Image,'line200x320.bmp','bmp');
