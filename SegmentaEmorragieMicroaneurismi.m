function SegmentaEmorragieMicroaneurismi(RGB)
%SEGMENTAEMORRAGIEMICROANEURISMI Segment haemorrhages and microaneurysms.

    figure; imshow(RGB); title('Original Image');

    % 1) Extract and pre-process the green channel
    G = RGB(:, :, 2);
    figure; imshow(G); title('Green Channel');

    J2 = adapthisteq(G, 'ClipLimit', 0.05);
    F2 = medfilt2(J2, [3 3]);
    figure; imshow(F2); title('CLAHE + Median Filter');

    % 2) Bottom-hat to emphasise lesions
    se2 = strel('disk', 10);
    B2 = imbothat(F2, se2);
    figure; imshow(B2); title('Bottom-Hat');

    % 3) Threshold and clean up
    t2 = graythresh(B2);
    BW2 = imbinarize(B2, t2);
    figure; imshow(BW2); title('Binary Mask');

    % 4) Remove vessels if the mask is available
    resultsDir = getResultsDir();
    maskVasiFile = fullfile(resultsDir, 'mask_vasi.png');
    if exist(maskVasiFile, 'file')
        maskVasi = logical(imread(maskVasiFile));
        BWem = imdilate(maskVasi, strel('disk', 1));
        BW2(BWem) = 0;
    else
        warning('Vessel mask not found: subtraction was skipped.');
        BWem = false(size(BW2));
    end
    figure; imshow(BW2); title('Vessel-Removed Mask');

    % 5) Morphological cleanup
    BWclean = imopen(BW2, strel('disk', 2));
    figure; imshow(BWclean); title('After Morphology');

    % 6) Separate haemorrhages from microaneurysms
    BWhemo = bwareaopen(BWclean, 30);
    figure; imshow(BWhemo); title('Haemorrhages (>= 30 px^2)');

    BWmicro = BWclean & ~BWhemo;
    figure; imshow(BWmicro); title('Microaneurysms');

    % 7) Build final overlay
    outFinal = RGB;
    for c = 1:3
        tmp = outFinal(:, :, c);
        tmp(BWhemo) = 255 * (c == 2);    % green for haemorrhages
        tmp(BWmicro) = 255 * (c ~= 2);   % magenta for microaneurysms
        outFinal(:, :, c) = tmp;
    end
    figure; imshow(outFinal); title('Final Overlay');

    % Save results
    imwrite(BWem,     fullfile(resultsDir, 'emorragie_mask.png'));
    imwrite(BWhemo,   fullfile(resultsDir, 'emorragie_solo_mask.png'));
    imwrite(BWmicro,  fullfile(resultsDir, 'microaneurismi_mask.png'));
    imwrite(outFinal, fullfile(resultsDir, 'emorragie_microaneurismi_overlay.png'));
end
