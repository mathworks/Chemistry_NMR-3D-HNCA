
function Visualizing_HNCA(dataFileName)
% Visualizing_HNCA Visualizes HNCA data from a given file
% This function loads HNCA data from a specified MATLAB .mat file and
% allows the user to interactively explore the data through generated
% figures.
%
% Usage:
%   Visualizing_HNCA(dataFileName) - dataFileName is the name of the .mat file
%   containing 'c_ax_ppm', 'h_ax_ppm', 'n_ax_ppm', and 'data' variables.

if nargin < 1
    error('Visualizing_HNCA requires the name of a .mat file as input.');
end

try
    load(dataFileName,'c_ax_ppm','h_ax_ppm','n_ax_ppm','data');
catch ME
    error('Failed to load the specified file. Please check the file name and path.');
end

% Get the Nitrogen spectrum
n_spectrum = max(max(data, [], 2), [], 3);
n_spectrum = squeeze(n_spectrum);
% Normalise Nitrogen Spectrum
n_spectrum = n_spectrum / max(n_spectrum, [], 'all');

% Get the tile layout
figure();
tiledlayout(3, 4);

% Assuming you want to scale the figure window to a specific size, e.g., 800x600 pixels
set(gcf, 'Position', [100, 100, 800, 600]); % Adjust [100, 100, 800, 600] as needed

while true
    % Plot nitrogen spectrum
    nexttile(3, [1 2]);
    plot((n_ax_ppm), flip(n_spectrum));
    xlabel('^{15}N Slice');

    % Pick nitrogen position from graph ppm
    [x, ~] = ginput(1);

    % Nitrogen ppm position needs to be converted to corresponding slice position
    x_axis_diff = n_ax_ppm(2) - n_ax_ppm(3);
    n_slice = ceil((n_ax_ppm(1) - x) / x_axis_diff);

    % Red line at plot
    xline(x, '-r');

    % Extract nitrogen spectrum
    hc_slice = squeeze(data(n_slice, :, :));

    % Plot the slice
    nexttile(1, [3 2]);
    smax = max(hc_slice, [], 'all');
    levels = 0.95 * smax * linspace(0, 1, 20).^2 + 0.05 * smax;
    contour(h_ax_ppm, c_ax_ppm, hc_slice, levels);
    set(gca, 'XDir', 'reverse', 'YDir', 'reverse');
    xlabel('^{1}H chemical shift, ppm');
    ylabel('^{13}C chemical shift, ppm'); drawnow;
    title("Pyruvate Labelled GB1 HNCA Slice nitrogen ppm " + (x))

    % Reset figure "SPACE" button press
    set(gcf, 'currentch', char(1))

    % Go interactive
    while true
        % Get mouse input
        nexttile(1, [3 2]);
        [h_ppm, c_ppm] = ginput(1);

        % Locate nearest pixel
        h_px = dsearchn(h_ax_ppm, h_ppm);
        c_px = dsearchn(c_ax_ppm, c_ppm);

        % Get the snippet
        h_px = [h_px - 16, h_px + 15];
        c_px = [c_px - 32, c_px + 31];
        if all(h_px >= 1) && all(h_px <= size(hc_slice, 2)) && all(c_px >= 1) && all(c_px <= size(hc_slice, 1))
            % Extract snippet
            snip = hc_slice(c_px(1):c_px(2), h_px(1):h_px(2));
            snip_h_ppm = h_ax_ppm(h_px(1):h_px(2));
            snip_c_ppm = c_ax_ppm(c_px(1):c_px(2));

            % Plot snippet
            nexttile(7, [2, 2]);
            imagesc(snip_h_ppm, snip_c_ppm, snip); hold on;
                plot([snip_h_ppm(6) snip_h_ppm(6)],...
                     [snip_c_ppm(1) snip_c_ppm(end)],'w--');
                plot([snip_h_ppm(end-6) snip_h_ppm(end-6)],...
                     [snip_c_ppm(1) snip_c_ppm(end)],'w--');
                plot([snip_h_ppm(1) snip_h_ppm(end)],...
                     [snip_c_ppm(12) snip_c_ppm(12)],'w--');
                plot([snip_h_ppm(1) snip_h_ppm(end)],...
                     [snip_c_ppm(end-12) snip_c_ppm(end-12)],'w--');
                xlabel('^{1}H chemical shift , ppm');
                ylabel('^{13}C chemical shift, ppm'); title('First snippet');
                set(gca,'XDir','reverse','YDir','reverse');
                axis tight; axis square; drawnow; hold off;

            %If any keyboard pressed break loop reselect peak
            if get(gcf,'CurrentCharacter')~=char(1)
                break;
            end 
        end
    end
end
end








    

