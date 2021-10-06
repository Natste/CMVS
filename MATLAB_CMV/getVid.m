function getVid(inputStruct,filename)
%% Turn images in struct into an avi file
v = VideoWriter(filename);
open(v);

for k = 1:length(inputStruct)
   frame = inputStruct(:,k);
   writeVideo(v,frame);
end

close(v);
end
