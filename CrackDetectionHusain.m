%% Initial Data
%Jumlah Image
N = 8; 
K = 1;
%% Read All Image
img = {};
img2 = {};
for i=1:N
  img{i}=sprintf('Crack/%d%s',i,'.jpg');
  img2{i}=sprintf('Non-Crack/%d%s',i,'.jpg');
  img{i}=imread(img{i});
  img2{i}=imread(img2{i});
end

% figure, imshow(img{1}); 
% title('Original');
%% Convert into Gray Level
grayImg = {};
grayImg2 = {};
for i=1:N
    grayImg{i} = rgb2gray(img{i});
    grayImg2{i} = rgb2gray(img2{i});
end
% figure, imshow(grayImg{1}); 
% title('Gray Level');
%% Median filter w/ MASK[5,5]
medImg = {};
medImg2 = {};
for i=1:N
    medImg{i} = medfilt2(grayImg{i},[5,5]);
    medImg2{i} = medfilt2(grayImg2{i},[5,5]);
    %looping j times
    for j=1:K
        medImg{i} = medImg{i} + medfilt2(grayImg{i},[5,5]);
        medImg2{i} = medImg2{i} + medfilt2(grayImg2{i},[5,5]);
    end
end
% figure, imshow(medImg{1}); 
% title('Med Level');
%% Create Structuring Element 15 pixels for 0,30,60,90,120,150 degres
SE = {};
for i=0:5
   SE{i+1} = strel('line',15,i*30); 
end
%% Image opening in the six direction for each gray level image && Overlap Image to Single one
imgOpen = {};
imgOverlap = {};
imgOpen2 = {};
imgOverlap2 = {};
for i=1:N
    for j=1:6
        imgOpen{j} = imopen(medImg{i},SE{j});
        imgOpen2{j} = imopen(medImg2{i},SE{j});
        if j==6
            imgOverlap{i} = imgOpen{1};
            imgOverlap2{i} = imgOpen2{1};
            for l=2:6
                imgOverlap{i} = imfuse(imgOverlap{i},imgOpen{l});
                imgOverlap2{i} = imfuse(imgOverlap2{i},imgOpen2{l});
            end
        end
    end
end
% figure, imshow(imgOverlap{1}); 
% title('Overlap Level');
%% Image regions and Convert to binary image with otsu threshold
imgBw = {};
imgBw2 = {};
for i=1:N
   %crack
   level = graythresh(imgOverlap{i});
   imgBw{i} = im2bw(imgOverlap{i},level);
   %inverse
   imgBw{i} = ~imgBw{i};
   %non-crack
   level2 = graythresh(imgOverlap2{i});
   imgBw2{i} = im2bw(imgOverlap2{i},level2);
   %inverse
   imgBw2{i} = ~imgBw2{i};
end
% for i=1:N
% figure, imshow(imgBw{i}); 
% title('Binary');    
% end

%%
%  s = regionprops(imgBw2{6},'centroid');
%  centroids = cat(1, s.Centroid);
%  figure, imshow(imgBw2{6})
%  hold on
%  plot(centroids(:,1),centroids(:,2), 'b*')
%  hold off

%% Prepare properties image region (Eccentricity and Area) for crack
imgProp = {};
areaProp = {};
eccentricityProp = {};
majorAxisProp = {};
minorAxisProp = {};
for i=1:N
   imgProp{i} = regionprops(imgBw{i},'Area','Eccentricity','MajorAxisLength','MinorAxisLength'); 
   areaProp{i} = vertcat(imgProp{i}.Area);
   eccentricityProp{i} = vertcat(imgProp{i}.Eccentricity);
   majorAxisProp{i} = vertcat(imgProp{i}.MajorAxisLength);
   minorAxisProp{i} = vertcat(imgProp{i}.MinorAxisLength);
end

%% Prepare properties image region (Eccentricity and Area) for non-crack
imgProp2 = {};
areaProp2 = {};
eccentricityProp2 = {};
majorAxisProp2 = {};
minorAxisProp2 = {};
for i=1:N
   imgProp2{i} = regionprops(imgBw2{i},'Area','Eccentricity','MajorAxisLength','MinorAxisLength'); 
   areaProp2{i} = vertcat(imgProp2{i}.Area);
   eccentricityProp2{i} = vertcat(imgProp2{i}.Eccentricity);
   majorAxisProp2{i} = vertcat(imgProp2{i}.MajorAxisLength);
   minorAxisProp2{i} = vertcat(imgProp2{i}.MinorAxisLength);
end

%% Count Area
%Area>=200
area1 = {};
%Area 200>~>=150
area2 = {};
%Area 150>~>=100
area3 = {};
%Area 100>~>=50
area4 = {};
%Area <50
area5 = {};

for i=1:N
   counter1 = 0;
   counter2 = 0;
   counter3 = 0;
   counter4 = 0;
   counter5 = 0;
   for j=1:size(imgProp{i})
       if imgProp{i}(j).Area < 50
          counter5 = counter5 + 1;
       else if imgProp{i}(j).Area >= 50 && imgProp{i}(j).Area < 100
               counter4 = counter4 + 1;
           else if imgProp{i}(j).Area >= 100 && imgProp{i}(j).Area < 150
                   counter3 = counter3 + 1;
               else if imgProp{i}(j).Area >= 150 && imgProp{i}(j).Area < 200
                       counter2 = counter2 + 1;
                   else counter1 = counter1 + 1;
                   end
               end
           end
       end
   end
   area1{i} = counter1;
   area2{i} = counter2;
   area3{i} = counter3;
   area4{i} = counter4;
   area5{i} = counter5;
end

%% Count Eccentricity
%eccentricity 0.1>=~>=0.95
eccentricity1 = {};
%eccentricity 0.95>~>=0.90
eccentricity2 = {};
%eccentricity 0.90>~>=0.85
eccentricity3 = {};
%eccentricity 0.85>~>=0.80
eccentricity4 = {};
%eccentricity <0.80
eccentricity5 = {};

for i=1:N
   counter1 = 0;
   counter2 = 0;
   counter3 = 0;
   counter4 = 0;
   counter5 = 0;
   for j=1:size(imgProp{i})
       if imgProp{i}(j).Eccentricity < 0.80
          counter5 = counter5 + 1;
       else if imgProp{i}(j).Eccentricity >= 0.80 && imgProp{i}(j).Eccentricity < 0.85
               counter4 = counter4 + 1;
           else if imgProp{i}(j).Eccentricity >= 0.85 && imgProp{i}(j).Eccentricity < 0.90
                   counter3 = counter3 + 1;
               else if imgProp{i}(j).Eccentricity >= 0.90 && imgProp{i}(j).Eccentricity < 0.95
                       counter2 = counter2 + 1;
                   else counter1 = counter1 + 1;
                   end
               end
           end
       end
   end
   eccentricity1{i} = counter1;
   eccentricity2{i} = counter2;
   eccentricity3{i} = counter3;
   eccentricity4{i} = counter4;
   eccentricity5{i} = counter5;
end

%% Accuracy Count Crack
counter1 = {};
counter2 = {};
counter3 = {};
counter4 = {};
counter5 = {};
counter6 = {};
counter7 = {};
counter8 = {};
counter9 = {};
counter10 = {};
counter11 = {};
counter12 = {};
counter13 = {};
counter14 = {};
counter15 = {};
counter16 = {};

for i=1:N
    counter1{i} = 0;    
    counter2{i} = 0;    
    counter3{i} = 0;    
    counter4{i} = 0;    
    counter5{i} = 0;    
    counter6{i} = 0;    
    counter7{i} = 0;    
    counter8{i} = 0;
    counter9{i} = 0;    
    counter10{i} = 0;    
    counter11{i} = 0;    
    counter12{i} = 0;    
    counter13{i} = 0;    
    counter14{i} = 0;    
    counter15{i} = 0;    
    counter16{i} = 0;
end
total = {};
for i=1:16
   total{i} = 0; 
end
for i=1:N
    for j=1:size(imgProp{i})
       if(imgProp{i}(j).Area >= 50 && imgProp{i}(j).Eccentricity >= 0.8)
           counter1{i} = counter1{i} + 1;
           if(imgProp{i}(j).Area >= 50 && imgProp{i}(j).Eccentricity >=0.85)
               counter2{i} = counter2{i} + 1;
               if(imgProp{i}(j).Area >= 50 && imgProp{i}(j).Eccentricity >=0.9)
                   counter3{i} = counter3{i} + 1;
                   if(imgProp{i}(j).Area >= 50 && imgProp{i}(j).Eccentricity >=0.95)
                       counter4{i} = counter4{i} + 1;
                   end
               end
           end
       end
       if(imgProp{i}(j).Area >= 100 && imgProp{i}(j).Eccentricity >= 0.8)
           counter5{i} = counter5{i} + 1;
           if(imgProp{i}(j).Area >= 100 && imgProp{i}(j).Eccentricity >=0.85)
               counter6{i} = counter6{i} + 1;
               if(imgProp{i}(j).Area >= 100 && imgProp{i}(j).Eccentricity >=0.9)
                   counter7{i} = counter7{i} + 1;
                   if(imgProp{i}(j).Area >= 100 && imgProp{i}(j).Eccentricity >=0.95)
                       counter8{i} = counter8{i} + 1;
                   end
               end
           end
       end
       if(imgProp{i}(j).Area >= 150 && imgProp{i}(j).Eccentricity >= 0.8)
           counter9{i} = counter9{i} + 1;
           if(imgProp{i}(j).Area >= 150 && imgProp{i}(j).Eccentricity >=0.85)
               counter10{i} = counter10{i} + 1;
               if(imgProp{i}(j).Area >= 150 && imgProp{i}(j).Eccentricity >=0.9)
                   counter11{i} = counter11{i} + 1;
                   if(imgProp{i}(j).Area >= 150 && imgProp{i}(j).Eccentricity >=0.95)
                       counter12{i} = counter12{i} + 1;
                   end
               end
           end
       end
       if(imgProp{i}(j).Area >= 200 && imgProp{i}(j).Eccentricity >= 0.8)
           counter13{i} = counter13{i} + 1;
           if(imgProp{i}(j).Area >= 200 && imgProp{i}(j).Eccentricity >=0.85)
               counter14{i} = counter14{i} + 1;
               if(imgProp{i}(j).Area >= 200 && imgProp{i}(j).Eccentricity >=0.9)
                   counter15{i} = counter15{i} + 1;
                   if(imgProp{i}(j).Area >= 200 && imgProp{i}(j).Eccentricity >=0.95)
                       counter16{i} = counter16{i} + 1;
                   end
               end
           end
       end
    end
end

for i=1:N
        if counter1{i} ~= 0
            total{1} = total{1} + 1;
        end 
        if counter2{i} ~= 0
            total{2} = total{2} + 1; 
        end
        if counter3{i} ~= 0
            total{3} = total{3} + 1;
        end
        if counter4{i} ~= 0
            total{4} = total{4} + 1;
        end
        if counter5{i} ~= 0
            total{5} = total{5} + 1;
        end
        if counter6{i} ~= 0
            total{6} = total{6} + 1;
        end
        if counter7{i} ~= 0
            total{7} = total{7} + 1;
        end
        if counter8{i} ~= 0
            total{8} = total{8} + 1;
        end
        if counter9{i} ~= 0
            total{9} = total{9} + 1;
        end
        if counter10{i} ~= 0
            total{10} = total{10} + 1;
        end
        if counter11{i} ~= 0
            total{11} = total{11} + 1;
        end
        if counter12{i} ~= 0
            total{12} = total{12} + 1;
        end
        if counter13{i} ~= 0
            total{13} = total{13} + 1;
        end
        if counter14{i} ~= 0
            total{14} = total{14} + 1;
        end
        if counter15{i} ~= 0
            total{15} = total{15} + 1;
        end
        if counter16{i} ~= 0
            total{16} = total{16} + 1;
        end
end

%% Accuracy Count Non-Crack
counter2_1 = {};
counter2_2 = {};
counter2_3 = {};
counter2_4 = {};
counter2_5 = {};
counter2_6 = {};
counter2_7 = {};
counter2_8 = {};
counter2_9 = {};
counter2_10 = {};
counter2_11 = {};
counter2_12 = {};
counter2_13 = {};
counter2_14 = {};
counter2_15 = {};
counter2_16 = {};

for i=1:N
    counter2_1{i} = 0;    
    counter2_2{i} = 0;    
    counter2_3{i} = 0;    
    counter2_4{i} = 0;    
    counter2_5{i} = 0;    
    counter2_6{i} = 0;    
    counter2_7{i} = 0;    
    counter2_8{i} = 0;
    counter2_9{i} = 0;    
    counter2_10{i} = 0;    
    counter2_11{i} = 0;    
    counter2_12{i} = 0;    
    counter2_13{i} = 0;    
    counter2_14{i} = 0;    
    counter2_15{i} = 0;    
    counter2_16{i} = 0;
end
total2 = {};
for i=1:16
   total2{i} = 0; 
end
for i=1:N
    for j=1:size(imgProp2{i})
       if(imgProp2{i}(j).Area >= 50 && imgProp2{i}(j).Eccentricity >= 0.8)
           counter2_1{i} = counter2_1{i} + 1;
           if(imgProp2{i}(j).Area >= 50 && imgProp2{i}(j).Eccentricity >=0.85)
               counter2_2{i} = counter2_2{i} + 1;
               if(imgProp2{i}(j).Area >= 50 && imgProp2{i}(j).Eccentricity >=0.9)
                   counter2_3{i} = counter2_3{i} + 1;
                   if(imgProp2{i}(j).Area >= 50 && imgProp2{i}(j).Eccentricity >=0.95)
                       counter2_4{i} = counter2_4{i} + 1;
                   end
               end
           end
       end
       if(imgProp2{i}(j).Area >= 100 && imgProp2{i}(j).Eccentricity >= 0.8)
           counter2_5{i} = counter2_5{i} + 1;
           if(imgProp2{i}(j).Area >= 100 && imgProp2{i}(j).Eccentricity >=0.85)
               counter2_6{i} = counter2_6{i} + 1;
               if(imgProp2{i}(j).Area >= 100 && imgProp2{i}(j).Eccentricity >=0.9)
                   counter2_7{i} = counter2_7{i} + 1;
                   if(imgProp2{i}(j).Area >= 100 && imgProp2{i}(j).Eccentricity >=0.95)
                       counter2_8{i} = counter2_8{i} + 1;
                   end
               end
           end
       end
       if(imgProp2{i}(j).Area >= 150 && imgProp2{i}(j).Eccentricity >= 0.8)
           counter2_9{i} = counter2_9{i} + 1;
           if(imgProp2{i}(j).Area >= 150 && imgProp2{i}(j).Eccentricity >=0.85)
               counter2_10{i} = counter2_10{i} + 1;
               if(imgProp2{i}(j).Area >= 150 && imgProp2{i}(j).Eccentricity >=0.9)
                   counter2_11{i} = counter2_11{i} + 1;
                   if(imgProp2{i}(j).Area >= 150 && imgProp2{i}(j).Eccentricity >=0.95)
                       counter2_12{i} = counter2_12{i} + 1;
                   end
               end
           end
       end
       if(imgProp2{i}(j).Area >= 200 && imgProp2{i}(j).Eccentricity >= 0.8)
           counter2_13{i} = counter2_13{i} + 1;
           if(imgProp2{i}(j).Area >= 200 && imgProp2{i}(j).Eccentricity >=0.85)
               counter2_14{i} = counter2_14{i} + 1;
               if(imgProp2{i}(j).Area >= 200 && imgProp2{i}(j).Eccentricity >=0.9)
                   counter2_15{i} = counter2_15{i} + 1;
                   if(imgProp2{i}(j).Area >= 200 && imgProp2{i}(j).Eccentricity >=0.95)
                       counter2_16{i} = counter2_16{i} + 1;
                   end
               end
           end
       end
    end
end

for i=1:N
        if counter2_1{i} == 0
            total2{1} = total2{1} + 1;
        end 
        if counter2_2{i} == 0
            total2{2} = total2{2} + 1; 
        end
        if counter2_3{i} == 0
            total2{3} = total2{3} + 1;
        end
        if counter2_4{i} == 0
            total2{4} = total2{4} + 1;
        end
        if counter2_5{i} == 0
            total2{5} = total2{5} + 1;
        end
        if counter2_6{i} == 0
            total2{6} = total2{6} + 1;
        end
        if counter2_7{i} == 0
            total2{7} = total2{7} + 1;
        end
        if counter2_8{i} == 0
            total2{8} = total2{8} + 1;
        end
        if counter2_9{i} == 0
            total2{9} = total2{9} + 1;
        end
        if counter2_10{i} == 0
            total2{10} = total2{10} + 1;
        end
        if counter2_11{i} == 0
            total2{11} = total2{11} + 1;
        end
        if counter2_12{i} == 0
            total2{12} = total2{12} + 1;
        end
        if counter2_13{i} == 0
            total2{13} = total2{13} + 1;
        end
        if counter2_14{i} == 0
            total2{14} = total2{14} + 1;
        end
        if counter2_15{i} == 0
            total2{15} = total2{15} + 1;
        end
        if counter2_16{i} == 0
            total2{16} = total2{16} + 1;
        end
end
%% Total Accuracy Crack
akurasi = {};
akutasi2 = {};
totalAkurasi = {};
for i=1:16
    akurasi{i} = total{i}/N;
    akurasi2{i} = total2{i}/N;
end
for i=1:16
   totalAkurasi{i} = (akurasi{i}+akurasi2{i})/2; 
end
%% Write to Excel
filename = '2crackDetection1.xlsx';
kriteria1 = {'>=50','>=50','>=50','>=50','>=100','>=100','>=100','>=100','>=150','>=150','>=150','>=150','>=200','>=200','>=200','>=200'};
kriteria2 = {'>=0.80','>=0.85','>=0.90','>=0.95','>=0.80','>=0.85','>=0.90','>=0.95','>=0.80','>=0.85','>=0.90','>=0.95','>=0.80','>=0.85','>=0.90','>=0.95'};
headers = {'Area','Eccentricity','Accuracy of crack detection','Accuracy of non-crack detection', 'Overall Accuracy'};
data = [akurasi];
data2 = [akurasi2];
data3 = [totalAkurasi];
xlswrite(filename,headers,'Sheet1','A1');
xlswrite(filename,data.','Sheet1','C2');
xlswrite(filename,data2.','Sheet1','D2');
xlswrite(filename,data3.','Sheet1','E2');
xlswrite(filename,kriteria1.','Sheet1','A2');
xlswrite(filename,kriteria2.','Sheet1','B2');
%% Write to Excel
% filename = 'imgProp2.xlsx';
% for i=1:N
%    data = [areaProp2{i},eccentricityProp2{i},majorAxisProp2{i},minorAxisProp2{i}];
%    headers = {'Area','Eccentricity','MajorAxisLength','MinorAxisLength'};
%    xlswrite(filename,headers,i,'A1');
%    xlswrite(filename,data,i,'A2');
% end

%% Centroid
% s = regionprops(imgBw{1},'centroid');
% centroids = cat(1, s.Centroid);
% figure, imshow(imgBw{1})
% hold on
% plot(centroids(:,1),centroids(:,2), 'b*')
% hold off