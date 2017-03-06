clear all ;

A = imread('girlFace.jpg');

[M,N] = size(A);
fig1 = figure('position', [0, 0, 1400, 400]) ; % plot the original image to compare
subplot(2,6,3)
imshow(A);
title('Image origin') ;
k=7 ;

for i = 35:10:85 % we plot results for different threshold values
    B = threshold(A,i) ;
    
    subplot(2,6,k)
    imshow(B) ;
    title(['Threshold = ' num2str(i) ]);
    k=k+1 ;
    
end

saveas(gcf, 'Q2C_Result', 'jpg'); 

%BW = roipoly(A) ; % I create my ground truth segmentation using roipoly, the result is in 'BinaryThreshold.jpg'

fig2 = figure ; % we plot the binary threshold I obtained
imshow('BinaryThreshold.jpg') , title('Binary threshold obtained using roipoly') ;

