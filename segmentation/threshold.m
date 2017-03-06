function B = threshold(img, k)
% img is the original image we want to segment
% k is the threshold we choose
% B is the binary result of the segmentation 

[M, N] = size(img) ;

B = zeros(M,N, 'uint8') ;

for i=1:M
    for j=1:N
        if(img(i,j) >= k) % if the pixel intensity value is above the threshold, we set his value to 255
            B(i,j) = 255 ;
        else % if not, the pixel will be black
            B(i,j) = 0;
        end
    end
end

B = uint8(B) ;

end