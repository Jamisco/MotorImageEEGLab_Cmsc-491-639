
% Get the list of files in the folder
fName = 'SubjectData_Raw';
files = dir(fName);
subjectFiles = {};

% Iterate over the list of files
for i = 1:numel(files)
    % Get the name of the current file
    file_name = files(i).name;
    filePath = files(i);

    % Check if the current item is a file (not a folder or '.' or '..')
    if ~files(i).isdir && ~strcmp(file_name, '.') && ~strcmp(file_name, '..')
        SaveFile(filePath, file_name);
    end
end

disp('Preprocess Complete.');

function SaveFile(filePath, fileName)

    pattern = 'CLA-([^-]+)-.*';

    subjectData = load(fullfile(filePath.folder, fileName));
    % Extract the subject name using regular expressions
    subjectName = regexp(fileName, pattern, 'tokens', 'once');
         
    % Access EEG data from the loaded structure
    eeg_data = subjectData.o.data;
    eeg_markers = subjectData.o.marker;
    
    % Find the indices where markers change from zero to non-zero and back to zero
    marker_onset_indices = find(diff([0; eeg_markers]) > 0);

    % Find the indices where markers change from non-zero to zero
    marker_offset_indices = find(diff([eeg_markers; 0]) < 0);
   

    % Initialize an empty cell array to store epochs
    fullEpochs = cell(1, numel(marker_onset_indices));

    % this will be the epochs with no zeroes
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

    saveFolder = fullfile('SubjectData_Processed', subjectName);
    saveFolder = char(saveFolder);

    if ~isfolder(saveFolder)
        mkdir(saveFolder);
    end

    %save the actual eeg data
   % dlmwrite(fullfile(saveFolder, 'RawEEG_Data.txt'), eeg_data, 'delimiter', '\t');

    saveDir = fullfile(saveFolder, 'FullEpochData');

    EpochSplitter(eeg_data, eeg_markers, fullEpochs, saveDir);

    saveDir = fullfile(saveFolder, 'HalfEpochData');

    EpochSplitter(eeg_data, eeg_markers, fullEpochs, saveDir);

    
    disp( ['Processed and Saved EEG Data For ', fileName]);

end
