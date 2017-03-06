clear all ;

% we take the original image and the groundTruth to compute the ROC curve
groundTruth = imread('BinaryThreshold.jpg') ;
originImage = imread('girlFace.jpg');

[M, N] = size(originImage) ;
tp = 0; % number of true positive
tn = 0 ; % number of true negative
fp = 0 ; % number of false positive
fn = 0 ; % number of false negative

numberOfThreshold = 256 ; %the number of threshold we will use to plot the ROC curve
X = zeros(1,numberOfThreshold) ; % contain the false positive rate
Y = zeros(1,numberOfThreshold) ; % contain the true positive rate

for i= 1:numberOfThreshold
    A = threshold(originImage,i) ;
    for m=1:M
        for n=1:N
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
    X(1, i) = fp/(tn+fp) ; % false positive rate
    Y(1,i) = tp/(tp+fn) ; %true positive rate
    fp = 0;
    fn = 0 ;
    tp =0 ;
    tn = 0 ;
end
% save('ROC_Threshold','X','Y') ; % used in advanced section

figure,
plot(X,Y, 'r-','LineWidth',2),
title('ROC curve for the girl face image using the threshold algorithm') ;
saveas(gcf,'Q3C_ROC','jpg') ;

% we use the findThreshold algorithm to find the best threshold (the one
% given the value closest to (0,1)

thres = findThreshold(X,Y) 

fig3 = figure('position', [0, 0, 700, 300]) ;
subplot(1,3,1) 
imshow(originImage), title('Original Image') ;

subplot(1,3,2)
imshow(groundTruth), title('Ground Truth') ;

subplot(1,3,3) 
imshow(threshold(originImage, thres)), title('Threshold obtained using the algorithm');

saveas(gcf, 'Q3C_Result', 'jpg'); 

