clear;
s = serialport("COM5", 115200);

A = read(s,2457600,"char");

B = dec2bin(A, 8);

for i = 1: 2 : size(A,2)
    RED((i+1)/2) = bin2dec(B(i, 1:5));
    GREEN((i+1)/2) = bin2dec([B(i, 6:8), B(i+1, 1:3)]);
    BLUE((i+1)/2) = bin2dec(B(i+1, 4:8));
end

k = 1;
num = size(RED, 2)/307200;

for v = 1:480
    for h = 1:640
         rgb_1(v, h, 1) = RED(k)/31;
         rgb_1(v, h, 2) = GREEN(k)/63;
         rgb_1(v, h, 3) = BLUE(k)/31;
        
         if(num > 1)
         rgb_2(v, h, 1) = RED(k + 307200)/31;
         rgb_2(v, h, 2) = GREEN(k + 307200)/63;
         rgb_2(v, h, 3) = BLUE(k + 307200)/31;
         end
         
         if(num > 2)
         rgb_3(v, h, 1) = RED(k + 614400)/31;
         rgb_3(v, h, 2) = GREEN(k + 614400)/63;
         rgb_3(v, h, 3) = BLUE(k + 614400)/31;
         end
         
         if(num > 3)
         rgb_4(v, h, 1) = RED(k + 921600)/31;
         rgb_4(v, h, 2) = GREEN(k + 921600)/63;
         rgb_4(v, h, 3) = BLUE(k + 921600)/31;
         end
        k = k+1;
    end
end
load('name.mat');

if(num == 1)
    imwrite(rgb_1, append(int2str(n), '.png'));
else
    imwrite(rgb_1, append(int2str(n), '_low.png'));
    imwrite(rgb_2, append(int2str(n), '_mid.png'));
    imwrite(rgb_3, append(int2str(n), '_high.png'));
    imwrite(rgb_4, append(int2str(n), '_hdr.png'));
end

if(num ==1)
    imshow(rgb_1)
else
    montage({rgb_1, rgb_2, rgb_3, rgb_4});
end
n = n + 1;
save('name.mat', 'n');
delete(s)