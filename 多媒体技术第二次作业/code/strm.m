function p=strm(str1,str2)
k=min(length(str1),length(str2));
p = 0;
for n=1:k   %�Ƚ�ǰkλ
    if(str1(n)>str2(n))
        p=1;break;
    elseif(str1(n)==str2(n))
        p=0;
    else
        p=-1;break;
    end
end
if(p==0)
    if(length(str1)>length(str2)) %ǰkλ��ȣ���str1����
        p=1;
    elseif(length(str1)==length(str2))
        p=0;
    else
        p=-1;
    end
end