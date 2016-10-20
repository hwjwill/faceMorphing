function [] = main(imname1, imname2, points1csv, points2csv)
points1 = csvread(points1csv);
points2 = csvread(points2csv);
im1 = imread(imname1);
im2 = imread(imname2);
im1 = rgb2gray(im1);
im2 = rgb2gray(im2);

points = (points1 + points2) / 2;
%points = points1 * 0.9 + points2 * 0.1;
tri = delaunay(points);
[midR, midC] = splitRC(tri, points);
[r1, c1] = splitRC(tri, points1);
[r2, c2] = splitRC(tri, points2);

result1 = warp(im1, r1, c1, midR, midC);
result2 = warp(im2, r2, c2, midR, midC);
figure(1);
imshow(result1);
result = result1 * 0.5 + result2 * 0.5;
figure(2);
imshow(result);
% hold on;
% for a = 1:size(midR, 1)
%     line([midC(a, 1), midC(a, 2)], [midR(a, 1), midR(a, 2)]);
%     line([midC(a, 3), midC(a, 2)], [midR(a, 3), midR(a, 2)]);
%     line([midC(a, 1), midC(a, 3)], [midR(a, 1), midR(a, 3)]);
% end
% hold off;
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
        result(y(1, j), y(2, j)) = im1(x(1, j), x(2, j));
    end
end
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