function [result] = nonLocalMeans(image, sigma, h, patchSize, windowSize)

% the result will be the denoised image after applying the algorithm
windowShift = floor(windowSize/2) ;
%deal with the borders
image_big = padarray(image, [windowShift,windowShift], 'replicate');
[M,N] = size(image) ;
result = zeros(M,N,'double') ;
patchShift = floor(patchSize/2) ;

% initialization of the cell of integral images
integralImages = cell(windowSize*windowSize,1) ;
index = 1 ;

% loop over all the possible shift
for i=1:windowSize
    for j = 1:windowSize
        % extract the shift window
        img_shift = image_big(i:i+M-1, j:j+N-1);
        
        % compute the SSD image for this offset
        ssd_image = (img_shift-image).^2 ;
        
        % compute the integral image
        integral_im = computeIntegralImage(ssd_image,patchShift) ;

        integralImages{index} = integral_im; % store it
        index = index+1 ;
    end
end

for i=1:M
    for j=1:N
        distances = zeros(windowSize*windowSize,1) ;
        for s=1:windowSize*windowSize
            % evaluate the distance
            distances(s,1) = evaluateIntegralImage(integralImages{s}, i, j, patchShift) ;
        end
        % put all the pixel in a row to optimize the computation 
        window = image_big(i:i+windowSize-1, j:j+windowSize-1) ;
        window = reshape(window.',[windowSize*windowSize,1]) ;
        
        % compute the weight 
        weights = computeWeighting(distances, h, sigma, patchSize) ;
        
        % Store the result for this pixel 
        result(i,j) =  sum(window.*weights)/sum(weights) ;
    end
end
result = uint8(result) ;
end