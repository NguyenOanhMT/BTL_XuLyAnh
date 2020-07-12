function DOG_octaves = calculate_DOG(octaves)
    DOG = cell(size(octaves, 1), 1);
    for i=1:size(octaves, 1)
        DOG{i} = zeros(size(octaves{i}, 1), size(octaves{i}, 2), size(octaves{i}, 3)-1);
        for j=2:size(octaves{i},3)
            DOG{i}(:,:,j-1) = octaves{i}(:,:,j) - octaves{i}(:,:,j-1);
        end
    end
    DOG_octaves = DOG;
end