function make_histograms(times, kbq_ml_dkc_mx, t_codes)
% Creates a 9-bar histogram for each time point in the parent fraction data
% times = Titles (each histogram represents one time)
% kbq_ml_dkc_mx = y-data
% t_codes = matrix of data types (same dimensions as kbq_ml_dkc_mx) ('M =
% Metabolite', 'P = Parent', etc...)

% Get dimensions of input matrices
[rows, cols] = size(t_codes);

% Figure out how many subplots (num_graphs) will be needed and which row of
% the kbq_ml_dkc matrix will be graphed as the first subplot (first)
first = rows;
num_graphs = 0;
for r=1:rows
    will_graph = false;
    for c=1:cols
        if strcmp(t_codes(r,c),'M') || strcmp(t_codes(r,c),'P')
            if r < first
                first = r-1;
            end
            will_graph = true;
        end
    end
    if will_graph
        num_graphs = num_graphs + 1;
    end
end

% Plot the data
for iter=1:2
    figure;
    hold on;
    for r=1:rows
        sub = false;
        for c=1:cols
            if strcmp(t_codes(r,c),'M') || strcmp(t_codes(r,c),'P')
                sub = true;
            end
        end
        if sub
            subplot(1,num_graphs,r-first);
            met = zeros(1,0);
            parent = zeros(1,0);
            num_m_bars = 0;
            num_p_bars = 0;
            for c=1:cols
                if strcmp(t_codes(r,c),'M')
                    met(end+1)=kbq_ml_dkc_mx(r,c);
                    num_m_bars = num_m_bars + 1;
                elseif strcmp(t_codes(r,c), 'P')
                    parent(end+1)=kbq_ml_dkc_mx(r,c);
                    num_p_bars = num_p_bars+1;
                end
            end
            % Put the parent & met data into different columns to allow for
            % different colors
            data = zeros(num_m_bars+num_p_bars,2);
            data(1:num_m_bars,1) = met';
            data(num_m_bars+1:end,2) = parent';
            h = bar(data,3);
            set(h(1),'FaceColor','r');
            set(h(2),'FaceColor',[.2, 0, 0.8]);
            if iter == 1
                ylim([0 1]);            
                xlabel('Tube #');
                ylabel('kBq/mL');
            else
                ylim('auto');
                xlabel('Tube #');
                ylabel('kBq/mL');
            end
            if (r-first == 1)
                legend('Metabolite', 'Parent', 'Location', 'NorthWestOutside');
            else
                legend 'off';
            end
            title_str = [num2str(round(times(r-first)./60)) ' Min.'];
            title(title_str, 'FontSize', 10, 'FontWeight', 'bold');

            set(gca, 'FontSize', 7);
        end
    end

% Save Histograms as a BMP image
set(gcf, 'Position', [519 711 1250 270]);
disp(iter)
filename = ['histograms_' num2str(iter)];
saveas(gcf, filename, 'bmp');
end

end