function [] = main(im1, points)
imshow(im1);
tri = delaunay(points);
hold on;
for a = 1:size(points, 1)
   plot(points(a, 1), points(a, 2), 'g.'); 
end
for b = 1:size(tri, 1)
    point1 = tri(b, 1);
    point2 = tri(b, 2);
    point3 = tri(b, 3);
    line([points(point1, 1), points(point2, 1)], [points(point1, 2), points(point2, 2)]);
    line([points(point2, 1), points(point3, 1)], [points(point2, 2), points(point3, 2)]);
    line([points(point3, 1), points(point1, 1)], [points(point3, 2), points(point1, 2)]);
end
hold off;
end