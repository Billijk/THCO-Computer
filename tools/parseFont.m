clear;
x = imread('font.png');

HEIGHT = int16(36);
WIDTH = int16(16);

cnt = 32;
for i = 1:5
    for j = 1:40
        if cnt >= 127
            break;
        end
        if mod(j, 2) == 1
            top = (i - 1) * HEIGHT + 7;
            bottom = i * HEIGHT + 6;
            left = (j - 1) * WIDTH + 1;
            right = j * WIDTH;
            charc = x(top: bottom, left: right);
            charc = charc(:);
            fileId = fopen(strcat('chars/', num2str(cnt)), 'w');
            for k = 1: length(charc)
                s = charc(k) / 255;
                fprintf(fileId, '%d', s);
            end
            fclose(fileId);
            cnt = cnt + 1;
        end
    end
end