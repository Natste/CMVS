function outputArray = get_matrix(cmvSample, dataWindow, matrixType)
%% This function maps lux data into a selected matrix type
[dataLength, nSensors] = size(cmvSample);
cmvSampleNorm = get_norm(cmvSample);
% pages = dataLength - dataWindow + 1;

% cmvMask = NaN(dataLength);
% switch nSensors
%   case 1
%     cmvSample(:, [1, 2, 3, 4,    6, 7, 8, 9]) = cmvMask(:, 1:8);
%   case 2
%     cmvSample(:, [   2, 3  4, 5, 6, 7, 8   ]) = cmvMask(:, 1:7);
%   case 3
%     cmvSample(:, [   2, 3  4,    6, 7, 8,  ]) = cmvMask(:, 1:6);
%   case 4
%     cmvSample(:, [1,    3,    5,    7,    9]) = cmvMask(:, 1:5);
%   case 5
%     cmvSample(:, [1,    3,          7,    9]) = cmvMask(:, 1:4);
%   case 6
%     cmvSample(:, [      3,    5,    7      ]) = cmvMask(:, 1:3);
%   case 7
%     cmvSample(:, [      3,          7      ]) = cmvMask(:, 1:2);
%   case 8
%     cmvSample(:,              5             ) = cmvMask(:, 1:1);
% end
% Get raw pixels
% rawMat = reshape(cmvSample', [3, 3, dataLength]);
% rawMat = permute(rawMat, [2, 1, 3]);
% for idataLen = 1:dataLength
%     iTemp = [cmvSample(idataLen, 5) cmvSample(idataLen, 4) cmvSample(idataLen, 6);
%              cmvSample(idataLen, 8) cmvSample(idataLen, 7) cmvSample(idataLen, 9);
%              cmvSample(idataLen, 2) cmvSample(idataLen, 1) cmvSample(idataLen, 3)];

%     rawMat(:, :, idataLen) = iTemp;
% end

% Get pixels
if strcmp(matrixType, 'normalized')
  sampleArray = cmvSampleNorm;
else
  sampleArray = cmvSample;
end
if isequal(sqrt(nSensors), round(sqrt(nSensors)))
  newshape = [sqrt(nSensors) sqrt(nSensors) dataLength];
elseif isprime(nSensors)
  newshape = [1, nSensors, dataLength];
else
  newshape = round([sqrt(nSensors), nSensors - sqrt(nSensors), dataLength]);
end
outputArray = reshape(sampleArray', newshape);
outputArray = permute(outputArray,  [2, 1, 3]);
outputArray = outputArray(:, :, 1:dataWindow) / dataWindow;
% outputArray = fillmissing()


% switch matrixType
%     case 'i'
%         iMat = zeros(3, 3, pages);
%         for ipage = 1:pages
%             for k = 1:dataWindow
%                 iTemp = [cmvSample(ipage - 1 + k, 5) cmvSample(ipage - 1 + k, 4) cmvSample(ipage - 1 + k, 6);
%                          cmvSample(ipage - 1 + k, 8) cmvSample(ipage - 1 + k, 7) cmvSample(ipage - 1 + k, 9);
%                          cmvSample(ipage - 1 + k, 2) cmvSample(ipage - 1 + k, 1) cmvSample(ipage - 1 + k, 3)];

%                 iMat(:, :, ipage) = iMat(:, :, ipage) + iTemp;
%             end
%             iMat(:, :, ipage) = iMat(:, :, ipage) / dataWindow;
%         end
%         outputArray = iMat;

%     case 'iNorm'
%         % Get normalized pixels
%         iNormMat = zeros(3, 3, pages);
%         for ipage = 1:pages
%             for k = 1:dataWindow
%                 iTemp = [cmvSampleNorm(ipage - 1 + k, 5) cmvSampleNorm(ipage - 1 + k, 4) cmvSampleNorm(ipage - 1 + k, 6);
%                          cmvSampleNorm(ipage - 1 + k, 8) cmvSampleNorm(ipage - 1 + k, 7) cmvSampleNorm(ipage - 1 + k, 9);
%                          cmvSampleNorm(ipage - 1 + k, 2) cmvSampleNorm(ipage - 1 + k, 1) cmvSampleNorm(ipage - 1 + k, 3)];

%                 iNormMat(:, :, ipage) = iNormMat(:, :, ipage) + iTemp;
%             end
%             iNormMat(:, :, ipage) = iNormMat(:, :, ipage) / dataWindow;
%         end
%         outputArray = iNormMat;

%     case 'iNormV2'
%         iNormMatV2 = zeros(3, 3, pages);
%         for ipage = 1:pages
%             for k = 1:dataWindow
%                 iTemp = [cmvSampleNorm(ipage - 1 + k, 7) cmvSampleNorm(ipage - 1 + k, 8) cmvSampleNorm(ipage - 1 + k, 9);
%                          cmvSampleNorm(ipage - 1 + k, 4) cmvSampleNorm(ipage - 1 + k, 5) cmvSampleNorm(ipage - 1 + k, 6);
%                          cmvSampleNorm(ipage - 1 + k, 1) cmvSampleNorm(ipage - 1 + k, 2) cmvSampleNorm(ipage - 1 + k, 3)];

%                 iNormMatV2(:, :, ipage) = iNormMatV2(:, :, ipage) + iTemp;
%             end
%             iNormMatV2(:, :, ipage) = iNormMatV2(:, :, ipage) / dataWindow;
%         end
%         outputArray = iNormMatV2;

%     case 'iAvgNorm'
%         iAvgNormMat = zeros(3, 3, pages);
%         idx = 1;
%         for ipage = 1:dataLength
%             iTemp = [cmvSampleNorm(ipage, 5) cmvSampleNorm(ipage, 4) cmvSampleNorm(ipage, 6);
%                      cmvSampleNorm(ipage, 8) cmvSampleNorm(ipage, 7) cmvSampleNorm(ipage, 9);
%                      cmvSampleNorm(ipage, 2) cmvSampleNorm(ipage, 1) cmvSampleNorm(ipage, 3)];

%             iAvgNormMat(:, :, idx) = iAvgNormMat(:, :, idx) + iTemp;
%             if mod(ipage, dataWindow) == 0
%                 iAvgNormMat(:, :, idx) = iAvgNormMat(:, :, idx) / dataWindow;
%                 idx = idx + 1;
%             end
%         end
%         outputArray = iAvgNormMat;

%     otherwise
%         fprintf('ERROR')
% end

end
