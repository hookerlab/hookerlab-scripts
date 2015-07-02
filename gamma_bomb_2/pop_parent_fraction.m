% Created by: Tom Morin
% Date: 5/28/15

function complete = pop_parent_fraction(files, directory)
% Generate a parent fraction curve from data from a population of several 
% participants
% INPUT: files = bld files containing parent fraction data points

% Read in data files, create matrices, and plot all matrices on one graph
complete = false;
cat_data = zeros(0,2);
[num_files,~] = size(files);
figure
for m=1:num_files
    disp(files{m});
    A = dlmread(files{m}, '\t', 1, 0);
    cat_data = cat(1, cat_data, A);
    hold on;
    %plot(A(:,1),A(:,2),'*r');    
end
title('Parent Fraction from Population Data','FontSize', 10,'FontWeight', 'bold');
xlabel('Time (s)', 'FontSize', 7);
ylabel('Parent Fraction', 'FontSize', 7);
cat_data = sortrows(cat_data);

pop_pf_mx = handle_repeated_data(cat_data);
plot(pop_pf_mx(:,1),pop_pf_mx(:,2),'*b');

% Write final Parent Fraction data file to csv_dir from gamma bomb gui
print_list({'sample-time[seconds]';'parent-fraction[1/1]'}, pop_pf_mx, fullfile(directory,'parentfraction.bld'),4);
complete = true;
end


function pop_pf_mx = handle_repeated_data(cat_data)
% Prepare the data points for curve fitting by ensuring that the data is a
% one-to-one function (one y-value for each x-value)
% If there are multiple y-values for one x-value, average them together

pop_pf_mx(1,:) = cat_data(1,:);
num_repeats = 0;
for m=2:length(cat_data)-1
    if pop_pf_mx(end,1) ~= cat_data(m,1)
        num_repeats = 0;
        pop_pf_mx(end+1,:) = cat_data(m,:);
    else
        num_repeats = num_repeats + 1;
        pop_pf_mx(end,2) = (pop_pf_mx(end,2).*num_repeats) + cat_data(m,2);
        pop_pf_mx(end,2) = pop_pf_mx(end,2) ./ (num_repeats+1);
    end
end
end