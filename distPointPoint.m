function dist = distPointPoint(pt1, pt2)

    dist = 0;
    for i=1:length(pt1)
        dist = dist + (pt1(i) - pt2(i))^2;
    end
    dist = sqrt(dist);

end


