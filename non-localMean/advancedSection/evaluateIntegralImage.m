function [patchSum] = evaluateIntegralImage(ii, row, col, patchShift)

% This function calculate the sum over the patch centred at row, col
% of size patchSize of the integral image ii

% be careful of the indices because we had some rows and cols for borders
L1 = ii(row, col) ;
L2 = ii(row, col+2*patchShift+1) ;
L3 = ii(row+2*patchShift+1, col+2*patchShift+1) ;
L4 = ii(row+2*patchShift+1, col) ;

% store the distance for this pixel, this patchShift and this integral
% image
patchSum = L3-L2-L4+L1 ;
end