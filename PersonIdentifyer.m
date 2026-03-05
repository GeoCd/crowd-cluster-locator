load('People.mat');
positveInst=People;
PosDir=fullfile('c:\','Users','Jorge','OneDrive','Escritorio','UPIITA','Neurodifusos','ProjectTest2','Positives');
addpath(PosDir);
NegDir=fullfile('c:\','Users','Jorge','OneDrive','Escritorio','UPIITA','Neurodifusos','ProjectTest2','Negatives');
trainCascadeObjectDetector('PersonLocator.xml',positveInst,NegDir,'NumCascadeStages',9,'FalseAlarmRate',0.1,'FeatureType','Haar');