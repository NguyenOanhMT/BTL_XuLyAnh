function layerData = Calculate_Deteminant_Hessian(layerData,img)
% tinh det(H) va luu gia tri vao cau truc layerData 
%  
%  inputs,
%    layerData : layer can tinh gia det(H) va cac gia tri khac
%    img : anh dau vao de tinh cac gia tri
%  
%  outputs,
%    layerData : layer da dien du du lieu
%  

    step = fix( layerData.step);                     % step size for this filter
    b = fix((layerData.filter - 1) / 2 + 1);         % border for this filter
    l = fix(layerData.filter / 3);                   % lobe for this filter (filter size / 3)(l0)
    w = fix(layerData.filter);                       % filter size

    inverse_area = 1 / double(w * w);                % normalisation factor

    [ac,ar]=ndgrid(0:layerData.width-1,0:layerData.height-1);
    ar=ar(:); ac=ac(:);

    % get the image coordinates
    r = int32(ar * step);
    c = int32(ac * step);

    % Compute response components
    Dxx =   Calculate_Sum_Area(r - l + 1, c - b, 2 * l - 1, w,img) - Calculate_Sum_Area(r - l + 1, c - fix(l / 2), 2 * l - 1, l, img) * 3;
    Dyy =   Calculate_Sum_Area(r - b, c - l + 1, w, 2 * l - 1,img) - Calculate_Sum_Area(r - fix(l / 2), c - l + 1, l, 2 * l - 1,img) * 3;
    Dxy = + Calculate_Sum_Area(r - l, c + 1, l, l,img) + Calculate_Sum_Area(r + 1, c - l, l, l,img) ...
          - Calculate_Sum_Area(r - l, c - l, l, l,img) - Calculate_Sum_Area(r + 1, c + 1, l, l,img);

    % Normalise the filter responses with respect to their size
    Dxx = Dxx*inverse_area;
    Dyy = Dyy*inverse_area;
    Dxy = Dxy*inverse_area;

    % Get the determinant of hessian response & laplacian sign
    layerData.responses = (Dxx .* Dyy - 0.9 * Dxy .* Dxy);
    layerData.laplacian = (Dxx + Dyy) >= 0;

end

