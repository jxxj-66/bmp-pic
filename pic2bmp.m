function []=pic2bmp(f1,f2)
f1 = fopen(f1,'rb');
fseek(f1,2,'bof');
note_num= struct('H',fread(f1,2)).H(1);
f_col= struct('H',fread(f1,2)).H(1);
f_row= struct('H',fread(f1,2)).H(1);
fseek(f1,14,'bof');
f_x_dpi = fread(f1,4);
f_y_dpi = fread(f1,4);
px_size= struct('I',fread(f1,4)).I(1);
if px_size == 8
    fseek(f1,64+note_num,'bof');
    color_table = zeros(256, 4,"int8");
    for i =[1,256]
        r= struct('B', fread(f1,1));
        g= struct('B', fread(f1,1));
        b= struct('B', fread(f1,1));
        alpha= struct.unpack('B', fread(f1,1));
        color_table(i,1) = r;
        color_table(i,2) = g;
        color_table(i,3) = b;
        color_table(i,4) = alpha;
    end
    fseek(f1,64+note_num+1024,'bof');
    img = zeros(f_row, f_col,"int8");
    for row =[1,f_row]
        for col =[1,f_col]
            index = struct('B',fread(f1,1));
            img(row, col) = index;
        end
    end
else
    fseek(f1,64+note_num,'bof');
    img = zeros(f_row, f_col, 3, "int8");
    for row =[1,f_row]
        for col =[1,f_col]
            img(row, col, 1) = struct('B', fread(f1,1)).B;
            img(row, col, 2) = struct('B', fread(f1,1)).B;
            img(row, col, 3) = struct('B', fread(f1,1)).B;
        end
    end
    f2 = fopen(f2,'wb');
    fwrite(f2,"b'B'");
    fwrite(f2,"b'M'");
    if px_size==8
        if mod(f_col,4)==0
            fSize=54+1024+f_row*f_col;
        else
            fSize=54+1024+f_row*(int(f_col/4)+1)*4;
        end
    else
        if mod(f_col,4)==0
            fSize=54+f_row*f_col*3;
        else
            fSize=54+f_row*int16((f_col/4+1))*4*3;
        end
    end
    fwrite(f2,struct('L',fSize));
    fwrite(f2,struct('h', 0));
    fwrite(f2,struct('h', 0));
    if px_size==8
        f_offset=54+1024;
    else
        f_offset=54;
    end
    fwrite(f2,f_offset);
    fwrite(f2,40);
    fwrite(f2,f_col);
    fwrite(f2, f_row);
    fwrite(f2,1);
    fwrite(f2,px_size);
    fwrite(f2, 0);
    fwrite(f2, 0);
    fwrite(f2,f_x_dpi);
    fwrite(f2,f_y_dpi);
    fwrite(f2,0);
    fwrite(f2,0);
    if px_size==8
        for i =[1,256]
            fwrite(f2,color_table(i,3));
            fwrite(f2,color_table(i,2));
            fwrite(f2,color_table(i,1));
            fwrite(f2,color_table(i,4));
        end
        count=0;
        for row =[1,f_row]
            for col =[1,f_col]
                count = count+1;
                fwrite(f1,struct('B',img(row,col)));
                while mod(count,4)~=0
                    fwrite(f2,struct('B',0));
                    count = count +1;
                end
            end
        end
    else
        count = 0;
        for row =[1,f_row]
            for col =[1, f_col]
                count = count + 3;
                fwrite(f2,img(row, col, 1));
                fwrite(f2,img(row, col, 2));
                fwrite(f2,img(row, col, 3));
            end
        end
        while mod(count,4) ~= 0
            fwrite(f2,0);
            count = count+1;
        end
    end
end
end