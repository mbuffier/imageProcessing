function r = task5

img_old = double(imread('images/MSM.jpeg'))/255 ;

% select the region in the first one
[BW, xi, yi] = roipoly(img_old) ;

% compute a color chanel for each images
img1_old_r = img_old(:,:,1) ;
img1_old_g = img_old(:,:,2) ;
img1_old_b = img_old(:,:,3) ;

% apply the function for each color chanel according to the masks
result_r = erase(img1_old_r, BW) ;
result_g = erase(img1_old_g,BW) ;
result_b = erase(img1_old_b,BW) ;

% reconstruct the result
result1 = cat(3,result_r,result_g,result_b) ;

% select the region in the other image

img2 = double(imread('images/eagle.jpeg'))/255 ;
img2 = imresize(img2,0.5) ;

[BW1, xi, yi] = roipoly(img2) ;
xi = xi - min(xi) ;
yi = yi - min(yi) ;

% choose where to import it in the second one
[c,r,~] = impixel(result1) ;
xi = xi+c ;
yi = yi+r ;

% create the mask for the second image 
BW2 = roipoly(result1, xi, yi) ;

% compute a color chanel for each images 
img1_r = img2(:,:,1) ;
img1_g = img2(:,:,2) ;
img1_b = img2(:,:,3) ;

img2_r = result1(:,:,1) ;
img2_g = result1(:,:,2) ;
img2_b = result1(:,:,3) ;

% apply the function for each color chanel according to the masks 
result_r = importG(img1_r, img2_r, BW1,BW2) ;
result_g = importG(img1_g, img2_g, BW1,BW2) ;
result_b = importG(img1_b, img2_b, BW1,BW2) ;

% reconstruct the result 
result2 = cat(3,result_r,result_g,result_b) ;

% plot the result and save it 
figure,
subplot(1,3,1), imshow(img_old) ;
subplot(1,3,2), imshow(img2) ;
subplot(1,3,3), imshow(result1) ;
saveas(gcf, 'result_task5.jpg') ;

figure,
imshow(result2) ;
saveas(gcf, 'result_task5_2.jpg') ;

end

function result = importG(img1, img2, BW1, BW2)

% creat the new image
[M2, N2] = size(img2) ;
mask_invert2 = double(ones(M2,N2)-BW2) ; % create the inverted mask
img_new = img2.*mask_invert2 ; % the image which the region removed

% compute a vector with a value for each pixel p in the region with the sum of v(pq) =
% dp-dq for each q in Np with dp-dq = max(gp-gq , fp-fq)
v_field = computeVecField(img1, BW1,img2, BW2) ;

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

% function which takes the maximum of the v field for each pixel in omega and compute the final vector
function result = computeVecField(img1, BW1,img2, BW2)
% compute a vector for each region of size 4*card(omega)
vecV1 = vectOmega(img1, BW1) ;
vecV2 = vectOmega(img2, BW2) ;

% only keep the highest value for each pixel in all directions
mask = abs(vecV2) > abs(vecV1) ;

% sum the result for each pixel
result = sum(mask.*vecV2+(ones(size(mask))-mask).*vecV1,1) ;
end

% for each image compute a M*N*4 vector with 4 values per pixel
% (corresponding to the 4 neighboors)
function result = vectOmega(img, mask)
[M,N] = size(img);

inter = zeros(M,N,4) ;

inter(:,:,1) = computeV(img, 1) ;
inter(:,:,2) = computeV(img, 2) ;
inter(:,:,3) = computeV(img, 3) ;
inter(:,:,4) = computeV(img, 4) ;

result = zeros(4,M*N) ;
index = 1 ;

% if the result is in the mask, we add it to the vector
for i=1:M
    for j=1:N
        if mask(i,j) == 1
            result(:,index) = reshape(inter(i,j,:), [4,1]) ;
            index = index+1 ;
        end
    end
end
result = result(:,1:index-1) ; % it's size is now 4*card(omega)
end

% compute an image with the difference between a pixel and its indexed
% neighboors for each pixel
function result = computeV(img, index)

if index == 1
    K = [0 -1 0 ; 0 1 0 ; 0 0 0] ;
elseif index ==2
    K = [0 0 0 ; 0 1 -1 ; 0 0 0] ;
elseif index == 3
    K = [0 0 0 ; 0 1 0 ; 0 -1 0] ;
elseif index == 4
    K = [0 0 0 ; -1 1 0 ; 0 0 0] ;
end

result = conv2(img, K, 'same') ;
end

function result = erase(img, BW)
[M,N] = size(img) ;
boundaries_img = zeros(M,N) ;
index = 0 ;
mask = double(BW) ;
mask_big = padarray(mask, [1,1],'replicate') ;

mask_invert = double(ones(M,N)-mask) ;
img_new = img.*mask_invert ; 

% go throught the image to number the pixel and create the border image
for i = 2:M+1
    for j = 2:N+1
        % create the boundaries image
        patch = mask_big(i-1:i+1,j-1:j+1) ; % extract a patch to see if it's in the border
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

% number of pixel in the region
num_omega = max(mask(:)) ;

% to create the sparse matrix A
is = zeros(5*num_omega,1) ;
js = zeros(5*num_omega,1) ;
s = zeros(5*num_omega,1) ;
elm_A = 1 ; % index to fill js, is and s
B = zeros(num_omega,1) ;
mask = padarray(mask, [1,1]) ;
boundaries_img = padarray(boundaries_img, [1,1]) ;

% go over all the pixel and in the boucle only if it's in the region to
% fill A
for i = 2:M+1
    for j = 2:N+1
        % in the region
        if mask(i,j) > 0
            index = mask(i,j) ; % number of the pixel in omega
            
            % fill the diagonal of A
            is(elm_A,1) = index ;
            js(elm_A,1) = index ;
            s(elm_A,1) = 4 ;
            elm_A = elm_A + 1 ;
            
            % fill matrix A
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
            
            % fill the vector B
            sumBound = 0 ;
            if boundaries_img(i-1,j) == 1
                sumBound = sumBound + img(i-2,j-1) ;
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

% construct A
A = sparse(is,js,s,num_omega,num_omega) ;

% look for the result X
X = A\B ;

% loop to fill the new image
img_new = padarray(img_new, [1,1]) ;
for i=2:M-1
    for j = 2:N-1
        if mask(i,j)>0
            img_new(i,j) = X(mask(i,j),1) ;
        end
    end
end

img_new = img_new(2:M+1, 2:N+1) ;

result = img_new ;

end