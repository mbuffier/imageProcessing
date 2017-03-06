function result = computeWeighting(d, h, sigma, patchSize)
    M = size(d,1) ;
    sigma_vec = repmat(2*sigma^2, M, 1) ;
    
    % re-scale the distances 
    d = d./patchSize ;
    
    % compute the weight for all distances in the same time 
    up = max(d-sigma_vec,zeros(M,1)) ; 
    result = exp(-up./(h^2));
end