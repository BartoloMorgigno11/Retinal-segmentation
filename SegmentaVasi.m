function SegmentaVasi(RGB)
%SEGMENTAVASI Segment retinal vessels from an RGB fundus image.

    % Convert to double to allow arithmetic processing
    im = im2double(RGB);

    % 1) PCA gray: derive a grayscale projection from Lab space
    lab  = rgb2lab(im);
    f    = 0;
    wlab = reshape(bsxfun(@times, cat(3, 1 - f, f / 2, f / 2), lab), [], 3);
    [~, S] = pca(wlab);
    S     = reshape(S, size(lab));
    gray  = mat2gray(S(:, :, 1));
    figure; imshow(gray); title('PCA Gray');

    % 2) CLAHE to boost local contrast
    J = adapthisteq(gray, 'NumTiles', [20 20], 'NBins', 1024);
    figure; imshow(J); title('After CLAHE');

    % 3) Background subtraction
    h  = fspecial('average', [7 7]);
    JF = imfilter(J, h);
    Z  = imsubtract(JF, J);
    figure; imshow(Z); title('Background Subtraction');

    % 4) Automatic thresholding (IsoData) with offset
    level  = isodata(Z);
    offset = 0.003;
    BW = imbinarize(Z, level - offset);
    figure; imshow(BW); title('Binary Mask');

    % 5) Remove small components (>= 150 px^2)
    BW2 = bwareaopen(BW, 150);
    figure; imshow(BW2); title('Area >= 150 px^2');

    % 6) Final overlay
    out = imoverlay(im, BW2, [0 0 0]);
    figure; imshow(out); title('Segmented Vessels');

    % Save results
    resultsDir = getResultsDir();
    imwrite(BW2, fullfile(resultsDir, 'mask_vasi.png'));
    imwrite(out, fullfile(resultsDir, 'overlay_vasi.png'));
end

% ==== Local helpers ======================================================
function level = isodata(I)
    % Compute threshold via IsoData method
    I = im2uint8(I(:));
    [counts, N] = imhist(I);
    mu = cumsum(counts);
    T = round(sum(N .* counts) / mu(end));
    while true
        MBT = sum(N(1:T) .* counts(1:T)) / sum(counts(1:T));
        MAT = sum(N(T:end) .* counts(T:end)) / sum(counts(T:end));
        Tn  = round((MBT + MAT) / 2);
        if abs(Tn - T) < 1, break; end
        T = Tn;
    end
    level = (T - 1) / (N(end) - 1);
end

function out = imoverlay(in, mask, color)
    % Overlay a binary mask on the input image
    mask = logical(mask);
    in8 = im2uint8(in);
    col8 = im2uint8(color);
    if ndims(in8) == 2
        in8 = cat(3, in8, in8, in8);
    end
    for c = 1:3
        ch = in8(:, :, c);
        ch(mask) = col8(c);
        in8(:, :, c) = ch;
    end
    out = in8;
end
