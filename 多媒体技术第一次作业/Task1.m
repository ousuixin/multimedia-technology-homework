figure(1); 
img = imread('lena.jpg');
background = imread('Åµ±´¶û.jpg');
[h,w,c] = size(background);

img_r = zeros(h,w,1);
img_r(:,:,1) = img(:,:,1);
img_r = uint8(img_r);

center = [h/2, w/2];

for i = 1 : 5 : center(1)*(2^0.5)
    for j = center(1) - i : center(1) + i
        for k = center(2) - i : center(2) + i
            if ( (j-center(1))^2 + (k-center(2))^2 < i^2 && (j>0&&j<=h) && (k>0&&k<=w) )
                background(j,k,1) = img_r(j,k,1);
            end
        end
    end
   imshow(background(:,:,1)); 
end