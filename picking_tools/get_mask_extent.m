function [x, y, w, h] = get_mask_extent(mask, kwargs)
%[x, y, w, h] = get_mask_extent(mask; 'type')
% Takes a mask and retuns the extent of the smallest possible rectangle 
% around it, where values ~= 0.
% 
% Parameters
% ----------
%   mask:
%   type: ('outer')
% 
% Returns
% ----------
%   x:
%   y:
%   w:
%   h:

arguments
    mask double
    kwargs.type = 'outer'
end
[row_index, col_index, ~] = find(~isnan(mask) & mask~= 0);

if strcmp(kwargs.type, 'outer')
    % get min/max indices of mask
    x = int16(min(col_index));
    w = int16(max(col_index)) - x;
    y = int16(min(row_index));
    h = int16(max(row_index)) - y;
end
