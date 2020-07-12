function descriptor = Get_Descriptor(ip, img)
% Tinh gia descriptor: 64 chieu
% Input:
%   ip = ipts[i] 
%   img: anh dau vao 
% Output
%   descriptor: vector 64 chieu, bieu dien diem hap dan

    X = round(ip.x);
    Y = round(ip.y);
    S = round(ip.scale);
    
    co = cos(ip.orientation);
    si = sin(ip.orientation);

    % Basis coordinates of samples, if coordinate 0,0, and scale 1
    [lb,kb]=ndgrid(-4:4,-4:4); lb=lb(:); kb=kb(:);

    %Calculate descriptor for this interest point
    [jl,il]=ndgrid(0:3,0:3); il=il(:)'; jl=jl(:)';

    ix = (il*5-8);
    jx = (jl*5-8);

    % 2D matrices instead of double for-loops, il, jl
    cx=length(lb); cy=length(ix);
    lb=repmat(lb,[1 cy]); lb=lb(:);
    kb=repmat(kb,[1 cy]); kb=kb(:);
    ix=repmat(ix,[cx 1]); ix=ix(:);
    jx=repmat(jx,[cx 1]); jx=jx(:);

    % Coordinates of samples (not rotated)
    l=lb+jx; k=kb+ix;

    %Get coords of sample point on the rotated axis
    sample_x = round(X + (-l * S * si + k * S * co)); 
    sample_y = round(Y + (l * S * co + k * S * si));

    %Get the gaussian weighted x and y responses
    xs = round(X + (-(jx+1) * S * si + (ix+1) * S * co));
    ys = round(Y + ((jx+1) * S * co + (ix+1) * S * si));

    gauss_s1 = SurfDescriptor_Gaussian(xs - sample_x, ys - sample_y, 2.5 * S);
    rx = IntegralImage_HaarX(sample_y, sample_x, 2 * S,img);
    ry = IntegralImage_HaarY(sample_y, sample_x, 2 * S,img);

    %Get the gaussian weighted x and y responses on the aligned axis
    rrx = gauss_s1 .* (-rx * si + ry * co);  rrx=reshape(rrx,cx,cy);
    rry = gauss_s1 .* ( rx * co + ry * si);  rry=reshape(rry,cx,cy);

    % Get the gaussian scaling
    cx = -0.5 + il + 1; cy = -0.5 + jl + 1;
    gauss_s2 = SurfDescriptor_Gaussian(cx - 2, cy - 2, 1.5);

    dx = sum(rrx,1);
    dy = sum(rry,1);
    mdx = sum(abs(rrx),1);
    mdy = sum(abs(rry),1);
    dx_yn = 0; mdx_yn = 0; 
    dy_xn = 0; mdy_xn = 0;

    descriptor=[dx;dy;mdx;mdy].* repmat(gauss_s2,[4 1]);

    len = sum((dx.^2 + dy.^2 + mdx.^2 + mdy.^2 + dx_yn + dy_xn + mdx_yn + mdy_xn) .* gauss_s2.^2);

    %Convert to Unit Vector
    descriptor= descriptor(:) / sqrt(len);
    
    % ve 
    if(1)
        for i=1:size(rrx,2)
            p1=reshape(rrx(:,i),[9,9]);
            p2=reshape(rry(:,i),[9,9]);
            p=[p1;ones(1,9)*0.02;p2];
            if(i==1)
                pic=p;
            else
                pic=[pic ones(19,1)*0.02 p];
            end
        end
        imshow(pic,[]);
    end
end

function surfGaussian= SurfDescriptor_Gaussian(x, y, sig)
    surfGaussian = 1 / (2 * pi * sig^2) .* exp(-(x.^2 + y.^2) / (2 * sig^2));
end

