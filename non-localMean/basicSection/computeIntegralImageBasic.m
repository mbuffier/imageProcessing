function [ii] = computeIntegralImageBasic(image)

[M, N] = size(image) ;
ii = zeros(M+1,N+1,'double');
S = zeros(M+1,N+1) ;

% to use the same formula for all the image
image = padarray(image, [1, 1], 'pre') ;
numRow = floor(M/4)*4 ;

% we go throught the image 4 rows at a time
for i=2:4:numRow+1
    for j=2:N+1 % for each col each time
        S(i,j) = image(i,j) + S(i,j-1) ;
        S(i+1,j) = image(i+1,j) + S(i+1,j-1) ;
        S(i+2,j) = image(i+2,j) + S(i+2,j-1) ;
        S(i+3,j) = image(i+3,j) + S(i+3,j-1) ;
        
        ii(i,j) = ii(i-1,j)+S(i,j) ;
        ii(i+1,j) = ii(i-1,j)+S(i,j)+S(i+1,j) ;
        ii(i+2,j) = ii(i+1,j)+S(i+2,j) ;
        ii(i+3,j) = ii(i+1,j)+S(i+2,j)+S(i+3,j) ;
    end
end

% as the image might not have a number of row which divides by 4, we add
% the remaining pixels
rowRemain = mod(M,4) ;
if rowRemain == 1
    for j=2:N+1
        S(numRow+2,j) = image(numRow+2,j) + S(numRow+2,j-1) ;
        ii(numRow+2,j) = ii(numRow+1,j)+S(numRow+2,j) ;
    end
elseif rowRemain == 2
    for j=2:N+1
        S(numRow+2,j) = image(numRow+2,j) + S(numRow+2,j-1) ;
        S(numRow+3,j) = image(numRow+3,j) + S(numRow+3,j-1) ;

        ii(numRow+2,j) = ii(numRow+1,j)+S(numRow+2,j) ;
        ii(numRow+3,j) = ii(numRow+1,j)+S(numRow+2,j)+S(numRow+3,j) ;
    end
elseif rowRemain == 3
    for j=3:N+1
        S(numRow+2,j) = image(numRow+2,j) + S(numRow+2,j-1) ;
        S(numRow+3,j) = image(numRow+3,j) + S(numRow+3,j-1) ;
        S(numRow+4,j) = image(numRow+4,j) + S(numRow+4,j-1) ;

        ii(numRow+2,j) = ii(numRow+1,j)+S(numRow+2,j) ;
        ii(numRow+3,j) = ii(numRow+1,j)+S(numRow+2,j)+S(numRow+3,j) ;
        ii(numRow+3,j) = ii(numRow+4,j)+S(numRow+4,j) ;
    end
end

% remove the added first row and col of zero
ii = ii(2:end,2:end) ;
end