clear all ;

imageOrigin = imread('girlFace.jpg') ;

%choose_pixel_pos = impixelinfo;
% I choosed the pixel position for the seed thanks to impixelinfo
% I took a pixel on the forehead as a seed, so the region of the skin grows from there
seed = [182 104] ;
figure, 
imshow(imageOrigin) ;
hold on ;
 plot(182,104,'r+','MarkerSize',15) ;
hold off ;

saveas(gcf, 'Q1A_SeedImage', 'jpg'); 


groundTruth = imread('BinaryThreshold.jpg') ;

[M, N] = size(imageOrigin) ;

% we plot an ROC curve to find the best value of the threshold

tp = 0; % number of true positive
tn = 0 ; % number of true negative
fp = 0 ; % number of false positive
fn = 0 ; % number of false negative

numberOfThreshold = 256 ; % the number of threshold we will use to plot the ROC curve
X_RG = zeros(1,numberOfThreshold) ; % will contain the false positive rate
Y_RG = zeros(1,numberOfThreshold) ; % will contain the true positive rate

for i= 1:numberOfThreshold
    A = regionGrowing(imageOrigin, seed,i) ;
    for m=1:M
        for n=1:N % for every pixel we look for the cluster it belongs to
            if(groundTruth(m,n) == 0 && A(m,n) ==0)
                tn = tn+1 ;
            elseif(groundTruth(m,n) == 0 && A(m,n) == 255)
                fp = fp + 1 ;
            elseif(groundTruth(m,n) == 255 && A(m,n) == 0)
                fn = fn +1 ;
            elseif(groundTruth(m,n) == 255 && A(m,n) == 255)
                tp = tp +1 ;
            end
        end
    end
    X_RG(1, i) = fp/(tn+fp) ; % false positive rate
    Y_RG(1,i) = tp/(tp+fn) ; %true positive rate
    fp = 0;
    fn = 0 ;
    tp =0 ;
    tn = 0 ;
end
load('ROC_Threshold.mat') ;

figure, % we plot the ROC curve for both algorithms on the same figure
title('ROC curves for the girlFace image using a region growing algorithm and the threshold ones'),
plot(X_RG,Y_RG, 'r-','LineWidth',2);
hold on
plot(X,Y, 'g-','LineWidth',2); legend('Region Growing') ;
hold off
saveas(gcf, 'Q1A_ROC', 'jpg'); 

thres = findThreshold(X_RG,Y_RG)  % use this function again to find the best threshold 

fig3 = figure ;
set(fig3, 'Position', [0 0 850 400]),
subplot(1,3,1) 
imshow(imageOrigin), title('Original Image') ;

subplot(1,3,2)
imshow(groundTruth), title('Ground Truth') ;

subplot(1,3,3) 
imshow(regionGrowing(imageOrigin, seed, thres)), title('Segmentation obtained using the region growing algorithm');

saveas(gcf, 'Q1A_Result', 'jpg'); 

% ***** Comparaison between threshold and segmentation *****

fig4 = figure ;
set(fig4, 'Position', [0 0 650 400]),

subplot(1,2,1)
imshow('threshold_result.jpg'), title('Threshold');

subplot(1,2,2)
imshow(regionGrowing(imageOrigin, seed, thres)), title('Segmentation obtained using the region growing algorithm') ;

saveas(gcf, 'Q1A_Comparaison', 'jpg'); 
