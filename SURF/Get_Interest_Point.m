    function ipts = Get_Interest_Point(iimg)
    % Tim cac diem hap dan tren anh iimg
        % filter index map
        filter_map = [0,1,2,3;
                      1,3,4,5;
                      3,5,6,7;
                      5,7,8,9;
                      7,9,10,11]+1;

        % Set tham so mac dinh
        n_octave = 5; % so octave
        init_sample = 2; % buoc lay mau mac dinh
        threshold = 0.0002;
        np=0; ipts=struct;
        % Build the scale space map
        scaleSpaceMap = Build_Scale_Space(iimg,n_octave,init_sample);
        % Tim cuc dai trong dia phuong scale and space
        for o = 1:n_octave
            for i = 1:2
                bot = scaleSpaceMap{filter_map(o,i)};
                mid = scaleSpaceMap{filter_map(o,i+1)};
                top = scaleSpaceMap{filter_map(o,i+2)};

                % loop over middle response layer at density of the most
                % sparse layer (always top), to find maxima across scale and space
                [col,row]=ndgrid(0:top.width-1,0:top.height-1);
                row=row(:); col=col(:);

                % p = array(index cac diem local maximum)
                p = find(Find_Local_Maximum(top,mid,bot,row,col,threshold));

                % Xac dinh chinh xac diem hap dan bang noi suy lan can
                for j=1:length(p)
                    index=p(j);
                    [ipts,np]=Neighbor_Interpolation(row(index), col(index), top, mid, bot, ipts,np);
                end
            end
        end

    % Show laplacian and response maps with found interest-points
    % Show the response map
    disp('Done build Scale-space');
    fig_h=ceil(length(scaleSpaceMap)/3);
    h=figure;  set(h,'name','Build Scale-space');
    for i=1:length(scaleSpaceMap), 
        pic=reshape(scaleSpaceMap{i}.laplacian,[scaleSpaceMap{i}.width scaleSpaceMap{i}.height]);
        subplot(3,fig_h,i); imshow(pic,[]); hold on;
    end
    disp('Found keypoints after interpolating and thresholding');
    h=figure; set(h,'name','Found keypoints after interpolating and thresholding');
    h_res=zeros(1,length(scaleSpaceMap));
    for i=1:length(scaleSpaceMap), 
        pic=reshape(scaleSpaceMap{i}.responses,[scaleSpaceMap{i}.width scaleSpaceMap{i}.height]);
        h_res(i)=subplot(3,fig_h,i); imshow(pic,[]); hold on;
    end

    % Show the maximum points
    disp(['Number of interest points found ' num2str(np)]);
    scales=zeros(1,length(scaleSpaceMap));
    scaley=zeros(1,length(scaleSpaceMap));
    scalex=zeros(1,length(scaleSpaceMap));
    for i=1:length(scaleSpaceMap)
        scales(i)=scaleSpaceMap{i}.filter*(2/15);
        scalex(i)=scaleSpaceMap{i}.width/size(iimg,2);
        scaley(i)=scaleSpaceMap{i}.height/size(iimg,1);
    end
    for i=1:np
        [t,ind]=min((scales-ipts(i).scale).^2);
        plot(h_res(ind),ipts(i).y*scaley(ind)+1,ipts(i).x*scalex(ind)+1,'o','color',rand(1,3));
    end
    



