% the process1 step, will
% load eegData and marker from file
% append marker state to first column of eegData
% add fillers(bunch of zeroes) between each trial period in the eegData
% save the data has EEGData_P1, denoting EEGData Process1

fName = 'SubjectData_Raw';
files = dir(fName);
subjectFiles = {};

numChannels = 23; % Update this with your actual number of channels

%add at the end of an epoch to sperate them
filler = zeros(250, numChannels);

% Iterate over the list of files
for i = 1:numel(files)
    % Get the name of the current file
    file_name = files(i).name;
    filePath = files(i);

    % Check if the current item is a file (not a folder or '.' or '..')
    if ~files(i).isdir && ~strcmp(file_name, '.') && ~strcmp(file_name, '..')
        ProcessFile(filePath, file_name, filler);
    end
end

disp('Process 1 Complete.');

function ProcessFile(filePath, fileName, filler)

    pattern = 'CLA-([^-]+)-.*';

    subjectData = load(fullfile(filePath.folder, fileName));
    % Extract the subject name using regular expressions
    subjectName = regexp(fileName, pattern, 'tokens', 'once');
    subjectName = subjectName{1};

    % Access EEG data from the loaded structure
    eeg_data = subjectData.o.data;
    eeg_markers = subjectData.o.marker;
    
    eeg_data = [eeg_markers, eeg_data];

    % Find the indices where markers change from zero to non-zero and back to zero
    marker_onset_indices = find(diff([0; eeg_markers]) > 0);

    % Extract epochs from the EEG data
    for i = 1:numel(marker_onset_indices) - 1

        index = marker_onset_indices(i) - 1 + (i * size(filler, 1));

        eeg_data = [eeg_data(1:index,:); filler; eeg_data(index+1:end,:)];

    end

    saveFolder = fullfile('SubjectData_Processed\Process1');
    saveName = [subjectName, '_EEGData_P1.txt'];
    saveFolder = char(saveFolder);

    if ~isfolder(saveFolder)
        mkdir(saveFolder);
    end

    %save the processed eeg data
    dlmwrite(fullfile(saveFolder, saveName), eeg_data, 'delimiter', '\t');

    disp([subjectName 'EEG Data Processed']);

end