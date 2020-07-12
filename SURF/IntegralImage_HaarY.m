function resY=IntegralImage_HaarY(row, column, size, img)
% Tinh Haar-wavelet responses theo phuong Y
    resY= Calculate_Sum_Area(row, column - size / 2, size / 2, size , img)...
        - Calculate_Sum_Area(row - size / 2, column - size / 2, size / 2, size , img);
end 
