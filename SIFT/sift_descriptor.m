function descriptors = sift_descriptor(num_keypoints, key_points, orient_magn, theta_keys, I)
    [height_I, width_I] = size(I(:,:,1));
    
    lambda_descr = 6;
    n_hist = 4;
    n_ori = 8;
    delta_min = 0.5;
    
    f = cell(num_keypoints, 1);
    abs_keypoint = cell(num_keypoints, 1);
    %f = {};
    count = 0;
    for kp=1:num_keypoints
        key_point = key_points{kp};
        o_key = key_point(1);
        s_key = key_point(2);
        sigma_key = key_point(3);
        x_key = key_point(4);
        y_key = key_point(5);
        temp = sqrt(2)*lambda_descr*sigma_key;
        if(x_key >= temp && x_key <= height_I - temp...
                && y_key >= temp && y_key <= width_I - temp)
            hist = zeros(n_hist, n_hist, n_ori);
            temp = temp * (n_hist+1)/n_hist;
            m_from = round((x_key - temp)/(delta_min*2^(o_key-1)));
            m_to = round((x_key + temp)/(delta_min*2^(o_key-1)));
            n_from = round((y_key - temp)/(delta_min*2^(o_key-1)));
            n_to = round((y_key + temp)/(delta_min*2^(o_key-1)));
            m_to = min(size(orient_magn{o_key}{s_key}{2},1), m_to);
            n_to = min(size(orient_magn{o_key}{s_key}{2},2), n_to);
            m_from = max(m_from, 1);
            n_from = max(n_from, 1);
            for m=m_from:m_to
                for n=n_from:n_to
                    x_mn = ((m*delta_min*2^(o_key-1)-x_key)*cos(theta_keys{kp}) + ...
                          (n*delta_min*2^(o_key-1)-y_key)*sin(theta_keys{kp}))/sigma_key;
                    y_mn = (-(m*delta_min*2^(o_key-1)-x_key)*sin(theta_keys{kp}) + ...
                          (n*delta_min*2^(o_key-1)-y_key)*cos(theta_keys{kp}))/sigma_key;
                    if(max(abs(x_mn), abs(y_mn)) < lambda_descr*(n_hist+1)/n_hist)
                        theta_mn = orient_magn{o_key}{s_key}{2}(m,n) - mod(theta_keys{kp}, 2*pi);
                        temp_1 = m*delta_min*2^(o_key-1) - x_key;
                        temp_2 = n*delta_min*2^(o_key-1) - y_key;
                        temp_3 = 2*((lambda_descr*sigma_key)^2);
                        c_descr_mn = exp(-(temp_1^2 + temp_2^2)/temp_3) * orient_magn{o_key}{s_key}{1}(m,n);
                        for i=1:n_hist
                            x_i = (i - (1+n_hist)/2)*2*lambda_descr/n_hist;
                            for j=1:n_hist
                                y_j = (j - (1+n_hist)/2)*2*lambda_descr/n_hist;
                                temp_4 = abs(x_i-x_mn);
                                temp_5 = abs(y_j-y_mn);
                                if(temp_4 <= 2*lambda_descr/n_hist && ...
                                        temp_5 <= 2*lambda_descr/n_hist)
                                    for k=1:n_ori
                                        temp_6 = abs(2*pi*(k-1)/n_ori - mod(theta_mn, 2*pi));
                                        if(temp_6 < 2*pi/n_ori)
                                            hist(i, j, k) = hist(i, j, k) + ...
                                                (1-n_hist*temp_4/(2*lambda_descr))*...
                                                (1-n_hist*temp_5/(2*lambda_descr))*...
                                                (1-n_ori*temp_6/(2*pi))*c_descr_mn;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            count = count + 1;
            for i=1:n_hist
                for j=1:n_hist
                    for k=1:n_ori
                        f{count}((i-1)*n_hist*n_ori+(j-1)*n_ori+k) = hist(i, j, k);
                    end
                end
            end
            
            f_modul = norm(f{count});
            for l=1:n_hist*n_hist*n_ori
                f{count}(l) = min(f{count}(l), 0.2*f_modul); 
                f{count}(l) = min(floor(512*f{count}(l)/f_modul), 255);
            end
            abs_keypoint{count} = [x_key y_key sigma_key theta_keys{kp}];
        end
    end
    
    result = cell(3, 1);
    result{1} = f;
    result{2} = abs_keypoint;
    result{3} = count;
    
    descriptors = result;
end