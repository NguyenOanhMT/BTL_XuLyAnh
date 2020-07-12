function scaleSpaceMap = Build_Scale_Space(iimg,n_octaves,init_sample)
% Calculate responses for the first n_octaves:
% Oct1: 9,  15, 21, 27
% Oct2: 15, 27, 39, 51
% Oct3: 27, 51, 75, 99
% Oct4: 51, 99, 147,195
% Oct5: 99, 195,291,387
%
% Input: 
%   iimg: anh dau vao danh dang integral image
%   n_octaves: so luong octave can tao
%   init_sample: buoc lay mau (sampling step)
% Output: scaleSpaceMap: thap scale space co data

    % cap phat bo nho luu tru scale space
    scaleSpaceMap = [];
    j = 0; 

    % Lay kich thuoc anh
    w = (size(iimg,2)/init_sample);
    h = (size(iimg,1)/init_sample);
    step_sampling = init_sample;
    
    % Tao khung thap scale space
    if (n_octaves >= 1)
        j=j+1; scaleSpaceMap{j}=Layer_Data(w, h,step_sampling,9);
        j=j+1; scaleSpaceMap{j}=Layer_Data(w, h, step_sampling, 15);
        j=j+1; scaleSpaceMap{j}=Layer_Data(w, h, step_sampling, 21);
        j=j+1; scaleSpaceMap{j}=Layer_Data(w, h, step_sampling, 27);
    end

    if (n_octaves >= 2)
        j=j+1; scaleSpaceMap{j}=Layer_Data(w / 2, h / 2, step_sampling * 2, 39);
        j=j+1; scaleSpaceMap{j}=Layer_Data(w / 2, h / 2, step_sampling * 2, 51);
    end

    if (n_octaves >= 3)
        j=j+1; scaleSpaceMap{j}=Layer_Data(w / 4, h / 4, step_sampling * 4, 75);
        j=j+1; scaleSpaceMap{j}=Layer_Data(w / 4, h / 4, step_sampling * 4, 99);
    end

    if (n_octaves >= 4)
        j=j+1; scaleSpaceMap{j}=Layer_Data(w / 8, h / 8, step_sampling * 8, 147);
        j=j+1; scaleSpaceMap{j}=Layer_Data(w / 8, h / 8, step_sampling * 8, 195);
    end

    if (n_octaves >= 5)
        j=j+1; scaleSpaceMap{j}=Layer_Data(w / 16, h / 16, step_sampling * 16, 291);
        j=j+1; scaleSpaceMap{j}=Layer_Data(w / 16, h / 16, step_sampling * 16, 387);
    end

    % Extract responses from the image
    for i=1:length(scaleSpaceMap)
        scaleSpaceMap{i}=Calculate_Deteminant_Hessian(scaleSpaceMap{i},iimg);
    end

end

function layerData= Layer_Data(width, height, step, filter)
% xây dung cau truc du lieu luu tru thong tin cua 1 layer trong scale space
% Input: 
%   width, height: kich thuoc layer
%   step: Buoc lay mau(sampling step) cua layer nay
%   filter: kich thuoc box filter
% Output: 
%   (structure)layerData{
%         width, 
%         height,
%         step,
%         filter,
%         responses, : ma tran cot, kich thuoc width*height, luu tru det(H)
%         laplacian  : ma tran cot, kich thuoc width*height
%     } 
    width = floor(width);
    height = floor(height);
    step = floor(step);     
    filter = floor(filter);
    
    layerData.width = width;
    layerData.height = height;
    layerData.step = step;
    layerData.filter = filter;
    layerData.responses = zeros(width * height,1); % luu det(H)
    layerData.laplacian = zeros(width * height,1);
end
