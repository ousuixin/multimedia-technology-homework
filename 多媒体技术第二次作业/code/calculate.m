%% ���÷�ֵ����Ƚ��ж�������PSNR=20 ��log��_10?��(x_peak)/(��_d )��
function calculate(picture1,picture2)
img1 = imread(picture1);
img2 = imread(picture2);
[~,~,c] = size(img2);
if (c == 1)
    %˵����gif
    [img2,map] = imread(picture2);
    img2 = ind2rgb(img2,map);
end
%x_peak����256
x_peak = 256.0;
%�������ݺ������������еķ�����㣺
%�������Ҷ�ͼƬת��
ray1 = rgb2gray(img1);
ray2 = rgb2gray(img2);
[r,c] = size(ray1);
%���������
myVariance = 0;
for i = 1:r
    for j = 1:c
        myVariance = myVariance + double((ray1(i,j)-ray2(i,j))^2);
    end
end
StandardDeviation = myVariance/(r*c);
disp("ʧ���Ϊ��");
disp(20*log(x_peak/StandardDeviation)/log(10));