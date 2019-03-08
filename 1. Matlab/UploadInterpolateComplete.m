% Upload _5_FinalData.csv with information for march, april, may
% Make interpolation
% All this is extracted from main.m

%% Load data (REAL)
clear
%m6data = csvread('m6_5_data.csv',1,0);
%m6data(m6data == 9999) = -1;
%save('m6FinalData.mat','m6data')
%load m6FinalData.mat

%clear
%m11data = csvread('m11_5_data.csv',1,0);
%m11data(m11data == 9999) = -1;
%save('m11FinalData.mat','m11data')
%load m11FinalData.mat

%% Global interpolation (REAL)
%newData = [m6data(:,1:3) -1*ones(size(m6data,1),7) m6data(:,11:13)];
%listLinks = unique(m6data(:,1));
%dates = unique(m6data(:,2));
newData = [m11data(:,1:3) -1*ones(size(m11data,1),7) m11data(:,11:13)];
listLinks = unique(m11data(:,1));
dates = unique(m11data(:,2));
p = 10;

for link_i = listLinks'
    for date_i = dates'
        %indexLinkDate = find(m6data(:,1) == link_i & m6data(:,2) == date_i);
        %absoluteTimeSection = m6data(indexLinkDate,3);
        indexLinkDate = find(m11data(:,1) == link_i & m11data(:,2) == date_i);
        absoluteTimeSection = m11data(indexLinkDate,3);
        
        for i = 4:10
            %sectionData = m6data(indexLinkDate,i);
            sectionData = m11data(indexLinkDate,i);
            sampleTime = absoluteTimeSection(sectionData ~= -1);
            sampleVariable = sectionData(sectionData ~= -1);
            
            if length(sampleTime) > 1
                % get large regions with -1
                indexEmptySet = strfind(sectionData',-1*ones(1,p));
                indexEmptySet1 = [indexEmptySet indexEmptySet+1 indexEmptySet+2 indexEmptySet+3 indexEmptySet+4 ...
                    indexEmptySet+5 indexEmptySet+6 indexEmptySet+7 indexEmptySet+8 indexEmptySet+9];
                interpolTimeIndex = setdiff(1:length(absoluteTimeSection),unique(indexEmptySet1));
                
                % interpolation
                interpol = interp1(sampleTime, sampleVariable, absoluteTimeSection(interpolTimeIndex));
                newData(indexLinkDate(interpolTimeIndex),i) = interpol';
                
                % interpolation (without excluding large empty regions)
                %interpol = interp1(sampleTime, sampleVariable, absoluteTimeSection);%complete
                %newData(indexLinkDate,i) = interpol;
            end
        end
    end
end
newData(isnan(newData)) = -1;

%% Adding day of week (REAL)
newData = [newData zeros(size(newData,1),1)];
newData(:,14) = weekday(datenum([floor(newData(:,2)/10000),mod(floor(newData(:,2)/100),100),mod(newData(:,2),100)]));

%% Save interpolated data
%m6newData = newData;
%save('m6FinalData_Interp.mat','m6newData')
%clear newData

%m11newData = newData;
%save('m11FinalData_Interp.mat','m11newData')
%clear newData

%% Writting .csv (REAL)
headerRow = {'link_id', 'm_date', 'absolute_time', 'travel_time', 'free_flow', 'profile_time', 'traffic_concentration', 'traffic_speed', 'traffic_flow', 'traffic_headway', 'congestion_event', 'poor_event', 'other_event', 'day_week'};
filename = 'm6_6_FinalDataInterp.csv';
printCSV( newData, headerRow, filename )

