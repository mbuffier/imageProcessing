% ********************************* For image 1 : Alley *****************
% set the parameters 
patchSize = 3;
sigma = 20; % standard deviation (different for each image!)
h = 0.55; %decay parameter
windowSize = 21;

% read the image 
imageNoisy = imread('../images/alleyNoisy_sigma20.png') ;
imageReference = imread('../images/alleyReference.png');

% % ********************************* For image 2 : Town *****************
% % set the parameters 
% patchSize = 3;
% sigma = 5; % standard deviation (different for each image!)
% h = 0.55; %decay parameter
% windowSize = 21;
% 
% % read the image 
% imageNoisy = imread('../images/townNoisy_sigma5.png') ;
% imageReference = imread('../images/townReference.png');
% % 
% % % ********************************* For image 3 : Trees *****************
% % % set the parameters 
% % patchSize = 3;
% % sigma = 10; % standard deviation (different for each image!)
% % h = 0.55; %decay parameter
% % windowSize = 21;
% % 
% % % read the image 
% % imageNoisy = imread('../images/treesNoisy_sigma10.png') ;
% % imageReference = imread('../images/treesReference.png');
% 
% 
% % ********************************* For all images *****************
% 
% % apply the nonLocalMean to each channel :
imageNoisy = double(imageNoisy) ;

imageNoisyR = imageNoisy(:,:,1) ;
imageNoisyG = imageNoisy(:,:,2) ;
imageNoisyB = imageNoisy(:,:,3) ;

filteredR = nonLocalMeans(imageNoisyR, sigma, h, patchSize, windowSize);
filteredG = nonLocalMeans(imageNoisyG, sigma, h, patchSize, windowSize);
filteredB = nonLocalMeans(imageNoisyB, sigma, h, patchSize, windowSize);

% reconstruct the image
filtered = cat(3, filteredR, filteredG,filteredB) ;

% show the results
imageNoisy = uint8(imageNoisy) ;

fig1 = figure('name', 'NL-Means Denoised Image');
set(fig1, 'Position', [0 0 1000 700]);
subplot(2,2,1),
imshow(imageReference), title('Image Reference');
subplot(2,2,2),
imshow(imageNoisy), title('Image noisy');
subplot(2,2,3),
imshow(filtered), title('Image filtered');

%Show the difference image : choose the red channel
diff_image = zeros(size(filtered)) ;
diff_image(:,:,1) = abs(imageNoisy(:,:,1) - filtered(:,:,1));
diff_image(:,:,2) = abs(imageNoisy(:,:,2) - filtered(:,:,2));
diff_image(:,:,3) = abs(imageNoisy(:,:,3) - filtered(:,:,3));

subplot(2,2,4),
imshow(diff_image),title('Difference image');

saveas(gcf, 'image3', 'jpg'); 

%Print some statistics ((Peak) Signal-To-Noise Ratio)
disp('For Noisy Input');
[peakSNR, SNR] = psnr(imageNoisy, imageReference);
disp(['SNR: ', num2str(SNR, 10), '; PSNR: ', num2str(peakSNR, 10)]);

disp('For Denoised Result');
[peakSNR, SNR] = psnr(filtered, imageReference);
disp(['SNR: ', num2str(SNR, 10), '; PSNR: ', num2str(peakSNR, 10)]);

%*************************** Testing parameters : windowSize ***************************
% set the parameters 
% patchSize = 3;
% sigma = 20; % standard deviation (different for each image!)
% h = 0.55; %decay parameter
% windowSize1 = 15;
% windowSize2 = 35;
% windowSize3 = 21;
% 
% % read the image 
% imageNoisy = imread('../images/alleyNoisy_sigma20.png') ;
% imageReference = imread('../images/alleyReference.png');
% 
% % apply the nonLocalMean to each channel :
% imageNoisy = double(imageNoisy) ;
% imageNoisyR = imageNoisy(:,:,1) ;
% imageNoisyG = imageNoisy(:,:,2) ;
% imageNoisyB = imageNoisy(:,:,3) ;
% 
% filteredR1 = nonLocalMeans(imageNoisyR, sigma, h, patchSize, windowSize1);
% filteredG1 = nonLocalMeans(imageNoisyG, sigma, h, patchSize, windowSize1);
% filteredB1 = nonLocalMeans(imageNoisyB, sigma, h, patchSize, windowSize1);
% 
% % reconstruct the image
% filtered1 = cat(3, filteredR1, filteredG1,filteredB1) ;
% 
% filteredR2 = nonLocalMeans(imageNoisyR, sigma, h, patchSize, windowSize2);
% filteredG2 = nonLocalMeans(imageNoisyG, sigma, h, patchSize, windowSize2);
% filteredB2 = nonLocalMeans(imageNoisyB, sigma, h, patchSize, windowSize2);
% 
% % reconstruct the image
% filtered2 = cat(3, filteredR2, filteredG2,filteredB2) ;
% 
% filteredR3 = nonLocalMeans(imageNoisyR, sigma, h, patchSize, windowSize3);
% filteredG3 = nonLocalMeans(imageNoisyG, sigma, h, patchSize, windowSize3);
% filteredB3 = nonLocalMeans(imageNoisyB, sigma, h, patchSize, windowSize3);
% 
% % reconstruct the image
% filtered3 = cat(3, filteredR3, filteredG3,filteredB3) ;
% imageNoisy = uint8(imageNoisy) ;
% 
% fig1 = figure('name', 'Window size test');
% set(fig1, 'Position', [0 0 1000 1000]);
% subplot(2,2,1),
% imshow(imageNoisy), title('Image noisy');
% subplot(2,2,2),
% imshow(filtered1), title('Window size = 15');
% subplot(2,2,3),
% imshow(filtered2), title('Window size = 35');
% subplot(2,2,4),
% imshow(filtered3), title('Window size = 21');
% 
% saveas(gcf, 'windowTest', 'jpg'); 
% 
% % %Print some statistics ((Peak) Signal-To-Noise Ratio)
% disp('For WS = 15');
% [peakSNR, SNR] = psnr(filtered1, imageReference);
% disp(['SNR: ', num2str(SNR, 10), '; PSNR: ', num2str(peakSNR, 10)]);
% 
% disp('For WS = 35');
% [peakSNR, SNR] = psnr(filtered2, imageReference);
% disp(['SNR: ', num2str(SNR, 10), '; PSNR: ', num2str(peakSNR, 10)]);
% 
% disp('For WS = 21');
% [peakSNR, SNR] = psnr(filtered3, imageReference);
% disp(['SNR: ', num2str(SNR, 10), '; PSNR: ', num2str(peakSNR, 10)]);
%*************************** Testing parameters : patchSize ***************************
% set the parameters 
% patchSize1 = 3;
% patchSize2 = 5;
% patchSize3 = 7;
% sigma = 20; % standard deviation (different for each image!)
% h = 0.55; %decay parameter
% windowSize = 15;
% 
% % read the image 
% imageNoisy = imread('../images/alleyNoisy_sigma20.png') ;
% imageReference = imread('../images/alleyReference.png');
% 
% % apply the nonLocalMean to each channel :
% imageNoisy = double(imageNoisy) ;
% imageNoisyR = imageNoisy(:,:,1) ;
% imageNoisyG = imageNoisy(:,:,2) ;
% imageNoisyB = imageNoisy(:,:,3) ;
% 
% filteredR1 = nonLocalMeans(imageNoisyR, sigma, h, patchSize1, windowSize);
% filteredG1 = nonLocalMeans(imageNoisyG, sigma, h, patchSize1, windowSize);
% filteredB1 = nonLocalMeans(imageNoisyB, sigma, h, patchSize1, windowSize);
% 
% % reconstruct the image
% filtered1 = cat(3, filteredR1, filteredG1,filteredB1) ;
% 
% filteredR2 = nonLocalMeans(imageNoisyR, sigma, h, patchSize2, windowSize);
% filteredG2 = nonLocalMeans(imageNoisyG, sigma, h, patchSize2, windowSize);
% filteredB2 = nonLocalMeans(imageNoisyB, sigma, h, patchSize2, windowSize);
% 
% % reconstruct the image
% filtered2 = cat(3, filteredR2, filteredG2,filteredB2) ;
% 
% filteredR3 = nonLocalMeans(imageNoisyR, sigma, h, patchSize3, windowSize);
% filteredG3 = nonLocalMeans(imageNoisyG, sigma, h, patchSize3, windowSize);
% filteredB3 = nonLocalMeans(imageNoisyB, sigma, h, patchSize3, windowSize);
% 
% % reconstruct the image
% filtered3 = cat(3, filteredR3, filteredG3,filteredB3) ;
% imageNoisy = uint8(imageNoisy) ;
% 
% fig1 = figure('name', 'Window size test');
% set(fig1, 'Position', [0 0 1000 1000]);
% subplot(2,2,1),
% imshow(imageNoisy), title('Image noisy');
% subplot(2,2,2),
% imshow(filtered1), title('Patch size = 3');
% subplot(2,2,3),
% imshow(filtered2), title('Patch size = 5');
% subplot(2,2,4),
% imshow(filtered3), title('Patch size = 7');
% 
% saveas(gcf, 'patchTest', 'jpg'); 
% 
% %*************************** Testing parameters : h value ***************************
% set the parameters 
% patchSize = 3;
% sigma = 20; % standard deviation (different for each image!)
% h1 = 0.55; 
% h2 = 0.40; 
% h3 = 0.35; 
% windowSize = 15;
% 
% % read the image 
% imageNoisy = imread('../images/alleyNoisy_sigma20.png') ;
% imageReference = imread('../images/alleyReference.png');
% 
% % apply the nonLocalMean to each channel :
% imageNoisy = double(imageNoisy) ;
% imageNoisyR = imageNoisy(:,:,1) ;
% imageNoisyG = imageNoisy(:,:,2) ;
% imageNoisyB = imageNoisy(:,:,3) ;
% 
% filteredR1 = nonLocalMeans(imageNoisyR, sigma, h1, patchSize, windowSize);
% filteredG1 = nonLocalMeans(imageNoisyG, sigma, h1, patchSize, windowSize);
% filteredB1 = nonLocalMeans(imageNoisyB, sigma, h1, patchSize, windowSize);
% 
% % reconstruct the image
% filtered1 = cat(3, filteredR1, filteredG1,filteredB1) ;
% 
% filteredR2 = nonLocalMeans(imageNoisyR, sigma, h2, patchSize, windowSize);
% filteredG2 = nonLocalMeans(imageNoisyG, sigma, h2, patchSize, windowSize);
% filteredB2 = nonLocalMeans(imageNoisyB, sigma, h2, patchSize, windowSize);
% 
% % reconstruct the image
% filtered2 = cat(3, filteredR2, filteredG2,filteredB2) ;
% 
% filteredR3 = nonLocalMeans(imageNoisyR, sigma, h3, patchSize, windowSize);
% filteredG3 = nonLocalMeans(imageNoisyG, sigma, h3, patchSize, windowSize);
% filteredB3 = nonLocalMeans(imageNoisyB, sigma, h3, patchSize, windowSize);
% 
% % reconstruct the image
% filtered3 = cat(3, filteredR3, filteredG3,filteredB3) ;
% imageNoisy = uint8(imageNoisy) ;
% 
% fig1 = figure('name', 'Window size test');
% set(fig1, 'Position', [0 0 1000 1000]);
% subplot(2,2,1),
% imshow(imageNoisy), title('Image noisy');
% subplot(2,2,2),
% imshow(filtered1), title('h=0.55');
% subplot(2,2,3),
% imshow(filtered2), title('h=0.4');
% subplot(2,2,4),
% imshow(filtered3), title('h=0.35');
% 
% saveas(gcf, 'hTest', 'jpg'); 