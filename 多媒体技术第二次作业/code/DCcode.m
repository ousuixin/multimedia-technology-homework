%% DCcode������DCϵ��ת���м���ʽ��size,amplitude�����У�Ȼ���size������������
function code = DCcode(DCcoe, type)
% ����DCϵ���Ĺ����������
T1 = {'00' '010' '011' '100' '101' '110' '1110' '11110' '111110' '1111110' '11111110' '111111110'}; 
% ɫ��DCϵ���Ĺ����������
T2 = {'00' '01' '10' '110' '1110' '11110' '111110' '1111110' '11111110' '111111110' '1111111110' '11111111110'}; 
DCcoeAmplitude = abs(DCcoe);
DCcoeSize = 0;
while (DCcoeAmplitude/(2^DCcoeSize)>=1)
    DCcoeSize= DCcoeSize+1;
end
if (type == 1)
    S1 = char(T1(DCcoeSize+1));
else 
    S1 = char(T2(DCcoeSize+1));
end

if (DCcoe == 0)
    S2 = '';
elseif (DCcoe > 0)
    S2 = dec2bin(DCcoeAmplitude);
else 
    S2 = dec2bin(DCcoeAmplitude);
    for i = 1:length(S2)
        if (S2(i) == '1')
            S2(i) = '0';
        else 
            S2(i) = '1';
        end
    end
end

code = [S1 S2];
