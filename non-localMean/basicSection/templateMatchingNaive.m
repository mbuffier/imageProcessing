function [offsetsRows, offsetsCols, distances] = templateMatchingNaive(row, col, img,patchSize, searchWindowSize)

% row and col are the coordonnee of the pixel I want to test 
% we will return the distances in function of the offset in rows and cols

% to compute the patches
patchShift = floor(patchSize/2) ;
windowShift = floor(searchWindowSize/2) ;

% we deals with the borders
img = padarray(img, [patchShift,patchShift], 'replicate') ; 
img = padarray(img, [windowShift,windowShift]) ; 

% we extract the center patch and the windowSearch 
% position pixel is (row+patchShift+windowShift ,
%                    col+patchShift+windowShift)
center_patch = img(row+windowShift:row+2*patchShift+windowShift, col+windowShift:col+2*patchShift+windowShift) ;
windowSearch = img(row:row+2*patchShift+2*windowShift,col:col+2*patchShift+2*windowShift) ;


% initialization of the parameters
offseti = -windowShift ;
offsetj = -windowShift ;
index = 1;
offsetsRows = zeros(searchWindowSize*searchWindowSize,1);
offsetsCols = zeros(searchWindowSize*searchWindowSize,1);
distances = zeros(searchWindowSize*searchWindowSize, 1);

% go over each pixel in the search window
for i=1+patchShift:searchWindowSize+patchShift
    for j=1+patchShift:searchWindowSize+patchShift
        % extract the current patch 
        current_patch = windowSearch(i-patchShift:i+patchShift , j-patchShift:j+patchShift) ;
        
        % compute the SSD
        ssd = (current_patch-center_patch).^2 ;   
        dist = sum(ssd(:)) ;
        
        % Store the values 
        offsetsRows(index,1) = offseti ;
        offsetsCols(index,1) = offsetj ;
        distances(index,1) = dist ;
        
        index = index+1 ;
        offsetj = offsetj +1 ;
    end
    offsetj =  -windowShift ;
    offseti=offseti+1;
end

end