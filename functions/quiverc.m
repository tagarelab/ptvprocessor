function hh = quiverc(varargin)
% Modified version QUIVERC BY PASCAL ACKERMANN, extended lightly for
% compatibility with PTVProcessor

% Modified version of Quiver to plots velocity vectors as arrows
% with components (u,v) at the points (x,y) using the current colormap

% Bertrand Dano 3-3-03
% Copyright 1984-2002 The MathWorks, Inc.
% Extended by Pascal Ackermann (pascal.ackermann@rwth-aachen.de) Feb 16 2018

%QUIVERC Quiver color plot.
%   QUIVERC(X,Y,U,V) plots velocity vectors as arrows with components (u,v)
%   at the points (x,y).  The matrices X,Y,U,V must all be the same size
%   and contain corresponding position and velocity components (X and Y
%   can also be vectors to specify a uniform grid).  QUIVERC automatically
%   scales the arrows to fit within the grid.
%
%   QUIVERC(U,V) plots velocity vectors at equally spaced points in
%   the x-y plane.
%
%   QUIVERC(U,V,S) or QUIVERC(X,Y,U,V,S) automatically scales the
%   arrows to fit within the grid and then stretches them by S.  Use
%   S=0 to plot the arrows without the automatic scaling.
%
%   QUIVERC(...,LINESPEC) uses the plot linestyle specified for
%   the velocity vectors.  Any marker in LINESPEC is drawn at the base
%   instead of an arrow on the tip.  Use a marker of '.' to specify
%   no marker at all.  See PLOT for other possibilities.
%
%   QUIVERC(X,Y,U,V,'equal',scaling) scales each arrow to be of length 1.
%   Use the scaling parameter to increase or decrease size.
%
%   QUIVERC(X,Y,U,V,'equal',scaling,'limits',[min max]) sets the limits of
%   the colorbar accordingly. This way, several plots can be achieved using
%   the same colormapping for vector magnitudes (x and y).
%
%   QUIVERC(...,'filled') fills any markers specified.
%
%   H = QUIVERC(...) returns a vector of line handles.
%
%   Example:
%      [x,y] = meshgrid(-2:.2:2,-1:.15:1);
%      z = x .* exp(-x.^2 - y.^2); [px,py] = gradient(z,.2,.15);
%      contour(x,y,z), hold on
%      quiverc(x,y,px,py), hold off, axis image
%
%   See also FEATHER, QUIVERC3, PLOT.
%   Clay M. Thompson 3-3-94
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 5.21 $  $Date: 2002/06/05 20:05:16 $
%-------------------------------------------------------------

set(gca, 'color', 'blue');
% Arrow head parameters
alpha = 0.33; % Size of arrow head relative to the length of the vector
beta = 0.23;  % Width of the base of the arrow head relative to the length
autoscale = 1; % Autoscale if ~= 0 then scale by this.
plotarrows = 1; % Plot arrows
sym = '';

filled = 0;
ls = '-';
ms = '';
col = '';
lw=1;

useEqualArrowLengths = false;
scaling = 1;
useCustomLimits = false;
plotColorbar = false;

nin = nargin;
% Parse the string inputs
while isstr(varargin{nin}),
    vv = varargin{nin};
    if ~isempty(vv) & strcmp(lower(vv(1)),'f')
        filled = 1;
        nin = nin-1;
    else
        if strcmp(lower(vv(1)),'c')
            plotColorbar = true;
            nin = nin-1;
        else
            if strcmp(lower(vv(1)),'l')
                useCustomLimits = true;
                nin = nin-1;
            else
                if strcmp(lower(vv(1)),'e')
                    useEqualArrowLengths = true;
                    nin = nin-1;
                else
                    
                    [l,c,m,msg] = colstyle(vv);
                    if ~isempty(msg),
                        error(sprintf('Unknown option "%s".',vv));
                    end
                    if ~isempty(l), ls = l; end
                    if ~isempty(c), col = c; end
                    if ~isempty(m), ms = m; plotarrows = 0; end
                    if isequal(m,'.'), ms = ''; end % Don't plot '.'
                    nin = nin-1;
                end
            end
        end
    end
end

nin = nargin;
error(nargchk(2,9,nin));

% Check numeric input arguments
if nin<4, % quiverc(u,v) or quiverc(u,v,s)
    [msg,x,y,u,v] = xyzchk(varargin{1:2});
else
    [msg,x,y,u,v] = xyzchk(varargin{1:4});
end
if ~isempty(msg), error(msg); end

if nin==3 | nin==5 % quiverc(u,v,s) or quiverc(x,y,u,v,s) or quiverc(x,y,u,v,'equal')
    if isnumeric(varargin{nin}) % quiverc(u,v,s) or quiverc(x,y,u,v,s)
        autoscale = varargin{nin};
    else
        if strcmp(varargin{nin}, 'equal') % quiverc(x,y,u,v,'equal')
            useEqualArrowLengths = true;
            autoscale = false;
        end
        if strcmp(varargin{nin}, 'colorbar') % quiverc(x,y,u,v,'colorbar')
            plotColorbar = true;
        end
    end
end

if nin==6 | nin==8% quiverc(x,y,u,v,'equal',scaling) or %quiverc(x,y,u,v,'equal',scaling,'limits', [min max])
    useEqualArrowLengths = true;
    scaling = varargin{6};
    autoscale = false;
    if(strcmp(varargin{nin-1}, 'limits'))
        useCustomLimits = true;
        minLimit = varargin{nin}(1);
        maxLimit = varargin{nin}(2);
    end
end

if nin==7 % QUIVERC(X,Y,U,V,'equal',scaling,'colorbar') | 7
    useEqualArrowLengths = true;
    autoscale = false;
    plotColorbar = true;
    scaling = varargin{6};
end

if nin==9 % QUIVERC(X,Y,U,V,'equal',scaling,'limits',[min max],'colorbar')
    autoscale = false;
    plotColorbar = true;
    useCustomLimits = true;
    useEqualArrowLengths = true;
    scaling = varargin{6};
    minLimit = varargin{8}(1);
    maxLimit = varargin{8}(2);
end

% Scalar expand u,v

if prod(size(u))==1, u = u(ones(size(x))); end
if prod(size(v))==1, v = v(ones(size(u))); end


if (autoscale && ~useEqualArrowLengths && ~useCustomLimits)
    % Base autoscale value on average spacing in the x and y
    % directions.  Estimate number of points in each direction as
    % either the size of the input arrays or the effective square
    % spacing if x and y are vectors.
    if min(size(x))==1, n=sqrt(prod(size(x))); m=n; else [m,n]=size(x); end
    delx = diff([min(x(:)) max(x(:))])/n;
    dely = diff([min(y(:)) max(y(:))])/m;
    len = sqrt((u.^2 + v.^2)/(delx.^2 + dely.^2));
    autoscale = autoscale*0.9 / max(len(:));
    u = u*autoscale; v = v*autoscale;
end

%----------------------------------------------
% Define colormap
vr=sqrt(u.^2+v.^2);
if useCustomLimits
    vrn=round(vr/(maxLimit-minLimit)*64);
else
    vrn = round(vr/max(vr(:))*64);
end
jj = customJetColor;
CC=colormap(jj);
ax = newplot;
next = lower(get(ax,'NextPlot'));
hold_state = ishold;
%-----------------------------------------------
% Make vectors the same length
if (useEqualArrowLengths)
    magnitudes = sqrt(u.^2 + v.^2);
    u=(u./magnitudes)*scaling;
    v=(v./magnitudes)*scaling;
end

%----------------------------------------------
% Make velocity vectors and plot them

x = x(:).';y = y(:).';
u = u(:).';v = v(:).';
vrn=vrn(:).';
uu = [x;x+u;repmat(NaN,size(u))];
vv = [y;y+v;repmat(NaN,size(u))];
vrn1= [vrn;repmat(NaN,size(u));repmat(NaN,size(u))];

uui=uu(:);  vvi=vv(:);  vrn1=vrn1(:); imax=size(uui);
hold on

for i=  1:3:imax-1
    ii=int16(round(vrn1(i)));
    if ii==0; ii=1; end
    c1= CC(ii,1);   
    c2= CC(ii,2);    
    c3= CC(ii,3);
    plot(uui(i:i+1),vvi(i:i+1),'linewidth',lw,'color',[c1 c2 c3]);
end

%--------------------------------------------lkuag/packermann
% Add correpsonding colorbar to the plot
%first, get the clim,ytick from hh=colorbar;then convert [vmax,vmin] for yticklabel;

if plotColorbar
    hh=colorbar;
    % set colorbar scaling accordingly
    %caxis([0 max(vr)]);
    magnitudes=sqrt(u.^2 + v.^2);
    qtLim = 0.97;
    maxLimit = quantile(magnitudes, qtLim);
    caxis([0 maxLimit])
    % set colorbar text to white
    hh.Color = 'white';
end

%----------------------------------------------
% Make arrow heads and plot them
if plotarrows,
    
    hu = [x+u-alpha*(u+beta*(v+eps));x+u; ...
        x+u-alpha*(u-beta*(v+eps));repmat(NaN,size(u))];
    hv = [y+v-alpha*(v-beta*(u+eps));y+v; ...
        y+v-alpha*(v+beta*(u+eps));repmat(NaN,size(v))];
    vrn2= [vrn;vrn;vrn;vrn];
    
    uui=hu(:);  vvi=hv(:);  vrn2=vrn2(:); imax=size(uui);
    
    for i=  1:imax-1
        ii=int16(round(vrn2(i)));
        if ii==0; ii=1; end
        c1= CC(ii,1);    c2= CC(ii,2);    c3= CC(ii,3);
        plot(uui(i:i+1),vvi(i:i+1),'linewidth',lw,'color',[c1 c2 c3]);
    end
    
else
    h2 = [];
end
%----------------------------------------------

if ~isempty(ms), % Plot marker on base
    hu = x; hv = y;
    hold on
    h3 = plot(hu(:),hv(:),[col ms]);
    if filled, set(h3,'markerfacecolor',get(h1,'color')); end
else
    h3 = [];
end

if ~hold_state, hold off, view(2); set(ax,'NextPlot',next); end

if nargout>0, hh = [h1;h2;h3]; end
set (gca,'Ydir','reverse')
set(gca, 'color', [0 0 0],'Xcolor','w','Ycolor','w');
set(gcf, 'color', [0 0 0]);
set(gcf, 'InvertHardCopy', 'off');