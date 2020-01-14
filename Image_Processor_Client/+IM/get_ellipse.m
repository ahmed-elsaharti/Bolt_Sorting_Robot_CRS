function E = get_ellipse(Img, direct)
%GET_ELLIPSE Equivalent ellipse of an image
%   E = IM.GET_ELLIPSE(IMG) finds the equivalent ellipse of an image IMG. 
%   IMG is a n-by-m image, and E is a structure containing the ellipse 
%   properties.
%
%   E = IM.GET_ELLIPSE(..., 'direct', false) will not try to assign a
%   direction based on the third moment. The orientation of the object will
%   be unchanged but the direction is pi-undetermined.
%
%   See also: IM.draw_ellipse

% --- Default values
if ~exist('direct', 'var')
    direct = true;
end

% --- Computing moments

% Object's pixels coordinates
I = find(Img);
[j, i] = ind2sub(size(Img), I);

% Function handle to compute the moments
moment = @(p,q) sum((i.^p).*(j.^q).*double(Img(I)));

% --- Prepare the output
E = struct();

% --- Get the Moments
E.m00 = moment(0, 0);
E.m10 = moment(1, 0);
E.m01 = moment(0, 1);
E.m11 = moment(1, 1);
E.m02 = moment(0, 2);
E.m20 = moment(2, 0);

% --- Ellipse properties

%EXTRA PARAMS
%Area:
E.area = E.m00;


% Barycenter
E.x = E.m10/E.m00;
E.y = E.m01/E.m00;

% Central moments (intermediary step)
a = E.m20/E.m00 - E.x^2;
b = 2*(E.m11/E.m00 - E.x*E.y);
c = E.m02/E.m00 - E.y^2;

% Orientation (radians)
E.theta = 1/2*atan(b/(a-c)) + (a<c)*pi/2;

% Minor and major axis
E.w = sqrt(8*(a+c-sqrt(b^2+(a-c)^2)))/2;
E.l = sqrt(8*(a+c+sqrt(b^2+(a-c)^2)))/2;

% Ellipse focal points
d = sqrt(E.l^2-E.w^2);
E.x1 = E.x + d*cos(E.theta);
E.y1 = E.y + d*sin(E.theta);
E.x2 = E.x - d*cos(E.theta);
E.y2 = E.y - d*sin(E.theta);

% Ellipse direction
if direct
    tmp = [i-mean(i) j-mean(j)]*[cos(E.theta) -sin(E.theta) ; sin(E.theta) cos(E.theta)];
    if skewness(tmp(:,1))>0
        
        % Fix direction
        E.theta = mod(E.theta + pi, 2*pi);
        tmp = [E.x1 E.y1];
        
        % Swap F1 and F2
        E.x1 = E.x2;
        E.y1 = E.y2;
        E.x2 = tmp(1);
        E.y2 = tmp(2);
    end
end