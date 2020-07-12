% Doc anh dau vao
I1 = imread('coca_logo.png');
I2 = imread('coca_cola4.jpg');
figure,imshow(I1);
figure,imshow(I2);

% convert sang anh tich hop
iI1 = Convert_Integral_Image(I1);
iI2 = Convert_Integral_Image(I2);

% Xac dinh cac diem hap dan
ipts1 = Get_Interest_Point(iI1);
ipts2 = Get_Interest_Point(iI2);

if(~isempty(ipts1))
    ipts1 = Descriptor_Interesting_Points(ipts1,iI1);
end

if(~isempty(ipts2))
    ipts2 = Descriptor_Interesting_Points(ipts2,iI2);
end

% Put the landmark descriptors in a matrix
  D1 = reshape([ipts1.descriptor],64,[]); 
  D2 = reshape([ipts2.descriptor],64,[]); 
  
% Find the best matches
  err=zeros(1,length(ipts1));
  cor1=1:length(ipts1); 
  cor2=zeros(1,length(ipts1));
  for i=1:length(ipts1),
      distance=sum((D2-repmat(D1(:,i),[1 length(ipts2)])).^2,1);
      [err(i),cor2(i)]=min(distance);
  end
% Sort matches on vector distance
  [err, ind]=sort(err); 
  cor1=cor1(ind); 
  cor2=cor2(ind);
  
  
% Show both images
  figure;
  height_1 = size(I1,1);
  width_1 = size(I1,2);
  height_2 = size(I2,1);
  width_2 = size(I2,2);
  
  total_width = width_1 + width_2;
  if(height_1>height_2)
      total_height = height_1;
  else
      total_height = height_2;
  end
  
  combined_image = ones(total_height, total_width, 3);
  combined_image(1:height_1,1:width_1,:) = I1;
  combined_image(1:height_2,(width_1+1):(width_2+width_1),:) = I2;
  imagesc(double(combined_image)/double(255));
  colormap(gray(256));
  hold on;
  
% Show the best matches
  for i=1:10
      c=rand(1,3);
      plot([ipts1(cor1(i)).x ipts2(cor2(i)).x+size(I1,2)],[ipts1(cor1(i)).y ipts2(cor2(i)).y],'-','Color',c)
      plot([ipts1(cor1(i)).x ipts2(cor2(i)).x+size(I1,2)],[ipts1(cor1(i)).y ipts2(cor2(i)).y],'o','Color',c)
  end
  title('Matching 2 images');
  disp('Done matching');
