function [number_cluster mean] = meanShift(A,windowSize)

% mean will be the return of the clustered image 
%number_cluster is the number of cluster the windowSize gives
% A is the original image
% windowSize is the size of the window we choose

[M,N]=size(A);
mean = zeros(M,N);

histo=imhist(A).'; % we are going the look for the mode of the histogram
histo = [zeros(1,floor(windowSize/2)) histo zeros(1,floor(windowSize/2))] ; % we add
% some zeros to handle the case where the window would shift near the
% boundaries

int_value = [zeros(1,floor(windowSize/2)) [0:255] zeros(1,floor(windowSize/2))] ;
% int_value contain all the possible value of intensity of the histogram

search_centre = [histo ; int_value] ; % we combine the value of intensity and the histogram

for i=1:M
    for j=1:N % we loop on each of the pixel to find his center
        center_value = A(i,j);
        left_window = uint8(center_value+1); % add 1 to evoid indices with a zero value
        right_window = uint8(center_value+2*floor(windowSize/2)+1);
        % in both case we shift of floor(windowSize/2) as we add some zeros
        % at search_centre
        
        new_center = floor(sum(search_centre(1,left_window:right_window).*search_centre(2,left_window:right_window)) / sum(search_centre(1,left_window:right_window)));
        % we find the new center by finding the mean in our window
        
        while (true) % continue to loop until convergence
            center_value = new_center;
            left_window = uint8(center_value+1); 
            right_window = uint8(center_value+2*floor(windowSize/2)+1);
            
            new_center = floor(sum(search_centre(1,left_window:right_window).*search_centre(2,left_window:right_window)) / sum(search_centre(1,left_window:right_window)));
    
            if(center_value == new_center) % if convergence we break
                break ;
            end
        end
        mean(i,j)=center_value; % fill mean with the value of the centre for each pixel 
        mean = uint8(mean) ;
    end
end

% as some centres might be very closed, we rescale the value to be between 0
% and 255 
mean_unique = unique(mean) ; % all the centre values
number_cluster = uint8(size(mean_unique,1)) ; % nombre of clusters

for i = 1:M
   for j = 1:N
       position = find(mean(i,j)==mean_unique) ; 
       mean(i,j) = (position*255)/(number_cluster+1) ; % rescale according the number of clusters
   end
end

mean = uint8(mean) ; % we convert mean to be able to show it




