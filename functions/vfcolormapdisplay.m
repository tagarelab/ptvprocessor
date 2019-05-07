function vfcolormapdisplay(colordat, climits, qx, qy, normalize, scale, ...
                                                            sparsity, color)
% VFCOLORMAPDISPLAY     Display velocity map attribute on colormap 
% VFCOLORMAPDISPLAY(colordat, climits, qx, qy) plots normalized RED arrows
% of length 5 from qx, qy matrix inputs, on top of a colormap generated
% from matrix input colordat, with the colors ranging as specified by input
% climits, which is assumed to be a two-element array
% VFCOLORMAPDISPLAY(colordat,climits,qx,qy,normalize,scale,sparsity,color)
% uses qx,qy data to plot arrows with color specified by user, at a scale
% and sparsity specified by the user, on top of a colormap specified by
% colordat and climits

    DEFAULT_SPARSITY = 10;
    DEFAULT_SCALE = 5;
    DEFAULT_COLOR = 'r';
    if nargin < 8
        color = DEFAULT_COLOR;
    end
    if nargin < 7
        sparsity = DEFAULT_SPARSITY;
    end
    if nargin < 5
        normalize = true;
        scale = DEFAULT_SCALE;
    end
    
    % normalize quiver data as desired
    if normalize
        mags = sqrt(qx.^2 + qy.^2);
        qx = qx ./ mags;
        qy = qy ./ mags;
    end
    
    % display the color data
    imagesc(colordat); 
    colorbar; 
    caxis(climits);
    hold on;
    
    % obtain quiver-ready values;
    [x_id, y_id, x_vals, y_vals] = getQuiverInput(qx, qy, sparsity);
    quiver(x_id, y_id, scale * x_vals, scale * y_vals, 0, color); % this is true scaling
    
end

