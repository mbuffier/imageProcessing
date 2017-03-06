function [ii] = computeIntegralImage(image,patchShift)

[M, N] = size(image) ;
ii = zeros(M+1,N+1,'double');

S= zeros(M+1,N+1) ;
image_big = padarray(image, [1, 1], 'pre') ;
numRow = floor(M/4)*4 ;

for i=2:4:numRow+1
    for j=2:N+1
        S(i,j) = image_big(i,j) + S(i,j-1) ;
        S(i+1,j) = image_big(i+1,j) + S(i+1,j-1) ;
        S(i+2,j) = image_big(i+2,j) + S(i+2,j-1) ;
        S(i+3,j) = image_big(i+3,j) + S(i+3,j-1) ;
        
        ii(i,j) = ii(i-1,j)+S(i,j) ;
        ii(i+1,j) = ii(i-1,j)+S(i,j)+S(i+1,j) ;
        ii(i+2,j) = ii(i+1,j)+S(i+2,j) ;
        ii(i+3,j) = ii(i+1,j)+S(i+2,j)+S(i+3,j) ;
    end
end

rowRemain = mod(M,4) ;
if rowRemain == 1
    for j=2:N+1
        S(numRow+2,j) = image_big(numRow+2,j) + S(numRow+2,j-1) ;
        ii(numRow+2,j) = ii(numRow+1,j)+S(numRow+2,j) ;
    end
elseif rowRemain == 2
    for j=2:N+1
        S(numRow+2,j) = image_big(numRow+2,j) + S(numRow+2,j-1) ;
        S(numRow+3,j) = image_big(numRow+3,j) + S(numRow+3,j-1) ;

        ii(numRow+2,j) = ii(numRow+1,j)+S(numRow+2,j) ;
        ii(numRow+3,j) = ii(numRow+1,j)+S(numRow+2,j)+S(numRow+3,j) ;
    end
elseif rowRemain == 3
    for j=3:N+1
        S(numRow+2,j) = image_big(numRow+2,j) + S(numRow+2,j-1) ;
        S(numRow+3,j) = image_big(numRow+3,j) + S(numRow+3,j-1) ;
        S(numRow+4,j) = image_big(numRow+4,j) + S(numRow+4,j-1) ;

        ii(numRow+2,j) = ii(numRow+1,j)+S(numRow+2,j) ;
        ii(numRow+3,j) = ii(numRow+1,j)+S(numRow+2,j)+S(numRow+3,j) ;
        ii(numRow+3,j) = ii(numRow+4,j)+S(numRow+4,j) ;
    end
end

ii = ii(2:end,2:end) ;

% to deal with the bordel after 
ii = padarray(ii, [patchShift+1, patchShift+1], 'pre') ;
ii = padarray(ii, [patchShift+1, patchShift+1], 'replicate', 'post') ;

end