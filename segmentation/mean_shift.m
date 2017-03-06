imageOrigin = imread('girlFace.jpg') ;

fig1 = figure('position', [0, 0, 1000, 500]) ;
subplot(2,3,2)
imshow(imageOrigin);
title('Original Image') ;

for i = 1:2:5 % we will compare the results for different size of the window
    windowSize = i*10 ;
    [numberClusters B] = meanShift(imageOrigin,windowSize) ;
    
    subplot(2,3,3+round(i/2))
    imshow(B,'Border','tight') ;
    title(['Result with a window of ' num2str(i*10) ' which gives ' num2str(numberClusters) ' clusters']);

end

saveas(gcf, 'questionA2', 'jpg'); 
