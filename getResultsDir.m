function path = getResultsDir()
%GETRESULTSDIR Return the results directory path, creating it if necessary.
    projectRoot = fileparts(mfilename('fullpath'));
    path = fullfile(projectRoot, 'results');
    if ~exist(path, 'dir')
        mkdir(path);
    end
end
