foregroundDetector = vision.ForegroundDetector(...
    'NumGaussians', 3, 'NumTrainingFrames', 50);
videoReader = vision.VideoFileReader('GRMN0090.MP4');

filename = 'motionBasedResult.gif';

for i = 1:59
    frame = step(videoReader); % read the next video frame
end
for i = 60:200
    frame = step(videoReader);
    foreground = step(foregroundDetector, frame);
    
    se = strel('square', 3);
    filteredForeground = imopen(foreground, se);
    blobAnalysis = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
    'AreaOutputPort', false, 'CentroidOutputPort', false, ...
    'MinimumBlobArea', 150);
    bbox = step(blobAnalysis, filteredForeground);
    result = insertShape(frame, 'Rectangle', bbox, 'Color', 'green');
    figure(3); imshow(result); title('Detected Cars');

    
    figure(1); 
    imshow(frame); title('Video Frame');
    figure(2);
    imshow(foreground); title('Foreground');

    [imind,cm] = rgb2ind(result,256);
    if i == 60
        ;
    else
        if i ==61
            imwrite(imind,cm,filename,'gif','loopcount',inf);
        else
            imwrite(imind,cm,filename,'gif','WriteMode','append');
        end
    end
end

