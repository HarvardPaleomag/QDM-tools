function [transForm, refFrame] = tform_bin_up(transForm, refFrame, bin)
%[transForm, refFrame] = tform_bin_up(transForm, refFrame, bin)
% Transforms the binned data up to LED. Calls tform_led2data.
% 
% 
% Parameters
% ----------
%     tform: affine2d
%     binning: int
% 
% Example
% -------
%     A binning of 2, the output will decrease the size of an
%     aray from (600x960) -> (1200x1920)

binTransForm = [[1, 1, 1]; [1, 1, 1]; [bin, bin, 1]];
transForm.T = transForm.T .* binTransForm;

refFrame.ImageSize = refFrame.ImageSize * bin;

refFrame.YWorldLimits(2) = refFrame.ImageSize(1) + 0.5;% refFrame.YWorldLimits * bin;
refFrame.XWorldLimits(2) = refFrame.ImageSize(2) + 0.5;%refFrame.XWorldLimits * bin;
