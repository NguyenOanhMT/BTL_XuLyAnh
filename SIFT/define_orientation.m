function grad_and_theta_keys = define_orientation(key_points, octaves, I)
    orient_magn = cell(size(octaves,1),size(octaves{1},4),2);
    [height_I, width_I] = size(I(:,:,1));
    lambda = 1.5;
    delta_min = 0.5;
    n_bins = 36;

    count = 0;
    o_count = 0;
    key_points_n = cell(key_points{2}, 1);
    for o = 1:size(octaves,1)
        for s = 1:size(octaves{o},3)
            filter_diff_x = [0 0 0; -1 0 1; 0 0 0];
            diff_x_mat = imfilter(octaves{o}(:,:,s), filter_diff_x);
            
            filter_diff_y = [0 1 0; 0 0 0; 0 -1 0];
            diff_y_mat = imfilter(octaves{o}(:,:,s), filter_diff_y);
              
            magn_mat = sqrt(diff_x_mat.*diff_x_mat + diff_y_mat.*diff_y_mat);
            orient_mat = atan2(diff_y_mat, diff_x_mat); 
            
            orient_magn{o}{s}{1} = magn_mat; 
            orient_magn{o}{s}{2} = orient_mat;
        end 
    end 
    
    theta_keys = cell(key_points{2}, 1);
    for kp=1:key_points{2}
        theta_keys{kp} = 0;
        key_point = key_points{1}{kp};
        o_key = key_point(1);
        s_key = key_point(2);
        x_key = key_point(4);
        y_key = key_point(5);
        sigma_key = key_point(3);
        if(x_key >= 3*lambda*sigma_key && x_key <= height_I - 3*lambda*sigma_key && ...
                y_key >= 3*lambda*sigma_key && y_key <= width_I - 3*lambda*sigma_key)
            hist = zeros(n_bins,1); 
            m_from = round((x_key-3*lambda*sigma_key)/(delta_min*2^(o_key-1)));
            m_to = round((x_key+3*lambda*sigma_key)/(delta_min*2^(o_key-1)));
            n_from = round((y_key-3*lambda*sigma_key)/(delta_min*2^(o_key-1)));
            n_to = round((y_key+3*lambda*sigma_key)/(delta_min*2^(o_key-1)));
            m_from = max(m_from, 1);
            n_from = max(n_from, 1);
            for m=m_from:m_to
                for n=n_from:n_to
                    temp_1 = m*delta_min*2^(o_key-1) - x_key;
                    temp_2 = n*delta_min*2^(o_key-1) - y_key;
                    temp_3 = 2*((lambda*sigma_key)^2);
                    c_ori_mn = exp(-(temp_1^2 + temp_2^2)/temp_3) * orient_magn{o_key}{s_key}{1}(m,n);
                    bin_ori_mn = round(n_bins/(2*pi)*mod(orient_magn{o_key}{s_key}{2}(m,n), 2*pi)+0.5);
                    hist(bin_ori_mn) = hist(bin_ori_mn) + c_ori_mn;
                end
            end
            
            smoothing_kernel = [1/3 1/3 1/3];
            hist = conv(hist, smoothing_kernel);
            t = 0.8;
            for k=2:n_bins-1
                if(hist(k)>hist(k-1) && hist(k)>hist(k+1) && hist(k)>=t*max(hist))
                    if(count == o_count)
                        count = count + 1;
                    end
                    theta_keys{count} = 2*pi*(k-1)/n_bins + pi/n_bins*((hist(k-1)-hist(k+1))/(hist(k-1)-2*hist(k)+hist(k+1)));
                    key_points_n{count} = key_point;
                end
            end
            o_count = count;
        end
    end
    result = cell(4, 1);
    result{1} = theta_keys;
    result{2} = orient_magn;
    result{3} = key_points_n;
    result{4} = count;
    grad_and_theta_keys = result;
end