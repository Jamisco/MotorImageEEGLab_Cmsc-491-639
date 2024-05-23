% the process1 step, will
% load eegData and marker from file
% append marker state to first column of eegData
% add fillers(bunch of zeroes) between each trial period in the eegData
% save the data has {SubjectName}_EEGData_P1, denoting EEGData Process1

% once you have filtered the data in the Process1 Folder using eeglab
% save it in the Filtered_EEGData folder. 
% Process 2 will then get the filteredData from there and processes them
% Process 2 then saves the processed Data in a new folder, process2

fName = 'SubjectData_Processed\Filtered_EEGData';
files = dir(fName);
subjectFiles = {};

% Iterate over the list of files
for i = 1:numel(files)
    % Get the name of the current file
    file_name = files(i).name;
    filePath = files(i);

    % Check if the current item is a file (not a folder or '.' or '..')
    if ~files(i).isdir && ~strcmp(file_name, '.') && ~strcmp(file_name, '..')
        ProcessFile(filePath, file_name);
    end
end

disp('Process 2 Complete.');

function ProcessFile(filePath, fileName)

    % Extract the subject name using regular expressions
    subjectName = regexp(fileName, '^[^_]+', 'match', 'once');

    saveFolder = fullfile('SubjectData_Processed\Process2\', subjectName);

    eeg_data = load(fullfile(filePath.folder, fileName));
    eeg_markers = eeg_data(:, 1);

    % Remove the first column from eeg_data
    eeg_data(:, 1) = [];

    % Find the indices where markers change from zero to non-zero and back to zero
    marker_onset_indices = find(diff([0; eeg_markers]) > 0);
    % Prepend 1 at the beginning of the cell array.
    % The reason for this is so we can extract the initial relaxed State
    marker_onset_indices = [1; marker_onset_indices];

    % Find the indices where markers change from non-zero to zero
    marker_offset_indices = find(diff([eeg_markers; 0]) < 0);

    % Prepend the 2nd value in onsetArray. 
    % This is to extract the relaxedEpoch state
    marker_offset_indices = [marker_onset_indices(2) - 1; marker_offset_indices];

    % this will be the epoch for the full trial
    fullEpochs = cell(1, numel(marker_onset_indices));

    % this will be the epochs when the visual cue is being shown
    % aka the first 1 second of the 3 second trail
    halfEpochs = cell(1, numel(marker_onset_indices));

    % Extract epochs from the EEG data
    for i = 1:numel(marker_onset_indices)
        
        start_index = marker_onset_indices(i);
        halfEnd_index = marker_offset_indices(i);

        fullEnd_index = 0;

        % Find the index of the next onset marker
        if i < numel(marker_onset_indices)
            fullEnd_index = marker_onset_indices(i+1) - 1;
        else
            % If this is the last onset marker, set the end index to the end of the data
            fullEnd_index = numel(eeg_markers);
        end
        
        fullEpochs{i} = [start_index, fullEnd_index];
        halfEpochs{i} = [start_index, halfEnd_index];

    end

    saveFolder = fullfile('SubjectData_Processed\Process2\', subjectName);

    saveDir = fullfile(saveFolder, 'FullEpochData');
    EpochSplitter(eeg_data,eeg_markers, fullEpochs, saveDir);

    saveDir = fullfile(saveFolder, 'HalfEpochData');
    EpochSplitter(eeg_data, eeg_markers, halfEpochs, saveDir);

    disp([subjectName ' Processed']);

end
