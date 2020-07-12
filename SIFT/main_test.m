
function main_test() 
    I1 = imread('coca_logo.png');
    I2 = imread('coca_cola6.jpg');
    C_match_relative = 0.6;
    
    % mang mau color
    C = {'k','b','c','g','y'};
    Cp = {'ko','bo','co','go','yo'};
    
    scale_space_1 = scale_space(I1);
    disp('Done building scale space image 1');
    figure;
    for i=1:length(scale_space_1)
        for j=1:size(scale_space_1{i}, 3)
            subplot(length(scale_space_1), size(scale_space_1{i}, 3), (i-1)*size(scale_space_1{i}, 3)+j)
            imshow(uint8(scale_space_1{i}(:,:,j)));
        end
    end
    suptitle('Step 1: Gaussian Scale Space');
    
    DOG_octaves_1 = calculate_DOG(scale_space_1);
    disp('Done calculating diffenrence of gaussian image 1');
    figure;
    for i=1:length(DOG_octaves_1)
        for j=1:size(DOG_octaves_1{i}, 3)
            subplot(length(DOG_octaves_1), size(DOG_octaves_1{i}, 3), (i-1)*size(DOG_octaves_1{i}, 3)+j)
            imshow(uint8(DOG_octaves_1{i}(:,:,j)));
        end
    end
    suptitle('Step 2: DoG Scale Space');
    
    keypoints_1 = calculate_key_points(DOG_octaves_1, I1);
    disp('Done calculating extremas image 1');
    figure, imagesc(I1);
    hold on;
    for i=1:keypoints_1{2}
        plot(keypoints_1{1}{i}(5),keypoints_1{1}{i}(4),'bo','MarkerSize',keypoints_1{1}{i}(3)*4+0.5,'LineWidth',1);
    end
    title('Step 3: Found keypoints after interpolating and thresholding');
    
    grad_and_theta_keys_1 = define_orientation(keypoints_1, scale_space_1, I1);
    disp('Done calculating reference orientation for keypoints image 1');
    figure, imagesc(I1);
    hold on;
    for i=1:grad_and_theta_keys_1{4}
        x1 = grad_and_theta_keys_1{3}{i}(5);
        y1 = grad_and_theta_keys_1{3}{i}(4);
        L = grad_and_theta_keys_1{3}{i}(3)*8+1;
        alpha = grad_and_theta_keys_1{1}{i};
        x2 = x1 + (L/2*cos(alpha));
        y2 = y1 + (L/2*sin(alpha));
        plot(x1,y1,'bo','MarkerSize',L,'LineWidth',1);
        plot([x1 x2],[y1 y2],'b');
    end
    title('Step 4: Keypoints and orientations');
    
    descriptors_1 = sift_descriptor(grad_and_theta_keys_1{4}, grad_and_theta_keys_1{3}, grad_and_theta_keys_1{2}, grad_and_theta_keys_1{1}, I1);
    disp('Done normalizing descriptors image 1');
    fprintf('The number of keypoints founded in image 1: %d\n', descriptors_1{3});
    
    scale_space_2 = scale_space(I2);
    disp('Done building scale space image 2');
    DOG_octaves_2 = calculate_DOG(scale_space_2);
    disp('Done calculating diffenrence of gaussian image 2');
    keypoints_2 = calculate_key_points(DOG_octaves_2);
    disp('Done calculating extremas image 2');
    grad_and_theta_keys_2 = define_orientation(keypoints_2, scale_space_2, I2);
    disp('Done calculating reference orientation for keypoints image 2');
    descriptors_2 = sift_descriptor(grad_and_theta_keys_2{4}, grad_and_theta_keys_2{3}, grad_and_theta_keys_2{2}, grad_and_theta_keys_2{1}, I2);
    disp('Done normalizing descriptors image 2');
    fprintf('The number of keypoints founded in image 2: %d\n', descriptors_2{3});
    
    %figure, imshow(I1);
    %hold on;
    %for i=1:descriptors_1{3}
    %    plot(descriptors_1{2}{i}(2), descriptors_1{2}{i}(1), 'go', 'MarkerSize', descriptors_1{2}{i}(3)*4);
    %end
    
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
    
    num_matches = 0;
    for i=1:descriptors_1{3}
        pos = 0;
        value_min = Inf;
        value_second_min = Inf;
        for j = 1:descriptors_2{3}
            dist = norm(descriptors_1{1}{i} - descriptors_2{1}{j});
            if value_second_min > dist 
                value_second_min = dist;
            end
            if(value_min > dist)
                pos = j;
                value_second_min = value_min;
                value_min = dist;
            end
        end

        if (value_min < C_match_relative*value_second_min)
            num_matches = num_matches + 1;
            plot(descriptors_1{2}{i}(2),descriptors_1{2}{i}(1),Cp{mod(num_matches,5)+1}, 'MarkerSize',descriptors_1{2}{i}(3)*4+0.5, 'LineWidth', 2);
            plot(width_1+descriptors_2{2}{pos}(2),descriptors_2{2}{pos}(1),Cp{mod(num_matches,5)+1}, 'MarkerSize',descriptors_2{2}{pos}(3)*4+0.5, 'LineWidth', 2);
            plot([descriptors_1{2}{i}(2),width_1+descriptors_2{2}{pos}(2)],[descriptors_1{2}{i}(1) descriptors_2{2}{pos}(1)], C{mod(num_matches,5)+1}, 'LineWidth', 2);
        end
    end
    title('Matching 2 images');
    fprintf('Done matching, num_matches = %d\n', num_matches);
end