close all;clear all;clc;
addpath('/Users/wcurrier/Desktop/Matlab_Functions');

% Functions needed: time_builder.m in_to_m. F_to_C.m jul2greg.m greg2jul.m
% Fix_missing_hourly_SNOTEL.m

% To get time_builder.m see the forked folder from NicWayand called time_management 


% Written by William Currier November 1, 2015
%% Script Adjustments Adjust these to get SNOTEL data for where you want it

site_names={'Dungeness','Mount Crag','Buckinghorse','Waterhole'};
site_numbers=[943,648,1107,974];
Elev=[4010,3960,4870,5010];
Lat=[47.86,47.766,47.716,47.95];
Long=[123.083,123.0333,123.45,123.433];

%Adjust the time you want to look at
Years=[2014:2015];

hourly=1; % 1 means get the hourly data as well - Note this might take a minute or two to run

%% Make Data Strucutres of Daily Data from the Four SNOTEL sites in the OLYMPICS
for jj=1:length(Years)-1
    
    start_date=(strcat(num2str(Years(jj)),'-10-1'));
    end_date=(strcat(num2str(Years(jj+1)),'-9-30'));


    Ta=[];Tmax=[];Tmin=[];Ppt=[];obsSWE=[];SnowDepth=[];
        for ii=1:length(site_names)
    
            url=strcat('http://www.wcc.nrcs.usda.gov/reportGenerator/view_csv/customSingleStationReport,metric/daily/',num2str(site_numbers(1,ii)),':WA:SNTL%7Cid=%22%22%7Cname/',start_date,',',end_date,'/TAVG::value,TMAX::value,TMIN::value,PRCP::value,WTEQ::value,SNWD::value');
            data=urlread(url);
            delimiter = ','; startRow = 9; formatSpec = '%s%f%f%f%f%f%f%f%[^\n\r]';
            dataArray = textscan(data, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false);

                Met.site_names(1,ii).site_name=site_names(1,ii);
                Met.site_names(1,ii).time = time_builder(datenum(dataArray{:, 1}));
                Met.site_names(1,ii).Ta = (dataArray{:, 2});
                Met.site_names(1,ii).Tmax = (dataArray{:, 3});
                Met.site_names(1,ii).Tmin = (dataArray{:, 4});
                Met.site_names(1,ii).Ppt = (dataArray{:, 5});
                Met.site_names(1,ii).SWE = (dataArray{:, 6});
                Met.site_names(1,ii).SnowDepth = (dataArray{:, 7}).*10;
                Met.site_names(1,ii).Elev=Elev(1,ii);
                Met.site_names(1,ii).Lat=Lat(1,ii);
                Met.site_names(1,ii).Long=Long(1,ii);
                Met.site_names(1,ii).site_number=site_numbers(1,ii);

            Ta=[Ta,(dataArray{:, 2})];
            Tmax=[Tmax,(dataArray{:, 4})];
            Tmin=[Tmin,(dataArray{:, 3})];
            Ppt=[Ppt,((dataArray{:, 5}))];
            obsSWE=[obsSWE,((dataArray{:, 6}))];
            SnowDepth=[SnowDepth,((dataArray{:, 7}).*10)];
            

            clearvars filename delimiter startRow formatSpec fileID dataArray data url ii;

        end

end

% Get Hourly Data from SNOTEL Sites
if hourly==1
for jj=1:length(Years)-1
    
start_date=(strcat(num2str(Years(jj)),'-10-1'));
end_date=(strcat(num2str(Years(jj+1)),'-9-30'));
% end_date=datestr(now,29);


Tobs=[];SWE_hour=[];SnowDepth_hour=[];RH_hour=[];WindSpeed=[];
    for ii=1:length(site_names)
    
            url=strcat('http://www.wcc.nrcs.usda.gov/reportGenerator/view_csv/customSingleStationReport/hourly/',num2str(site_numbers(1,ii)),':WA:SNTL|id=%22%22|name/',start_date,',',end_date,'/TOBS::value,WTEQ::value,SNWD::value,SRADV::value,SRADX::value,RHUMV::value,WSPDV::value');
            data=urlread(url); delimiter = ','; startRow = 9; formatSpec = '%s%f%f%f%f%f%f%f%[^\n\r]';
            dataArray = textscan(data, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false);

                MetHour.site_names(1,ii).site_name=site_names(1,ii);
                
                MetHour.site_names(1,ii).time = time_builder(datenum(dataArray{:, 1}));
                
                MetHour.site_names(1,ii).Tobs = F_to_C(fix_missing_hourly_SNOTEL(MetHour.site_names(1,ii).time,(dataArray{:, 2}))); % [C]
                MetHour.site_names(1,ii).SWE = in_to_m(fix_missing_hourly_SNOTEL(MetHour.site_names(1,ii).time,(dataArray{:, 3}))).*1000; % [mm]
                MetHour.site_names(1,ii).SnowDepth = in_to_m(fix_missing_hourly_SNOTEL(MetHour.site_names(1,ii).time,(dataArray{:, 4}))).*1000; %{mm]
                MetHour.site_names(1,ii).SWAvg = fix_missing_hourly_SNOTEL(MetHour.site_names(1,ii).time,(dataArray{:, 5})); % [W/m^2]
                MetHour.site_names(1,ii).SWmax = fix_missing_hourly_SNOTEL(MetHour.site_names(1,ii).time,(dataArray{:, 6})); % [W/m^2]
                MetHour.site_names(1,ii).RH = fix_missing_hourly_SNOTEL(MetHour.site_names(1,ii).time,(dataArray{:, 7})); % [%]
                MetHour.site_names(1,ii).WindSpeed = fix_missing_hourly_SNOTEL(MetHour.site_names(1,ii).time,(dataArray{:, 8})); % [m/s]
                MetHour.site_names(1,ii).Elev=Elev(1,ii);
                MetHour.site_names(1,ii).Lat=Lat(1,ii);
                MetHour.site_names(1,ii).Long=Long(1,ii);
                MetHour.site_names(1,ii).site_number=site_numbers(1,ii);
                
                
            Tobs=[Tobs,fix_missing_hourly_SNOTEL(MetHour.site_names(1,ii).time,(dataArray{:, 2}))];
            SWE_hour=[SWE_hour,fix_missing_hourly_SNOTEL(MetHour.site_names(1,ii).time,(dataArray{:, 3}))];
            SnowDepth_hour=[SnowDepth_hour,fix_missing_hourly_SNOTEL(MetHour.site_names(1,ii).time,(dataArray{:, 4}))];
            RH_hour=[RH_hour,fix_missing_hourly_SNOTEL(MetHour.site_names(1,ii).time,(dataArray{:, 7}))];
            WindSpeed=[WindSpeed,fix_missing_hourly_SNOTEL(MetHour.site_names(1,ii).time,(dataArray{:, 7}))];
            MetHour.site_names(1,ii).time = time_builder(datenum(dataArray{1, 1}{1,1}),datenum(dataArray{1, 1}{end,1}),1);
            clearvars filename delimiter startRow formatSpec fileID dataArray data url ii;
    end
end
end
