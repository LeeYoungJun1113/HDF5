clc;
close all;
clear all;

cnt = 0;

for F1 = 1:49
    test = imread(['dataset(tiff49)/',num2str(F1), '.tif']);
    
    if size(test,3) == 4
        test = test(:,:,1:3);
    end
    test = rgb2gray(test);
    
    if numel(test) == 512^2
        cnt = cnt + 1;
        input(:,:,cnt) = im2double(test);
        scan_num(cnt) = F1;
    end
end

input = input(:,:,2:16);
target = zeros(4,15);

for F1 = 2:16
    test = loadjson(['Data_Labeled(3type,49)/',num2str(scan_num(F1)), '.json']);
    scan_range = test.shapes(3).points;
    target(:, F1-1) = reshape(scan_range,4,1);
end

figure; imagesc(input(:,:,1));colormap gray; hold on;
plot(target(1:2,1), target(3:4,1), '-yo');


h5create('chest_test.h5','/input', [512,512,3]);
h5write('chest_test.h5', '/input', input(:,:,13:15));
% 정답레이블
h5create('chest_test.h5','/target', [4,3]);
h5write('chest_test.h5', '/target', target(:,13:15) / 512);

in_train = input(:,:,1:12);
tar_train = target(:,1:12);

in_train2 = fliplr(in_train);
tar_train2 = [tar_train(2:-1:1,:); tar_train(3:4,:)];

in_train3 = flipud(in_train);
tar_train3 = [tar_train(1:2,:); 512 - tar_train(3:4,:)];

in_train_set = cat(3, in_train, in_train2, in_train3);
tar_train_set = cat(2, tar_train, tar_train2, tar_train3);

% rand_idx=randperm(36);
% 
% in_shuf = in_train_set(:,:,rand_idx);
% tar_shuf = tar_train_set(:,rand_idx);

h5create('chest_train.h5','/input', size(in_train_set));
h5write('chest_train.h5', '/input', in_train_set);
h5create('chest_train.h5','/target', size(tar_train_set));
h5write('chest_train.h5', '/target', tar_train_set / 512);


