function binning = detect_binning(inData, kwargs)
%[binning] = detect_binning(inData; 'refFrame')
% 
% Parameters
% ----------
%   inData: struct
%       B111 or Bz data
%   refFrame: ('none')
% 
% Returns
% ----------
%   binning:

arguments
   inData
   kwargs.refFrame = 'none'
end

if isstruct(inData) & strcmp(kwargs.refFrame, 'none')
    % check for differences in LED naming
    [bool, dataName, ledName] = is_B111(inData);

    led = inData.(ledName);
    data = inData.(dataName);

    binning = (size(led,1) / size(data,1));
end

if isa(kwargs.refFrame, 'imref2d')
    binning = kwargs.refFrame.ImageSize ./ size(inData);
    
    if ~ binning(1) == binning(2)
        error('uneven binning')
    end
    
    binning = binning(1);
end

