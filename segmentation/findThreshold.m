function [thresValue] = findThreshold(X, Y)

sizeX = size(X,2) ;

A = ones(1,sizeX) ;
B = ones(1,sizeX) ;

dist = sqrt((X-A).^2+((1-Y)-B).^2);

minDiff = find(dist==min(dist)) ;

thresValue = minDiff(1) ;
end
