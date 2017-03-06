function r = task4_ImportG

close all;
% choose which images to use 
% img1 = double(imread('images/monkey.jpeg'))/255 ;
% img2 = double(imread('images/sky.png'))/255 ;
% img2 = imresize(img2,0.5) ;

% img1 = double(imread('images/boat.jpeg'))/255 ;
% img2 = double(imread('images/space.jpeg'))/255 ;
% img2 = imresize(img2,0.7) ;

% img1 = double(imread('images/whale.jpeg'))/255 ;
% img2 = double(imread('images/see.jpeg'))/255 ;
% img2 = imresize(img2,0.9) ;

% select the region in the first one
[BW1, xi, yi] = roipoly(img1) ;
xi = xi - min(xi) ;
yi = yi - min(yi) ;

% choose where to import it in the second one
[c,r,~] = impixel(img2) ;
xi = xi+c ;
yi = yi+r ;

% create the mask for the second image 
BW2 = roipoly(img2, xi, yi) ;

% compute a color chanel for each images 
img1_r = img1(:,:,1) ;
img1_g = img1(:,:,2) ;
img1_b = img1(:,:,3) ;

img2_r = img2(:,:,1) ;
img2_g = img2(:,:,2) ;
img2_b = img2(:,:,3) ;

% apply the function for each color chanel according to the masks 
result_r = importG(img1_r, img2_r, BW1,BW2) ;
result_g = importG(img1_g, img2_g, BW1,BW2) ;
result_b = importG(img1_b, img2_b, BW1,BW2) ;

% reconstruct the result 
result = cat(3,result_r,result_g,result_b) ;

% plot the result and save it 
imshow(result) ;
saveas(gcf, 'task4_IG_result.jpg') ;
end

function result = importG(img1, img2, BW1, BW2)

% creat the new image
[M2, N2] = size(img2) ;
mask_invert2 = double(ones(M2,N2)-BW2) ; % create the inverted mask
img_new = img2.*mask_invert2 ; % the image which the region removed

% compute a vector for each pixel p in the region with the sum of v(pq) =
% gp-gq for each q in Np
v_field = computeV(img1, BW1) ;

result = importGradient(img2,v_field, BW2, img_new) ;

end


function result = importGradient(img, v_field, mask, newImg)

[M,N] = size(img) ;
boundaries_img = zeros(M,N) ;
index = 0 ;
mask = double(mask) ;
mask_big = padarray(mask, [1,1],'replicate') ;

for i = 2:M+1
    for j = 2:N+1
        % create the boundaries image
        patch = mask_big(i-1:i+1,j-1:j+1) ;
        result = isBoundary(patch) ;
        if result == 1
            boundaries_img(i-1,j-1) = 1 ; % compute the boundaries
        end
        
        % create the list of pixel in omega
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

for i = 2:M+1
    for j = 2:N+1
        if mask(i,j) > 0
            index = mask(i,j) ; % position of the pixel in omega
            is(elm_A,1) = index ;
            js(elm_A,1) = index ;
            s(elm_A,1) = 4 ;
            sumBound = v_field(1,index) ;
            
            elm_A = elm_A + 1 ;
            
            % matrix A
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

is = is(1:elm_A-1,:) ;
js = js(1:elm_A-1,:) ;
s = s(1:elm_A-1,:) ;

A = sparse(is,js,s,num_omega,num_omega) ;
X = A\B ;

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
