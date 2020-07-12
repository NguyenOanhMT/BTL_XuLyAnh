function r = gaussian_filter(I, sigma, kernel_size)
    if ~exist('kernel_size', 'var')
        kernel_size = round(4*sigma)*2+1;
    end
    
    if(kernel_size < 1)
        kernel_size = 1; 
    end 
    h = fspecial('gaussian', kernel_size, sigma);
    r = filter2(h, I, 'same');
end