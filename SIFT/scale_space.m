function all_octaves = scale_space(I)
    sigma_min = 0.8;        %tham so sigma khoi tao
    delta_min = 0.5;        %ban dau anh zoom len 2 lan
    n_spo = 3;              %so luong scale moi octave
    n_oct = 5;              %so luong octave
    sigma_in = 0.5;         %tham so Gauss nhan chap voi anh dau vao
        
    total_scales = n_spo + 3;   %moi octave co 3 scale bo sung
    if(size(I, 3) > 1)          
        I = rgb2gray(I);
    end
    I_init = imresize(I, 1/delta_min, 'bilinear'); %tao anh dau vao kich thuoc gap doi
    H_init = fspecial('gaussian', 3, 0.5);         %nhan chap Gauss voi anh dau vao
    I_init = filter2(H_init, I_init, 'same');
    
    curr_sigma = sigma_min;
    
    init_image = I_init;
    prev_image = I_init;
    octaves = cell(n_oct, 1);
    %Tinh toan tren tung octave
    for o=1:n_oct
        octaves{o} = zeros(size(init_image, 1), size(init_image, 2), total_scales);
        for s=1:total_scales
            blured_image = gaussian_filter(prev_image, curr_sigma);
			prev_image = blured_image;
			disp(['Octave number: ' num2str(o) ' with blur level ' num2str(s) ' and sigma value = ' num2str(curr_sigma)]);
			octaves{o}(:, :, s) = blured_image; 
			curr_sigma  = sigma_min * (2^(s/n_spo+o-1)); 
        end
        %tinh lai sigma cho anh dau tien cua octave
        curr_sigma  = sigma_min * (2^o); 
        %giam kich thuoc anh di 2 lan
        init_image = reduce_a_half(octaves{o}(:,:,total_scales-3));
        prev_image = init_image;
    end
    all_octaves = octaves;
    
    function r = reduce_a_half(I)
		r=I(1:2:end,1:2:end);	
	end 
end