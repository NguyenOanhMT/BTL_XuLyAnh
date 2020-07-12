function rectSum = Calculate_Sum_Area(row,col, rows, cols, iimg)
% Tinh toan tong gia tri cua 1 vung anh hinh chu nhat xac dinh 
% boi 4 tham so dau tien tren anh iimg
% Input:
%   row,col : 2 tham so xac dinh goc trai ben tren cua vung can tinh
%   rows, cols: so hang va so cot cua vung can tinh, tinh tu goc trai tren
% Output:
%   rectSum: Tong gia tri cac diem anh trong vung hinh chu nhat can tinh
    % Get integer coordinates
    row=fix(row);
    col=fix(col);
    rows=fix(rows);
    cols=fix(cols);

    % Get the corner coordinates of the box integral
    r1 = min(row, size(iimg,1));
    c1 = min(col, size(iimg,2));
    r2 = min(row + rows, size(iimg,1));
    c2 = min(col + cols, size(iimg,2));

    % Get the values at the cornes of the box integral (fast 1D index look up)
    sx=size(iimg,1);
    A = iimg(max(r1+(c1-1)*sx,1));
    B = iimg(max(r1+(c2-1)*sx,1));
    C = iimg(max(r2+(c1-1)*sx,1));
    D = iimg(max(r2+(c2-1)*sx,1));

    % If coordinates are outside at the top or left, the value must be zero
    A((r1<1)|(c1<1))=0;
    B((r1<1)|(c2<1))=0;
    C((r2<1)|(c1<1))=0;
    D((r2<1)|(c2<1))=0;

    % Minimum value of the integral is zero
    rectSum=max(0, A - B - C + D);
end

