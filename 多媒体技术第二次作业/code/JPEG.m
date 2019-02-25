function JPEG(name)
%% ��ȡͼ�����ͼ��/��Ϊ8�ı���
img = imread(name);
[r0,c0,~] = size(img);
disp("ԭͼ���С����bit����Ϊ��");
disp(r0*c0*3*8);
imgTemp = zeros(floor((r0-1)/8+1)*8,floor((c0-1)/8+1)*8,3);
imgTemp(1:r0,1:c0,1:3) = img(1:r0,1:c0,1:3);
img = imgTemp;
[r,c,color] = size(img);

%% YUV��ɫת��
R = img(:,:,1);
G = img(:,:,2);
B = img(:,:,3);

Y = 0.299*R + 0.587*G + 0.114*B;
U = -0.147*R- 0.289*G + 0.436*B;
V = 0.615*R - 0.515*G - 0.100*B;
% YUV = cat(3, Y, U, V);
% figure; imshow(YUV);

%% ɫ�ȶ��β�����ʹ��4��2��0������
sampleU = zeros(r/2, c/2);
sampleV = zeros(r/2, c/2);
for i = 1:r/2
    for j = 1:c/2
        sampleU(i,j) = U(i*2-1,j*2-1);
        sampleV(i,j) = V(i*2-1,j*2-1);
    end
end

%% ����Ĳ����ֳ����������ֱ���ѹ���ͽ������������Ȼ�󷵻ؽ����ķ���
Y = EncodeAndDecode(Y,1);
sampleU = EncodeAndDecode(sampleU,2);
sampleV = EncodeAndDecode(sampleV,2);

%% �����YUV��ɫתRGB
for i = 1:r
    for j = 1:c
        U(i,j) = sampleU(floor((i-1)/2+1),floor((j-1)/2+1));
        V(i,j) = sampleV(floor((i-1)/2+1),floor((j-1)/2+1));
    end
end
reConStr = zeros(r,c,color);
reConStr(:,:,1) = Y + 1.14 * V;
reConStr(:,:,2) = Y - 0.39 * U - 0.58 * V;
reConStr(:,:,3) = Y + 2.03 * U;
reConStr = uint8(reConStr);
figure; imshow(reConStr(1:r0,1:c0,1:3));
%imwrite(reConStr(1:r0,1:c0,1:3), 'task2_2.jpg');