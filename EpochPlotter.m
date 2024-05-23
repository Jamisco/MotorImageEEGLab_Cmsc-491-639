
function [relaxPlot, p1, p2, p3] = EpochPlotter(refData, e1, e2, e3)

% c3, c4, t3, t4 channel. This channel are related to hand data
index = [5,6,9,10,15,16];

relaxedAvg = zeros(1, 4);

for i = 1:numel(index)
    relaxedAvg(i) = GetColAvg_TrimPercent(refData, index(i));
end

relaxPlot = relaxedAvg;

e1Avg = zeros(1, 4);
e2Avg = zeros(1, 4);
e3Avg = zeros(1, 4);

for x = 1:numel(index)

    colIndex = index(x);
    eVal1 = GetColAvg_TrimPercent(e1, colIndex);
    eVal2 = GetColAvg_TrimPercent(e2, colIndex);
    eVal3 = GetColAvg_TrimPercent(e3, colIndex);

    e1Avg(x) = eVal1;
    e2Avg(x) = eVal2;
    e3Avg(x) = eVal3;

    %e1Avg(x) = abs(relaxedAvg(x) + eVal);
end

p1 = e1Avg;
p2 = e2Avg;
p3 = e3Avg;

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
    trim_percent = 0;
    
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