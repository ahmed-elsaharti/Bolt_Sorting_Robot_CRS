function [ ObjectParams ] = DetectObj( originalimage,OBlack,threshold,straythresh,disksize )
%-------------------------------------------------------------------------------------
%This function produces a matrix with each row containing each object's X
%centroid, Y centroid, Orientation in radians, area in pixels and width in pixels.
%-------------------------------------------------------------------------------------
%This code was based on the 'Labeling of objects in an image using
%segmentation in Matlab' Tutorial by Rashi Agrawal
%(https://www.youtube.com/watch?v=XrC1r80-p-k)
%-------------------------------------------------------------------------------------
%OBlack = 1 if object is dark and background is light, 2 if object is light
%and background is dark
%threshold: the threshold of binary image conversion
%straythresh: pixel size of 'objects' to ignore after segmentation (noise, etc)
%disksize: size of morphological disk used when morphilogically opening
%image while segmenting
%-------------------------------------------------------------------------------------


ObjectParams=[];
objcounter=0;

figure,imshow(originalimage)
title('Original Image')
hold on


if (OBlack==1)
bwimage=1-im2bw(originalimage,threshold);
else
    bwimage=im2bw(originalimage,threshold);
end


filledimage=imfill(bwimage);
se=strel('disk',disksize);
filledimage=imopen(filledimage,se);

label=bwlabel(filledimage);

for j=1:1:max(max(label))
[row, col]=find(label==j);
length=max(row)-min(row); %-2?
width=max(col)-min(col); %-2?
    if (length>straythresh || width>straythresh)
        objcounter=objcounter+1;
        if (OBlack==1)
        target=uint8(ones([length width 3])*255);
        else target=uint8(zeros([length width 3]));
        end
        sy=min(col)-1;
        sx=min(row)-1;

        for i=1:1:size(row,1)
          x=row(i,1)-sx;
          y=col(i,1)-sy;
          target(x,y,1)=originalimage(row(i,1),col(i,1),1);
        end
        for i=1:1:size(row,1)
          x=row(i,1)-sx;
          y=col(i,1)-sy;
          target(x,y,2)=originalimage(row(i,1),col(i,1),2);
        end
        for i=1:1:size(row,1)
          x=row(i,1)-sx;
          y=col(i,1)-sy;
          target(x,y,3)=originalimage(row(i,1),col(i,1),3);
        end
    binarized=label==j;
    E=IM.get_ellipse(binarized);
    IM.draw_ellipse(E, 'color', 'm');
    IM.draw_ellipse(E, 'color', 'm','elements', 'axis');
    text(E.x+(E.w/2), E.y, [num2str(objcounter)],'Color','white', 'FontSize', 20);
    plot(E.x,E.y,'b+', 'MarkerSize', 10,'LineWidth',2)
    
    
    %Rotating the segmented image of the Jth object
    rotated=rotateAround(binarized,E.y,E.x,radtodeg(E.theta)-90);
    % figure,imshow(rotated)
    %Searching for the first and last pixels in the width direction
    begincheck=1;
    while rotated(round(E.y),begincheck)~=1
    begincheck=begincheck+1;
    end
    Startpixel=begincheck;
    endcheck=begincheck;
    while rotated(round(E.y),endcheck)==1
    endcheck=endcheck+1;
    end
    Endpixel=endcheck-1;
    
    
    ObjectParams=[ObjectParams; E.x E.y rad2deg(E.theta) E.area Endpixel-Startpixel];
    else
    end

end





hold off
end

