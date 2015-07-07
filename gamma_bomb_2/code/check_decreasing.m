function [num_deleted, adjusted_data] = check_decreasing(data)
% Check that data is monatonically decreasing after initial hill
% If data prematurely approaches zero, omit these points from analysis

tail_avg = 0;
temp = zeros(0,2); % Temporary matrix
cutoff_min = 60; % Program starts looking for bad points here
cutoff_max = 200;

% Calculate the average of all measurements taken after 60 seconds
for m=1:size(data)
    if data(m,1) > cutoff_min
        temp(end+1,:) = data(m,:);
        tail_avg = mean(temp);
    end
end
clear temp;
approx_zero = min(tail_avg(1,2)./2, data(end,2)); % Cutoff for what is considered to be "near zero"

% Add a third column to the data table (1 = keep the point, 0 = delete it)
% Default: keep all points
for m=1:size(data)
    data(m,3) = 1;
end

% Determine the minima within the range of analysis (between time at cutoff_min &
% time at cutoff_max)
for m=2:size(data)-1
    if(data(m,2)<data(m+1,2) && data(m,2)<data(m-1,2))
        data(m,3) = 0;
    end
    if(data(m,1)<cutoff_min || data(m,1)>cutoff_max)
        data(m,3) = 1;
    end
    if(data(m,2)>approx_zero)
        data(m,3) = 1;
    end
end

% Delete points adjacent to the minima found above when necessary
larger = 0;
for m=2:size(data)-1
    if(data(m,3) == 0)
        larger = max(data(m+1,2), data(m-1,2));
    end
end
for m=2:size(data)-1
    for m=2:size(data)-1
        if data(m,2) < larger && (data(m+1,3)==0 || data(m-1,3)==0)
            data(m,3) = 0;
        end
    end
end
        

% Store points we'll keep for further analyses in 'adjusted_data'
% Store all deleted points in deleted_points
adjusted_data = zeros(0,2);
deleted_points = zeros(0,2);
for m=1:size(data)
    if data(m,3) == 1
        adjusted_data(end+1,:) = data(m,1:2);
    else
        deleted_points(end+1,:) = data(m,1:2);
    end
end
%adjusted_data(end+1,:) = data(end,1:2); % Add final data point to adjusted_data
[num_deleted,~] = size(deleted_points);

%% Plot to Debug
% figure
% hold on;
% plot(data(:,1),data(:,2), '.r');
% set(gca, 'XScale', 'log');
% title('Before');
% plot(adjusted_data(:,1),adjusted_data(:,2), '.');
% set(gca, 'XScale', 'log');
% refline(0, approx_zero);
% refline(Inf, cutoff_min);
% refline(Inf, cutoff_max);
% title('Adjusting for Points that Prematurely Approach Zero');
% hold off;

end