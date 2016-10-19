function [] = main(imname1, points1, points2)
im1 = imread(imname1);
imshow(im1);
points = (points1 + points2) / 2;
tri = delaunay(points);
[midR, midC] = splitRC(tri, points);
[r1, c1] = splitRC(tri, points1);
A = computeAffine([r1(1, :), c1(1, :)], [midR(1, :), midC(1, :)])
hold on;
for a = 1:size(midR, 1)
    line([midR(a, 1), midR(a, 2)], [midC(a, 1), midC(a, 2)]);
    line([midR(a, 3), midR(a, 2)], [midC(a, 3), midC(a, 2)]);
    line([midR(a, 1), midR(a, 3)], [midC(a, 1), midC(a, 3)]);
end
hold off;
end

function [r, c] = splitRC(tri, points)
r = zeros(size(tri));
c = zeros(size(tri));
for a = 1:size(tri, 1)
    point1 = tri(a, 1);
    point2 = tri(a, 2);
    point3 = tri(a, 3);
    r(a, 1) = points(point1, 1);
    r(a, 2) = points(point2, 1);
    r(a, 3) = points(point3, 1);
    c(a, 1) = points(point1, 2);
    c(a, 2) = points(point2, 2);
    c(a, 3) = points(point3, 2);
end
end

function [A] = computeAffine(tri1_pts, tri2_pts)
x = [tri1_pts(1:3); tri1_pts(4:6); 1, 1, 1];
y = [tri2_pts(1:3); tri2_pts(4:6); 1, 1, 1];
A = y * x ^ -1;
end