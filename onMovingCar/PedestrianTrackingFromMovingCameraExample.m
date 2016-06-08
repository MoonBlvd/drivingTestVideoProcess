function PedestrianTrackingFromMovingCameraExample()
% Create system objects used for reading video, loading prerequisite data file, detecting pedestrians, and displaying the results.
videoFile       = 'GRMN0090.MP4';
imgHeight = 1080;
bbox = [200, 30, 30, 50; 180, 29, 29, 48; 160, 25, 25, 45];

%scaleDataFile   = 'pedScaleTable.mat'; % An auxiliary file that helps to determine the size of a pedestrian at different pixel locations.

scaleDataFile = helperTableOfScales(bbox,imgHeight);

obj = setupSystemObjects(videoFile, scaleDataFile);

% Create an empty array of tracks.
tracks = initializeTracks();

% ID of the next track.
nextId = 1;

% Set the global parameters.
option.ROI                  = [40 95 400 140];  % A rectangle [x, y, w, h] that limits the processing area to ground locations.
option.scThresh             = 0.3;              % A threshold to control the tolerance of error in estimating the scale of a detected pedestrian.
option.gatingThresh         = 0.9;              % A threshold to reject a candidate match between a detection and a track.
option.gatingCost           = 100;              % A large value for the assignment cost matrix that enforces the rejection of a candidate match.
option.costOfNonAssignment  = 10;               % A tuning parameter to control the likelihood of creation of a new track.
option.timeWindowSize       = 16;               % A tuning parameter to specify the number of frames required to stabilize the confidence score of a track.
option.confidenceThresh     = 2;                % A threshold to determine if a track is true positive or false alarm.
option.ageThresh            = 8;                % A threshold to determine the minimum length required for a track being true positive.
option.visThresh            = 0.6;              % A threshold to determine the minimum visibility value for a track being true positive.

% Detect people and track them across video frames.
cont = ~isDone(obj.reader);
while cont
    frame   = readFrame();

    [centroids, bboxes, scores] = detectPeople();

    predictNewLocationsOfTracks();

    [assignments, unassignedTracks, unassignedDetections] = ...
        detectionToTrackAssignment();

    updateAssignedTracks();
    updateUnassignedTracks();
    deleteLostTracks();
    createNewTracks();

    displayTrackingResults();

    % Exit the loop if the video player figure is closed by user.
    cont = ~isDone(obj.reader) && isOpen(obj.videoPlayer);
end