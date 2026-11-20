function SegmentaEssudati(RGB)
%SEGMENTAESSUDATI Segment exudates from an RGB fundus image.

    % 1) Extract the green channel
    G = RGB(:, :, 2);
    figure; imshow(G); title('Green Channel');

    % 2) Bottom-hat to enhance bright lesions
    %    Disc radius tuned to highlight typical exudate size
    seBottom = strel('disk', 15);
    C = imbothat(G, seBottom);
    figure; imshow(C, []); title('Bottom-Hat');

    % 3) Top-hat to further boost exudate response
    seTop = strel('disk', 50);
    H = imtophat(G, seTop);
    figure; imshow(H, []); title('Top-Hat');

    % 4) Build the exudate mask
    mask = imbinarize(H - C, 0.2);

    % 5) Remove the optic disc if the mask is available
    resultsDir = getResultsDir();
    diskMaskFile = fullfile(resultsDir, 'disco_mask.png');
    if exist(diskMaskFile, 'file')
        maskDisco = logical(imread(diskMaskFile));
        mask(maskDisco) = 0;
    else
        warning('Optic disc mask not found: no subtraction applied.');
    end
    figure; imshow(mask); title('Exudate Mask');

    % 6) Overlay using a light green colour
    color = [128, 255, 0];
    out = RGB;
    for i = 1:3
        tmp = out(:, :, i);
        tmp(mask) = color(i);
        out(:, :, i) = tmp;
    end
    figure; imshow(out); title('Exudate Overlay');

    % Save results
    imwrite(mask, fullfile(resultsDir, 'essudati_mask.png'));
    imwrite(out, fullfile(resultsDir, 'essudati_overlay.png'));
end
