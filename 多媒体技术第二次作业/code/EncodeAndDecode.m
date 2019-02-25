%% 该函数输入一个编码前的颜色/亮度通道，并进行压缩和解码，然后返回解码后的通道
function imgAfterDecode = EncodeAndDecode(imgBefore, type)
%% 对图像进行分块
[r0,c0] = size(imgBefore);
tempImgBefore = zeros(floor((r0-1)/8+1)*8, floor((c0-1)/8+1)*8);
tempImgBefore(1:r0,1:c0) = imgBefore(1:r0,1:c0);
imgBefore = tempImgBefore;
[r,c] = size(imgBefore);
extendR = r/8;
extendC = c/8;
Blocks = zeros(extendR*extendC*8, 8);
for i = 1:extendR
    for j = 1:extendC
        Blocks((i-1)*extendC*8+(j-1)*8+1:(i-1)*extendC*8+j*8,:) = imgBefore((i-1)*8+1:(i-1)*8+8, (j-1)*8+1:(j-1)*8+8);
    end
end

%% 对图像进行DCT变换
for i = 1:extendR*extendC
    Blocks((i-1)*8+1:(i-1)*8+8,:) = dct2(Blocks((i-1)*8+1:(i-1)*8+8,:));
end

%% 对图像进行量化
% 亮度量化表
table1 = [
    16 11 10 16 24 40 51 61;
    12 12 14 19 26 58 60 55;
    14 13 16 24 40 57 69 55;
    14 17 22 29 51 87 80 62;
    18 22 37 56 68 109 103 77; 
    24 35 55 64 81 104 113 92;                         
    49 64 78 87 103 121 120 101;                     
    72 92 95 98 112 100 103 99
];
% 色度量化表
table2 = [
    17 18 24 47 99 99 99 99; 
    18 21 26 66 99 99 99 99; 
    24 26 56 99 99 99 99 99; 
    47 66 99 99 99 99 99 99; 
    99 99 99 99 99 99 99 99; 
    99 99 99 99 99 99 99 99; 
    99 99 99 99 99 99 99 99; 
    99 99 99 99 99 99 99 99
];
if (type == 1)
    for i = 1:extendR*extendC
        Blocks((i-1)*8+1:(i-1)*8+8,:) = round(Blocks((i-1)*8+1:(i-1)*8+8,:)./table1);
    end
else
    for i = 1:extendR*extendC
        Blocks((i-1)*8+1:(i-1)*8+8,:) = round(Blocks((i-1)*8+1:(i-1)*8+8,:)./table2);
    end
end
%% 熵编码
% 进行z编序
Zcode = zeros(extendR*extendC, 64);
order = [
    1 9 2 3 10 17 25 18 11 4 5  12 19 26 33 41 34 27 20 13 6 7 14 21 28 35 42 49 57 50 43 36 29 22 15 8 16 23 30 37 44 51 58 59 52 45 38 31 24 32 39 46 53 60 61 54 47 40 48 55 62 63 56 64
];
for i = 1:extendR*extendC
    block = reshape(Blocks((i-1)*8+1:(i-1)*8+8,:),1,64);
    for j = 1:64
        Zcode(i,j) = block(order(j));
    end
end
% DC系数编码，先做DPCM编码（这个能够一次得出，AC系数的游长编码需要遍历，得出的结果中每一段长度都不一样，所以统一放到ACcode函数里面做）
DCcoes = zeros(1,extendR*extendC);
DCcoes(1) = Zcode(1,1);
for i = 2:extendR*extendC
    DCcoes(i) = Zcode(i,1) - Zcode(i-1,1);
end

% DCcode函数：DC系数转成中间形式（size,amplitude）序列，然后对size做哈夫曼编码
% ACcode函数：AC系数先做游长编码，再转为symbol1（runlength,size）和symbol2(amplitude)，然后对symbol1做哈夫曼编码
jpegCode = [];
for i = 1:extendR*extendC
    jpegCode = [jpegCode DCcode(DCcoes(i),type) ACcode(Zcode(i,2:64),type)];
end
disp("该通道压缩率后bit数为：");
disp(length(jpegCode));

%% 熵解码
% 亮度DC系数的哈夫曼编码表
T10 = {'00' '010' '011' '100' '101' '110' '1110' '11110' '111110' '1111110' '11111110' '111111110'}; 
% 色度DC系数的哈夫曼编码表
T20 = {'00' '01' '10' '110' '1110' '11110' '111110' '1111110' '11111110' '111111110' '1111111110' '11111111110'}; 
% 亮度AC系数的哈夫曼编码表
T1 = {
    '1010' '00' '01' '100' '1011' '11010' '1111000' '11111000'  '1111110110' '1111111110000010' '1111111110000011';  
    
    '1100' '11011' '1111001' '111110110' '11111110110' '1111111110000100' '1111111110000101' '1111111110000110' '1111111110000111' '1111111110001000' '0';  
    
    '11100' '11111001' '1111110111' '111111110100' '1111111110001001' '1111111110001010' '1111111110001011' '1111111110001100' '1111111110001101' '1111111110001110' '0';  
    
    '111010' '111110111' '111111110101' '1111111110001111' '1111111110010000' '1111111110010001' '1111111110010010' '1111111110010011' '1111111110010100' '1111111110010101' '0';  
    
    '111011' '1111111000' '1111111110010110' '1111111110010111' '1111111110011000' '1111111110011001' '1111111110011010' '1111111110011011' '1111111110011100' '1111111110011101' '0';  
    
    '1111010' '11111110111' '1111111110011110' '1111111110011111' '1111111110100000' '1111111110100001' '1111111110100010' '1111111110100011' '1111111110100100' '1111111110100101' '0';  
    
    '1111011' '111111110110' '1111111110100110' '1111111110100111' '1111111110101000' '1111111110101001' '1111111110101010' '1111111110101011' '1111111110101100' '1111111110101101' '0';  
    
    '11111010' '111111110111' '1111111110101110' '1111111110101111' '1111111110110000' '1111111110110001' '1111111110110010' '1111111110110011' '1111111110110100' '1111111110110101' '0';  
    
    '111111000' '111111111000000' '1111111110110110' '1111111110110111' '1111111110111000' '1111111110111001' '1111111110111010' '1111111110111011' '1111111110111100' '1111111110111101' '0';  
    
    '111111001' '1111111110111110' '1111111110111111' '1111111111000000' '1111111111000001' '1111111111000010' '1111111111000011' '1111111111000100' '1111111111000101' '1111111111000110' '0';  
    
    '111111010' '1111111111000111' '1111111111001000' '1111111111001001' '1111111111001010' '1111111111001011' '1111111111001100' '1111111111001101' '1111111111001110' '1111111111001111' '0';  

    '1111111001' '1111111111010000' '1111111111010001' '1111111111010010' '1111111111010011' '1111111111010100' '1111111111010101' '1111111111010110' '1111111111010111' '1111111111011000' '0';  
    
    '1111111010' '1111111111011001' '1111111111011010' '1111111111011011' '1111111111011100' '1111111111011101' '1111111111011110' '1111111111011111' '1111111111100000' '1111111111100001' '0';     

    '11111111000' '1111111111100010' '1111111111100011' '1111111111100100' '1111111111100101' '1111111111100110' '1111111111100111' '1111111111101000' '1111111111101001' '1111111111101010' '0';  
    
    '1111111111101011' '1111111111101100' '1111111111101101' '1111111111101110' '1111111111101111' '1111111111110000' '1111111111110001' '1111111111110010' '1111111111110011' '1111111111110100' '0';  
    
    '11111111001' '1111111111110101' '1111111111110110' '1111111111110111' '1111111111111000' '1111111111111001' '1111111111111010' '1111111111111011' '1111111111111100' '1111111111111101' '1111111111111111'
};  
T2 = {
    '00' '01' '100' '1010' '11000' '11001' '111000' '1111000' '111110100' '1111110110' '111111110100';  
    
    '1011' '111001' '11110110' '111110101' '11111110110' '111111110101' '1111111110001000' '1111111110001001' '1111111110001010' '1111111110001011' '0';  
    
    '11010' '11110111' '1111110111' '111111110110' '111111111000010' '1111111110001100' '1111111110001101' '1111111110001110' '1111111110001111' '1111111110010000' '0';  
    
    '11011' '11111000' '1111111000' '111111110111' '1111111110010001' '1111111110010010' '1111111110010011' '1111111110010100' '1111111110010101' '1111111110010110' '0';  
    
    '111010' '111110110' '1111111110010111' '1111111110011000' '1111111110011001' '1111111110011010' '1111111110011011' '1111111110011100' '1111111110011101' '1111111110011110' '0';  
    
    '111011' '1111111001' '1111111110011111' '1111111110100000' '1111111110100001' '1111111110100010' '1111111110100011' '1111111110100100' '1111111110100101' '1111111110100010' '0';  
    
    '1111001' '11111110111' '1111111110100111' '1111111110101000' '1111111110101001' '1111111110101010' '1111111110101011' '1111111110101100' '1111111110101101' '1111111110101110' '0';  
    
    '1111010' '11111111000' '1111111110101111' '1111111110110000' '1111111110110001' '1111111110110010' '1111111110110011' '1111111110110100' '1111111110110101' '1111111110110110' '0';  
    
    '11111001' '1111111110110111' '1111111110111000' '1111111110111001' '1111111110111010' '1111111110111011' '1111111110111100' '1111111110111101' '1111111110111110' '1111111110111111' '0';  
    
    '111110111' '1111111111000000' '1111111111000001' '1111111111000010' '1111111111000011' '1111111111000100' '1111111111000101' '1111111111000110' '1111111111000111' '1111111111001000' '0';  
    
    '111111000' '1111111111001001' '1111111111001010' '1111111111001011' '1111111111001100' '1111111111001101' '1111111111001110' '1111111111001111' '1111111111010000' '1111111111010001' '0';  
    
    '111111001' '1111111111010010' '1111111111010011' '1111111111010100' '1111111111010101' '1111111111010110' '1111111111010111' '1111111111011000' '1111111111011001' '1111111111011010' '0';  
    
    '111111010' '1111111111011011' '1111111111011100' '1111111111011101' '1111111111011110' '1111111111011111' '1111111111100000' '1111111111100001' '1111111111100010' '1111111111100011' '0';  
    
    '11111111001' '1111111111100100' '1111111111100101' '1111111111100110' '1111111111100111' '1111111111101000' '1111111111101001' '1111111111101010' '1111111111101011' '1111111111101100' '0';  
    
    '11111111100000' '1111111111101101' '1111111111101110' '1111111111101111' '1111111111110000' '1111111111110001' '1111111111110010' '1111111111110011' '1111111111110100' '1111111111110101' '0';  
    
    '1111111010' '111111111000011' '1111111111110110' '1111111111110111' '1111111111111000' '1111111111111001' '1111111111111010' '1111111111111011' '1111111111111100' '1111111111111101' '1111111111111111'
};
% 对T1和T2做一些预处理（排序）
T11 = cell(1,16*11); order1 = zeros(1,16*11); T21 = cell(1,16*11); order2 = zeros(1,16*11);
for i = 1:16
    for j = 1:11
        T11((i-1)*11 + j) = T1(i,j);
        order1((i-1)*11 + j) = (i-1)*11 + j;
        T21((i-1)*11 + j) = T2(i,j);
        order2((i-1)*11 + j) = (i-1)*11 + j;
    end
end
for i = 16*11:-1:1
    for j = 1:i-1
        if (strm(char(T11(j)), char(T11(j+1))) == 1)%交换
            tempStr = T11(j);
            T11(j) = T11(j+1);
            T11(j+1) = tempStr;
            tempOrder = order1(j);
            order1(j) = order1(j+1);
            order1(j+1) = tempOrder;
        end
    end
end
for i = 16*11:-1:1
    for j = 1:i-1
        if (strm(char(T21(j)), char(T21(j+1))) == 1)%交换
            tempStr = T21(j);
            T21(j) = T21(j+1);
            T21(j+1) = tempStr;
            tempOrder = order2(j);
            order2(j) = order2(j+1);
            order2(j+1) = tempOrder;
        end
    end
end
ZcodeAfter = zeros(extendR*extendC, 64);
% decode函数：将哈夫曼编码转化为矩阵信息
index = 1;
if (type == 1)
    for i = 1:extendR*extendC
        %首先匹配DC系数
        for j = 1:12
            DCcoeSizeDecode = char(T10(j));
            if (strcmpi(DCcoeSizeDecode,jpegCode(index:index+length(DCcoeSizeDecode)-1)))
                index = index+length(DCcoeSizeDecode);
                if (j==1)
                    if (i == 1)
                        ZcodeAfter(i, 1) = 0;%求出DC系数为0
                    else
                        ZcodeAfter(i, 1) = ZcodeAfter(i-1, 1);
                    end
                else 
                    DCcoeAmpDecode = jpegCode(index:index+j-1-1);
                    index = index+j-1;
                    if (DCcoeAmpDecode(1) == '0') 
                        for k = 1:length(DCcoeAmpDecode)
                            if (DCcoeAmpDecode(k) == '1')
                                DCcoeAmpDecode(k) = '0';
                            else
                                DCcoeAmpDecode(k) = '1';
                            end
                        end
                        DCcoeAmpDecode = -bin2dec(DCcoeAmpDecode);
                    else
                        DCcoeAmpDecode = bin2dec(DCcoeAmpDecode);
                    end
                    if (i == 1)
                        ZcodeAfter(i, 1) = DCcoeAmpDecode;
                    else
                        ZcodeAfter(i, 1) = ZcodeAfter(i-1, 1)+DCcoeAmpDecode;
                    end
                end
                break;
            end
        end
        if (ZcodeAfter(i, 1) ~= Zcode(i,1))
            disp(i);
            disp(1);
            disp(ZcodeAfter(i-1, 1));
            disp(ZcodeAfter(i, 1));
            disp(Zcode(i,1));
            break;
        end
        %然后匹配AC系数
        num = 2;
        while (num <= 64)
            if (length(jpegCode) < index+15)
                ACcodeSymbol1 = jpegCode(index:length(jpegCode));
            else
                ACcodeSymbol1 = jpegCode(index:index+15);
            end
            start = 15;
            stop = 176;
            mid = floor((start+stop)/2);
            while (start <= stop)
                if (length(char(T11(mid))) > length(ACcodeSymbol1))
                    mycmp = char(T11(mid));
                    mycmp = mycmp(1:length(ACcodeSymbol1));
                else 
                    mycmp = char(T11(mid));
                end
                if (strm(ACcodeSymbol1(1:length(mycmp)), mycmp) == 0)
                    break;
                elseif (strm(ACcodeSymbol1(1:length(mycmp)), mycmp) == -1)
                    stop = mid-1;
                    mid = floor((start+stop)/2);
                else 
                    start = mid+1;
                    mid = floor((start+stop)/2);
                end
            end
            index = index+length(mycmp);
            ACcodeSymbol1 = order1(mid);
            runLength = floor((ACcodeSymbol1-1)/11);
            ACcodeSize = ACcodeSymbol1 - runLength*11;
            if (runLength == 0 || runLength == 15) 
                ACcodeSize = ACcodeSize-1;
            end
            if (ACcodeSize ~= 0)%如果是0，那么index不用变，因为不编码
                ACcodeAmpDecode = jpegCode(index:index+ACcodeSize-1);
                index = index+ACcodeSize;
                if (ACcodeAmpDecode(1) == '0')
                    for j = 1:length(ACcodeAmpDecode)
                        if (ACcodeAmpDecode(j) == '1')
                            ACcodeAmpDecode(j) = '0';
                        else 
                            ACcodeAmpDecode(j) = '1';
                        end
                    end
                    ACcodeAmpDecode = -bin2dec(ACcodeAmpDecode);
                else
                    ACcodeAmpDecode = bin2dec(ACcodeAmpDecode);
                end
            else
                ACcodeAmpDecode = 0;
            end
            
            if (runLength == 0 && ACcodeAmpDecode == 0)
                break;
            else
                for j = 1:runLength
                    ZcodeAfter(i, num) = 0;
                    num = num+1;
                end
                ZcodeAfter(i, num) = ACcodeAmpDecode;
                num = num+1;
            end
        end
    end
else
    for i = 1:extendR*extendC
        %首先匹配DC系数
        for j = 1:12
            DCcoeSizeDecode = char(T20(j));
            if (strcmpi(DCcoeSizeDecode,jpegCode(index:index+length(DCcoeSizeDecode)-1)))
                index = index+length(DCcoeSizeDecode);
                if (j==1)
                    if (i == 1)
                        ZcodeAfter(i, 1) = 0;%求出DC系数为0
                    else
                        ZcodeAfter(i, 1) = ZcodeAfter(i-1, 1);
                    end
                else 
                    DCcoeAmpDecode = jpegCode(index:index+j-1-1);
                    index = index+j-1;
                    if (DCcoeAmpDecode(1) == '0') 
                        for k = 1:length(DCcoeAmpDecode)
                            if (DCcoeAmpDecode(k) == '1')
                                DCcoeAmpDecode(k) = '0';
                            else
                                DCcoeAmpDecode(k) = '1';
                            end
                        end
                        DCcoeAmpDecode = -bin2dec(DCcoeAmpDecode);
                    else
                        DCcoeAmpDecode = bin2dec(DCcoeAmpDecode);
                    end
                    if (i == 1)
                        ZcodeAfter(i, 1) = DCcoeAmpDecode;
                    else
                        ZcodeAfter(i, 1) = ZcodeAfter(i-1, 1)+DCcoeAmpDecode;
                    end
                end
                break;
            end
        end
        if (ZcodeAfter(i, 1) ~= Zcode(i,1))
            disp(i);
            disp(1);
            disp(ZcodeAfter(i-1, 1));
            disp(ZcodeAfter(i, 1));
            disp(Zcode(i,1));
            break;
        end
        %然后匹配AC系数
        num = 2;
        while (num <= 64)
            if (length(jpegCode) < index+15)
                ACcodeSymbol1 = jpegCode(index:length(jpegCode));
            else
                ACcodeSymbol1 = jpegCode(index:index+15);
            end
            start = 15;
            stop = 176;
            mid = floor((start+stop)/2);
            while (start <= stop)
                if (length(char(T21(mid))) > length(ACcodeSymbol1))
                    mycmp = char(T21(mid));
                    mycmp = mycmp(1:length(ACcodeSymbol1));
                else 
                    mycmp = char(T21(mid));
                end
                if (strm(ACcodeSymbol1(1:length(mycmp)), mycmp) == 0)
                    break;
                elseif (strm(ACcodeSymbol1(1:length(mycmp)), mycmp) == -1)
                    stop = mid-1;
                    mid = floor((start+stop)/2);
                else 
                    start = mid+1;
                    mid = floor((start+stop)/2);
                end
            end
            index = index+length(mycmp);
            ACcodeSymbol1 = order2(mid);
            runLength = floor((ACcodeSymbol1-1)/11);
            ACcodeSize = ACcodeSymbol1 - runLength*11;
            if (runLength == 0 || runLength == 15) 
                ACcodeSize = ACcodeSize-1;
            end
            if (ACcodeSize ~= 0)%如果是0，那么index不用变，因为不编码
                ACcodeAmpDecode = jpegCode(index:index+ACcodeSize-1);
                index = index+ACcodeSize;
                if (ACcodeAmpDecode(1) == '0')
                    for j = 1:length(ACcodeAmpDecode)
                        if (ACcodeAmpDecode(j) == '1')
                            ACcodeAmpDecode(j) = '0';
                        else 
                            ACcodeAmpDecode(j) = '1';
                        end
                    end
                    ACcodeAmpDecode = -bin2dec(ACcodeAmpDecode);
                else
                    ACcodeAmpDecode = bin2dec(ACcodeAmpDecode);
                end
            else
                ACcodeAmpDecode = 0;
            end
            
            if (runLength == 0 && ACcodeAmpDecode == 0)
                break;
            else
                for j = 1:runLength
                    ZcodeAfter(i, num) = 0;
                    num = num+1;
                end
                ZcodeAfter(i, num) = ACcodeAmpDecode;
                num = num+1;
            end
        end
    end
end
% zig-zag还原
BlocksAfter = zeros(extendR*extendC*8, 8);
for i = 1:extendR*extendC
    blockAfter = zeros(1,64);
    for j = 1:64
        blockAfter(order(j)) = ZcodeAfter(i,j);
    end
    BlocksAfter((i-1)*8+1:(i-1)*8++8,:) = reshape(blockAfter,8,8);
end
Blocks = BlocksAfter;

%% 对图像进行反量化
if (type == 1)
    for i = 1:extendR*extendC
        Blocks((i-1)*8+1:(i-1)*8+8,:) = Blocks((i-1)*8+1:(i-1)*8+8,:).*table1;
    end
else
    for i = 1:extendR*extendC
        Blocks((i-1)*8+1:(i-1)*8+8,:) = Blocks((i-1)*8+1:(i-1)*8+8,:).*table2;
    end
end

%% 对图像进行逆DCT变换
for i = 1:extendR*extendC
    Blocks((i-1)*8+1:(i-1)*8+8,:) = idct2(Blocks((i-1)*8+1:(i-1)*8+8,:));
end

%% 对图像进行块合并
imgAfterDecode = zeros(r,c);
for i = 1:extendR
    for j = 1:extendC
        imgAfterDecode((i-1)*8+1:(i-1)*8+8, (j-1)*8+1:(j-1)*8+8) = Blocks((i-1)*extendC*8+(j-1)*8+1:(i-1)*extendC*8+j*8,:);
    end
end
imgAfterDecode = imgAfterDecode(1:r0,1:c0);
