function IntensityGraph(summary, results)

%% INTENSITY GRAPH
% Input Summary & Results excel spreadsheets from ImageJ macro to quickly
% determine the number of fusion events present in an image stack and
% identify the events as proliferating or unchanging. The function is used
% as follows:
%
% IntensityGraph('summary_sheet_name.xls', 'results_sheet_name.xls')
%
% The results are displayed via text output and the sorted data are saved
% into excel spreadsheets, e.g. "YLocations-07-Mar-2010-T12-37-47.csv"
% Figures will also display scatter plots of Area, X Location, and Y
% Location data.

warning off all

%% Open Summary & Results sheets
% Read Summary excel sheet into MATLAB
[data] = xlsread(summary);

% Store number of identified 'blobs'
num = data(:,1);
clear data

% Read Results excel sheet into MATLAB
[data] = xlsread(results);

% Store Area, X, Y data
vals = data(:,2:4);
clear data

%% Sort Area, X, Y by image number
% Create empty matrices and set initial counts
area = zeros(length(num),max(num));
X = zeros(length(num),max(num));
Y = zeros(length(num),max(num));
counta = 1;
countx = 1;
county = 1;

% For each image, find the number of blobs and sort area, X, Y data into
% rows based on the number of data points for each image. E.G. If 5 blobs
% are identified in an image, find the 5 area, X, Y data points
% corresponding to that image and place in single row - the number of which
% is the image number.
for i = 1:length(num) % number of images
    n = num(i,1); % number of blobs in each image
    d1 = vals(counta:counta+n-1,1); % pick out data points for each image
    flip1 = d1';
    area(i,:) = [flip1 zeros(1,max(num)-length(flip1))]; % store in rows
    counta = counta+n; % advance count
    d2 = vals(countx:countx+n-1,2);
    flip2 = d2';
    X(i,:) = [flip2 zeros(1,max(num)-length(flip2))];
    countx = countx+n;
    d3 = vals(county:county+n-1,3);
    flip3 = d3';
    Y(i,:) = [flip3 zeros(1,max(num)-length(flip3))];
    county = county+n;
end

%% Remove 'blob' areas under 1000 pixels
% Create new empty matrices for "large blobs" and set initial count
lgarea = zeros(size(area));
lgX = zeros(size(X));
lgY = zeros(size(Y));
count = 1;

% Any blob area under 1000 pixels isn't interesting - most cell areas are
% much larger. Go through each row and only store areas (and corresponding
% X,Y coordinates) that are larger than 1000 pixels.
for j = 1:size(X,1)
    for k = 1:size(X,2)
        if area(j,k) >= 1000
            lgarea(j,count) = area(j,k);
            lgX(j,count) = X(j,k);
            lgY(j,count) = Y(j,k);
            count = count+1;
        end
    end
    count = 1;
end

%% Remove extra columns of zeros
[r,c] = find(lgarea);
m = max(c);
newarea = lgarea(:,1:m);
newX = lgX(:,1:m);
newY = lgY(:,1:m);

%% Average nearby locations & sum nearby areas
% Create empty matrices and intial count
avgarea = zeros(size(newarea));
avgX = zeros(size(newX));
avgY = zeros(size(newY));
avgcount = 1;

% Some blobs are accidentally classified as two separate blobs, but should
% really be considered one area. If the X & Y coordinates for two areas in
% the same image are within 10 pixels of each other, the areas are added
% together and the X & Y coordinates are averaged.
for g = 1:size(newY,1)
    for h = 1:size(newY,2)-1
        if abs(newX(g,h)-newX(g,h+1))<10 && abs(newY(g,h)-newY(g,h+1))<10
            avgX(g,avgcount) = (newX(g,h)+newX(g,h+1))/2;
            avgY(g,avgcount) = (newY(g,h)+newY(g,h+1))/2;
            avgarea(g,avgcount) = newarea(g,h)+newarea(g,h+1);
            avgcount = avgcount+1;
        else
            avgX(g,avgcount) = newX(g,h);
            avgY(g,avgcount) = newY(g,h);
            avgarea(g,avgcount) = newarea(g,h);
            avgX(g,avgcount+1) = newX(g,h+1);
            avgY(g,avgcount+1) = newY(g,h+1);
            avgarea(g,avgcount+1) = newarea(g,h+1);
            avgcount = avgcount +1;
        end
    end
    avgcount = 1;
end

%% Sort data by 'blob' locations
% Create empty matrices (larger than needed)
farea = zeros(size(avgarea,1),2.*size(avgarea,2));
fX = zeros(size(avgX,1),2.*size(avgX,2));
fY = zeros(size(avgY,1),2.*size(avgY,2));

% Blobs may appear & disappear in different images. Using the Y coordinate
% data (because it is given in increasing size, generally), the coordinates
% in a column are compared to the smallest coordinate in that column. If
% they are within 150 pixels of each other, they remain in the same column
% (as they are most likely the same 'blob'). If not, all the data in their
% row is shifted to the right and a zero is placed in the column. The
% matching blob data for X and area is also moved.

for u = 1:size(fY,2)
    zY = nonzeros(avgY(:,u));
    pY = min(zY);
    
    for i = 1:size(fY,1)
        if abs(avgY(i,u)-pY)<165
            fY(i,u:size(avgY,2)) = avgY(i,u:size(avgY,2));
            fX(i,u:size(avgX,2)) = avgX(i,u:size(avgX,2));
            farea(i,u:size(avgarea,2)) = avgarea(i,u:size(avgarea,2));
        else fY(i,u) = 0; fX(i,u) = 0; farea(i,u) = 0;
            fY(i,u+1:size(avgY,2)+1) = avgY(i,u:size(avgY,2));
            fX(i,u+1:size(avgX,2)+1) = avgX(i,u:size(avgX,2));
            farea(i,u+1:size(avgarea,2)+1) = avgarea(i,u:size(avgarea,2));
        end
    end
    avgY = fY;
    avgX = fX;
    avgarea = farea;
    clear zY
end

%% Remove extra columns of zeros
[r,c] = find(fY);
m = max(c);
farea = farea(:,1:m);
fX = fX(:,1:m);
fY = fY(:,1:m);

for a = 1:size(fY,2)
    if fY(:,1)==0
        fY = fY(:,2:m);
        fX = fX(:,2:m);
        farea = farea(:,2:m);
    end
    [r,c] = find(fY);
    m = max(c);
end
clear a r c

%% Determine number of blobs/fusions & classify them
% The number of fusion events (or 'blobs') located is equal to the number
% of columns in the final area, X, and Y matrices.
s = size(farea,2);
st = num2str(s);
message = strcat('Number of fusion events=',st);
disp(message)

% Generally, fusion areas change the most drastically with proliferation.
% Thus, by finding the range of areas (max area - min area) for each fusion
% event, those with the largest ranges (>8000 pixels) are classified as
% "proliferating" and the rest are considered to be "unchanging".
lo = zeros(1,s);
hi = zeros(1,s);
for c = 1:s
    lo(1,c) = min(nonzeros(farea(:,c)));
    hi(1,c) = max(nonzeros(farea(:,c)));
end
diff = hi-lo;
pro = length(find(diff>8000));
same = s-pro;
pro = num2str(pro);
same = num2str(same);
stpro = strcat('Number of proliferating events=',pro);
stsame = strcat('Number of unchanging events=',same);
disp(stpro)
disp(stsame)

%% Plot sorted data for visual verification
% Area data for each fusion event is displayed in a scatter plot
figure;
t = 1:size(farea,1);
hold all
for c = 1:s
    plot(t,farea(:,c),'*')
end
hold off
title('\fontsize{14}Area of Fusion Events ') 
xlabel('Image Number')
ylabel('Area (pixels^2)')

% X location data for each fusion event is displayed in a scatter plot
figure;
t = 1:size(fX,1);
hold all
for c = 1:s
    plot(t,fX(:,c),'*')
end
hold off
title('\fontsize{14}X Location of Fusion Events ') 
xlabel('Image Number')
ylabel('X Location (pixels)')

% Y location data for each fusion event is displayed in a scatter plot
figure;
t = 1:size(fY,1);
hold all
for c = 1:s
    plot(t,fY(:,c),'*')
end
hold off
title('\fontsize{14}Y Location of Fusion Events ') 
xlabel('Image Number')
ylabel('Y Location (pixels)')

%% Store sorted data as new excel sheets
% For future reference, sorted data is stored into time-stamped excel
% spreadsheets.
labelY = 'YLocation-';
newlabelY = strcat(labelY, datestr(now,'dd-mmm-yyyy-THH-MM-SS'), '.xls');
xlswrite(newlabelY, fY);

labelX = 'XLocation-';
newlabelX = strcat(labelX, datestr(now,'dd-mmm-yyyy-THH-MM-SS'), '.xls');
xlswrite(newlabelX, fX);

labelarea = 'Area-';
newlabelarea = strcat(labelarea, datestr(now,'dd-mmm-yyyy-THH-MM-SS'), '.xls');
xlswrite(newlabelarea, farea);

end
