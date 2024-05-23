function CreatePlot(relaxedData, p1, p2, p3)
    % Specify the x-axis labels
    x_labels = {'C3', 'C4', 'O1', 'O2', 'T3', 'T4'};
    
    % Initialize a figure
    figure;
    
    % Define a helper function to plot pairs of values
    function plotPairs(data, color, marker, lineWidth)
        for i = 1:2:length(data) - 1
            plot([i, i+1], [data(i), data(i+1)], [color, marker, '-'], 'LineWidth', lineWidth);
            hold on;
        end
    end

    % Plot the relaxedData with blue color and circle markers
    plotPairs(relaxedData, 'b', 'o', 1);

    %line size
    ls = .8;

    % Plot the p1 data with green color and square markers
    plotPairs(p1, 'g', 's', ls);
    
    % Plot the p2 data with red color and square markers
    plotPairs(p2, 'r', 's', ls);
    
    % Plot the p3 data with black color and square markers
    plotPairs(p3, 'k', 's', ls);

    % Customize the x-axis labels
    xticks(1:numel(x_labels));  % Set the x-axis tick positions
    xticklabels(x_labels);      % Set the x-axis tick labels
    
    % Add labels, title
    xlabel('Channels');
    ylabel('Values');
    title('Comparison of Relaxed and Average EEG Data');

    % Create custom legend entries
    h1 = plot(NaN, NaN, 'bo-', 'DisplayName', 'Relaxed State');
    h2 = plot(NaN, NaN, 'gs-', 'DisplayName', 'Left Hand State', 'LineWidth', ls);
    h3 = plot(NaN, NaN, 'rs-', 'DisplayName', 'Right Hand State', 'LineWidth', ls);
    h4 = plot(NaN, NaN, 'ks-', 'DisplayName', 'Passive State', 'LineWidth', ls);
    
    % Show legend with best position
    legend([h1, h2, h3, h4], 'Location', 'best');

    hold off;
end
