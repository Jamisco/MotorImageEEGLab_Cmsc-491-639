function EpochSplitter(eeg_data, eeg_markers, epochs, savePath)

% Define the number of channels
numChannels = 22; % Update this with your actual number of channels
rowLength = 0;

% Preallocate 2D arrays to hold EEG data for each marker group
g1 = zeros(rowLength, numChannels);
g2 = zeros(rowLength, numChannels);
g3 = zeros(rowLength, numChannels);

%add at the end of an epoch to sperate them
filler = zeros(250, numChannels);

% Initialize counters for each group
count_group1 = 0;
count_group2 = 0;
count_group3 = 0;

total1 = 0;
total2 = 0;
total3 = 0;

channel2Remove = [1,2,3,4,7,8,11,12,13,14,17,18,19,20,21];

sI = epochs{1}(2);
relaxedEpoch = eeg_data(1:sI, :);
relaxedEpoch = RemoveChannels(relaxedEpoch, channel2Remove);
relaxedEpoch = [relaxedEpoch; filler];

% Loop over each epoch range
for i = 1:numel(epochs)
    
    % Extract the start and stop indices of the current epoch range
    start_index = epochs{i}(1);
    stop_index = epochs{i}(end);
    
    % Extract the marker state for the current epoch
    marker_state = eeg_markers(start_index);
    
    % Extract EEG data for the current epoch range
    % Replace this with your code to load or extract EEG data for the epoch
    eeg_data_epoch = eeg_data(start_index:stop_index, :); % Assuming EEG data is in the 22nd column
    eeg_data_epoch = RemoveChannels(eeg_data_epoch, channel2Remove);

    eeg_data_epoch = [eeg_data_epoch; filler];

    if i == 1
        % the first index is the resting state. We add to start of all
        % markers
        continue;
    end

    % Add EEG data to the proper data group based on the marker state
    switch marker_state
        case 1
            % Add EEG data to group 1
            count_group1 = count_group1 + 1;
            total1 =  total1 + size(eeg_data_epoch, 1);
            g1 = [g1; eeg_data_epoch];
        case 2
            % Add EEG data to group 2
            count_group2 = count_group2 + 1;
            total2 =  total2 + size(eeg_data_epoch, 1);
            g2 = [g2; eeg_data_epoch];
        case 3
            % Add EEG data to group 3
            count_group3 = count_group3 + 1;
            total3 =  total3 + size(eeg_data_epoch, 1);
            g3 = [g3; eeg_data_epoch];
        otherwise
            % Handle unknown marker state
            disp(['Warning: Unknown marker state ', num2str(marker_state)]);
    end
end

disp(['Done Splitting Data...']);

% Remove unused rows
g1 = g1(1:total1, :);
g2 = g2(1:total2, :);
g3 = g3(1:total3, :);

[r,p1,p2,p3] = EpochPlotter(relaxedEpoch, g1, g2, g3);

% % we add the relaxed state at the start of each epoch so they can be
% % processed in eeglab
% g1 = [relaxedEpoch; g1];
% g2 = [relaxedEpoch; g2];
% g3 = [relaxedEpoch; g3];

p4 = [r;p1;p2;p3]; 

savePath = char(savePath);

if ~isfolder(savePath)
    mkdir(savePath);
end

CreatePlot(r,p1,p2,p3);
sp = [savePath, '\PlotPicture.png'];
saveas(gcf, sp);
close(gcf);


dlmwrite(fullfile(savePath, 'RelaxedState.txt'), relaxedEpoch, 'delimiter', '\t');
dlmwrite(fullfile(savePath, 'EpochData1.txt'), g1, 'delimiter', '\t');
dlmwrite(fullfile(savePath, 'EpochData2.txt'), g2, 'delimiter', '\t');
dlmwrite(fullfile(savePath, 'EpochData3.txt'), g3, 'delimiter', '\t');

dlmwrite(fullfile(savePath, 'PlotDatas.txt'), p4, 'delimiter', '\t');

end

function result = RemoveChannels(matrix, col_indices)

    % Initialize result with the original matrix
    result = matrix;
    
    % Replace specified elements with zeros
    result(:, col_indices) = 0;
end

