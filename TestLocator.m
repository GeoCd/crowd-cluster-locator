clear; 
close all; 
clc; 

Detector = vision.CascadeObjectDetector('PersonLocator.xml');
CrowdImage = imread('People2.jpg');
objectBox = step(Detector,CrowdImage);
objectGathering=1;
a=size(objectBox);
for x=1:a(1)
    if (200 < objectBox(x,3) && objectBox(x,3)< 1000) && (200 < objectBox(x,4) && objectBox(x,4)< 1000)
        locatedCrowds(objectGathering,1) = objectBox(x, 1)
        locatedCrowds(objectGathering,2) = objectBox(x, 2)
        locatedCrowds(objectGathering,3) = objectBox(x, 3)
        locatedCrowds(objectGathering,4) = objectBox(x, 4)
        objectGathering=objectGathering+1;
    end
end
detectedCrowds = insertObjectAnnotation(CrowdImage,'rectangle',locatedCrowds,'Person');
figure(1);
imshow(detectedCrowds);