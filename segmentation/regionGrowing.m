function B = regionGrowing(I, seed, threshold)

% B is the output image segmented
% I is the image to segment
% seed is the choosen seed
% Threshold is the threshold we want to satisfy in the function

[M, N] = size(I) ;

% we set a matrix to zeros to count the point visited or not and 
% we initializing it with the seed
visited = zeros(M,N) ;
visited(seed(1),seed(2)) = 1 ;

boundary = zeros(2, M*N+1) ; % boundaries will contain the pixel we have to visit
boundary_cursor = 2 ; % boundary_cursor kept track of the position of the position of the visited point

boundary(:,boundary_cursor) = seed; % initialization

while(boundary_cursor~=1) % we stop when boundary doesn't contain any elements anymore
    
    nextPoint = boundary(:,boundary_cursor) ; % we test the last point in the list, where the cursor is
    boundary_cursor = boundary_cursor-1 ; % we update the cursor
    
    if(include(I(nextPoint(1), nextPoint(2)), threshold)) % we test the point to see if it verifies the threshold
        visited(nextPoint(1), nextPoint(2)) = 255; % if he does its value is set to 255
        i = nextPoint(1);
        j = nextPoint(2);
        listSize =0;
        
        % the next conditions allow to deal with the boundaries of the
        % image 
        if(i==1) % top row
            if(j==1)
                list_of_pixel = [i i+1 i+1; j+1 j+1 j] ; % we fill in a list of neighboors
                listSize =3 ;
            elseif(j==N)
                list_of_pixel = [i i+1 i+1; j-1 j-1 j] ;
                listSize =3;
            else
            list_of_pixel = [i i+1 i+1 i+1 i; j-1 j-1 j j+1 j+1] ;
            listSize =5;
            end
        end
        if(i==M) % bottom row
            if(j==1)
                list_of_pixel = [i-1 i-1 i; j j+1 j+1] ;
                listSize =3;
            elseif(j==N)
                list_of_pixel = [i i-1 i-1; j-1 j-1 j] ;
                listSize =3;
            else
            list_of_pixel = [i i-1 i-1 i-1 i; j-1 j-1 j j+1 j+1] ;
            listSize =5;
            end
        end
        
        if(j==1 && i~=1 && i~=M) % left column
            list_of_pixel = [i-1 i-1 i i+1 i+1; j j+1 j+1 j+1 j] ;
            listSize = 5;
        end
        if(j==N && i~=1 && i~=M) % right column
            list_of_pixel = [i-1 i-1 i i+1 i+1; j j-1 j-1 j-1 j] ;
            listSize =5;
        end
        if(i~=1 && i~=M && j~=1 && j~=N) % any other cases inside the image
            list_of_pixel = [i-1 i-1 i-1 i i+1 i+1 i+1 i; j-1 j j+1 j+1 j+1 j j-1 j-1] ;
            listSize =8;
        end
        
        for k=1:listSize % we go through the list and if the pixel isn't already in boundary, we add it
            if(visited(list_of_pixel(1,k), list_of_pixel(2,k))==0)
                visited(list_of_pixel(1,k), list_of_pixel(2,k))=1 ;
                boundary_cursor = boundary_cursor+1 ;
                boundary(:,boundary_cursor) = list_of_pixel(:,k) ;
            end
        end
    end
end
B = visited ;
end


function test = include(Int_point, threshold)
test = (Int_point>=threshold) ; % test if the point satisfied the threshold
end
