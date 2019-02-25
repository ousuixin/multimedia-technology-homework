figure(1);
img = imread('redapple.jpg');
imshow(img);
[r,c,z] = size(img);
pixel_num = r*c;

% 将三维的img变为二维表示，其中行表示像素位置（（row-1）*width+col）,列表示通道（r/g/b）
img_temp = zeros(r*c,4);
for i = 1:r
    for j = 1:c
        img_temp((i-1)*c+j,1:3) = img(i,j,1:3);
        img_temp((i-1)*c+j,4) = (i-1)*c+j;
    end
end

% 遍历八次，每次将分组变多两倍，最后得到256个分组
part = 1;
for i = 1:8
    % 每次循环part会变多一倍，表示下次划分时的组数，初始化为1
    if (i==1||i==4||i==7)
        cmp = 1;
    elseif (i==2||i==5||i==8)
        cmp = 2;
    elseif (i==3||i==6)
        cmp = 3;
    end
    for j = 1:part
        % 在这里面的每次循环需要将每个分组划分成两个分组，如果i==1||i==4||i==7，划分标准是第一列，i==2||i==5||i==8，划分标准是第二列，如果i==3||i==6，划分标准是第三列
        if (i == 1)
            img_temp(floor((j-1)/part*pixel_num+1):floor(j/part*pixel_num),1:4) = sortrows(img_temp(floor((j-1)/part*pixel_num+1):floor(j/part*pixel_num),1:4));
        else
            img_temp(floor((j-1)/part*pixel_num+1):floor(j/part*pixel_num),1:4) = sortrows(img_temp(floor((j-1)/part*pixel_num+1):floor(j/part*pixel_num),1:4), cmp); 
        end
    end
    part = part*2;
    
    % 在第一次循环之后去重
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
        
        % 将img_temp的下表更换为img_ori的下标
        start = 1;
        for j = 1:pixel_num
            img_temp(j,4) = start;
            while (start<=r*c &&img_temp(j,1)==img_ori(start,1)&&img_temp(j,2)==img_ori(start,2)&&img_temp(j,3)==img_ori(start,3))
                start = start+1;
            end
        end
    end
end

% 分组完毕之后，一共256个分组，将每个组的r、g、b平均值作为代表颜色，并使用这三个均值替换原图中这个组的像素的rgb值
img = zeros(r,c,z);% 这里将img置为纯黑图片，足以知道新图片是重新由color_table中的颜色值生成的，因为代码中给img像素颜色赋值的只有color_table这个大小为256*3的矩阵中的行（在75行）
color_table = zeros(256,3);
for i = 1:256
    color_table(i,1:3) = mean(img_temp(floor((i-1)/256*pixel_num+1):floor(i/256*pixel_num),1:3));
end

% 遍历像素点，使用生成的颜色表中的颜色值代替原来的颜色值，从而得到8位彩色图
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