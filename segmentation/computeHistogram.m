clear all ;

A = imread('girlface.jpg');
B = imread('test.jpg');

% for both images we plot the image and their histogram
figure ;
subplot(2,2,1)
imshow(A) 
subplot(2,2,2)
imshow(B) 

subplot(2,2,3)
histogram(A)
subplot(2,2,4)
histogram(B)

saveas(gcf, 'Q1C_result', 'jpg'); % save the result

