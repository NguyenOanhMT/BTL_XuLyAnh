function keypoints = calculate_key_points(DOG, I)
    C_DOG = 0.015;
    C_EDGE = 10;
    delta_min = 0.5;
    sigma_min = 0.8;
    n_spo = 3;

    count = 0;    
    keypoint_abs = {};
    
    for o=1:size(DOG, 1)
        for l=2:(size(DOG{o}, 3)-1)
            for r = 2:size(DOG{o},1)-1
				for c = 2:size(DOG{o},2)-1
                    is_keypoint = false;
                    isMax = true;
                    isMin = true;
                    for l_3x3 = l-1 : l+1
                        for r_3x3 = r-1 : r+1
                            for c_3x3 = c-1 : c+1
                                if l_3x3 == l && r_3x3 == r && c_3x3 == c
                                    continue
                                end
                                if isMax && DOG{o}(r,c,l) <= DOG{o}(r_3x3,c_3x3,l_3x3)
                                    isMax = false;
                                end
                                if isMin && DOG{o}(r,c,l) >= DOG{o}(r_3x3,c_3x3,l_3x3)
                                    isMin = false;
                                end
                                
                            end
                        end
                    end
                    
                    if isMax || isMin
                         if(is_keypoint == false)
                            count = count + 1; 
                            is_keypoint = true; 
                         end
                    end
                    
                    if(is_keypoint==true) 
                        if(abs(DOG{o}(r,c,l)) < 0.8*C_DOG)
                            count = count - 1; 
                            is_keypoint = false;                             
                        end
                    end
                    
                    l_n = l;
                    r_n = r;
                    c_n = c;
                    x_n = 0;
                    y_n = 0;
                    sigma_n = 0;
                    w = 0;
                    H = zeros(3, 3);
                    if(is_keypoint==true)
                        g = zeros(3, 1);
                        num_tries = 1;
                        alpha = ones(1, 3);
                        while(num_tries < 6 && max(abs(alpha)) >= 0.6)
                            H(1, 1) = DOG{o}(r_n,c_n,l_n+1) + DOG{o}(r_n,c_n,l_n-1) - 2*DOG{o}(r_n,c_n,l_n);
                            H(2, 2) = DOG{o}(r_n+1,c_n,l_n) + DOG{o}(r_n-1,c_n,l_n) - 2*DOG{o}(r_n,c_n,l_n);
                            H(3, 3) = DOG{o}(r_n,c_n+1,l_n) + DOG{o}(r_n,c_n-1,l_n) - 2*DOG{o}(r_n,c_n,l_n);
                            H(1, 2) = (DOG{o}(r_n+1,c_n,l_n+1) - DOG{o}(r_n-1,c_n,l_n+1) - DOG{o}(r_n+1,c_n,l_n-1) + DOG{o}(r_n-1,c_n,l_n-1))/4;
                            H(1, 3) = (DOG{o}(r_n,c_n+1,l_n+1) - DOG{o}(r_n,c_n-1,l_n+1) - DOG{o}(r_n,c_n+1,l_n-1) + DOG{o}(r_n,c_n-1,l_n-1))/4;
                            H(2, 3) = (DOG{o}(r_n+1,c_n+1,l_n) - DOG{o}(r_n+1,c_n-1,l_n) - DOG{o}(r_n-1,c_n+1,l_n) + DOG{o}(r_n-1,c_n-1,l_n))/4;
                            H(2, 1) = H(1, 2);
                            H(3, 1) = H(1, 3);
                            H(3, 2) = H(2, 3);
                            g(1, 1) = (DOG{o}(r_n,c_n,l_n+1) - DOG{o}(r_n,c_n,l_n-1))/2;
                            g(2, 1) = (DOG{o}(r_n+1,c_n,l_n) - DOG{o}(r_n-1,c_n,l_n))/2;
                            g(3, 1) = (DOG{o}(r_n,c_n+1,l_n) - DOG{o}(r_n,c_n-1,l_n))/2;
                            alpha = -inv(H)*g;
                            w = DOG{o}(r_n,c_n,l_n) - 0.5*g'*inv(H)*g;
                            delta_oe = delta_min*2^(o-1);
                            if(max(abs(alpha))<0.6)
                                sigma_n = 2^(o-1)*sigma_min*2^((alpha(1)+l_n)/n_spo);
                                x_n = delta_oe*(alpha(2) + r_n);
                                y_n = delta_oe*(alpha(3) + c_n);
                            end
                            l_n = round(l_n + alpha(1));
                            r_n = round(r_n + alpha(2));
                            c_n = round(c_n + alpha(3));
                            if(l_n <= 1 || r_n <= 1 || c_n <= 1 || l_n >= (size(DOG{o}, 3)-1) || r_n >= size(DOG{o},1)-1 || c_n >= size(DOG{o},2)-1)
                                is_keypoint = false;
                                count = count - 1;
                                break;
                            end
                            num_tries = num_tries + 1;
                        end
                        
                        if(is_keypoint==true)
                            if(max(abs(alpha)) >= 0.6)
                                is_keypoint = false;
                                count = count - 1;
                            end
                        end
                    end
                    
                    if(is_keypoint==true) 
                        if(abs(w) < C_DOG)
                            is_keypoint = false; 
                            count = count - 1; 
                        end
                    end
                    
                    if(is_keypoint==true)
                        %derivative_yy = (DOG{o}(r_n-1,c_n,l_n) + ...
                        %       DOG{o}(r_n+1,c_n,l_n) - ... 
                        %       2.0*DOG{o}(r_n,c_n,l_n));    
                        %derivative_xx = (DOG{o}(r_n,c_n-1,l_n) + ...
                        %       DOG{o}(r_n,c_n+1,l_n) - ... 
                        %       2.0*DOG{o}(r_n,c_n,l_n));     
                        %derivative_xy = (DOG{o}(r_n-1,c_n-1,l_n) + ...
                        %       DOG{o}(r_n+1,c_n+1,l_n) - ... 
                        %       DOG{o}(r_n+1,c_n-1,l_n) - ... 
                        %       DOG{o}(r_n-1,c_n+1,l_n))/4; 
                           
                        tr = H(2, 2) + H(3, 3);
                        determinant_H = H(2, 2) * H(3, 3) - H(2, 3)*H(2, 3); 
                        ratio = tr^2/determinant_H; 
                        threshold = ((C_EDGE+1)^2)/C_EDGE;
                        if(ratio >= threshold || determinant_H < 0)
                            is_keypoint = false; 
                            count = count - 1; 
                        end 
                    end
                    
                    if(is_keypoint==true)
                       keypoint_abs{count} = [o l_n sigma_n x_n y_n];
                    end
                end
            end
        end
    end
    
    result = cell(2,1); 
    result{1} = keypoint_abs;
    result{2} = count;
    keypoints = result; 
end