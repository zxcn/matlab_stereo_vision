clear
clc
close all

% 加载标定参数
load stereoParams.mat

% 待计算图像路径
left_image_path = './Data/Scene/Left/Gray0001.png';
right_image_path = './Data/Scene/Right/Gray0001.png';

% 读取图片
I1 = double(imread(left_image_path));
I2 = double(imread(right_image_path));

% 极线校正
[J1, J2, reprojectionMatrix] = rectifyStereoImages(I1,I2,stereoParams,'OutputView','valid','FillValues',0);
J1 = mat2gray(J1,[0,1023]);
J2 = mat2gray(J2,[0,1023]);
figure,imshowpair(J1,J2),title('极线校正结果')

% disparityBM：BlockMatch计算视差
% DisparityRange：视差范围
% BlockSize：匹配块的大小
disparityMap = disparityBM(J1,J2,"DisparityRange",[0,128],"BlockSize",25);
figure,imshow(disparityMap,[0,128]),title('视差')

% 重建三维点云
xyzPoints = reconstructScene(disparityMap,reprojectionMatrix);

% 点云维度由HxWx3转换为(HxW)x3
xyzPoints = reshape(xyzPoints,[],3);
% 滤除z值大于2000的点
m = xyzPoints(:,3)<2000;
ind = find(m==1);
xyzPoints = xyzPoints(m,:);

% 显示点云
figure,pcshow(xyzPoints);