function path = getResultsDir()
%GETRESULTSDIR Return the output directory, creating it if needed.
%   RETINAL_RESULTS_DIR can isolate output in automated tests or local runs.
%   With no override, retain the original ./results/ behavior.
    projectRoot = fileparts(mfilename('fullpath'));
    path = getenv('RETINAL_RESULTS_DIR');
    if isempty(path)
        path = fullfile(projectRoot, 'results');
    end
    if ~exist(path, 'dir')
        mkdir(path);
    end
end
