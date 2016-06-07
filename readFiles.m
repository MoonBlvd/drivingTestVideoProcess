clear all;
% f1 = fopen('ann_arbor.mbinary','r');
% f2 = fopen('lewisburg.mbinary');
% f3 = fopen('nitro.mbinary');
% AA = fread(f1);
% LB = fread(f2);
% NI = fread(f3);
trafficVideo  = VideoReader('GRMN0090.MP4');
nFrames = trafficVideo.NumberOfFrames;
darkCarValue = 180;
whiteCarValue = 100;
ratio = 0.5;
I = read(trafficVideo,1);
I = imresize(I,ratio);
[height,width] = size(I);
I = I(round(height*1/3):end,1:end,:);
findCars = zeros([size(I,1),size(I,2),3,1], class(I));
filename = 'originalVideo.gif';
for i = 60:200
    newFrame = read(trafficVideo,i);
    newFrame = imresize(newFrame,ratio);
    % figure(1);
    % imshow(bwFrame); % cannot do svd on unit8 nor show double image
                     % so show the image before svd

    % corp the image
    newFrame = newFrame(round(height*1/3):end,1:end,:);
    figure(2);
    imshow(newFrame);
    findCars(:,:,:,i) = newFrame; 
    
    bwFrame = rgb2gray(newFrame);

    % compression
    bwFrame = double(bwFrame);
    k = 50;
    [U,S,V] = svd(bwFrame);
    bwFrame = U(:,1:k)*S(1:k,1:k)*V(:,1:k)';
    % remove dark
    noDarkCar = imextendedmax(bwFrame,whiteCarValue);
    noWhiteCar = imextendedmax(bwFrame,darkCarValue);
    
    figure(3);
    subplot(2,1,1)
    imshow(noDarkCar);
    subplot(2,1,2)
    imshow(noWhiteCar);
    
    [imind,cm] = rgb2ind(newFrame,256);
    if i == 60
        imwrite(imind,cm,filename,'gif','loopcount',inf);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append');
    end
    % remove lanes and small objects
    sedisk = strel('disk',20);
    noLaneNoDark = imopen(noDarkCar,sedisk);
    noLaneNoWhite = imopen(noWhiteCar,sedisk);
    % figure(4);
    % imshow(noLane);
    noLaneNoDark = bwareaopen(noLaneNoDark, 150);
    noLaneNoWhite = bwareaopen(noLaneNoWhite, 150);

   
%     stats = regionprops(noLane,{'Centroid','Area'});
%     if ~isempty(stats.Area)
%         aeras = [stats.Area];
%         [maxAera, index] = max(aeras);
%         c = floor(stats(index).Centroid);
%         width = 50;
%         rows = c(2)-width:c(2)+width;
%         cols = c(1)-width:c(1)+width;
%         findCars(rows,cols,1,i) = 255;
%         findCars(rows,cols,2,i) = 0;
%         findCars(rows,cols,3,i) = 0;
%     end
%     figure(5)
%     imshow(findCars);
%     a = 1;
end
frameRate = trafficVideo.FrameRate;
implay(findCars,frameRate);
