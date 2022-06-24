function fit_center_crop(filePath, cropSize, fitParams)
%fit_center_crop('filePath', 'cropSize', 'fitOrder', 'xy', 'cropFactor', 'downSample', 'nRuns', 'quad', 'outputtrue', 'checkPlot', 'statsPlot', 'save', 'constrained', 'm0', 'hguess', 'minheight', 'maxheight', 'boxwidth', 'method', 'noise', 'SNR', 'AUTO', 'minTol', 'display', 'expData', 'dx', 'dy', 'imagefolder', 'sourceName')
% 
% Parameters
% ----------
%   filePath:
%   cropSize:
%   filePath: ('none')
%   cropSize: ([50,50])
%   fitOrder: ('none')
%   xy: ('picker')
%   cropFactor: ('none')
%   downSample: (1 % speedup)
%   nRuns: (10)
%   quad: (1)
%   outputtrue: (true)
%   checkPlot: (true)
%   statsPlot: (false)
%   save: (false)
%   constrained: (false)
%   m0: (1e-12)
%   hguess: (2.5e-5)
%   minheight: (0)
%   maxheight: (100e-6)
%   boxwidth: (100e-6)
%   method: (1 %0)
%   noise: (0 %0)
%   SNR: (0 %signal-to-noise ratio in dB)
%   AUTO: (0 %automatically find dipole position from Bt map)
%   minTol: (1)
%   display: (false)
%   expData: ('none' % loaded data passed -> no need to load data again)
%   dx: (false)
%   dy: (false)
%   imagefolder: ('none')
%   sourceName: ('none')
% 
% Returns
% ----------
 
arguments
    filePath = 'none';
    cropSize = [50,50];
    
    fitParams.fitOrder = 'none';
    fitParams.xy = 'picker';
    fitParams.cropFactor = 'none';
    fitParams.downSample = 1; % speedup
    fitParams.nRuns = 10;
    fitParams.quad = 1;
    fitParams.outputtrue {mustBeBoolean(fitParams.outputtrue)} = true;
    fitParams.checkPlot (1,1) {mustBeBoolean(fitParams.checkPlot)} = true;
    fitParams.statsPlot (1,1) {mustBeBoolean(fitParams.statsPlot)} = false;
    fitParams.save {mustBeBoolean(fitParams.save)} = false; 
    
    fitParams.constrained {mustBeBoolean(fitParams.constrained)} = false; 
    fitParams.m0 = 1e-12;
    fitParams.hguess = 2.5e-5;
    fitParams.minheight = 0;
    fitParams.maxheight = 100e-6;
    fitParams.boxwidth = 100e-6;

    fitParams.method = 1; %0 = least squares, 1=Nelder-Mead
    fitParams.noise = 0; %0 = no noise
    fitParams.SNR = 0; %signal-to-noise ratio in dB
    fitParams.AUTO = 0; %automatically find dipole position from Bt map
    fitParams.minTol = 1;
    fitParams.display {mustBeBoolean(fitParams.display)} = false;
    
    fitParams.expData = 'none'; % loaded data passed -> no need to load data again
    fitParams.dx = false
    fitParams.dy = false
    
    fitParams.imagefolder = 'none';
    fitParams.sourceName = 'none'
end

filePath = automatic_input_ui__(filePath, 'title', 'pick Bz file for fitting', 'type', 'file');
fitParameter = namedargs2cell(fitParams);
fit = fit_source('filePath', filePath, fitParameter{:});

X = [round(fit.x - cropSize(1)/2), round(fit.x + cropSize(1)/2)];
Y = [round(fit.y - cropSize(2)/2), round(fit.y + cropSize(2)/2)];

crop_map('filePath', filePath, 'row', Y, 'col', X, 'checkPlot', fitParams.checkPlot);

msg = sprintf('Cropping the map around source location (%i px, %i px)', round(fit.x), round(fit.y));
logMsg('info', msg, 1, 0);