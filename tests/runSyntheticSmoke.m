function runSyntheticSmoke()
%RUNSYNTHETICSMOKE Exercise research segmentation with artificial RGB input.
% Does not establish diagnostic validity, image-level accuracy or GUI behavior.
    root = fileparts(fileparts(mfilename('fullpath')));
    addpath(root);
    scratch = tempname;
    mkdir(scratch);
    oldDir = getenv('RETINAL_RESULTS_DIR');
    oldVisible = get(groot, 'DefaultFigureVisible');
    cleanup = onCleanup(@() restoreEnvironment(oldDir, oldVisible, scratch));
    setenv('RETINAL_RESULTS_DIR', scratch);
    set(groot, 'DefaultFigureVisible', 'off');

    rng(2026);
    rows = 584;
    cols = 565;
    [X, Y] = meshgrid(linspace(0, 1, cols), linspace(0, 1, rows));
    background = 34 + 70*X + 25*Y + 9*randn(rows, cols);
    brightDisc = ((X-0.69).^2 / 0.08^2 + (Y-0.41).^2 / 0.09^2) < 1;
    vessel = (abs(Y - (0.32 + 0.13*sin(8*X))) < 0.005) | ...
             (abs(Y - (0.57 - 0.10*sin(7*X))) < 0.004);
    synthetic = zeros(rows, cols, 3, 'uint8');
    synthetic(:,:,1) = uint8(max(0, min(255, background+50 + 85*brightDisc-50*vessel)));
    synthetic(:,:,2) = uint8(max(0, min(255, background+35 + 100*brightDisc-65*vessel)));
    synthetic(:,:,3) = uint8(max(0, min(255, background-5 + 65*brightDisc-25*vessel)));

    SegmentaVasi(synthetic);
    SegmentaDiscoOttico(synthetic);
    SegmentaEssudati(synthetic);
    SegmentaEmorragieMicroaneurismi(synthetic);

    expected = {
        'mask_vasi.png', 'overlay_vasi.png', ...
        'disco_mask.png', 'disco_overlay.png', ...
        'essudati_mask.png', 'essudati_overlay.png', ...
        'emorragie_mask.png', 'emorragie_solo_mask.png', ...
        'microaneurismi_mask.png', ...
        'emorragie_microaneurismi_overlay.png'
    };
    for k = 1:numel(expected)
        file = fullfile(scratch, expected{k});
        assert(isfile(file), 'Required synthetic smoke artifact missing: %s', expected{k});
        info = imfinfo(file);
        assert(info.Height == rows && info.Width == cols, ...
            'Unexpected size for %s: %d x %d', expected{k}, info.Height, info.Width);
    end

    fprintf('SYNTHETIC_SMOKE_PASS: %d output masks/overlays verified.\n', numel(expected));
    close all force;
end

function restoreEnvironment(originalDir, originalVisible, scratch)
    setenv('RETINAL_RESULTS_DIR', originalDir);
    set(groot, 'DefaultFigureVisible', originalVisible);
    close all force;
    if isfolder(scratch)
        rmdir(scratch, 's');
    end
end
