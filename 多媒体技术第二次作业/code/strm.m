function p=strm(str1,str2)
k=min(length(str1),length(str2));
p = 0;
for n=1:k   %比较前k位
    if(str1(n)>str2(n))
        p=1;break;
    elseif(str1(n)==str2(n))
        p=0;
    else
        p=-1;break;
    end
end
if(p==0)
    if(length(str1)>length(str2)) %前k位相等，但str1更长
        p=1;
    elseif(length(str1)==length(str2))
        p=0;
    else
        p=-1;
    end
end