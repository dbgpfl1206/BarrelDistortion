% 카메라 왜곡 보정(r대r)
clear; clc;

img=imread(""); % Insert Image Path
[h,w,c]=size(img);

r=0;
[img_x,img_y]=meshgrid(1-r:w+r,1-r:h+r);
img_X=reshape(img_x,1,[]);
img_Y=reshape(img_y,1,[]);
one=ones(1,size(img_X,2));

fc = [ 968.90083*0.9   975.04250*0.9 ];
cc = [ 951.58318   544.61484 ];
kc = [ -0.18899   0.02762   0.00019   0.00030  0.00000 ];
A = [fc(1) 0 cc(1);0 fc(2) cc(2);0 0 1];

Rtz_World=inv(A)*[img_X;img_Y;one];
Rtz_X=Rtz_World(1,:);
Rtz_Y=Rtz_World(2,:);
Rtz_Z=Rtz_World(3,:);

correct_h=size(img_x,1);
correct_w=size(img_x,2);
correct_img=zeros(correct_h,correct_w,c,'uint8');

for i=1:correct_w
    for j=1:correct_h
        original_r=(Rtz_X(correct_h*(i-1)+j)^2+Rtz_Y(correct_h*(i-1)+j)^2).^0.5;
        theta=atan(original_r);
        distortion_r=1 + kc(1).*original_r.^2 + kc(2).*original_r.^4 + kc(5).*original_r.^6;
        dis_tx = 2*kc(3)*Rtz_X(correct_h*(i-1)+j)*Rtz_Y(correct_h*(i-1)+j) + kc(4)*(original_r.^2+2*Rtz_X(correct_h*(i-1)+j)^2);   %tangential distortion x
        dis_ty = 2*kc(4)*Rtz_X(correct_h*(i-1)+j)*Rtz_Y(correct_h*(i-1)+j) + kc(3)*(original_r.^2+2*Rtz_Y(correct_h*(i-1)+j)^2);   %tangential distortion y
        distortion_X=distortion_r.*Rtz_X(correct_h*(i-1)+j)+dis_tx;
        distortion_Y=distortion_r.*Rtz_Y(correct_h*(i-1)+j)+dis_ty;
        correct_XY=A*[distortion_X;distortion_Y;1];
        correct_X=round(correct_XY(1,1));
        correct_Y=round(correct_XY(2,1));
        if (0<correct_X)&&(0<correct_Y)&&(correct_X<w)&&(correct_Y<h)
            correct_img(j,i,1)=img(correct_Y,correct_X,1);
            correct_img(j,i,2)=img(correct_Y,correct_X,2);
            correct_img(j,i,3)=img(correct_Y,correct_X,3);
        end
    end
end
%% Plot
subplot(121)
imshow(img)
title('Before')
subplot(122)
imshow(correct_img)
title('After')