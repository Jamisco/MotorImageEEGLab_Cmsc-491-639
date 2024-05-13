
function [relaxPlot, epochPlot] = EpochPlotter(refData, epochs)

% c3, c4, cz, t3, t4
index = [8, 9, 10, 11];

relaxedAvg = zeros(1, 4);

for i = 1:4
    relaxedAvg(i) = GetColAvg_TrimPercent(refData, index(i));
end

relaxPlot = relaxedAvg;

epochAvg = zeros(1, 4);

for x = 1:4

    colIndex = index(x);
    eVal = GetColAvg_TrimPercent(epochs, colIndex);

    %epochAvg(x) = eVal;
    epochAvg(x) = abs(relaxedAvg(x) - eVal);
end

epochPlot = epochAvg;

end

% will find the mean, abs(values) in the column greater than threshold are
% removed
function column_average = GetColAvg_TrimThreshHold(matrix, column_index)
    trim_percent = .1;
    
    % Extract the specified column
    column_values = matrix(:, column_index);

    threshold = 8;

    % Find indices of values greater than the threshold
    idx = abs(column_values) > threshold;
    
    % Remove values greater than the threshold
    trimmed_values = column_values(~idx);
    
    % Compute the average of the remaining values
    column_average = mean(trimmed_values);
end

% will fine the mean, Will remove the top and bottom x percent of values
function column_average = GetColAvg_TrimPercent(matrix, column_index)
    trim_percent = .02;
    
    % Extract the specified column
    column_values = matrix(:, column_index);

    % Sort the column values in ascending order
    sorted_values = sort(column_values);
    
    % Compute the number of values to discard from the top and bottom
    num_values_to_discard = round(trim_percent * numel(sorted_values));
    
    % Remove the top and bottom x percent of values
    trimmed_values = sorted_values(num_values_to_discard+1 : end - num_values_to_discard);
    
    % Compute the average of the remaining values
    column_average = mean(trimmed_values);
end