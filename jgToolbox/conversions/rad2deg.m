function [DEG] = rad2deg(RAD)% function [DEG] = rad2deg(RAD)%% Converts radians to degrees. Degrees are 1/360 of the% full arc of the unit circle, 2pi. So the radians% must be multiplied by (2*pi/360).%% March 23, 1997.  JMG ABS PJB  U of Toronto Vision lab.DEG = RAD/(2*pi/360);return