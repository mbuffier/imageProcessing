function r = task3_ImportG

close all;

% choose which images to use 
img1 = double(rgb2gray(imread('images/monkey.jpeg')))/255 ;
img2 = double(rgb2gray(imread('images/sky.png')))/255 ;
img2 = imresize(img2,0.5) ;

% img1 = double(rgb2gray(imread('images/boat.jpeg')))/255 ;
% img2 = double(rgb2gray(imread('images/space.jpeg')))/255 ;
% img2 = imresize(img2,0.7) ;

% img1 = double(rgb2gray(imread('images/whale.jpeg')))/255 ;
% img2 = double(rgb2gray(imread('images/see.jpeg')))/255 ;
% img2 = imresize(img2,0.9) ;

% select the region in the first one
[BW1, xi, yi] = roipoly(img1) ;
xi = xi - min(xi) ;
yi = yi - min(yi) ;

% choose where to import it in the second one
[c,r,~] = impixel(img2) ;
xi = xi+c ;
yi = yi+r ;

% creat the new image
BW2 = roipoly(img2, xi, yi) ;
[M2, N2] = size(img2) ;
mask_invert2 = double(ones(M2,N2)-BW2) ; % create the inverted mask
img_new = img2.*mask_invert2 ; % the image which the region removed

% compute a vector for each pixel p in the region with the sum of v(pq) =
% gp-gq for each q in Np
v_field = computeV(img1, BW1) ;

% compute the result image
img2_result = importGradient(img2,v_field, BW2, img_new) ;

% plot the result
fig1 = figure,
set(fig1, 'Position', [0 0 1500 500]) ;
subplot(1,3,1),
imshow(img1) ;

subplot(1,3,2),
imshow(img2) ;

subplot(1,3,3),
imshow(img2_result) ;

saveas(gcf, 'task3_IG_result.jpg') ;
end


function result = importGradient(img, v_field, mask, newImg)

% initialization of the boundaries image and take care of the borders
[M,N] = size(img) ;
boundaries_img = zeros(M,N) ;
index = 0 ;
mask = double(mask) ;
mask_big = padarray(mask, [1,1],'replicate') ;

% go throught the image to number the pixel and create the border image
for i = 2:M+1
    for j = 2:N+1
        % create the boundaries image
        patch = mask_big(i-1:i+1,j-1:j+1) ;
        result = isBoundary(patch) ;
        if result == 1
            boundaries_img(i-1,j-1) = 1 ; % compute the boundaries
        end
        
        % create the numbered list of pixel in omega
        if mask_big(i,j) == 1
            mask(i-1,j-1) = mask(i-1,j-1) + index ;
            index = index+1 ;
        end
    end
end

num_omega = max(mask(:)) ;

% to create the sparse matrix
is = zeros(5*num_omega,1) ;
js = zeros(5*num_omega,1) ;
s = zeros(5*num_omega,1) ;
elm_A = 1 ;
B = zeros(num_omega,1) ;
mask = padarray(mask, [1,1]) ;
boundaries_img = padarray(boundaries_img, [1,1]) ;

% go over all the pixel and in the boucle only if it's in the region to
% fill A
for i = 2:M+1
    for j = 2:N+1
        if mask(i,j) > 0
            index = mask(i,j) ; % position of the pixel in omega
            
            % fill the diagonal of A
            is(elm_A,1) = index ;
            js(elm_A,1) = index ;
            s(elm_A,1) = 4 ;
            elm_A = elm_A + 1 ;
            
            % fill the matrix A
            if mask(i-1,j) > 0
                is(elm_A,1) = index ;
                js(elm_A,1) = mask(i-1,j) ;
                s(elm_A,1) = -1 ;
                elm_A = elm_A + 1 ;
            end
            
            if mask(i,j-1) > 0
                is(elm_A,1) = index ;
                js(elm_A,1) = mask(i,j-1) ;
                s(elm_A,1) = -1 ;
                elm_A = elm_A + 1 ;
            end
            
            if mask(i,j+1) > 0
                is(elm_A,1) = index ;
                js(elm_A,1) = mask(i,j+1) ;
                s(elm_A,1) = -1 ;
                elm_A = elm_A + 1 ;
            end
            
            if mask(i+1,j) > 0
                is(elm_A,1) = index ;
                js(elm_A,1) = mask(i+1,j) ;
                s(elm_A,1) = -1 ;
                elm_A = elm_A + 1 ;
            end
            
            % vector B
            % add for pixel the value of sum vpq computed before
            sumBound = v_field(1,index) ;
            if boundaries_img(i-1,j) == 1
                sumBound = sumBound + img(i-2,j-1)  ;
            end
            if boundaries_img(i,j-1) == 1
                sumBound = sumBound + img(i-1,j-2) ;
            end
            if boundaries_img(i,j+1) == 1
                sumBound = sumBound + img(i-1,j) ;
            end
            if boundaries_img(i+1,j) == 1
                sumBound = sumBound + img(i,j-1) ;
            end
            B(index) = sumBound ;
        end
    end
end

% only keep the filled indices
is = is(1:elm_A-1,:) ;
js = js(1:elm_A-1,:) ;
s = s(1:elm_A-1,:) ;

%compute the results
A = sparse(is,js,s,num_omega,num_omega) ;
X = A\B ;

% fill in the result 
img_new = padarray(newImg, [1,1]) ;
for i=2:M-1
    for j = 2:N-1
        if mask(i,j)>0
            img_new(i,j) = X(mask(i,j),1) ;
        end
    end
end

result = img_new(2:M+1, 2:N+1) ;
end


function result = isBoundary(patch)
result = 0 ;

% 4 connectivity
test1 = patch(1,2) + patch(2,1)+patch(2,3)+patch(3,2) ;
test2 = patch(2,2) ;
if test2 == 0 && test1 > 0
    result = 1 ;
end
end

function result = computeV(img, BW1)

% apply a Kernel to the image at each pixel 
K = [0 -1 0 ; -1 4 -1 ; 0 -1 0] ;
result_conv = conv2(img, K,'same');

% initialization of the vector result 
[M,N] = size(BW1);
result = zeros(1, M*N) ;
index=1 ;

% go throught the image and add the value to the vector if it's in the mask
for i=1:M
    for j=1:N
        if BW1(i,j) == 1
            result(index) =  result_conv(i,j) ;
            index = index+1 ;
        end
    end
end
result = result(1,1:index-1) ;
end
