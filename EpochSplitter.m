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

channel2Remove = [1,2,3,4,5,6,7,12,13,14,15,16,17,18,19,20,21];

sI = epochs{1}(1);
relaxedEpoch = eeg_data(1:sI, :);

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

[r,p1] = EpochPlotter(relaxedEpoch, g1);
[r,p2] = EpochPlotter(relaxedEpoch, g2);
[r,p3] = EpochPlotter(relaxedEpoch, g3);

savePath = char(savePath);

if ~isfolder(savePath)
    mkdir(savePath);
end

CreatePlot(r,p1);
sp = [savePath, '\PlotPicture1.png'];
saveas(gcf, sp);
close(gcf);

CreatePlot(r,p2);
sp = [savePath, '\PlotPicture2.png'];
saveas(gcf, sp);
close(gcf);

CreatePlot(r,p3);
sp = [savePath, '\PlotPicture3.png'];
saveas(gcf, sp);
close(gcf);

% dlmwrite(fullfile(savePath, 'EpochData1.txt'), g1, 'delimiter', '\t');
% dlmwrite(fullfile(savePath, 'EpochData2.txt'), g2, 'delimiter', '\t');
% dlmwrite(fullfile(savePath, 'EpochData3.txt'), g3, 'delimiter', '\t');

dlmwrite(fullfile(savePath, 'PlotData1.txt'), p1, 'delimiter', '\t');
dlmwrite(fullfile(savePath, 'PlotData2.txt'), p2, 'delimiter', '\t');
dlmwrite(fullfile(savePath, 'PlotData2.txt'), p3, 'delimiter', '\t');

end

function CreatePlot(relaxedData, avgData)

% Specify the x-axis labels
x_labels = {'C3', 'C4', 'Cz', 'T3', 'T4'};

% Plot the relaxedData with blue color and circle markers
plot(relaxedData, 'bo-', 'DisplayName', 'Relaxed Data');
hold on;  % Hold the plot to overlay the next plot

% Plot the avgData with red color and square markers
plot(avgData, 'rs-', 'DisplayName', 'Average Data');

% Customize the x-axis labels
xticks(1:numel(x_labels));  % Set the x-axis tick positions
xticklabels(x_labels);      % Set the x-axis tick labels

% Add labels, title, and legend
xlabel('Channels');
ylabel('Values');
title('Comparison of Relaxed and Average EEG Data');
legend('Location', 'best');  % Show legend with best position

end



function result = RemoveChannels(matrix, col_indices)

    % Initialize result with the original matrix
    result = matrix;
    
    % Replace specified elements with zeros
    result(:, col_indices) = 0;
end

