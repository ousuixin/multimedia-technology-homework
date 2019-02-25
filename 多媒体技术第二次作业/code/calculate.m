%% 采用峰值信噪比进行度量，即PSNR=20 〖log〗_10?〖(x_peak)/(σ_d )〗
function calculate(picture1,picture2)
img1 = imread(picture1);
img2 = imread(picture2);
[~,~,c] = size(img2);
if (c == 1)
    %说明是gif
    [img2,map] = imread(picture2);
    img2 = ind2rgb(img2,map);
end
%x_peak采用256
x_peak = 256.0;
%输入数据和重现数据序列的方差计算：
%首先做灰度图片转换
ray1 = rgb2gray(img1);
ray2 = rgb2gray(img2);
[r,c] = size(ray1);
%计算均方差
myVariance = 0;
for i = 1:r
    for j = 1:c
        myVariance = myVariance + double((ray1(i,j)-ray2(i,j))^2);
    end
end
StandardDeviation = myVariance/(r*c);
disp("失真度为：");
disp(20*log(x_peak/StandardDeviation)/log(10));