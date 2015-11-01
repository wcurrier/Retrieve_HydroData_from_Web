close all;clear all;clc;
addpath('/Users/wcurrier/Desktop/Matlab_Functions');
% Functions needed: time_builder.m jul2greg.m greg2jul.m

% This downloads Daily Data from the USGS Streamflow Data
% Written by William Currier October 30, 2015
%% Script Adjustments - adjust these parameters

site_names={'Quinault','Duckabush','Dungeness','Skokomish'};
site_numbers=[12039500 ... % list of USGS site numbers
    ,12054000 ...
    ,12048000 ...
    ,12056500];


start_date='2007-9-25'; % make this four days back atleast from where you want because the startRow for each site changes
end_date='2015-9-30';

plotOutput=1; % plot the resulting stage height and discharge? 1 = yes, anything else = No
%% Make Data Strucutres of Daily Data from the Four SNOTEL sites in the OLYMPICS

    dischargeCFS=[];time=[];gageHtFt=[];
        for ii=1:length(site_names)
    
            url=strcat('http://waterdata.usgs.gov/nwis/dv?cb_00060=on&cb_00065=on&format=rdb&site_no=',num2str(site_numbers(1,ii)),'&referred_module=sw&period=&begin_date=',start_date,'&end_date=',end_date);
            data=urlread(url); delimiter = '\t'; startRow = 28; formatSpec = '%s%s%s%s%s%s%s%[^\n\r]';
            dataArray = textscan(data, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);


                    raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
                    for col=1:length(dataArray)-1
                        raw(1:length(dataArray{col}),col) = dataArray{col};
                    end
                    numericData = NaN(size(dataArray{1},1),size(dataArray,2));

                    for col=[4,6]
                        % Converts strings in the input cell array to numbers. Replaced non-numeric
                        % strings with NaN.
                        rawData = dataArray{col};
                        for row=1:size(rawData, 1);
                            % Create a regular expression to detect and remove non-numeric prefixes and
                            % suffixes.
                            regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
                            try
                                result = regexp(rawData{row}, regexstr, 'names');
                                numbers = result.numbers;

                                % Detected commas in non-thousand locations.
                                invalidThousandsSeparator = false;
                                if any(numbers==',');
                                    thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                                    if isempty(regexp(thousandsRegExp, ',', 'once'));
                                        numbers = NaN;
                                        invalidThousandsSeparator = true;
                                    end
                                end
                                % Convert numeric strings to numbers.
                                if ~invalidThousandsSeparator;
                                    numbers = textscan(strrep(numbers, ',', ''), '%f');
                                    numericData(row, col) = numbers{1};
                                    raw{row, col} = numbers{1};
                                end
                            catch me
                            end
                        end
                    end

                    %% Split data into numeric and cell columns.
                    rawNumericColumns = raw(:, [4,6]);
                    rawCellColumns = raw(:, [1,2,3,5,7]);


                    %% Replace non-numeric cells with NaN
                    R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
                    rawNumericColumns(R) = {NaN}; % Replace non-numeric cells



                    %% Clear temporary variables
                    clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me R;
                    
                    %% Save Data into structure and matrix
                    
                                Q.site_names(1,ii).site_name=site_names(1,ii);
                                Q.site_names(1,ii).time = time_builder(datenum(rawCellColumns(4:end, 3)));
                                Q.site_names(1,ii).dischargeCFS = cell2mat(rawNumericColumns(4:end, 1));
                                Q.site_names(1,ii).gageHtFt = cell2mat(rawNumericColumns(4:end, 2));
                        
                                time= Q.site_names(1,ii).time;
                                    gageHtFt=[gageHtFt,Q.site_names(1,ii).gageHtFt];
                                    dischargeCFS=[dischargeCFS,Q.site_names(1,ii).dischargeCFS];
                                    
                
                    
                    clear dischargeCFSTemp gageHtFtTemp rawNumericColumns rawCellColumns
        end
        
%%
       if plotOutput==1 
           subplot(2,1,1),
            plot(Q.site_names(1).time(:,7),dischargeCFS,'Linewidth',2),datetick
            legend(site_names)
            ylabel('Discharge [cfs]','Fontsize',20)
           subplot(2,1,2),
            plot(Q.site_names(1).time(:,7),gageHtFt,'Linewidth',2),datetick
            legend(site_names)
            ylabel('Stage Height [feet]','Fontsize',20)
       end