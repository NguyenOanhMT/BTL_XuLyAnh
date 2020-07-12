function ipts = Descriptor_Interesting_Points(ipts, img)
% Them orientation va descriptor vao cau truc ipts
% Input:
%   ipts: danh sach cac diem hap dan tim duoc
%   img: anh dau vao(integral image)
% Output:
%   ipts[]: danh sach cac diem hap dan da co du thong tin orientation, descriptor
    if (isempty(fields(ipts))), return; end
    
    % ve goc va 
%     if(1), h_ang=figure; drawnow, set(h_ang,'name','Angles'); else h_ang=[]; end
%     if(1), h_des=figure; drawnow, set(h_des,'name','Aligned Descriptor XY'); end

    for i=1:length(ipts)
       
       ip=ipts(i);
       % descriptor size
       ip.descriptorLength = 64;
       
       % chi hien thi 40 diem hap dan dau tien
       % tinh orientation
       %if(i <= 40), figure(h_ang), subplot(5,8,i), end
       ip.orientation=Get_Orientation(ip,img);

       % dien thong tin cho SURF descriptor
       %if(i <= 40), figure(h_des), subplot(10,4,i), end
       ip.descriptor=Get_Descriptor(ip, img);

       ipts(i).orientation=ip.orientation;
       ipts(i).descriptor=ip.descriptor;
    end

    %if(~isempty(h_ang)), figure(h_ang), colormap(jet); 
    %end
end

