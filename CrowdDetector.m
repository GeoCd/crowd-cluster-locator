clear; 
close all; 
clc; 

objectPosition=1;
alpha=0.1;
epochs=1000;
Grupo=[0,0,0,0,0,0];

Detector = vision.CascadeObjectDetector('PersonLocator.xml');
CrowdImage = imread('People3.jpg');
[ancho,largo,dimension]=size(CrowdImage);
objectBox = step(Detector,CrowdImage);
objectSizes=size(objectBox);

for x = 1 : objectSizes(1)
    if (200 < objectBox(x,3) && objectBox(x,3)< 1000) && (200 < objectBox(x,4) && objectBox(x,4)< 1000)
        locatedCrowds(objectPosition,1) = objectBox(x, 1);
        locatedCrowds(objectPosition,2) = objectBox(x, 2);
        locatedCrowds(objectPosition,3) = objectBox(x, 3);
        locatedCrowds(objectPosition,4) = objectBox(x, 4);
        objectPosition = objectPosition+1;
    end
end

detectedCrowds = insertObjectAnnotation(CrowdImage,'rectangle',locatedCrowds,'Person');

locatedSize = size(locatedCrowds);

for x = 1 : locatedSize(1)
    P = [(locatedCrowds(x,1)+(locatedCrowds(x,3)/2));...
        ancho-(locatedCrowds(x,2)+(locatedCrowds(x,4)/2))];
    Points(:,x) = P;
end

for x=1:locatedSize(1)
    for y=1:locatedSize(1)
    locationDistances(x,y) = sqrt((Points(1,x)-Points(1,y))^2+...
                                 (Points(2,x)-Points(2,y))^2);
    end
end

for x=1:locatedSize(1)
    minValue = nonzeros(locationDistances(x, :));
    [minRow, minCol] = find(locationDistances(x,:) == min(minValue));
    nearerLocation(1,x)=x;
    nearerLocation(2,x)=minCol;
    nearerLocation(3,x)=min(minValue);
end

for x=1:length(nearerLocation)
    for y=1:length(nearerLocation)/2
        if ((nearerLocation(1,x) == nearerLocation(2,y)) && (nearerLocation(2,x) == nearerLocation(1,y))) 
            rng('shuffle')
            WRandLocation(y,1)=((ancho*0.2) + (ancho*0.25-ancho*0.2) * rand())+...
                (Points(1,nearerLocation(1,x))+Points(1,nearerLocation(1,y)))/2;
            WRandLocation(y,2)=((largo*0.1) + (largo*0.15-largo*0.1) * rand())+...
                (Points(2,nearerLocation(2,x))+Points(2,nearerLocation(2,y)))/2;
        end
    end
end

Wtransposed=WRandLocation;
WFinal=Wtransposed;
[m,n]=size(Points); 
[i,j]=size(WFinal);

figure(1)
subplot(1,2,1)
hold on
title('W Training')
xlim([-500 4500])
ylim([-500 3500])
xline(largo/2)
yline(ancho/2)
plot(WFinal(:,1),WFinal(:,2),'pm') 
plot(Points(1,:),Points(2,:),'*k')

for x=1:epochs 
    for y=1:n
        loops=1;
        for z=1:i 
            Wdistance(z)=sqrt((Points(1,y)-WFinal(z,1))^2+(Points(2,y)-WFinal(z,2))^2);
        end 
        WinnerNN=compet(-Wdistance');
        for z=1:i 
            WFinal(z,:)=WFinal(z,:)+alpha*WinnerNN(z)*(Points(:,y)'-WFinal(z,:));
            plot(WFinal(:,1),WFinal(:,2),'pm')
        end 
    end 
end 

plot(WFinal(:,1),WFinal(:,2),'pg')
legend('PLane X','Plane Y','Iterations W','Persons');

subplot(1,2,2)
hold on
title('Groups Areas')
xlim([-500 4500])
ylim([-500 3500])
xline(largo/2)
yline(ancho/2)
plot(Points(1,:),Points(2,:),'*k') 

for x=-500:100:(largo+500)
    for y=-500:100:(ancho+500)
        for k=1:i
            Testing(k)=sqrt((x-WFinal(k,1))^2+(y-WFinal(k,2))^2);
        end
        PlotAreas = compet(-Testing.');
        if PlotAreas(1)==1
            plot(x,y,'.r')
        elseif PlotAreas(2)==1
            plot(x,y,'.g')
        elseif PlotAreas(3)==1
            plot(x,y,'.b')
        elseif PlotAreas(4)==1
            plot(x,y,'.m')
        elseif PlotAreas(5)==1
            plot(x,y,'.y')
        end
    end
end

legend('PLane X','Plane Y','Persons');

for x=1:n 
    for z=1:i 
        WPdistance(z)=sqrt((Points(1,x)-WFinal(z,1))^2+(Points(2,x)-WFinal(z,2))^2);
    end 
    NumberPersons=compet(-WPdistance');
    if NumberPersons(1)==1
        Grupo(1)=Grupo(1)+1;        
    elseif NumberPersons(2)==1
        Grupo(2)=Grupo(2)+1;
    elseif NumberPersons(3)==1
        Grupo(3)=Grupo(3)+1;
    elseif NumberPersons(4)==1
        Grupo(4)=Grupo(4)+1;
    elseif NumberPersons(5)==1
        Grupo(5)=Grupo(5)+1;
    elseif NumberPersons(6)==1
        Grupo(6)=Grupo(6)+1;
    end
end

%Si no hay coincidencia borrar W y reentrenar

figure(2);
subplot(1,2,1)
hold on;
imshow(detectedCrowds);
title('Original Input');

subplot(1,2,2)
imshow(detectedCrowds);
title('Located Crowd');
hold on;

for y=1:6 
    if 2 <= Grupo(y)
        plot(WFinal(y,1),(ancho-WFinal(y,2)),'pg');
        text(WFinal(y,1), (ancho-WFinal(y,2)),['Located ' num2str(Grupo(y)) ' Entities'], 'FontSize', 9,'Color','Red');
    end
end
legend('Groups')