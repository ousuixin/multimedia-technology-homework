figure(1);
img = imread('redapple.jpg');
imshow(img);
[r,c,z] = size(img);
pixel_num = r*c;

% ����ά��img��Ϊ��ά��ʾ�������б�ʾ����λ�ã���row-1��*width+col��,�б�ʾͨ����r/g/b��
img_temp = zeros(r*c,4);
for i = 1:r
    for j = 1:c
        img_temp((i-1)*c+j,1:3) = img(i,j,1:3);
        img_temp((i-1)*c+j,4) = (i-1)*c+j;
    end
end

% �����˴Σ�ÿ�ν����������������õ�256������
part = 1;
for i = 1:8
    % ÿ��ѭ��part����һ������ʾ�´λ���ʱ����������ʼ��Ϊ1
    if (i==1||i==4||i==7)
        cmp = 1;
    elseif (i==2||i==5||i==8)
        cmp = 2;
    elseif (i==3||i==6)
        cmp = 3;
    end
    for j = 1:part
        % ���������ÿ��ѭ����Ҫ��ÿ�����黮�ֳ��������飬���i==1||i==4||i==7�����ֱ�׼�ǵ�һ�У�i==2||i==5||i==8�����ֱ�׼�ǵڶ��У����i==3||i==6�����ֱ�׼�ǵ�����
        if (i == 1)
            img_temp(floor((j-1)/part*pixel_num+1):floor(j/part*pixel_num),1:4) = sortrows(img_temp(floor((j-1)/part*pixel_num+1):floor(j/part*pixel_num),1:4));
        else
            img_temp(floor((j-1)/part*pixel_num+1):floor(j/part*pixel_num),1:4) = sortrows(img_temp(floor((j-1)/part*pixel_num+1):floor(j/part*pixel_num),1:4), cmp); 
        end
    end
    part = part*2;
    
    % �ڵ�һ��ѭ��֮��ȥ��
    if (i==1)
        k = 1;
        img_unique = zeros(pixel_num, 4);
        img_unique(1,1:4) = img_temp(1,1:4);
        k = k+1;
        for j = 2:pixel_num
            if (img_temp(j-1,1) ~= img_temp(j,1) || img_temp(j-1,2) ~= img_temp(j,2) || img_temp(j-1,3) ~= img_temp(j,3)) 
                img_unique(k,1:4) = img_temp(j,1:4);
                k = k+1;
            end
        end
        img_ori = img_temp;
        img_temp = img_unique(1:k-1,1:4);
        [pixel_num,~] = size(img_temp);
        
        % ��img_temp���±����Ϊimg_ori���±�
        start = 1;
        for j = 1:pixel_num
            img_temp(j,4) = start;
            while (start<=r*c &&img_temp(j,1)==img_ori(start,1)&&img_temp(j,2)==img_ori(start,2)&&img_temp(j,3)==img_ori(start,3))
                start = start+1;
            end
        end
    end
end

% �������֮��һ��256�����飬��ÿ�����r��g��bƽ��ֵ��Ϊ������ɫ����ʹ����������ֵ�滻ԭͼ�����������ص�rgbֵ
img = zeros(r,c,z);% ���ｫimg��Ϊ����ͼƬ������֪����ͼƬ��������color_table�е���ɫֵ���ɵģ���Ϊ�����и�img������ɫ��ֵ��ֻ��color_table�����СΪ256*3�ľ����е��У���75�У�
color_table = zeros(256,3);
for i = 1:256
    color_table(i,1:3) = mean(img_temp(floor((i-1)/256*pixel_num+1):floor(i/256*pixel_num),1:3));
end

% �������ص㣬ʹ�����ɵ���ɫ���е���ɫֵ����ԭ������ɫֵ���Ӷ��õ�8λ��ɫͼ
for i = 1:pixel_num
    index_ori = img_temp(i,4);
    cur_color = img_ori(index_ori, 1:3);
    while (index_ori<=r*c&&cur_color(1) == img_ori(index_ori, 1)&&cur_color(2) == img_ori(index_ori, 2)&&cur_color(3) == img_ori(index_ori, 3))
        index = img_ori(index_ori, 4);
        img(floor((index-1)/c+1),mod(index-1,c)+1,1:3) = color_table(floor((i-1)/(pixel_num/256)+1),1:3);
        index_ori = index_ori+1;
    end
end
img = uint8(img);
figure(2);
imshow(img);
%imwrite(img, 'task2.jpg');