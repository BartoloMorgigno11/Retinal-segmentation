function SegmentaDiscoOttico(RGB)
%SEGMENTADISCOOTTICO Segment the optic disc from an RGB fundus image.

    RGBd = im2double(RGB);
    G = RGBd(:, :, 2);
    figure; imshow(G); title('Green Channel');

    % Enhance contrast on the green channel
    G = imadjust(G, [0.4, 0.7], [0, 1]);
    figure; imshow(G); title('Enhanced Contrast');

    % Build a coarse mask of the optic disc
    mask = G > 0;
    figure; imshow(mask); title('Binary Mask');

    % Dilate to consolidate the region
    maskDilate = imdilate(mask, strel('disk', 5));
    figure; imshow(maskDilate); title('Dilated Mask');

    % Extract the largest connected component
    CC = bwconncomp(maskDilate);
    stats = regionprops(CC, 'Area', 'Centroid', 'BoundingBox');
    [~, idx] = max([stats.Area]);

    % Build an elliptical mask
    bb = stats(idx).BoundingBox;
    c = stats(idx).Centroid;
    a = bb(4) / 2;
    b = bb(3) / 2;
    [rows, cols] = size(G);
    [X, Y] = meshgrid(1:cols, 1:rows);
    diskMask = ((X - c(1)).^2 / b^2) + ((Y - c(2)).^2 / a^2) <= 1;
    figure; imshow(diskMask); title('Optic Disc Mask');

    % Overlay the mask on the original image
    out = RGB;
    for i = 1:3
        tmp = out(:, :, i);
        tmp(diskMask) = 255;
        out(:, :, i) = tmp;
    end
    figure; imshow(out); title('Optic Disc Overlay');

    % Save results
    resultsDir = getResultsDir();
    imwrite(diskMask, fullfile(resultsDir, 'disco_mask.png'));
    imwrite(out, fullfile(resultsDir, 'disco_overlay.png'));
end
