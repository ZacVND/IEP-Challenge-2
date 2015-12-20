function DataLogger
 
%%User Defined Properties 

dataFileName = 'datafile2.csv';
port = '/dev/tty.uart-1FFF5184AB902652';

serialDataFormat = ['LDR:%i \r\n'];
fileHeader = ['Time,LDR'];

numberPlots = 1;

plotTitle = 'Serial Data Log';  % plot title
xLabel = 'Elapsed Time (s)';    % x-axis label
yLabel = 'Data';                % y-axis label

delay = 0.01;

%Set up Plot
close all
figure(1);
for n=1:numberPlots,
    subplot(numberPlots,1,n)
    plotGraph(n) = plot(0,0,'-mo',...
        'LineWidth',1,...
        'MarkerEdgeColor','k',...
        'MarkerFaceColor',[.49 1 .63],...
        'MarkerSize',2);
end
           
             
title(plotTitle,'FontSize',25);
xlabel(xLabel,'FontSize',15);
ylabel(yLabel,'FontSize',15);


% Open File to save data
if exist(fullfile(cd, dataFileName), 'file')
    disp('Data file already exists appending data');
    fileID = fopen(dataFileName,'a');
else
    fileID = fopen(dataFileName,'w');
    fprintf(fileID,fileHeader);  % Print file header
end


% COM1 on Windows, /dev/tty.KeySerial1 (or like device) on Mac
serialConnection=serial(port);

% lets setup a helper function thats called everytime a byte is received
set(serialConnection, 'BytesAvailableFcnMode', 'byte');
set(serialConnection, 'BytesAvailableFcnCount', 1);
set(serialConnection, 'BytesAvailableFcn', {@serialEventHandler,fileID,plotGraph,serialDataFormat});

fopen(serialConnection);

% Start timer
tic

while ishandle(plotGraph(1)) %Loop when Plot is Active
             %Allow MATLAB to Update Plot
        pause(delay);
end

finishup = onCleanup(@() cleanUp(serialConnection,fileID));
end


function serialEventHandler(serialConnection, ~,fileID,plotGraph,serialDataFormat)
bytes = get(serialConnection, 'BytesAvailable');
if(bytes > 0 ) % we may have alread read the data
    try
        Data = fscanf(serialConnection, serialDataFormat);
        time = toc;
        
        %Append data to file
        fprintf(fileID,'%f,%i\r\n',time,Data(1));
        
        for n=1:length(plotGraph),
            Told = get(plotGraph(n),'Xdata');
            T = [Told,time];
            Yold = get(plotGraph(n),'Ydata');
            Y = [Yold,Data(n)];
            set(plotGraph(n),'XData',T,'YData',Y);
        end
    catch
        warning('Data failed to parse');
    end
end
end

function cleanUp(serialConnection,fileID)

fclose(serialConnection);
fclose(fileID);
end

