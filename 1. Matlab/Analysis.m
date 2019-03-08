% --- GLOBAL OUTPUTS ---
% All this is extracted from statistics.m

% data (l)
% 1-5: link_id, m_date, absolute_time, travel_time, free_flow
% 6-10: profile_time, traffic_concentration, traffic_speed, traffic_flow, traffic_headway
% 11-14: congestion_event, poor_event, other_event, day_week
% 15: regime
% traffic_intensity_no_smoothed, traffic_intensity_smoothed (l)
% (initialJamIndex finalJamIndex lengthJam maxIntensity sizePerJam
% eventPercentage) (s0)

% indexFilter numValidJams (s)
% initialValidJamIndex finalValidJamIndex durationJam maxIntJam
%       sizeJam minuteInitialJam dayInitialJam (s)
% indexDataFilter intensityDataFilter (l)

% Output files:
% Data:         'm6FinalData_Analysis.mat'  'm11FinalData_Analysis.mat'
% Training:     'm6TrainingJams.mat'        'm11TrainingJams.mat'
% TestingV1:    'm6TestingJamsV1.mat'       'm11TestingJamsV1.mat'
% TestingV2:    'm6TestingJamsV2.mat'       'm11TestingJamsV2.mat'

%% ------------- DATA HANDLING --------------------
%% Upload data
clear

load m6FinalData_Interp.mat
data = [m6newData zeros(size(m6newData,1),1)];
clear m6newData
%load m11FinalData_Interp.mat
%data = [m11newData zeros(size(m11newData,1),1)];
%clear m11newData

%% Find traffic jams
travelTimeSection = data(:,4);
profileSection = data(:,5);
traffic_intensity = travelTimeSection - profileSection - 6;
traffic_jam_alert = traffic_intensity > 0;

% Finding the real traffic jams using 5 minute criteria
regime = zeros(length(traffic_intensity),1); % regime = 0 is normal regime, regime = 1 is congestion regime
counter_0 = 0;% Count number of consecutive zeros in traffic jam alert vector
counter_1 = 0;% Count number of consecutive ones in traffic jam alert vector
jam_flag = 0;
for i = 1:length(traffic_intensity)
    % Find first 5 consecutive points where traffic_intensity is > 0 and find traffic jam start point
    if traffic_jam_alert(i) == 0
        counter_0 = counter_0 + 1;
        counter_1 = 0;
    end
    if traffic_jam_alert(i) == 1
        counter_0 = 0;
        counter_1 = counter_1 + 1;
    end
    if counter_1 == 6
        jam_flag = 1;
        regime(i-5) = 1;
        regime(i-4) = 1;
        regime(i-3) = 1;
        regime(i-2) = 1;
        regime(i-1) = 1;
        regime(i-0) = 1;
    end
    if jam_flag == 1
        regime(i) = 1;
    end
    % Then, find first 5 consecutive points where traffic_intensity is <= 0
    if counter_0 == 6 && jam_flag == 1
        jam_flag = 0;
        regime(i-5) = 0;
        regime(i-4) = 0;
        regime(i-3) = 0;
        regime(i-2) = 0;
        regime(i-1) = 0;
        regime(i-0) = 0;
    end
end
data(:,15) = regime;
clear travelTimeSection profileSection regime traffic_jam_alert
clear counter_0 counter_1 jam_flag
%Output: data(:,15) traffic_intensity

%% Smoothing data
% Position of jams
regime = data(:,15);
initialJamIndex = strfind(regime',[0 1]) + 1;
finalJamIndex = strfind(regime',[1 0]);

traffic_intensity_smoothed = zeros(length(traffic_intensity),1);

% Smoothing data
for i = 1:length(initialJamIndex)
    if finalJamIndex(i) - initialJamIndex(i) + 1 >= 6
        intensityJam = traffic_intensity(initialJamIndex(i):finalJamIndex(i));
        intensityJamSmoothed = intensityJam;
        
        % Low pass filter
        intensityJamSmoothed(6:end) = 0.5*intensityJam(6:end) + ...
            0.25*intensityJam(6-1:end-1) + ...
            0.125*intensityJam(6-2:end-2) + ...
            0.0625*intensityJam(6-3:end-3) + ...
            0.0625*intensityJam(6-4:end-4);
        % plot
        %plot(intensityJam)
        %hold on
        %plot(intensityJamSmoothed)
        %hold off
        %pause
        
        traffic_intensity_smoothed(initialJamIndex(i):finalJamIndex(i)) = intensityJamSmoothed;
    end
end

traffic_intensity_no_smoothed = traffic_intensity;
clear traffic_intensity intensityJam intensityJamSmoothed
% Output: traffic_intensity_no_smoothed traffic_intensity_smoothed

%% Find jams without events

eventIndicator = zeros(1,length(initialJamIndex));
maxIntensity = zeros(1,length(initialJamIndex));
sizePerJam = zeros(1,length(initialJamIndex));
for i = 1:length(initialJamIndex)
    eventIndicator(i) = sum(data(initialJamIndex(i):finalJamIndex(i),13));
    maxIntensity(i) = max(traffic_intensity_smoothed(initialJamIndex(i):finalJamIndex(i)));
    sizePerJam(i) = sum(traffic_intensity_smoothed(initialJamIndex(i):finalJamIndex(i)));
end
lengthJam = finalJamIndex - initialJamIndex + 1;
eventPercentage = eventIndicator./lengthJam;

clear eventIndicator
%Output: initialJamIndex finalJamIndex lengthJam maxIntensity sizePerJam eventPercentage

%% Random choice of days
%dates = unique(data(:,2));
%dates = dates(dates ~= 20160325 & dates ~= 20160328 & dates ~= 20160502 & dates ~= 20160530);
%permutatedIndex = randperm(length(dates))'; %TODO
%save('m6m11TrainingDates.mat','dates','permutatedIndex')
load m6m11TrainingDates.mat

trainingDates = dates(permutatedIndex(1:62)); % 70% of days
testingDates = dates(permutatedIndex(63:end));

trainTestData = zeros(size(data,1),1); % 1:training -1: testing 0:holidays
for i = trainingDates'
    trainTestData(data(:,2) == i) = 1;
end
for i = testingDates'
    trainTestData(data(:,2) == i) = -1;
end

%Output: trainTestData (l)
clear trainingDates testingDates


%% Save global data
% data (l)
% 1-5: link_id, m_date, absolute_time, travel_time, free_flow
% 6-10: profile_time, traffic_concentration, traffic_speed, traffic_flow, traffic_headway
% 11-14: congestion_event, poor_event, other_event, day_week
% 15: regime
% traffic_intensity_no_smoothed, traffic_intensity_smoothed (l)

% (initialJamIndex finalJamIndex lengthJam maxIntensity sizePerJam
% eventPercentage) (s0)
% trainTestData (l)

%save('m11FinalData_Analysis.mat'...
%    ,'data','traffic_intensity_no_smoothed','traffic_intensity_smoothed'...
%    ,'initialJamIndex','finalJamIndex','lengthJam'...
%    ,'maxIntensity','sizePerJam','eventPercentage','trainTestData');

%% ------------- SELECTION OF JAMS --------------------
%% Load DATA HANDLING
clear
%load m6FinalData_Analysis.mat
load m11FinalData_Analysis.mat

%% Selection criteria
formFilter = lengthJam >= 20 & lengthJam <= 60*6 &...
    maxIntensity >= 20 &...
    data(initialJamIndex,3)' >= 5*60 & data(initialJamIndex,3)' < 23*60 &...
    data(finalJamIndex,3)' >= 5*60 & data(finalJamIndex,3)' < 23*60;

dayFilter = data(initialJamIndex,14)' ~= 1 & data(finalJamIndex,14)' ~= 7 &...
    data(initialJamIndex,2)' ~= 20160325 & data(initialJamIndex,2)' ~= 20160328 &...
    data(initialJamIndex,2)' ~= 20160502 & data(initialJamIndex,2)' ~= 20160530 & ...
    data(finalJamIndex,2)' ~= 20160325 & data(finalJamIndex,2)' ~= 20160328 &...
    data(finalJamIndex,2)' ~= 20160502 & data(finalJamIndex,2)' ~= 20160530;%it seems there are no crossing day jams in m6

%indexFilter = eventPercentage == 0 & formFilter & dayFilter;

% SET one of the following to choose training/test data
% Training
%indexFilter = eventPercentage == 0 & formFilter & dayFilter & trainTestData(initialJamIndex)' == 1;
% TestingV1
%indexFilter = eventPercentage == 0 & trainTestData(initialJamIndex)' ~= 1;
% TestingV2 (without weekends and holidays)
%indexFilter = eventPercentage == 0 & dayFilter & trainTestData(initialJamIndex)' ~= 1;
% TestingV3
%indexFilter = eventPercentage == 0 & lengthJam >= 20 & trainTestData(initialJamIndex)' ~= 1;

numValidJams = sum(indexFilter);

% Output: indexFilter numValidJams
% TODO 25mar 28mar 2may 30may

%% Vectors
initialValidJamIndex = initialJamIndex(indexFilter);
finalValidJamIndex = finalJamIndex(indexFilter);
durationJam = lengthJam(indexFilter);
maxIntJam = maxIntensity(indexFilter);
sizeJam = sizePerJam(indexFilter);
minuteInitialJam = data(initialValidJamIndex,3);
dayInitialJam = data(initialValidJamIndex,14);

% Output: initialValidJamIndex finalValidJamIndex durationJam maxIntJam
% sizeJam minuteInitialJam dayInitialJam

%% Find selected jams in original data - intensity !!!
indexDataFilter = zeros(length(traffic_intensity_smoothed),1);
for i = 1:numValidJams
    indexDataFilter(initialValidJamIndex(i):finalValidJamIndex(i)) = 1;
end
intensityDataFilter = traffic_intensity_smoothed.*indexDataFilter;
%Output: indexDataFilter intensityDataFilter

%% Save subsets of jams
% indexFilter numValidJams (s)
% initialValidJamIndex finalValidJamIndex durationJam maxIntJam
%       sizeJam minuteInitialJam dayInitialJam (s)
% indexDataFilter intensityDataFilter (l)

% save('m11TestingJamsV2.mat','indexFilter','numValidJams'...
%     ,'initialValidJamIndex','finalValidJamIndex','durationJam','maxIntJam'...
%     ,'sizeJam','minuteInitialJam','dayInitialJam'...
%     ,'indexDataFilter','intensityDataFilter');

% Training:     'm6TrainingJams.mat'    'm11TrainingJams.mat'
% TestingV1:    'm6TestingJamsV1.mat'   'm11TestingJamsV1.mat'
% TestingV2:    'm6TestingJamsV2.mat'   'm11TestingJamsV2.mat'
% TestingV3:    'm6TestingJamsV3.mat'   'm11TestingJamsV3.mat'


%% ------------- STATISTICS AND PLOTS --------------------
%% Load DATA HANDLING
clear
fontSizeGlobal = 21;
load m6FinalData_Analysis.mat
load m6TrainingJams.mat
%load m11FinalData_Analysis.mat
%load m11TrainingJams.mat

%% Un-normalised statistics A
set(0,'defaultfigurecolor',[1 1 1]);

% Duration
figure
h = histogram(durationJam/60,0:1/3:6,'FaceColor','none','Normalization','probability','LineWidth',1.1);
%hist(lengthJam(eventPercentage ~= 0))
xlabel('Traffic jam duration (hours)')
ylabel('Relative frequency')
set(gca, 'FontSize', fontSizeGlobal)
figure
xValues = (h.BinLimits(1)+h.BinWidth/2):h.BinWidth:h.BinLimits(2)-h.BinWidth/2;
yValues = h.Values/sum(h.Values);
xValues = xValues(2:end);
yValues = yValues(2:end);
pFit = polyfit(xValues(yValues ~= 0),log(yValues(yValues ~= 0)),1);
yFit = pFit(1)*xValues(yValues ~= 0)+pFit(2);%-0.6915
semilogy(xValues,yValues,'o','Color','k')
xlabel('Traffic jam duration d (hours)')
ylabel('Relative frequency f(d)')
set(gca, 'FontSize', fontSizeGlobal)
axis([0 5.5 0.002 1])
hold on
plot(xValues(yValues ~= 0),exp(yFit),'k-.')
text(3.5,0.3,strcat('f(d) ~ e^{',num2str(pFit(1),'%1.2f'),'*d}'),'FontSize', 16)

% Max intensity
figure
h = histogram(maxIntJam(maxIntJam<200)/60,'FaceColor','none','Normalization','probability','LineWidth',1.1);
xlabel('Max intensity of jam (minutes)')
ylabel('Relative frequency')
set(gca, 'FontSize', fontSizeGlobal)
%figure
%h = histogram(maxIntJam,'FaceColor','none','Normalization','probability','LineWidth',1.1);
figure
xValues = (h.BinLimits(1)+h.BinWidth/2):h.BinWidth:h.BinLimits(2)-h.BinWidth/2;
yValues = h.Values/sum(h.Values);
pFit = polyfit(xValues,log(yValues),1);
yFit = pFit(1)*xValues+pFit(2);%-0.0450
semilogy(xValues,yValues,'o','Color','k')
xlabel('Max intensity of jam (minutes)')
ylabel('Relative frequency')
set(gca, 'FontSize', fontSizeGlobal)
hold on
plot(xValues,exp(yFit),'k-.')
text(2.5,0.3,strcat('f(d) ~ e^{',num2str(pFit(1),'%1.2f'),'*d}'),'FontSize', 16)

%scatter(durationJam(maxIntJam<200),maxIntJam(maxIntJam<200)/60)

% Size
figure
h = histogram(sizeJam(sizeJam>0 & sizeJam < 60*50)/60,'FaceColor','none','Normalization','probability','LineWidth',1.1);
xlabel('Traffic jam size')
ylabel('Relative frequency')
set(gca, 'FontSize', fontSizeGlobal)
figure
xValues = (h.BinLimits(1)+h.BinWidth/2):h.BinWidth:h.BinLimits(2)-h.BinWidth/2;
yValues = h.Values/sum(h.Values);
pFit = polyfit(xValues,log(yValues),1);
yFit = pFit(1)*xValues+pFit(2);%-0.0763
semilogy(xValues,yValues,'o','Color','k')
xlabel('Traffic jam size')
ylabel('Relative frequency')
set(gca, 'FontSize', fontSizeGlobal)
hold on
plot(xValues,exp(yFit),'k-.')

% Plot matrix
figure
plotmatrix([durationJam(maxIntJam<100 & sizeJam>0 & sizeJam < 60*50)' maxIntJam(maxIntJam<100 & sizeJam>0 & sizeJam < 60*50)' sizeJam(maxIntJam<100 & sizeJam>0 & sizeJam < 60*50)']/60)

% Correlation between variables
figure
corrcoef(sizeJam,maxIntJam);
corrcoef(durationJam,maxIntJam);

%% Auto-correlation B
numLags = 60;
autocorrJams = NaN(numValidJams,numLags+1);
for i = 1:numValidJams
    lagi = min(numLags,durationJam(i)-1);
    [ACF,lags,bounds] = autocorr(traffic_intensity_smoothed(initialValidJamIndex(i):finalValidJamIndex(i)),lagi);
    autocorrJams(i,1:lagi+1) = ACF;
end
%plot(autocorrJams')
%errorbar(nanmean(autocorrJams,1),nanvar(autocorrJams,[],1))
%figure
stdAutocorr = nanstd(autocorrJams,[],1);
stdAutocorr(2:2:end) = 0;
errorbar(nanmean(autocorrJams,1),stdAutocorr, 'color', [0.5 0.5 0.5])
hold on
plot(nanmean(autocorrJams,1),'Color','k')
xlabel('Lag')
ylabel('Autocorrelation')
xlim([0 62])
set(gca, 'FontSize', fontSizeGlobal)

%% Statistics for hour C
% 1.
orderedHours = sort([data(initialValidJamIndex,3) data(finalValidJamIndex,3)]);
orderedHours = unique(orderedHours,'rows');
figure
for i = 1:length(orderedHours)
    plot(orderedHours(i,:),[i i])
    hold on
end

ax = gca;
ax.YTick = [];
ax.XTick = (0:3:24)*60;
ax.XTickLabel = {'00:00','03:00','06:00','09:00','12:00','15:00','18:00','21:00','00:00'};

%1.b !!!
orderedHours = sort([data(initialValidJamIndex,3) data(initialValidJamIndex,3)+durationJam']);
%orderedHours = unique(orderedHours,'rows');
figure
for i = 1:length(orderedHours)
    plot(orderedHours(i,:),[i i])
    hold on
end
ax = gca;
ax.YTick = [];
ax.XTick = (0:24)*60;
ax.XTickLabel = {'00:00','','','03:00','','','06:00','','','09:00','','','12:00','','','15:00','','','18:00','','','21:00','','','00:00'};
xlabel('Jam duration per hour')

% 2.
figure
scatter(data(initialValidJamIndex,3),log(durationJam))

% 3.
%NO histogram(data(initialValidJamIndex,3),24)
%ax = gca;
%ax.XTick = (0:3:24)*60;
%ax.XTickLabel = {'00:00','03:00','06:00','09:00','12:00','15:00','18:00','21:00','00:00'};

avgDuration = zeros(1,24);
avgMaxIntensity = zeros(1,24);
avgSize = zeros(1,24);
for i = 1:24
    avgDuration(i) = mean(durationJam(minuteInitialJam'/24 == i-1));
    avgMaxIntensity(i) = mean(maxIntJam(minuteInitialJam'/24 == i-1));
    avgSize(i) = mean(sizeJam(minuteInitialJam'/24 == i-1));
end
%A
bar(avgDuration/60,'FaceColor','none','LineWidth',1.1);
xlabel('Starting time')
ylabel('Average traffic jam duration (hours)')
ax = gca;
ax.XTick = (0:3:24);
ax.XTickLabel = {'00:00','03:00','06:00','09:00','12:00','15:00','18:00','21:00','00:00'};
set(gca, 'FontSize', fontSizeGlobal)
%B
figure
bar(avgMaxIntensity,'FaceColor','none','LineWidth',1.1);
xlabel('Starting time')
ylabel('Average max intensity of jam (minutes)')
ax = gca;
ax.XTick = (0:3:24);
ax.XTickLabel = {'00:00','03:00','06:00','09:00','12:00','15:00','18:00','21:00','00:00'};
set(gca, 'FontSize', fontSizeGlobal)
%C
figure
bar(avgSize/60,'FaceColor','none','LineWidth',1.1);
ylabel('Average traffic jam size')
ax = gca;
ax.XTick = (0:3:24);
ax.XTickLabel = {'00:00','03:00','06:00','09:00','12:00','15:00','18:00','21:00','00:00'};
xlabel('Starting time')
set(gca, 'FontSize', fontSizeGlobal)
% TODO correlation between these plots?

%% Day of the week D
avgDurationDay = zeros(1,7);
avgMaxIntensityDay = zeros(1,7);
avgSizeDay = zeros(1,7);
stdDurationDay = zeros(1,7);
stdMaxIntensityDay = zeros(1,7);
stdSizeDay = zeros(1,7);
for i = 1:7
    avgDurationDay(i) = mean(durationJam(dayInitialJam' == i));
    avgMaxIntensityDay(i) = mean(maxIntJam(dayInitialJam' == i));
    avgSizeDay(i) = mean(sizeJam(dayInitialJam' == i)/60);
    stdDurationDay(i) = std(durationJam(dayInitialJam' == i));
    stdMaxIntensityDay(i) = mean(maxIntJam(dayInitialJam' == i));
    stdSizeDay(i) = std(sizeJam(dayInitialJam' == i)/60);
end
%A
figure
bar(avgDurationDay,'FaceColor','none','LineWidth',1.1);
ax = gca;
ax.XTickLabel = {'Sun','Mon','Tue','Wed','Thu','Fri','Sat'};
ylabel('Average traffic jam duration (hours)')
set(gca, 'FontSize', fontSizeGlobal)
%AA
figure
errorbar(avgDurationDay,stdDurationDay, 'color', [0.5 0.5 0.5])
hold on
plot(avgDurationDay,'Color','k')
ax = gca;
ax.XTickLabel = {'','Sun','Mon','Tue','Wed','Thu','Fri','Sat',''};
ylabel('Average traffic jam duration (hours)')
set(gca, 'FontSize', fontSizeGlobal)
%B
figure
bar(avgMaxIntensityDay,'FaceColor','none','LineWidth',1.1);
ax = gca;
ax.XTickLabel = {'Sun','Mon','Tue','Wed','Thu','Fri','Sat'};
ylabel('Average max intensity of jam (minutes)')
set(gca, 'FontSize', fontSizeGlobal)
%BB
figure
errorbar(avgMaxIntensityDay,stdMaxIntensityDay, 'color', [0.5 0.5 0.5])
hold on
plot(avgMaxIntensityDay,'Color','k')
ax = gca;
ax.XTickLabel = {'','Sun','Mon','Tue','Wed','Thu','Fri','Sat',''};
ylabel('Average max intensity of jam (minutes)')
set(gca, 'FontSize', fontSizeGlobal)
%C
figure
bar(avgSizeDay,'FaceColor','none','LineWidth',1.1);
ax = gca;
ax.XTickLabel = {'Sun','Mon','Tue','Wed','Thu','Fri','Sat'};
ylabel('Average traffic jam size')
set(gca, 'FontSize', fontSizeGlobal)
%CC
figure
errorbar(avgSizeDay,stdSizeDay, 'color', [0.5 0.5 0.5])
hold on
plot(avgSizeDay,'Color','k')
ax = gca;
ax.XTickLabel = {'','Sun','Mon','Tue','Wed','Thu','Fri','Sat',''};
ylabel('Average traffic jam size')
set(gca, 'FontSize', fontSizeGlobal)
% TODO correlation between these plots?

%% Week vs. Weekend E
% Duration
figure
histogram(durationJam(dayInitialJam == 1 | dayInitialJam == 7))%hist(lengthJam(eventPercentage ~= 0))
hold on
histogram(durationJam(dayInitialJam > 1 & dayInitialJam < 7))

% Max intensity
figure
histogram(maxIntJam)

% Size
figure
histogram(sizeJam)
