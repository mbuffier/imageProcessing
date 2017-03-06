function r = task2(img)

close all ;
% load the image
img = double(rgb2gray(imread('images/tourEiffel.jpeg')))/255 ;

% draw the result 
fig1 = figure,
set(fig1, 'Position', [0 0 1500 400]) ;
subplot(1,3,1),
imshow(img) ; 

[M, N] = size(img) ; % size

% Selection of the region 
mask = roipoly(img) ;

% Creation of the image with the removed region
mask_invert = double(ones(M,N)-mask) ;
img_new = img.*mask_invert ; 

subplot(1,3,2),
imshow(img_new) ;

% initialization of the boundaries image and take care of the borders
boundaries_img = zeros(M,N) ;
index = 0 ;
mask = double(mask) ;
mask_big = padarray(mask, [1,1],'replicate') ;

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
subplot(1,3,3),
imshow(img_new) ;

saveas(gcf, 'task2Result.jpg') ;

r = img_new

end

% function wich return 1 for pixel at the border and 0 for other 
function result = isBoundary(patch)
result = 0 ;

% 4 connectivity
test1 = patch(1,2) + patch(2,1)+patch(2,3)+patch(3,2) ;
test2 = patch(2,2) ;
if test2 == 0 && test1 > 0 % if the pixel itself is out and at least one of its neighboor is in the region
    result = 1 ;
end
end
