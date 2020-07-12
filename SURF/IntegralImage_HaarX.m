function resX=IntegralImage_HaarX(row, column, size, img)
% Tinh Haar-wavelet responses theo phuong X
    resX= Calculate_Sum_Area(row-size/2,column, size, size / 2, img)...
        - Calculate_Sum_Area(row - size / 2, column - size / 2, size, size / 2, img);
end