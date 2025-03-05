%% 카메라 왜곡 보정(r대 theta)
%clear; clc;

%%
img=imread(""); % Insert Image Path
[h,w,c]=size(img);

% 이미지를 얼마나 볼 것인지 r을 통해 지정
r=2000;
[img_x,img_y]=meshgrid(1-r:w+r,1-r:h+r); 
img_X=reshape(img_x,1,[]);
img_Y=reshape(img_y,1,[]);
one=ones(1,size(img_X,2));

fc = [ size(img,2)*0.426295 size(img,2)*0.426295 ]; %pixel 단위
cc = [ size(img,2)*0.501493 size(img,1)*0.476360 ];
A = [fc(1) 0 cc(1);0 fc(2) cc(2);0 0 1];
kc = [1  -0.021296  -0.001587  0  0  0.00000 ]; %kc(1)*theta^1 + kc(2)*theta^3 + kc(3)*theta^5

Rtz_World=inv(A)*[img_X;img_Y;one];
Rtz_X=Rtz_World(1,:);
Rtz_Y=Rtz_World(2,:);
Rtz_Z=Rtz_World(3,:);

correct_h=size(img_x,1);
correct_w=size(img_x,2);
correct_img=zeros(correct_h,correct_w,c,'uint8');

for i=1:correct_w
    for j=1:correct_h
        original_r=sqrt(Rtz_X(correct_h*(i-1)+j)^2+Rtz_Y(correct_h*(i-1)+j)^2);
        theta=atan(original_r);
        distortion_r=kc(1)*theta^1 + kc(2)*theta^3 + kc(3)*theta^5;
        distortion_X=(distortion_r/original_r)*Rtz_X(correct_h*(i-1)+j); %왜곡된 r과 원래 r의 비율로 왜곡된 x구하기
        distortion_Y=(distortion_r/original_r)*Rtz_Y(correct_h*(i-1)+j);
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
%% 보정된 이미지 출력
subplot(121)
imshow(img)
title('Before')
subplot(122)
imshow(correct_img)
title('After')