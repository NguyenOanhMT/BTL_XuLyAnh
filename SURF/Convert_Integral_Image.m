function iimg = Convert_Integral_Image(img)
% Chuyen dinh dang anh dau vao thanh anh tich hop (integral image)
% Input: img anh mau hoac anh xam
% Output: iimg anh tich hop(integral image) thu duoc tu img
    % Convert Image to double
    switch(class(img))
        case 'uint8'
            I=double(img)/255;
        case 'uint16'
            I=double(img)/65535;
        case 'int8'
            I=(double(img)+128)/255;
        case 'int16'
            I=(double(img)+32768)/65535;
        otherwise
            I=double(img);
    end

    % Convert Image to greyscale
    if(size(I,3)==3)
        cR = .2989; cG = .5870; cB = .1140;
        I=I(:,:,1)*cR+I(:,:,2)*cG+I(:,:,3)*cB;
    end

    % Make the integral image
    iimg = cumsum(cumsum(I,1),2);
end

