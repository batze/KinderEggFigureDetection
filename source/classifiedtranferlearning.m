folderName = "getImage.m";
imds = imageDatastore(getImage
    IncludeSubfolders=true, ...
    LabelSource="foldernames");
numImages = numel(imds.Labels);
idx = randperm(numImages,16);
I = imtile(imds,Frames=idx);
figure
imshow(I)
classNames = categories(imds.Labels);
numClasses = numel(classNames);
[imdsTrain,imdsValidation,imdsTest] = splitEachLabel(imds,0.7,0.15,0.15,"randomized");

options = trainingOptions("adam", ...
    ValidationData=imdsValidation, ...
    ValidationFrequency=5, ...
    Plots="training-progress", ...
    Metrics="accuracy", ...
    Verbose=false);
net = trainnet(imdsTrain,net_1,"crossentropy",options);

inputSize = net.Layers(1).InputSize(1:2);

augimdsTrain = augmentedImageDatastore(inputSize,imdsTest);

YTest = minibatchpredict(net,imdsTest);
YTest = scores2label(YTest,classNames);

TTest = imdsTest.Labels;
figure
confusionchart(TTest,YTest);

%Classify New Image
im = imread("MerchDataTest.jpg");

im = imresize(im,inputSize(1:2));
X = single(im);

scores = predict(net,X);
[label,score] = scores2label(scores,classNames);

figure
imshow(im)
title(string(label) + " (Score: " + gather(score) + ")")