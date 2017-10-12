% first, import images
% im(:,:,:,1)=imread('1.jpg');
% for i=2:22
%     im(:,:,:,i)=imread(sprintf('%i.jpg',i));
% end

% define a crop region of interest:
rows=1077:1763; columns=890:2386;
% matrix should be WxHx3xnum, num is number of images
superim=im2double(imresize(im(rows,columns,:,1),3));
added=1;
imwrite(superim(:,1200:2000,:)/added,sprintf('align-super%i.png',added));
filename='originals.gif';
sfilename='superimages.gif';
for i=2:size(im,4)
    % now, calibration
    try 
        [tform,outputView]=imgeometric_matrixout(im(rows,columns,:,1),im(rows,columns,:,i));
        added=added+1
        temp=im2double(imresize(im(rows,columns,:,i),3));
%         tform.T(1,1)=tform.T(1,1)*3;
% tform.T(1,2)=tform.T(1,2)*3;
% tform.T(2,1)=tform.T(2,1)*3;
% tform.T(2,2)=tform.T(2,2)*3;
tform.T(3,1)=tform.T(3,1)*3;
tform.T(3,2)=tform.T(3,2)*3;
        superim=(superim)+imwarp(temp,tform,'OutputView',outputView);
%         imwrite(im(1213:1814,1210:1752,:,i),sprintf('redo-im-zoom%i.png',i));
        imwrite(superim(:,1200:2000,:)/added,sprintf('align-super%i.png',added));
    catch ME
        
    end
end
