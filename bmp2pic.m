function []=bmp2pic(f1,f2)
f1 = fopen(f1,'rb');
fseek(f1,10,"bof");
f_offset=struct('I',fread(f1,4)).I(1);
fseek(f1,4,"cof");
%f_width= struct('I',fread(f1,4));
f_width = 512;
%f_height= struct('I',fread(f1,4));
f_height = 512;
fseek(f1,2,"cof");
px_size = struct('I',fread(f1,4)).I(1);
fseek(f1,4,"cof");
f_x_dpi = fread(f1,4);
f_y_dpi = fread(f1,4);
if px_size == 8
    fseek(f1,54,"bof");
    color_table = zeros([256,4],"int8");
    for i =[1,256]
        b= struct('B', fread(f1,1));
        g= struct('B', fread(f1,1));
        r= struct('B', fread(f1,1));
        alpha= struct('B', fread(1));
        color_table(i,1) = r;
        color_table(i,2) = g;
        color_table(i,3) = b;
        color_table(i,4) = alpha;
    end
    fseek(f1,f_offset,"bof");
    img = zeros(f_height,f_width,"int8");
    count = 0;
    for row = [1,f_height]
        for col =[1,f_width]
            count = count + 1;
            index = struct('B',fread(f1,1));
            img(row,col)=index;
            while mod(count,4) ~= 0 
                fread(f1,1);
                count = count + 1;
            end
        end
    end
else
    fseek(f1,f_offset,'bof');
    img=zeros(f_height,f_width,3,'int8');
    count = 0;
    for row =[1,f_height]
        for col=[1,f_width]
            count = count + 3;
            img(row, col, 1) = struct('B',fread(f1,1)).B;
            img(row, col, 2) = struct('B',fread(f1,1)).B;
            img(row, col, 3) = struct('B',fread(f1,1)).B;
            while mod(count,4) ~= 0
                fread(f1,1);
                count = count + 1;
            end
        end
    end
end
f = fopen(f2,'wb');
fwrite(f,b'C');
fwrite(f,struct('c',"b'M'"));
fwrite(f,struct('H',0));
fwrite(f,struct('H',f_width));
fwrite(f,struct('H',f_height))
fwrite(f,struct('h',0));
fwrite(f,struct('h',0));
fwrite(f,struct('h',0));
fwrite(f,f_x_dpi);
fwrite(f,f_y_dpi);
fwrite(f,struct('I',px_size));
fseek(f,64,"bof");

if px_size==8
    for i =[1,256]
        fwrite(f,struct('B',color_table(i, 1)));
        fwrite(f,struct('B',color_table(i, 2)));
        fwrite(f,struct('B',color_table(i, 3)));
        fwrite(f,struct('B',color_table(i, 4)));
    end
    for row = [1,f_height]
        for col =[1,f_width]
            f.write(f,struct('B',img(row,col)));
        end
    end
else
    for row =[1,f_height]
        for col =[1,f_width]
            fwrite(f,struct('B',img(row,col,1)));
            fwrite(f,struct('B',img(row,col,2)));
            fwrite(f,struct('B',img(row,col,3)));
        end
    end
end
end