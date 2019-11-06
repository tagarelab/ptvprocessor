function vf_overlay(mu_x, mu_y, img, sparsity, scale, color, linewidth)
% VF_OVERLAY    Display velocity vectors overlaid on top of img
% VF_OVERLAY(mu_x, mu_y, img, sparsity, scale) displays green arrows with
% default line width 0.7 on top of img. Green arrows are two dimensional
% velocity vectors as represented by mu_X, mu_y, which are assumed to be
% matrices of the same size as the img. The 'sparsity' indicates how many
% pixels are skipped, vertically and horizontally, between vectors. 
% VF_OVERLAY(mu_x, mu_Y, img, sparsity, scale, color, linewidth) performs
% the overlaying display with the specified arrow color and linewidth

    % set defaults
    SCALE = scale;
    if nargin < 6
        color = 'g';
    end
    if nargin < 7
        linewidth = 0.7;
    end
    % obtain id and values for input into quiver
    [x_id,y_id,x_vals,y_vals] = getQuiverInput(mu_x,mu_y,sparsity);
   
    hold off;
    imshow(mat2gray(img));
    hold on;
    % scale is performed this way in order to achieve TRUE SCALE, as
    % Matlab's quiver function will otherwise do automatic normalization
    q=quiver(x_id, y_id, SCALE * x_vals,SCALE * y_vals, 0, color); % this is true scaling
    q.LineWidth=linewidth;
end
    
