function [patchSum] = evaluateIntegralImageBasic(ii, row, col, patchSize)

patchShift = floor(patchSize/2) ;

L1 = ii(row, col) ;
L2 = ii(row, col+2*patchShift+1) ;
L3 = ii(row+2*patchShift+1, col+2*patchShift+1) ;
L4 = ii(row+2*patchShift+1, col) ;

patchSum = L3-L2-L4+L1 ;
end