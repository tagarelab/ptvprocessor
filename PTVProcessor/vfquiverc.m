function vfquiverc(mu_x, mu_y, sparsity, scale, linewidth)
%VFQUIVERC   Display velocity fields as equal-length arrows, with colorbar.
% VFQUIVERC(mu_x,mu_y,sparsity,scale,linewidth) uses Pascal Ackermann's
% extended quiverc function to draw the velocity field given by velocity
% matrices mu_x,mu_y, using color to indicate magnitude

    % set defaults
    DEFAULT_SPARSITY = 12;
    DEFAULT_SCALE = 15;
    DEFAULT_LINEWIDTH = 0.7;
    
    % set values as needed
    if nargin < 2
        error('not enough inputs');
    end
    if nargin < 5
        linewidth = DEFAULT_LINEWIDTH;
        if nargin < 4
            scale = DEFAULT_SCALE;
            if nargin < 3
                sparsity = DEFAULT_SPARSITY;
            end
        end
    end
    
     % obtain id and values for input into quiver
    [x_id,y_id,xvals,yvals] = getQuiverInput(mu_x,mu_y,sparsity);
   

    quiverc(x_id,y_id,xvals,yvals,'equal',scale,'colorbar');

end

