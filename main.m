function [] = main()
%% Change part number to see different parts of this project
% Part 1 produces face morphing between two faces and save in a gif
% animation
% Part 2 takes 37 persons' face and find average shape and face, as well as
% morph selected person into average shape
% Part 3 morphes my picture to other's shape, or vice versa
% Part 4 return caricature of my face from mean face calculated from part 2
% Part 5 morphes me with average white female in America
part = 5;
if part == 1
    %% Compute face morphing between two faces and save in a gif animation
    % Both picture should be same size
    % Chagne csv name is columne and row index of each keypoints. Both
    % file points should be conresponding
    imname1 = 'will.jpg';
    imname2 = 'tom.jpg';
    points1csv = 'willPoints.csv';
    points2csv = 'tomPoints.csv';
    points1 = csvread(points1csv);
    points2 = csvread(points2csv);
    im1 = imread(imname1);
    im2 = imread(imname2);
    
    points = (points1 + points2) / 2;
    tri = delaunay(points);
    [r1, c1] = splitRC(tri, points1);
    [r2, c2] = splitRC(tri, points2);
    
    filename = 'result.gif';
    [imind, cm] = rgb2ind(im1, 256);
    imwrite(imind, cm, filename, 'gif', 'LoopCount', Inf, 'DelayTime', 1/5);
    
    for a = 43/44:-1/44:1/44
        result = morph(im1, im2, points1, points2, tri, a, a, r1, c1, r2, c2);
        [imind, cm] = rgb2ind(result, 256);
        imwrite(imind, cm, filename, 'gif', 'WriteMode', 'append', 'DelayTime', 1/15);
    end
    
    [imind, cm] = rgb2ind(im2, 256);
    imwrite(imind, cm, filename, 'gif', 'WriteMode', 'append', 'DelayTime', 1/5);
elseif part == 2
    %% Compute avg shape
    avgPts = zeros(62, 2);
    for i = 1:37
        points = readPts(i);
        avgPts = avgPts + points;
    end
    avgPts = avgPts / 37;
    data = csvread('data/1.csv');
    tri = data(1:58, 5:7) + 1;
    [midR, midC] = splitRC(tri, avgPts);
    avgShape = ones(480, 640) * 255;
    figure(1);
    imshow(avgShape);
    hold on;
    for a = 1:size(midR, 1)
        line([midC(a, 1), midC(a, 2)], [midR(a, 1), midR(a, 2)]);
        line([midC(a, 3), midC(a, 2)], [midR(a, 3), midR(a, 2)]);
        line([midC(a, 1), midC(a, 3)], [midR(a, 1), midR(a, 3)]);
    end
    hold off;
    
    %% Morph some faces into average shape.
    % Change num to decide which face to morph
    num = 5;
    tri = delaunay(avgPts);
    [midR, midC] = splitRC(tri, avgPts);
    source = readImg(num);
    sourcePts = readPts(num);
    [r1, c1] = splitRC(tri, sourcePts);
    sourcer = source(:, :, 1);
    sourceg = source(:, :, 2);
    sourceb = source(:, :, 3);
    morphedr = warp(sourcer, r1, c1, midR, midC);
    morphedg = warp(sourceg, r1, c1, midR, midC);
    morphedb = warp(sourceb, r1, c1, midR, midC);
    morphed = cat(3, morphedr, morphedg, morphedb);
    imshow(morphed);
    filename = strcat(num2str(num), '.jpg');
    imwrite(morphed, filename);
    
    %% Compute average face of the population
    avgr = zeros(480, 640);
    avgg = zeros(480, 640);
    avgb = zeros(480, 640);
    for j = 1:37
        source = readImg(j);
        sourcePts = readPts(j);
        [r1, c1] = splitRC(tri, sourcePts);
        sourcer = source(:, :, 1);
        sourceg = source(:, :, 2);
        sourceb = source(:, :, 3);
        avgr = avgr + double(warp(sourcer, r1, c1, midR, midC));
        avgg = avgg + double(warp(sourceg, r1, c1, midR, midC));
        avgb = avgb + double(warp(sourceb, r1, c1, midR, midC));        
    end
    avgr = uint8(avgr / 37);
    avgg = uint8(avgg / 37);
    avgb = uint8(avgb / 37);
    avgPop = cat(3, avgr, avgg, avgb);
    imwrite(avgPop, 'avgPop.jpg');
elseif part == 3
    %% Warp my face to average geometry, and average face into my geometry
    % Code below warps my face to average geometry. For reverse result,
    % change imname1 and swap pointsCSV
    imname1 = 'willHor.jpg';
    points1csv = 'willAvgPts.csv';
    points2csv = 'avgpts.csv';
    sourcePts = csvread(points1csv);
    points2 = csvread(points2csv);
    source = imread(imname1);
    tri = delaunay(points2);
    [r1, c1] = splitRC(tri, sourcePts);
    [midR, midC] = splitRC(tri, points2);
    sourcer = source(:, :, 1);
    sourceg = source(:, :, 2);
    sourceb = source(:, :, 3);
    morphedr = warp(sourcer, r1, c1, midR, midC);
    morphedg = warp(sourceg, r1, c1, midR, midC);
    morphedb = warp(sourceb, r1, c1, midR, midC);
    morphed = cat(3, morphedr, morphedg, morphedb);
    imwrite(morphed, 'will2avg.jpg');
    imshow(morphed);
elseif part == 4
    %% Calculate caricature
    % Lambda controls weight of delta
    lambda = 0.5;
    imname1 = 'willHor.jpg';
    points1csv = 'willAvgPts.csv';
    points2csv = 'avgpts.csv';
    facepts = csvread(points1csv);
    avgpts = csvread(points2csv);
    faceimg = imread(imname1);
    delta = facepts - avgpts;
    resultpts = avgpts + lambda * delta;
    tri = delaunay(resultpts);
    [r1, c1] = splitRC(tri, facepts);
    [midR, midC] = splitRC(tri, resultpts);
    sourcer = faceimg(:, :, 1);
    sourceg = faceimg(:, :, 2);
    sourceb = faceimg(:, :, 3);
    morphedr = warp(sourcer, r1, c1, midR, midC);
    morphedg = warp(sourceg, r1, c1, midR, midC);
    morphedb = warp(sourceb, r1, c1, midR, midC);
    morphed = cat(3, morphedr, morphedg, morphedb);
    imwrite(morphed, 'caricature.jpg');
    imshow(morphed);
elseif part == 5;
    %% Bells and whistle part.
    % Following generate my face with average white female color. This part
    % is dependent on result in part 3 to warp face to target shape
    im1 = imread('willWhite.jpg');
    im2 = imread('whiteWillshape.jpg');
    r = im1 * 0.5 + im2 * 0.5;
    imwrite(r, 'will2whiteAppearance.jpg');
    
    % Following generates my face to average white female shape and color
    im1 = imread('will2white.jpg');
    im2 = imread('white.jpg');
    r = im1 * 0.5 + im2 * 0.5;
    imwrite(r, 'whiteShapeAndColor.jpg');    
end
end

%% Helper functions
function [img] = readImg(num)
s = strcat('data/', num2str(num), '.bmp');
img = imread(s);
end

function [points] = readPts(num)
s = strcat('data/', num2str(num), '.csv');
data = csvread(s);
points = [data(:, 3) * 640, data(:, 4) * 480];
end

function [morphed_im] = morph(im1, im2, im1_pts, im2_pts, tri, warp_frac,...
    dissolve_frac, r1, c1, r2, c2)
im1r = im1(:, :, 1);
im1g = im1(:, :, 2);
im1b = im1(:, :, 3);
im2r = im2(:, :, 1);
im2g = im2(:, :, 2);
im2b = im2(:, :, 3);

points = im1_pts * warp_frac + im2_pts * (1 - warp_frac);
[midR, midC] = splitRC(tri, points);

result1r = warp(im1r, r1, c1, midR, midC);
result2r = warp(im2r, r2, c2, midR, midC);
resultr = result1r * dissolve_frac + result2r * (1 - dissolve_frac);

result1g = warp(im1g, r1, c1, midR, midC);
result2g = warp(im2g, r2, c2, midR, midC);
resultg = result1g * dissolve_frac + result2g * (1 - dissolve_frac);

result1b = warp(im1b, r1, c1, midR, midC);
result2b = warp(im2b, r2, c2, midR, midC);
resultb = result1b * dissolve_frac + result2b * (1 - dissolve_frac);

morphed_im = cat(3, resultr, resultg, resultb);
end

function [result] = warp(im1, r1, c1, midR, midC)
result = uint8(zeros(size(im1)));
for i = 1:size(midR, 1)
    A = computeAffine([r1(i, :), c1(i, :)], [midR(i, :), midC(i, :)]);
    mask = roipoly(im1, c1(i, :), r1(i, :));
    [triR, triC] = find(mask);
    x = [triR'; triC'; ones(size(triR))'];
    y = round(A * x);
    for j = 1:size(y, 2)
        if y(1, j) <= 0 || y(2, j) <= 0 || y(1, j) > size(im1, 1)...
                || y(2, j) > size(im1, 2)
            continue;
        end
        result(y(1, j), y(2, j)) = im1(x(1, j), x(2, j));
    end
end
[empR, empC] = find(result == 0);
for a = 1:size(empR)
    result(empR(a), empC(a)) = nearestVal(result, empR(a), empC(a));
end
end

function [avg] = nearestVal(img, r, c)
count = 0;
sum = 0;
for a = -1:1
    for b = -1:1
        candidateR = r + a;
        candidateC = c + b;
        if candidateR <= 0 ||  candidateR >= size(img, 1) + 1 ...
                || candidateC <= 0 || candidateC >= size(img, 2) + 1 ...
                || img(candidateR, candidateC) == 0
            continue;
        else
            count = count + 1;
            sum = sum + double(img(candidateR, candidateC));
        end
    end
end
avg = sum / count;
end

function [r, c] = splitRC(tri, points)
r = zeros(size(tri));
c = zeros(size(tri));
for a = 1:size(tri, 1)
    point1 = tri(a, 1);
    point2 = tri(a, 2);
    point3 = tri(a, 3);
    r(a, 1) = points(point1, 2);
    r(a, 2) = points(point2, 2);
    r(a, 3) = points(point3, 2);
    c(a, 1) = points(point1, 1);
    c(a, 2) = points(point2, 1);
    c(a, 3) = points(point3, 1);
end
end

function [A] = computeAffine(tri1_pts, tri2_pts)
x = [tri1_pts(1:3); tri1_pts(4:6); 1, 1, 1];
y = [tri2_pts(1:3); tri2_pts(4:6); 1, 1, 1];
A = y * x ^ -1;
end