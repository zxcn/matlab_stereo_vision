clear
clc
close all

% 图像后缀
image_suffix = '.png';

% 图像路径
left_image_path = './Data/Calibration/Left';
right_image_path = './Data/Calibration/Right';

% 查找路径下所有指定格式的图像
left_image_list = dir([left_image_path,'/*',image_suffix]);
right_image_list = dir([right_image_path,'/*',image_suffix]);

% 结构体转换为元胞数组
imageFileNames1 = cellfun(@(c1,c2)[c1,'/',c2],{left_image_list.folder},{left_image_list.name},'UniformOutput',false);
imageFileNames2 = cellfun(@(c1,c2)[c1,'/',c2],{right_image_list.folder},{right_image_list.name},'UniformOutput',false);

% 棋盘格检测
detector = vision.calibration.stereo.CheckerboardDetector();
[imagePoints, imagesUsed] = detectPatternPoints(detector, imageFileNames1, imageFileNames2);

% 棋盘格角点的世界坐标
% Generate world coordinates for the planar patten keypoints
squareSize = 20;  % 单位mm
worldPoints = generateWorldPoints(detector, 'SquareSize', squareSize);

% 读取左相机的第一个图像，获得图像长宽
I1 = imread(imageFileNames1{1});
[mrows, ncols, ~] = size(I1);

% estimateCameraParameters：相机标定函数
% EstimateSkew：是否计算Skew参数
% EstimateTangentialDistortion：是否计算切向畸变参数p1,p2
% NumRadialDistortionCoefficients：径向畸变参数数量，为2则仅使用k1,k2，为3则使用k1,k2,k3
% WorldUnits：尺度单位
% InitialIntrinsicMatrix：内参矩阵初始值
% InitialRadialDistortion：径向畸变初始值
% ImageSize：图像长宽
[stereoParams, pairsUsed, estimationErrors] = estimateCameraParameters(imagePoints, worldPoints, ...
    'EstimateSkew', false, 'EstimateTangentialDistortion', true, ...
    'NumRadialDistortionCoefficients', 3, 'WorldUnits', 'millimeters', ...
    'InitialIntrinsicMatrix', [], 'InitialRadialDistortion', [], ...
    'ImageSize', [mrows, ncols]);

% 显示重投影误差
% View reprojection errors
h1=figure; showReprojectionErrors(stereoParams);

%可视化标定板和相机位姿
% Visualize pattern locations
h2=figure; showExtrinsics(stereoParams, 'CameraCentric');

% 显示相机标定结果和误差
% Display parameter estimation errors
displayErrors(estimationErrors, stereoParams);

% 保存标定结果
save stereoParams stereoParams