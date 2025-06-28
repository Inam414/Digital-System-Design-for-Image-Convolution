function img2coe( )
img=imread('imag1.jpeg');
img = imresize((img),[120 120]);
imshow(img);
[height, width, channels] = size(img);
 
% Make sure the image is a 3-channel image
if channels ~= 3
    error('Image must be a 3-channel image');
end
 
% Initialize the .coe file
fid = fopen('im2.coe', 'w');
fprintf(fid, 'memory_initialization_radix=2;\nmemory_initialization_vector=\n');
 

for i = 1:height
    for j = 1:width
        
        r = img(i, j, 1);
        g = img(i, j, 2);
        b = img(i, j, 3);
        
        
        r_bin = dec2bin(r>100 , 1);
        g_bin = dec2bin(g>100 , 1);
        b_bin = dec2bin(b>100 , 1);
        
        
        pixel_bin = strcat(r_bin, g_bin, b_bin);
        
         
        if j==width && i==height
            fprintf(fid, '%s;\n', pixel_bin);
        else
             fprintf(fid, '%s,\n', pixel_bin);
        end
    end
end
 
% Close the .coe file
fclose(fid);
end
