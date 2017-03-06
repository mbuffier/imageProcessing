%% Some parameters to set - make sure that your code works at image borders!
clear all ;
% Row and column of the pixel for which we wish to find all similar patches 
% NOTE: For this section, we pick only one patch
row = 50;
col = 50;

% Patchsize - make sure your code works for different values
patchSize = 7 ;

% Search window size - make sure your code works for different values
searchWindowSize = 21 ;


%% Implementation of work required in your basic section-------------------

% TODO - Load Image
image = imread('../images/alleyReference.png') ;
[M,N,~] = size(image) ;
image = rgb2gray(image) ;
image = double(image)/255 ;

% TODO - Fill out this function
image_ii = computeIntegralImageBasic(image);
norm_image_ii = image_ii/max(image_ii(:)) ;

% TODO - Display the normalised Integral Image
figure('name', 'Normalised Integral Image'), 
imshow(norm_image_ii) ;


tic
[offsetsRows_naive, offsetsCols_naive, distances_naive] = templateMatchingNaive(row, col,image, ...
patchSize, searchWindowSize);
toc

tic
distances_ii = ...
templateMatchingIntegralImage(row, col, image, patchSize, searchWindowSize) ;
toc
% 
% %% Let's print out your results--------------------------------------------

% NOTE: Your results for the naive and the integral image method should be
% the same!
for i=1:length(offsetsRows_naive)
    disp(['offset rows: ', num2str(offsetsRows_naive(i)), '; offset cols: ',...
        num2str(offsetsCols_naive(i)), '; Naive Distance = ', num2str(distances_naive(i),10),...
        '; Integral Im Distance = ', num2str(distances_ii(i),10)]);
end