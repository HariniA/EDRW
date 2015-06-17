function D = diagonalize(vector)
    len = length(vector);
    D = zeros(len, 3);
    
    for i = 1:len
        D(i, :) = [i i vector(i)];
    end
    D = spconvert(D);       
end