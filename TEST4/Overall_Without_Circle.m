clc
clear all
tic

%%
%Read the Sonar Original Image
Original_Image = imread('sonar_original.jpg'); %Your Local Location of Sonar Image

%%
%Gray Image ---- From 3 Channels to 1 Channel
Img_gray = rgb2gray(Original_Image);  
[m, n] = size(Img_gray); 
figure(1)
imshow(Img_gray)
axis normal;
set(gca,'position',[0 0 1 1]);
print('Img_gray', '-dpng',  '-r600')

%%
%Denoise: DCT (Discrete Cosine Transform) 
%medfilt2, Lee, Kuan, Frost, wavelets
Img_Denoise = dct2(Img_gray);  %Discrete Cosine Transform : Noise --> High Frequency --> Low Amplitude
I = zeros(m, n);  
I(1:m/3, 1:n/3) = 1; %Keep Low Frequency Denoise High Frequency
Ydct = Img_Denoise .* I;  %Denoise
Img_Denoise = uint8(idct2(Ydct)); %Inverse Discrete Cosine Transform
figure(2)
imshow(Img_Denoise)
axis normal;
set(gca,'position',[0 0 1 1]);
print('Img_Denoise', '-dpng',  '-r600')

%%
%Edge Detection: Roberts Operator
%Operators: roberts, sobel, log, canny, prewitt
Img_Edge = edge(Img_Denoise, 'roberts');  %G[i,j] = |f[i , j] - f[ i+1, j+1]| + |f[i+1, j] - f[i, j+1]|
figure(3)
imshow(Img_Edge)
axis normal;
set(gca,'position',[0 0 1 1]);
print('Img_Edge', '-dpng',  '-r600')

%%
%Removing Shadow Boundaries
Extend_four = ones(m, n+16);
Extend_four_2 = ones(m, n+16);
for i = 1:m
    for j = 1:7
        Extend_four(i, j) = 150;
        Extend_four_2(i,j) = 150;
    end
end
for i = 1:m
    for j = n+8:n+16
        Extend_four(i, j) = 150;
        Extend_four_2(i, j) = 150;
    end
end
for i = 1:m
    for j = 1:n
        Extend_four(i, j+7) = Img_Denoise(i, j);
        Extend_four_2(i, j+7) = Img_Edge(i, j);
    end
end
jiegou = Extend_four_2;
jie2gou = Extend_four_2;
for i = 1:m
    for j = 8:n+8
        if Extend_four_2(i, j) == 1
         jiegou(i,j)=floor((Extend_four(i,j-7)+Extend_four(i,j-6)+Extend_four(i,j-5)+...
             Extend_four(i,j-4)+Extend_four(i,j-3)+Extend_four(i,j-2)+Extend_four(i,j-1))/9);
         jie2gou(i,j)=floor((Extend_four(i,j+7)+Extend_four(i,j+6)+Extend_four(i,j+5)+...
             Extend_four(i,j+4)+Extend_four(i,j+3)+Extend_four(i,j+2)+Extend_four(i,j+1))/7);
        end
    end
end
jiegou = uint8(jiegou);
jie2gou = uint8(jie2gou);
jiegou1 = jiegou;
for i = 1:m  
    for j = 1:n+8
        if jiegou(i, j) <= 80 && jie2gou(i, j) > 50 && jie2gou(i, j) < 150
            jiegou1(i, j) = 0;
        end
    end
end

Removing_Shadow_Boundaries = jiegou1(: ,8:n+7);
t = graythresh(Removing_Shadow_Boundaries);
Removing_Shadow_Boundaries = im2bw(Removing_Shadow_Boundaries, t);
figure(4)
imshow(Removing_Shadow_Boundaries)
axis normal;
set(gca,'position',[0 0 1 1]);
print('Removing_Shadow_Boundaries', '-dpng',  '-r600')

%%
% Localization Ship
% Find Line Location
[m, n]=size(Removing_Shadow_Boundaries);
A_line = [];

% Statistc the Number of White Pixels for m-line and Save to A[]
for i = 1:m
    for j = 1:n
        num_white = sum(Removing_Shadow_Boundaries(i, :));
        A_line(i) = num_white;  
    end
end

% Calculate the Possibility of the White Pixels Occupancy in Each Line Using A_line = A_line./sum(A_line);
A_line = A_line./sum(A_line);
x_axis_line = 1:1:m;
y_axis_line = A_line;

% medfilt1 the Histogram
B = medfilt1(A_line,10);
B = medfilt1(B,10);
y_axis2_line = B;

Hzy1_line = zeros(1, m+4);
Hzy1_line(3:m+2) = y_axis2_line;
hzyx_line(1:m+4) = 1:1:m+4;

Hzy2_line = Hzy1_line;
Maximum_line = 0;

% Find the Maximum Value tt of Line Histogram
for i = 3:m+2
    Hzy2_line(i) = (Hzy1_line(i-2) + Hzy1_line(i-1) + Hzy1_line(i) + Hzy1_line(i+1) + Hzy1_line(i+2)) / 5;
    if Hzy2_line(i) > Maximum_line
        Maximum_line = Hzy2_line(i);
        Maximum_line_index = i;
    end
end 

tt2_line = 10;
tt3_line = 10;

for i = 3:m+2
    if Hzy2_line(i)<=tt2_line  &&  i<Maximum_line_index
        tt2_line = Hzy2_line(i);  
        Line_Threshold1 = i;
    end
    
    if Hzy2_line(i)<tt3_line  &&  i>Maximum_line_index
        tt3_line = Hzy2_line(i); 
        Line_Threshold2 = i;
    end
end


%  Find Column Location
A_column = [];

% Calculate the Possibility of the White Pixels Occupancy in Each Column Using A_column = A_column./sum(A_column);
for i = 1:n
    for j = 1:m
        num_white = sum(Removing_Shadow_Boundaries(:, i));
    end
        A_column(i) = num_white;  
end
A_column = A_column ./ sum(A_column);

B = medfilt1(A_column,10);
B = medfilt1(B,10);
B = medfilt1(B,10);
B = medfilt1(B,10);
y_axis2_coulmn = B;

Hzy1_column = zeros(1,n+4);
Hzy1_column(3:n+2) = y_axis2_coulmn;
hzyx_column(1:n+4) = 1:1:n+4;

Hzy2_column = Hzy1_column;
Maximum_column = 0;

for i = 3:n+2
    Hzy2_column(i) = (Hzy1_column(i-2)+Hzy1_column(i-1)+Hzy1_column(i)+Hzy1_column(i+1)+Hzy1_column(i+2))/5;
    if Hzy2_column(i) > Maximum_column
        Maximum_column = Hzy2_column(i);
        tt1_column = i;
    end
end 

tt2_column = 10;
tt3_column = 10;
for i=3:n+2
    if Hzy2_column(i) <= tt2_column  && i<tt1_column
        tt2_column = Hzy2_column(i);  
        Column_Line_Threshold1 = i;
    end
    if Hzy2_column(i)<tt3_column  &&  i>tt1_column
        tt3_column = Hzy2_column(i);  
        Column_Line_Threshold2 = i;
    end
end

%Localization Ship
Locate_Ship = Removing_Shadow_Boundaries(Line_Threshold1:Line_Threshold2, Column_Line_Threshold1:Column_Line_Threshold2);
figure(5)
imshow(Locate_Ship)
axis normal;
set(gca,'position',[0 0 1 1]);
print('Locate_Ship', '-dpng',  '-r600')

%%
%Removing the Margin of Ship
[m1, n1] = size(Locate_Ship);
white_pixel = 1;
first_location = [];
last_location = [];
Locate_Ship_new = uint8(Locate_Ship);

%Find the first and Last White Pixel and Save the Index 
for i = 1:m1
    for j = 1:n1
        if Locate_Ship(i, j) == 0
            random_pixel = randi(224)+1;   
            Locate_Ship_new(i, j) = random_pixel;
        end
        pixel_line = uint8(Locate_Ship_new(i, :));
        [white_pixel ,index_first] = unique (pixel_line);  %Find the First White Pixel Using unique()
        [white_pixel, index_last]  = unique (pixel_line, 'legacy'); %Find the Last White Pixel using unique( ***,'legacy' )
        first_location(i) = index_first(1);
        last_location(i)  = index_last(1);
    end
end

first_coordinate = [];
last_coordinate = [];
line = 1:1:m1;
first_coordinate = [line', first_location'];  %Save the First Index
last_coordinate  = [line',  last_location'];  %Save the Last Index
            
%Margin of Ship
Locate_Ship_recreate = Locate_Ship;
for i = 1:m1
    for j = 1:n1
        if Locate_Ship_recreate(i, j) ~= 0
            Locate_Ship_recreate(i, j) = 0;
        end
        Locate_Ship_recreate(first_coordinate(i, 1), first_coordinate(i, 2)) = 1;  %Highlight the First Side (Left) White Margin
        Locate_Ship_recreate(last_coordinate(i, 1),  last_coordinate(i, 2)) = 1;  %Highlight the Last Side (Right) White Margin
    end
end

%Removing Margin of Ship ------> Change the Cycle 8 pixels into Black (0)
Dilate_New_Img = Locate_Ship;
for i = 1:m1-1
    Dilate_New_Img(first_coordinate(i, 1), first_coordinate(i, 2)) = 0;
    Dilate_New_Img(first_coordinate(i, 1)+1, first_coordinate(i, 2)) = 0;
    Dilate_New_Img(first_coordinate(i, 1), first_coordinate(i, 2)+1) = 0;
    Dilate_New_Img(first_coordinate(i, 1)+1, first_coordinate(i, 2)+1) = 0;
    
    Dilate_New_Img(last_coordinate(i, 1),  last_coordinate(i, 2))  = 0;
    Dilate_New_Img(last_coordinate(i, 1)+1,  last_coordinate(i, 2))  = 0;
    Dilate_New_Img(last_coordinate(i, 1),  last_coordinate(i, 2)+1)  = 0;
    Dilate_New_Img(last_coordinate(i, 1)+1,  last_coordinate(i, 2)+1)  = 0;
    
    if i > 1
        Dilate_New_Img(first_coordinate(i, 1)-1, first_coordinate(i, 2)) = 0;
        Dilate_New_Img(last_coordinate(i, 1)-1,  last_coordinate(i, 2))  = 0;
        
        if first_coordinate(i, 2) > 1
            Dilate_New_Img(first_coordinate(i, 1), first_coordinate(i, 2)-1) = 0;
            Dilate_New_Img(first_coordinate(i, 1)-1, first_coordinate(i, 2)-1) = 0;
        end
        
        if last_coordinate(i, 2) > 1
            Dilate_New_Img(last_coordinate(i, 1),  last_coordinate(i, 2)-1)  = 0;
            Dilate_New_Img(last_coordinate(i, 1)-1,  last_coordinate(i, 2)-1)  = 0;
        end
    end
end
figure(6)
imshow(Dilate_New_Img)
axis normal;
set(gca,'position',[0 0 1 1]);
print('Dilate_New_Img', '-dpng',  '-r600')

%%
%Dilate "Removing Boundaries" Image ------>Morphology
tool = strel('disk',4);
Img_Dilate = imdilate(Locate_Ship, tool);
figure(7)
imshow(Img_Dilate)
axis normal;
set(gca,'position',[0 0 1 1]);
print('Img_Dilate', '-dpng',  '-r600')

 %% 
%  %First Critical Condition (Left & Right Edge)
% [m2, n2] = size(Img_Dilate);
% white_pixel = 1;
% black_pixel = 0;
% first_Dalition_location = [];
% last_Dalition_location = [];
% Img_Dilate_Test = uint8(Img_Dilate);
% 
% %Find the first White Pixel of the Dalition Image and Save the Index 
% for i = 1:m2
%     for j = 1:n2
%         if Img_Dilate(i, j) == 0
%             random_pixel = randi(224)+1;   
%             Img_Dilate_Test(i, j) = random_pixel;
%         end
%         pixel_dilation_line = uint8(Img_Dilate_Test(i, :));
%         
%         [white_pixel ,index_dalition_first] = unique (pixel_dilation_line);  %Find the First White Pixel Using unique()
%         [black_pixel ,index_dalition_last] = unique (pixel_dilation_line, 'legacy');  %Find the Last White Pixel Using unique(***, 'legacy')
%         
%         first_Dalition_location(i) = index_dalition_first(1);
%         last_Dalition_location(i) = index_dalition_last(1);
%     end
% end
% 
% first_dalition_coordinate = [];
% last_dalition_coordinate = [];
% line_dalition = 1:1:m2;
% first_dalition_coordinate = [line_dalition', first_Dalition_location'];  %Save the First Index & Coordinate
% last_dalition_coordinate = [line_dalition', last_Dalition_location'];
% 
% for i = 1:m2
%     if first_dalition_coordinate(i, 2) <= first_coordinate(i, 2)
%         Img_Dilate(i, 1:first_coordinate(i, 2)) = 0;
%         Img_Dilate(i, 1:first_coordinate(i, 2)+5) = 0;
%         Img_Dilate(i+1, 1:first_coordinate(i, 2)+5) = 0;
%         if i > 1
%             Img_Dilate(i-1, 1:first_coordinate(i, 2)+5) = 0;
%         end
%     end
%     
%     if last_dalition_coordinate(i, 2) >= last_coordinate(i, 2)
%         Img_Dilate(i, last_coordinate(i, 2):last_dalition_coordinate(i, 2)) = 0;
%     end
% end
% 
% %Second Critical Condition (Left Edge)
% Left_Edge = zeros(m, n);
% for i = 1:m
%     for j = 1:n
%         if Img_Denoise(i, j) > 200
%             Left_Edge(i, j) = 1;
%         end
%     end
% end
% 
% [m, n] = size(Left_Edge);
% white_pixel = 1;
% final_first_white_location = [];
% Left_Edge_New = uint8(Left_Edge);
% 
% %Find the first White Pixel of the Dalition Image and Save the Index 
% for i = 1:m
%     for j = 1:n
%         line = uint8(Left_Edge_New(i, :));
%         [white_pixel ,index_first] = unique (line);  %Find the First White Pixel Using unique()
%         final_first_white_location(i) = index_first(1);
%     end
% end
% 
% first_white_coordinate = [];
% line_dalition = 1:1:m;
% first_white_coordinate = [line_dalition', final_first_white_location'];  %Save the First Index & Coordinate
% 
% for i = 1:m
%     if ismember(white_pixel, Left_Edge_New(i, :)) == 0 
%         i = i + 1;
%         if first_dalition_coordinate(i, 2) <= first_white_coordinate(i, 2)
%             Img_Dilate(i, 1:first_white_coordinate(i, 2)) = 0;
%             Img_Dilate(i, 1:first_white_coordinate(i, 2)+5) = 0;
%             Img_Dilate(i+1, 1:first_white_coordinate(i, 2)+5) = 0;
% 
%             if i > 1
%                 Img_Dilate(i-1, 1:first_white_coordinate(i, 2)+5) = 0;
%             end
%         end
%     end
% end
% Img_Dilate_With_restrain = Img_Dilate;
% figure(8)
% imshow(Img_Dilate_With_restrain)
% axis normal;
% set(gca,'position',[0 0 1 1]);
% print('Img_Dilate_With_restrain', '-dpng',  '-r600')

%%
% %Cover  Image
Coving_Image = Img_Dilate;  %Coving Image ------> Smaller Image
Coverd_Image = Img_Denoise;  %Coverd Image ------> Bigger Image
start_line = Line_Threshold1;
end_line = Line_Threshold2;
start_column = Column_Line_Threshold1;
end_column = Column_Line_Threshold2;

[h1, w1] = size(Img_Dilate);

for line_Expanded_Image = 1:h1
    for column_Expanded_Image = 1:w1
        for line_Image_Expanding = (start_line+line_Expanded_Image): end_line
            for column_Image_Expanding = (start_column+column_Expanded_Image): end_column     
                if Coving_Image(line_Expanded_Image, column_Expanded_Image) == 1
                    Coverd_Image(start_line+line_Expanded_Image, start_column+column_Expanded_Image) = 255;
                end
            end
        end
    end
end

Img_Dilate_Final = Coverd_Image;
figure(9)
imshow(Img_Dilate_Final)
axis normal;
set(gca,'position',[0 0 1 1]);
print('Img_Dilate_Final', '-dpng',  '-r600')

%%
% Read the Img_Dilate_Final Image
IM=Img_Dilate_Final;
[maxX,maxY]=size(IM);
IM=double(IM);

IMM=cat(3,IM,IM,IM);

cc1=0;
cc2=80;
cc3=200;

ttFcm=0;
while(ttFcm<1500000000000)
    
    ttFcm=ttFcm+1;
    
    c1=repmat(cc1,maxX,maxY);
    c2=repmat(cc2,maxX,maxY);
    c3=repmat(cc3,maxX,maxY);
    c=cat(3,c1,c2,c3);
    
    ree=repmat(0.000001,maxX,maxY);
    ree1=cat(3,ree,ree,ree);
    distance=IMM-c;
    distance=distance.*distance+ree1;
    daoShu=1./distance;
    daoShu2=daoShu(:,:,1)+daoShu(:,:,2)+daoShu(:,:,3);
    
    distance1=distance(:,:,1).*daoShu2;
    u1=1./distance1;
    distance2=distance(:,:,2).*daoShu2;
    u2=1./distance2;
    distance3=distance(:,:,3).*daoShu2;
    u3=1./distance3;
    
    ccc1=sum(sum(u1.*u1.*IM))/sum(sum(u1.*u1));
    ccc2=sum(sum(u2.*u2.*IM))/sum(sum(u2.*u2));
    ccc3=sum(sum(u3.*u3.*IM))/sum(sum(u3.*u3));
    tmpMatrix=[abs(cc1-ccc1)/cc1,abs(cc2-ccc2)/cc2,abs(cc3-ccc3)/cc3];
    pp=cat(3,u1,u2,u3);
    
    for i=1:maxX
        for j=1:maxY
            if max(pp(i,j,:))==u1(i,j)
                IX2(i,j)=1;
            elseif max(pp(i,j,:))==u2(i,j)
                IX2(i,j)=2;
            else
                IX2(i,j)=3;
            end
        end
    end
    
    if min(tmpMatrix)<0.000000001
        break;
    else
        cc1=ccc1;
        cc2=ccc2;
        cc3=ccc3;
    end
    
    for i=1:maxX
        for j=1:maxY
            if IX2(i,j)==3
                IMMM(i,j)=255;
            elseif IX2(i,j)==2
                IMMM(i,j)=100;
            else
                IMMM(i,j)=0;
            end
        end
    end
 
figure(10);
imshow(uint8(IMMM)); 
end

IMMM=uint8(IMMM);
Img_Segmentation  = IMMM;
figure(11)
imshow(Img_Segmentation)
axis normal;
set(gca,'position',[0 0 1 1]);
print('Img_Segmentation', '-dpng',  '-r600')

toc

% %%
% %Evaluation Result
% yt1=Original_Image;  %Read Original Image
% yt1=rgb2gray(yt1);   %Gray Original Image
% 
% yt2=imread('PS.jpg');   %Read Photoshop Image
% yt2=rgb2gray(yt2);   %Gray Photoshop Image
% 
% yt3=Img_Segmentation; 
% 
% [m,n]=size(yt1);     
% I1=zeros(m,n);     
% black=0;  
% gary=0;
% light=0;
% black1=0;    
% gary1=0;
% light1=0;
% black11=0;    
% gary11=0;
% light11=0;
% ss=73;
% tt=127;
% I11=uint8(I1);
% 
% for i=1:m
%     for j=1:n
%        if yt2(i,j)==0 && yt3(i,j)==0 
%            black1=black1+1;    
%        elseif yt2(i,j)==255  && yt3(i,j)==255 
%            light1=light1+1;  
%        elseif yt2(i,j)==100  && yt3(i,j)==100   
%            gary1=gary1+1; 
%        end
%        
%        if yt2(i,j)==0 
%            black=black+1;   
%        elseif yt2(i,j)==255 
%            light=light+1;  
%        elseif yt2(i,j)==100  
%            gary=gary+1; 
%        end
%        
%         if yt3(i,j)==0 
%             black11=black11+1;   
%         elseif yt3(i,j)==255 
%             light11=light11+1;  
%         elseif yt3(i,j)==100  
%             gary11=gary11+1; 
%         end
%         
%     end
% end
% 
% ytdfg = black1+light1+gary1;
% wmtx = black+light+gary;
% 
% hzyb = (black1/black11)*(black1/black);
% hzyg = (gary1/gary11)*(gary1/gary);
% hzyl = (light1/light11)*(light1/light);
% 
% Accuracy = (hzyb+hzyg+hzyl)/3;
% wc = (abs(black1-black)+abs(light1-light)+abs(gary1-gary))/(m*n);
% 
% %Final Evaluation
% fprintf('Total Accuracy of Sonar Image is %f%%.\n', Accuracy*100);
% fprintf('Accuracy of Object-Highlight is %f%%.\n', hzyl*100);
% fprintf('Accuracy of Object-Shadow is %f%%.\n', hzyb*100);
% fprintf('Accuracy of Sea-Bottom-Reverberation %f%%.\n', hzyg*100);



%%
% Draw Result
figure(11)
subplot(3, 3, 1), imshow(Original_Image), title('Original Image')
subplot(3, 3, 2), imshow(Img_gray), title('Gray Image')
subplot(3, 3, 3), imshow(Img_Denoise), title('Denoise Image (Discrete Cosine Transform)')
subplot(3, 3, 4), imshow(Img_Edge), title('Edge Image (Roberts)')
subplot(3, 3, 5), imshow(Removing_Shadow_Boundaries), title('Remove Shadow Boundaries')
subplot(3, 3, 6), imshow(Locate_Ship), title('Ship Localization (Threshold)')
subplot(3, 3, 7), imshow(Img_Dilate), title('Dilate White Pixel (Morphology Dilation)')
subplot(3, 3, 8), imshow(Img_Dilate_Final), title('Merge Denoise & Dilation Images')
subplot(3, 3, 9), imshow(Img_Segmentation), title('Fuzzy Clustering Segamentation')









