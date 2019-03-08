%% Load data - extract information
% Run Analysis.m
% or load Input files

% Input files:
% Data:         'm6FinalData_Analysis.mat'  'm11FinalData_Analysis.mat'
% Training:     'm6TrainingJams.mat'        'm11TrainingJams.mat'
% TestingV1:    'm6TestingJamsV1.mat'       'm11TestingJamsV1.mat'
% TestingV2:    'm6TestingJamsV2.mat'       'm11TestingJamsV2.mat'
% TestingV3:    'm6TestingJamsV3.mat'       'm11TestingJamsV3.mat'

% data (l)
% 1-5: link_id, m_date, absolute_time, travel_time, free_flow
% 6-10: profile_time, traffic_concentration, traffic_speed, traffic_flow, traffic_headway
% 11-14: congestion_event, poor_event, other_event, day_week
% 15: regime
% traffic_intensity_no_smoothed, traffic_intensity_smoothed (l)
% (initialJamIndex finalJamIndex lengthJam maxIntensity sizePerJam
% eventPercentage) (s0)
% trainTestData (l)

% indexFilter numValidJams (s)
% initialValidJamIndex finalValidJamIndex durationJam maxIntJam
%       sizeJam minuteInitialJam dayInitialJam (s)
% indexDataFilter intensityDataFilter (l)   %most important!

%% Upload
clear
motorway = 6;

if motorway == 6
    load m6FinalData_Analysis.mat
    %load m6TrainingJams.mat
    load m6TestingJamsV3.mat
else
    load m11FinalData_Analysis.mat
    %load m11TrainingJams.mat
    load m11TestingJamsV3.mat
end

%% Information
numMethods = 17;
finalModels = [1 3 8 10 11 16]; %[1 2 3 4 6 8 10 11 13 15];
nameModels = {'Thales','Thales 2.4','x2','Intensity algorithm',''...
    ,'Relative maximum algorithm','','Dynamical Trapezoid','Linear regression','Random guess'...
    ,'Linear model','','Mixed #1','Mixed #2','Mixed #3','Bayesian','Bayesian_time'};

% Parameter
minPrediction = 20; % min predicted duration

% Plots font
fontSizeGlobal = 21;

%% Parameter for 11 (Linear model)
if motorway == 6
    LinearModel = dlmread('Linear_Model_M6_toCalibrate.csv',' ',1,0);
else
    LinearModel = dlmread('Linear_Model_M11_toCalibrate.csv',' ',1,0);
end
linearParameters = [LinearModel(:,1:3) zeros(size(LinearModel,1),1)];
linearParameters(1:end-1,4) = linearParameters(2:end,3);
linearParameters(end,4) = Inf;

%% Parameter for 16-17 (Bayesian) if run
if motorway == 6
    load 'm6BayesianParameters.mat'
    load 'm6BayesianParametersMinute.mat'
else
    load 'm11BayesianParameters.mat'
    load 'm11BayesianParametersMinute.mat'
end

%Adjust weight matrix for model 17
[A,B] = max(weightTimeMatrix,[],2);
weightTimeMatrix = zeros(size(weightTimeMatrix,1),size(weightTimeMatrix,2));
for k = 1:size(weightTimeMatrix,1)
    weightTimeMatrix(k,B(k)) = 1;
end
%weightTimeMatrix = [weightTimeMatrix; ones(max(durationJam)-size(weightTimeMatrix,1),size(weightTimeMatrix,2))/size(weightTimeMatrix,2)];
weightTimeMatrix = [weightTimeMatrix; zeros(max(durationJam)-size(weightTimeMatrix,1),1) zeros(max(durationJam)-size(weightTimeMatrix,1),1) ones(max(durationJam)-size(weightTimeMatrix,1),1)];


%% Prediction matrix for 1,2,3,...? (Un-supervised/Supervised(11,16))
predictions = zeros(length(intensityDataFilter),numMethods);
T = 10;

for i = 1:numValidJams
    % --- Find intensity and intensity mean of last T values ----
    intensityJam = intensityDataFilter(initialValidJamIndex(i):finalValidJamIndex(i));
    meanTValuesMatrix = nan(durationJam(i),T);
    for k = 1:T
        meanTValuesMatrix(T+1:end,k) = intensityJam(T+1-k:end-k);
    end
    meanTValues = nanmean(meanTValuesMatrix,2);
    stdTValues = nanstd(meanTValuesMatrix,0,2);
    
    % --- Define going upwards and going downwards ----
    paramTolerance = 0.5;
    upIntensity = intensityJam >= meanTValues + paramTolerance*stdTValues;
    upIntensity(1:10) = 1; % suppose is going up at the begining
    downIntensity = intensityJam <= meanTValues - paramTolerance*stdTValues;
    plateauIntensity = upIntensity + downIntensity == 0;
    
    % ---- 1. Thales algorithm - 2. Thales algorithm 2.4 ----
    isMaximum = [0; diff(cummax(intensityJam)) > 0];
    predictionT = 0;
    for t = 6:durationJam(i)
        if isMaximum(t) == 1 || t == 6
            predictionT = t;
        end
        predictions(initialValidJamIndex(i) - 1 + t,1) = 2*predictionT;
        predictions(initialValidJamIndex(i) - 1 + t,2) = 2.4*predictionT;
    end
    
    % ---- 3. Factor x2 update always algorithm ----
    predictions(initialValidJamIndex(i) + 5:finalValidJamIndex(i),3) = 2*(6:durationJam(i));
    
    % ---- 4. Intensity algorithm ----
    paramIntensityAlg = 1;
    predictions(initialValidJamIndex(i) + 5:finalValidJamIndex(i),4) = (6:durationJam(i)) + paramIntensityAlg*intensityJam(6:end)';
    
    % ---- 5. Relative maximum algorithm I ----
    
    
    % ---- 6. Relative maximum algorithm II ----
    isMaximum = [1; diff(intensityJam) > 0];
    predictionT = 0;
    for t = 6:durationJam(i)
        if isMaximum(t) == 1 || t == 6
            predictionT = t;
        end
        predictions(initialValidJamIndex(i) - 1 + t,6) = 2*predictionT;
    end
    
    % ---- 7. Relative maximum algorithm III ----
    
    % ---- 8. Dynamic trapezoid ----
    treshholdMax = 0.8*cummax(intensityJam);
    for k = 6:durationJam(i)
        aValue = find(intensityJam(1:k) >= treshholdMax(k),1,'first');
        predictions(initialValidJamIndex(i) - 1 + k,8) = k + aValue;
    end
    
    % ---- 9. Linear regression (only valid for descent)
    slope = (intensityJam -  meanTValues) / 5;
    predictionLA = (1:durationJam(i))' - (intensityJam./slope); %t = -int0/slope + t0
    predictions(initialValidJamIndex(i) + 5:finalValidJamIndex(i),9) = predictionLA(6:end);
    %for i = 2: plot(intensityJam);hold on;plot(40,intensityJam(40),'*')

    % ---- 10. Random guess using median of duration ----
    predictions(initialValidJamIndex(i) + 5:finalValidJamIndex(i),10) = median(durationJam);
    
    % ---- 11. Linear model #1 ----
    % Find N values
    [valuePick, locPick] = findpeaks(intensityJam);
    locValues = zeros(1,durationJam(i));
    locValues(locPick) = 1;
    NValues = cumsum(locValues);
    NValues(NValues == 0) = 1;
    % Find L values
    if isempty(locPick)
        locPick = find(max(intensityJam));
        LValues = 1:durationJam(i);
    else
        LValues = zeros(1,durationJam(i));
        LValues(1:locPick(1)) = 1:locPick(1);
        if length(locPick) > 1
            for k = 2:length(locPick)
                LValues(locPick(k-1)+1:locPick(k)) = locPick(k-1);
            end
        end
        LValues(locPick(end)+1:end) = locPick(end);
    end
    %
    for t = 6:durationJam(i)
        inter = linearParameters(linearParameters(:,3)<=NValues(t) & NValues(t)<linearParameters(:,4),1);%must be unique
        slope = linearParameters(linearParameters(:,3)<=NValues(t) & NValues(t)<linearParameters(:,4),2);%must be unique
        logS = log(LValues(t))*slope + inter;
        predictions(initialValidJamIndex(i) - 1 + t,11) = (1+exp(logS))*t;
    end
    
    % ---- 12. ----
    
    % ---- 13. Mixed algorithm 1 ----
    % If global maximum, use x2 (3). If not, linear model (11)
    isMaximum = [1; diff(cummax(intensityJam)) > 0];
    predictions(initialValidJamIndex(i) + 5:finalValidJamIndex(i),13) = isMaximum(6:end).*predictions(initialValidJamIndex(i) + 5:finalValidJamIndex(i),3);
    predictions(initialValidJamIndex(i) + 5:finalValidJamIndex(i),13) = (1-isMaximum(6:end)).*predictions(initialValidJamIndex(i) + 5:finalValidJamIndex(i),11);
    
    % ---- 14. Mixed algorithm 2 ----
    % If ascent, use x2 (3). If plateau, do nothing. If descent, use linear
    % regression (9)
    predictions(initialValidJamIndex(i) + 5:finalValidJamIndex(i),14) = ...
        upIntensity(6:end).*predictions(initialValidJamIndex(i) + 5:finalValidJamIndex(i),3) +...
        downIntensity(6:end).*predictions(initialValidJamIndex(i) + 5:finalValidJamIndex(i),9);
    for t = 6:durationJam(i)
        if plateauIntensity(t)
            predictions(initialValidJamIndex(i) + t - 1,14) = predictions(initialValidJamIndex(i) + t - 2,14);
        end
    end
    
    % ---- 15. Mixed algorithm 3 Peter with stdv ----
    % If ascent, use x2 (3). If plateau, use relative max (6). If descent,
    % use dynamical trapezoid (8)
    predictions(initialValidJamIndex(i) + 5:finalValidJamIndex(i),15) = ...
        upIntensity(6:end).*predictions(initialValidJamIndex(i) + 5:finalValidJamIndex(i),3) +...
        downIntensity(6:end).*predictions(initialValidJamIndex(i) + 5:finalValidJamIndex(i),8) +...
        plateauIntensity(6:end).*predictions(initialValidJamIndex(i) + 5:finalValidJamIndex(i),6);
    
    % ---- 16. Bayesian mixed model ----
    % It has to be the last one
    % TODO Required: intervalMin finalModelsBayesian weightMatrix
    %selectedBinDay = ceil(((data(initialValidJamIndex(i),3):data(finalValidJamIndex(i),3)) - 5*60 + 1)/intervalMin); % the min is 5*60
    selectedBinDay = ceil(((data(initialValidJamIndex(i),3):data(finalValidJamIndex(i),3)))/intervalMin); % the min is 00:00
    selectedBinDay(selectedBinDay == 0) = 1440;
    if isempty(selectedBinDay) %Horrible
            selectedBinDay = ceil((([1440 1:data(finalValidJamIndex(i),3) data(initialValidJamIndex(i),3):1439]))/intervalMin); % the min is 00:00
    end
    predictions(initialValidJamIndex(i):finalValidJamIndex(i),16) = ...
        sum(weightMatrix(:,selectedBinDay).*predictions(initialValidJamIndex(i):finalValidJamIndex(i),finalModelsBayesian)')';
    % No deber?a predecir los primeros 5 minutos! TODO?
    predictions(initialValidJamIndex(i):initialValidJamIndex(i)+4,16) = 0;
    
    % ---- 17. Bayesian mixed model per minute ----
    % It has to be the last one
    predictions(initialValidJamIndex(i):finalValidJamIndex(i),17) = ...
        sum(weightTimeMatrix(1:durationJam(i),:).*predictions(initialValidJamIndex(i):finalValidJamIndex(i),finalModelsBayesianMin),2);
    predictions(initialValidJamIndex(i):initialValidJamIndex(i)+4,17) = 0;
end

% Fix minimum predicted duration
predictions(indexDataFilter == 1,:) = max(predictions(indexDataFilter == 1,:),minPrediction);


%% Plot
numMethodPlot = 8;
close all

for i = 1:numValidJams
    subplot(2,1,1); plot(intensityDataFilter(initialValidJamIndex(i):finalValidJamIndex(i)));
    midP = initialValidJamIndex(i) + ceil(durationJam(i)/2) - 1;
    subplot(2,1,2); plot(predictions(initialValidJamIndex(i):finalValidJamIndex(i),numMethodPlot));
    hold on; plot(durationJam(i)*ones(1,durationJam(i)));
    hold on; plot(ceil(durationJam(i)/2),predictions(midP,numMethodPlot),'*')
    hold on; plot(0.8*durationJam(i)*ones(1,durationJam(i)),'--');
    hold on; plot(1.2*durationJam(i)*ones(1,durationJam(i)),'--'); hold off;
    
    midP = initialValidJamIndex(i) + floor(durationJam(i)/2) - 1;
    jamForecastedTime = predictions(midP,numMethodPlot);
    pause
end

%% Evaluate accuracy table
accuracyTotal = zeros(numMethods,2); % accuracy_50 accuracy_overall

for numMethodPlot = finalModels
    
    % Evaluate accuracy of the algorithm just at the 50%
    goodForecast = zeros(1,numValidJams);
    for i = 1:numValidJams
        midP = initialValidJamIndex(i) + floor(durationJam(i)/2) - 1;
        jamForecastedTime = predictions(midP,numMethodPlot);
        goodForecast(i) = jamForecastedTime >= 0.8 * durationJam(i) && jamForecastedTime <= 1.2 * durationJam(i);
    end
    accuracy_50 = sum(goodForecast) / numValidJams;
    accuracyTotal(numMethodPlot,1) = accuracy_50;
    
    % Evaluate the overall accuracy of the algorithm
    accuracy = zeros(1,numValidJams);
    for i = 1:numValidJams
        vecPredictions = predictions(initialValidJamIndex(i)+5:finalValidJamIndex(i),numMethodPlot);
        accuracy(i) = sum(vecPredictions >= 0.8 * durationJam(i) & vecPredictions <= 1.2 * durationJam(i));
        accuracy(i) = accuracy(i)/(durationJam(i)-5);
    end
    accuracy_overall = sum(accuracy) / numValidJams;
    accuracyTotal(numMethodPlot,2) = accuracy_overall;
end

%% Calculate accuracy errors for % jam duration
numBins = 50; %Note: the first bin won't catch elements for jams with duration<6/0.05 = 6*numBins

finalErrors = zeros(numBins,numMethods);
finalErrorsCube = nan(numBins,numMethods,ceil(1.2*sum(durationJam)/numBins)); %1.2 guessing maximum size
    %cube of data of errors -> for calculating std dev
    %also useful for bayesian method!

countBins = zeros(numBins,1);

% Calculate error
for i = 1:numValidJams
    
    % Calculate error for all methods
    vecPredictions = predictions(initialValidJamIndex(i)+5:finalValidJamIndex(i),:);
    errorMatrix = abs(vecPredictions-durationJam(i))/durationJam(i);%TODO abs TODO ^2
    %errorMatrix = errorMatrix.^2;
    selectedBin = ceil(numBins*(6:durationJam(i))/durationJam(i))';
    
    % Fill error matrix
    for k = 1:length(selectedBin)
        countBins(selectedBin(k)) = countBins(selectedBin(k)) + 1;
        finalErrors(selectedBin(k),:) = finalErrors(selectedBin(k),:) + errorMatrix(k,:);
        finalErrorsCube(selectedBin(k),:,countBins(selectedBin(k))) = errorMatrix(k,:); %abs
    end
    
    
end

errorForPPlot = nansum(finalErrors,1)/sum(countBins);
finalErrors = (finalErrors./repmat(countBins,1,numMethods));
finalErrors2 = nanmean(finalErrorsCube,3); % two different methods. Should show the same: sum(sum(finalErrors-finalErrors2))
stdErrors = nanstd(finalErrorsCube,0,3);
mean(stdErrors,1);

%rmseForPPlot = sqrt(nansum(finalErrors,1)/sum(countBins));
%finalErrors2 = sqrt(nanmean(finalErrorsCube,3)); % two different methods. Should show the same: sum(sum(finalErrors-finalErrors2))

%% Plot accuracy errors for % jam duration

set(0,'defaultfigurecolor',[1 1 1]);
%errorbar(finalErrors2(:,finalModels),stdErrors(:,finalModels).^2)
%%%%%plot(finalErrors2(:,finalModels),'LineWidth', 3)
plot(finalErrors(:,finalModels),'LineWidth', 3)
axis([0 numBins 0 1])
legend(nameModels(finalModels))
xlabel('% jam duration')
ylabel('Avg abs error')
%ylabel('RMSE')
set(gca,'XTick',0:numBins/10:numBins)
set(gca,'XTickLabel',cellstr(num2str((0:0.1:1)')))
set(gca, 'FontSize', fontSizeGlobal)
set(gca, 'LineWidth', 2)

% Output points: printCSV( finalErrors(:,[10 1 11 8 16 3]), {}, 'm11_plotAccuracy_50bins.csv' )
    %hola = (stdErrors(:,[10 1 11 8 16 3])).^2;
% Output points: printCSV( hola, {}, 'm11_errorBars_50bins.csv' )

%% Plot P: 50% and overall accuracy

set(0,'defaultfigurecolor',[1 1 1]);
for k = 1:length(finalModels)
    plot(1-accuracyTotal(finalModels(k),1),errorForPPlot(finalModels(k)),'*','LineWidth', 3)
    text(1-accuracyTotal(finalModels(k),1)+0.02,errorForPPlot(finalModels(k)),nameModels(finalModels(k)),'FontSize',15)
    hold on
end
%axis([0 1 0 1])
legend(nameModels(finalModels))
xlabel('Inaccuracy at middle point')
ylabel('Avg abs error')
set(gca, 'FontSize', fontSizeGlobal)
set(gca, 'LineWidth', 2)

% Output points: printCSV( [1-accuracyTotal([10 1 11 8 16 3],1) errorForPPlot([10 1 11 8 16 3])'], {}, 'm11_plotPoints.csv' )

%% ----- Other stuff -----
%% Weighted model (%)

% 1. Calculate P(M|%)
intervalMin = 5;
finalModelsBayesian = [3 8 11]; %setdiff(finalModels,16);
[minErrorValues,bestModelIndex] = min(finalErrorsCube(:,finalModelsBayesian,:),[],2);
bestModelIndex(isnan(minErrorValues)) = 0; %bestModelIndex(isnan(bestModelIndex)) = 0;
bestModelIndex = squeeze(bestModelIndex); % Remove singleton dimensions
[modelOcurrence,modelIndex]=hist(bestModelIndex',unique(bestModelIndex'));

modelProbability = modelOcurrence(2:end,:)./repmat(sum(modelOcurrence(2:end,:)),length(finalModelsBayesian),1);

% 2. Calculate P(%|t)
binsPercentage = numBins;%20; % it has to be equal to numBins when calibrating
%binsMatrix = zeros((23-5)*60/5,binsPercentage);
binsMatrix = zeros(24*60,binsPercentage);

for i = 1:numValidJams
    %Prueba [(data(initialValidJamIndex,3):data(finalValidJamIndex,3))' (data(initialValidJamIndex,3):data(finalValidJamIndex,3))'-5*60+1 ((data(initialValidJamIndex,3):data(finalValidJamIndex,3))'-5*60+1)/intervalMin ceil(((data(initialValidJamIndex,3):data(finalValidJamIndex,3))'-5*60+1)/intervalMin)];
    %selectedBinDay = ceil(((data(initialValidJamIndex(i),3):data(finalValidJamIndex(i),3)) - 5*60 + 1)/intervalMin); % the min is 5*60
    selectedBinDay = ceil(((data(initialValidJamIndex(i),3):data(finalValidJamIndex(i),3)))/intervalMin); % the min is 00:00
    selectedBinPercentage = ceil(binsPercentage*(1:durationJam(i))/durationJam(i))';
    for k = 1:durationJam(i)
        binsMatrix(selectedBinDay(k),selectedBinPercentage(k)) = binsMatrix(selectedBinDay(k),selectedBinPercentage(k)) + 1;
    end
    %plot(selectedBinDay)
    %hold on
end

positionProbability = binsMatrix./repmat(sum(binsMatrix,2),1,binsPercentage);
% If no information, suppose uniform distribution
positionProbability(isnan(positionProbability)) = 1/binsPercentage;

% 3. Calculate modelProbability times positionProbability
weightMatrix = modelProbability*positionProbability';

% Output: intervalMin finalModelsBayesian weightMatrix
% save('m6BayesianParameters.mat','intervalMin','finalModelsBayesian','weightMatrix')
% save('m11BayesianParameters.mat','intervalMin','finalModelsBayesian','weightMatrix')

%% Weighted model (min)

% Calculate P(M|minute)
intervalMinMin = 5;
finalModelsBayesianMin = [3 8 11]; %setdiff(finalModels,16);
weightTimeMatrix = zeros(ceil(max(durationJam)/intervalMinMin),length(finalModelsBayesianMin));

for i = 1:numValidJams
    vecPredictions = predictions(initialValidJamIndex(i)+5:finalValidJamIndex(i),finalModelsBayesianMin);
    errorMatrix = abs(vecPredictions-durationJam(i))/durationJam(i);
    [minErrorValues,bestModelIndex] = min(errorMatrix,[],2);
    for k = 6:durationJam(i)
        weightTimeMatrix(ceil(k/intervalMinMin),bestModelIndex(k-5)) = weightTimeMatrix(ceil(k/intervalMinMin),bestModelIndex(k-5)) + 1;
    end
end

weightTimeMatrix = weightTimeMatrix./repmat(sum(weightTimeMatrix,2),1,length(finalModelsBayesianMin));
weightTimeMatrix(isnan(weightTimeMatrix)) = 1/length(finalModelsBayesianMin);

% Output: intervalMin finalModelsBayesian weightMatrix
% save('m6BayesianParametersMinute.mat','intervalMinMin','finalModelsBayesianMin','weightTimeMatrix')
% save('m11BayesianParametersMinute.mat','intervalMinMin','finalModelsBayesianMin','weightTimeMatrix')
