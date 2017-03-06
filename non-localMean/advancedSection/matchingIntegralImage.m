function distances = matchingIntegralImage(row, col, ...
    patchSize, searchWindowSize,integralImages)

% initialization
distances = zeros(searchWindowSize*searchWindowSize, 1);

for i=1:searchWindowSize*searchWindowSize
    % evaluate the distance
    dist = evaluateIntegralImage(integralImages{i}, row, col, patchSize) ;
    % store it
    distances(i,1) = dist ;
end

end