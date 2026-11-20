function Main
%MAIN Entry point for the retinal segmentation pipeline.
%
%   Prompts the user to pick a fundus image, optionally estimates diabetic
%   retinopathy severity (when a network is available), and runs the
%   segmentation modules. Results are written to the "results" folder.

    clear; close all; clc;
    projectRoot = fileparts(mfilename('fullpath'));
    warning(['Research-use prototype only: output is not validated for clinical ', ...
             'diagnosis, screening, or treatment decisions.']);

    %% Main parameters
    modelCandidates = {
        fullfile(projectRoot, 'dr_severity_regnet.mat')
        fullfile(projectRoot, 'models', 'dr_severity_regnet.mat')
    };
    inputSize = [224 224];
    targetSize = [584 565];
    resultsDir = fullfile(projectRoot, 'results');

    %% Prepare results folder
    if exist(resultsDir, 'dir')
        oldFiles = dir(fullfile(resultsDir, '*'));
        oldFiles = oldFiles(~[oldFiles.isdir]);
        for k = 1:numel(oldFiles)
            delete(fullfile(resultsDir, oldFiles(k).name));
        end
    else
        mkdir(resultsDir);
    end

    %% Select the image to analyse
    defaultDir = fullfile(projectRoot, 'data', 'images');
    if ~exist(defaultDir, 'dir')
        defaultDir = projectRoot;
    end
    [fn, pn] = uigetfile({'*.png;*.jpg;*.jpeg','Retinal images'}, ...
                         'Select retinal image', defaultDir);
    if isequal(fn, 0)
        disp('No image selected. Exiting.');
        return;
    end
    RGBorig = imread(fullfile(pn, fn));

    %% Severity estimation (optional)
    modelFile = locateFirstExisting(modelCandidates);
    if ~isempty(modelFile)
        S = load(modelFile);
        if ~isfield(S, 'drNet')
            warning('File %s does not contain the expected ''drNet'' variable.', modelFile);
        else
            drNet = S.drNet;
            Iprep = im2single(imresize(RGBorig, inputSize));
            sevPred = predict(drNet, Iprep);

            msg = sprintf('Research-only model output: %.1f %%', sevPred);
            fprintf('\n%s\n', msg);

            choice = questdlg({msg, 'Do you want to continue with the segmentation?'}, ...
                              'Continue?', 'Yes', 'No', 'Yes');
            if strcmp(choice, 'No')
                disp('Processing stopped by the user.');
                return;
            end
        end
    else
        warning('No severity model found. The pipeline will continue without this step.');
    end

    %% Resize image for the segmentation pipeline
    RGB = imresize(RGBorig, targetSize);

    %% Vessel segmentation
    disp('Segmenting vessels...');
    SegmentaVasi(RGB);

    %% Optic disc segmentation
    disp('Segmenting optic disc...');
    SegmentaDiscoOttico(RGB);

    %% Optional lesion segmentation
    scelta = input('Do you want to segment lesions (exudates, haemorrhages/microaneurysms)? [Y/N]: ', 's');
    if strcmpi(scelta, 'Y')
        disp('1) Exudates');
        disp('2) Haemorrhages/Microaneurysms');
        disp('3) Both');
        disp('4) Cancel');
        sc = input('Select an option (1-4): ');
        switch sc
            case 1
                SegmentaEssudati(RGB);
            case 2
                SegmentaEmorragieMicroaneurismi(RGB);
            case 3
                SegmentaEssudati(RGB);
                SegmentaEmorragieMicroaneurismi(RGB);
            otherwise
                disp('No additional segmentation performed.');
        end
    else
        disp('No additional segmentation performed.');
    end

    disp('Processing completed.');
end

function filePath = locateFirstExisting(candidates)
%LOCATEFIRSTEXISTING Return the first existing file in the list.
    filePath = '';
    for idx = 1:numel(candidates)
        if exist(candidates{idx}, 'file')
            filePath = candidates{idx};
            return;
        end
    end
end
