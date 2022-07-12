function fits = plotResults_CommLine(dataFolder, folderName, type, fits, binSize, kwargs)
%[fits] = plotResults_CommLine(dataFolder, folderName, type, fits, binSize; 'checkPlot', 'crop')
% 
% Parameters
% ----------
%   dataFolder:
%   folderName:
%   type:
%   fits:
%   binSize:
%   checkPlot: (false)
%   crop: ('none')
% 
% Returns
% ----------
%   fits:

arguments
    dataFolder
    folderName
    type
    fits
    binSize
    kwargs.checkPlot (1, 1) {mustBeBoolean(kwargs.checkPlot)} = false;
    kwargs.crop = 'none'
end

close all;
 
myDir = dataFolder;

ledFiles = dir(fullfile(myDir,'led.csv'));   %grab the first / only CSV
ledImgPath = fullfile(myDir, ledFiles(1).name);
ledImg = load(ledImgPath);

laserFiles = dir(fullfile(myDir,'laser.csv'));   %grab the first / only CSV
laserImgPath = fullfile(myDir, laserFiles(1).name);
laserImg = load(laserImgPath);

if ~strcmp(kwargs.crop, 'none')
    x0 = kwargs.crop(1);
    y0 = kwargs.crop(2);
    x1 = kwargs.crop(3)+x0;
    y1 = kwargs.crop(4)+y0;
    ledImg = ledImg(y0:y1,x0:y1);
    laserImg = laserImg(y0:y1,x0:x1);
end
gamma = 0.0028;
 
if type == 'np  '
    negB111Output = load(fullfile(myDir, folderName, 'run_00000.matdeltaBFit.mat'));
    posB111Output = load(fullfile(myDir, folderName, 'run_00001.matdeltaBFit.mat'));
    
    negDiff = - real( (negB111Output.Resonance2-negB111Output.Resonance1)/2 / gamma );
    posDiff = real( (posB111Output.Resonance2-posB111Output.Resonance1)/2 / gamma );

    B111ferro = (posDiff + negDiff)/2;
    B111para = (posDiff - negDiff)/2;
else
  if type == 'nppn'
    negB111Output = load(fullfile(myDir, folderName, 'run_00000.matdeltaBFit.mat'));
    posB111Output = load(fullfile(myDir, folderName, 'run_00001.matdeltaBFit.mat'));
    
    negDiff = - real( (negB111Output.Resonance2-negB111Output.Resonance1)/2 / gamma );
    posDiff = real( (posB111Output.Resonance2-posB111Output.Resonance1)/2 / gamma );
    
    negB111Output2 = load(fullfile(myDir, folderName, 'run_00003.matdeltaBFit.mat'));
    posB111Output2 = load(fullfile(myDir, folderName, 'run_00002.matdeltaBFit.mat'));
    
    negDiffR = - real( (negB111Output2.Resonance2-negB111Output2.Resonance1)/2 / gamma );
    posDiffR = real( (posB111Output2.Resonance2-posB111Output2.Resonance1)/2 / gamma );
    
    B111ferro = (posDiff + negDiff + posDiffR + negDiffR)/4;  %must divide ferro part by 2
    B111para = (posDiff - negDiff + posDiffR - negDiffR)/4;
  end
end
 
% get Chi squared values for pos and neg. fields / left right fit
chi2Pos1 = posB111Output.chiSquares1;
chi2Pos2 = posB111Output.chiSquares2;
chi2Neg1 = negB111Output.chiSquares1;
chi2Neg2 = negB111Output.chiSquares2;
% reshape the chi2 to conform to pixels
chi2Pos1 = reshape(chi2Pos1, size(B111ferro));
chi2Pos2 = reshape(chi2Pos2, size(B111ferro));
chi2Neg1 = reshape(chi2Neg1, size(B111ferro));
chi2Neg2 = reshape(chi2Neg2, size(B111ferro));

%% determine overall fit Success
pixelAlerts = posB111Output.pixelAlerts | negB111Output.pixelAlerts;

%% SAVE results for plotting later
B111dataToPlot.negDiff = double(negDiff); B111dataToPlot.posDiff = double(posDiff); 
B111dataToPlot.B111ferro = double(B111ferro); B111dataToPlot.B111para = double(B111para);
B111dataToPlot.chi2Pos1 = double(chi2Pos1); B111dataToPlot.chi2Pos2 = double(chi2Pos2); 
B111dataToPlot.chi2Neg1 = double(chi2Neg1); B111dataToPlot.chi2Neg2 = double(chi2Neg2);
B111dataToPlot.ledImg = ledImg; B111dataToPlot.pixelAlerts = pixelAlerts; 
B111dataToPlot.laser = laserImg;

save(fullfile(myDir, folderName, 'B111dataToPlot.mat'), '-struct', 'B111dataToPlot');

%% add to final_fits structure
fits.negDiff = negDiff; fits.posDiff = posDiff; 
fits.B111ferro = B111ferro; fits.B111para = B111para;
fits.ledImg = ledImg; fits.laserImg = laserImg; 
fits.pixelAlerts = pixelAlerts;

ODMR_to_B111_plot(fits, fullfile(myDir, folderName));
% %% PLOTS
% rng = .03;
% 
% r1 = nanmean(B111para(~pixelAlerts))-rng;    r2 = nanmean(B111para(~pixelAlerts))+rng;
%  
% %f1=figure; imagesc( (negDiff) ); axis equal tight; caxis([-r2 -r1]); colorbar; colormap(gca, turbo(512)); title('Negative current B_{111} (gauss)'); set(gca,'YDir','normal');
% [f1, ~, ~] = QDM_figure(negDiff, 'preThreshold', false, 'title', 'Negative current B_{111} (gauss)', 'cbTitle', 'B_{111} (G)');
% saveas(f1, fullfile(myDir, folderName,  'negCurrent.png'),'png');
% 
% %f2=figure; imagesc( (posDiff) ); axis equal tight; caxis([r1 r2]); colorbar; colormap(gca, turbo(512)); title('Positive current B_{111} (gauss)'); set(gca,'YDir','normal');
% [f2, ~, ~] = QDM_figure(posDiff, 'preThreshold', false, 'title', 'Positive current B_{111} (gauss)', 'cbTitle', 'B_{111} (G)');
% saveas(f2, fullfile(myDir, folderName,  'posCurrent.png'),'png');
% 
% %f3=figure; imagesc( B111ferro ); axis equal tight; caxis(-.1 + [-rng rng]); colorbar; colormap(gca, turbo(512)); title('Positive + negative ferro B_{111} (gauss)'); set(gca,'YDir','normal');
% [f3, ~, ~] = QDM_figure(B111ferro, 'preThreshold', false, 'title','Positive + negative ferro B_{111} (gauss)', 'cbTitle', 'B_{111} (G)');
% saveas(f3, fullfile(myDir, folderName,  'ferromagImg.png'),'png');
% 
% %f4=figure; imagesc(ledImg); axis equal tight; colorbar; colormap(gca, gray(512)); caxis auto; title('LED image'); set(gca,'YDir','normal');
% [f4, ~, ~] = QDM_figure(ledImg, 'preThreshold', false, 'led', true, 'title', 'LED image');
% saveas(f4, fullfile(myDir, folderName,  'ledImg.png'),'png');
% 
% %f5=figure; imagesc( B111para ); axis equal tight; caxis([r1 r2]); colorbar; colormap(gca, turbo(512)); title('Positive + negative para B_{111} (gauss)'); set(gca,'YDir','normal');
% [f5, ~, ~] = QDM_figure(B111para, 'preThreshold', false, 'title','Positive - negative ferro B_{111} (gauss)', 'cbTitle', 'B_{111} (G)');
% saveas(f5, fullfile(myDir, folderName,  'paramagImg.png'),'png');
% 
% f6=figure('Name','data','units','normalized','outerposition',[0 0 1 1]); set(gca,'YDir','normal');
% s1 = subplot(2,2,1); %imagesc( (negDiff) ,'hittest', 'off'); axis equal tight; caxis auto; colorbar; colormap(s1,turbo(512)); title('Negative current B_{111} (gauss)'); set(gca,'YDir','normal');
% QDM_figure(negDiff, 'ax', s1, 'preThreshold', false, 'title', 'Negative current B_{111} (gauss)', 'cbTitle', 'B_{111} (G)');
% caxis(auto
% s2 = subplot(2,2,2); %imagesc( (posDiff) ,'hittest', 'off'); axis equal tight; caxis auto; colorbar; colormap(s2,turbo(512)); title('Positive current B_{111} (gauss)'); set(gca,'YDir','normal');
% QDM_figure(posDiff, 'ax', s2, 'preThreshold', false, 'title', 'Positive current B_{111} (gauss)', 'cbTitle', 'B_{111} (G)');
% s3 = subplot(2,2,3); %imagesc( B111ferro ,'hittest', 'off'); axis equal tight;  caxis(mean2(B111ferro) + [-rng rng]); colorbar; colormap(s3,turbo(512)); title('Positive + negative ferro B_{111} (gauss)'); set(gca,'YDir','normal');
% QDM_figure(B111ferro, 'ax', s3, 'preThreshold', false, 'title','Positive + negative ferro B_{111} (gauss)', 'cbTitle', 'B_{111} (G)');
% s4 = subplot(2,2,4); %imagesc( (ledImg) ,'hittest', 'off'); axis equal tight; colorbar; colormap(s4,gray(512)); caxis auto; title('LED image'); set(gca,'YDir','normal');
% QDM_figure(ledImg, 'ax', s4, 'preThreshold', false, 'led', true, 'title', 'LED image');
% sgtitle(', B111 points up and out of page');
% ax = [s1,s2,s3];
% linkaxes(ax);
% saveas(f6, fullfile(myDir, folderName, 'allPlots.png'),'png');
% 
% map = [ 1 1 1; 1 0 0];
% f7=figure; imagesc( pixelAlerts ); axis equal tight; colormap(gca, map); title('pixel alerts'); set(gca,'YDir','normal');
% saveas(f7, fullfile(myDir, folderName,  'pixelAlerts.png'),'png');

if kwargs.checkPlot
    fig = figure('Name', 'spectra');
    bin.ledImg = ledImg;
    bin.B111ferro = B111ferro;
    binSize = detect_binning(bin);
    points = [0,0,0];
    for s = ax
       set(s,'ButtonDownFcn',{@clickFitFcn, binSize, ...
           negB111Output, negB111Output, points, ax, f6})
    end
    waitfor(f6)
    close all
    drawnow;
end


end

function clickFitFcn(hObj, event, binSize, posB111Output, negB111Output, points, ax, fig)
%clickFitFcn(hObj, event, binSize, posB111Output, negB111Output, points, ax, fig)
    % Get click coordinate
    spec = findobj( 'Type', 'Figure', 'Name', 'spectra' );
    dat = findobj( 'Type', 'Figure', 'Name', 'data' );
    
    click = event.IntersectionPoint;
    x = round(click(1));
    y = round(click(2));

    titleTxt = sprintf('X: %4i (%4i) Y: %4i (%4i)', ...
        round(x),round(x)*binSize,round(y), round(y)*binSize);
    
    %% plot spectra
    set(0, 'currentfigure', spec)
    ax1 = subplot(1,2,1); cla(); hold on
    
    plot(ax1, posB111Output.Freqs1, squeeze(posB111Output.Resonance1(y,x,:)), 'k.-','DisplayName','+')
    plot(ax1, negB111Output.Freqs1, squeeze(negB111Output.Resonance1(y,x,:)), 'k.-','DisplayName','-')
    
    ax2 = subplot(1,2,2); cla(); hold on
    plot(ax2, posB111Output.Freqs2, squeeze(posB111Output.Resonance2(y,x,:)), 'k.-','DisplayName','+')
    plot(ax2, negB111Output.Freqs2, squeeze(negB111Output.Resonance2(y,x,:)), 'k.-','DisplayName','-')
    
    %% plot points
    set(0, 'currentfigure', dat)
    for a = [ax1 ax2]
        ylabel(a, 'Intensity')
        xlabel(a, 'f (Hz)')
        legend(a, 'Location','southwest', 'NumColumns',3)
    end
    
    for i = 1:3
        point = points(i);
        if point ~= 0
            delete(point);
        end
        set(dat, 'currentaxes', ax(i))
        hold on
        point = scatter(round(x),round(y),'xr');
        points(i) = point;
    end
    title(ax1, titleTxt)
end