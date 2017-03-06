function distances = templateMatchingIntegralImage(row, col, ...
    img, patchSize, searchWindowSize)

% row and col are the coordonnee of the pixel I want to test
% we will return the distances in function of the offset in rows and cols
windowShift = floor(searchWindowSize/2) ;
patchShift = floor(patchSize/2) ;

[M, N] = size(img) ;

% initialization
index = 1 ;
distances = zeros(searchWindowSize*searchWindowSize, 1);

% image used to compute the shift image
img_big = padarray(img, [windowShift,windowShift], 'replicate') ;
%timeIntegralImages = 0; % time to compute the images

%go over the integral images to compute the sum of SSD for this patchSize
for i=1:searchWindowSize
    for j = 1:searchWindowSize
        
        % extract the shift window
        img_shift = img_big(i:i+M-1, j:j+N-1);
  
        % compute the SSD image for this offset
        ssd_image = (img_shift-img).^2 ;
        
        %tic
        % compute the integral image 
        integral_im = computeIntegralImageBasic(ssd_image) ;
         % we add zeros and replicate values to be able to have value for pixel at the borders
        integral_im = padarray(integral_im, [patchShift+1, patchShift+1],'pre') ;
        integral_im = padarray(integral_im, [patchShift+1, patchShift+1],'replicate','post') ;

        %timeIntegralImages = timeIntegralImages + toc ;
       
        % evaluate the distance
        dist = evaluateIntegralImageBasic(integral_im, row, col, patchSize) ;
        
        % store the result
        distances(index,1) = dist ;
        index = index+1 ;
    end
end
%timeIntegralImages
end