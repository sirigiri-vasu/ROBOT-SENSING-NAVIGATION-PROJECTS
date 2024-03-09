function [xc, yc, R] = circfit(x,y)
% CIRCFIT Fits a circle to a set of points using least squares.
%   [XC, YC, R] = CIRCFIT(X,Y) returns the center and radius of the best fit
%   circle to the points (X,Y). The input vectors X and Y must have the same
%   size.
%
%   The algorithm used in this function is based on the least-squares method
%   described in the paper "Least-squares fitting of circles and ellipses"
%   by W. Gander, G. Golub, and R. Strebel (BIT Numerical Mathematics, 1989).
%
%   Written by Amro (2017)

% determine the size of the input data
n = length(x);

% compute the sums of squares
x2 = x .* x;
y2 = y .* y;
Sx = sum(x);
Sy = sum(y);
Sx2 = sum(x2);
Sy2 = sum(y2);
Sxy = sum(x .* y);

% compute the coefficients of the linear system
A = [n, Sx, Sy; Sx, Sx2, Sxy; Sy, Sxy, Sy2];
B = [-sum(x2 + y2), -sum(x .* (x2 + y2)), -sum(y .* (x2 + y2))]';

% solve the linear system
C = A \ B;

% extract the center and radius of the circle
xc = -C(2) / 2;
yc = -C(3) / 2;
R = sqrt(xc^2 + yc^2 - C(1));

% return the results
end
