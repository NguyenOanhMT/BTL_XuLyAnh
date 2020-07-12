function isLocalMaximum = Find_Local_Maximum(top,mid,bot,row,col,threshold)
% Tim cuc dai dia Phuong 3x3x3 tren 3 layer top, mid, bot 
% Out: 1 ma tran cot kich thuoc bang kich thuoc det(H) cua mid,
%luu tru gia tri bool de xac dinh co phai cuc dai dia phuong hay khong
% bounds check
    layerBorder = fix((top.filter + 1) / (2 * top.step));
    bound_check_fail=(row <= layerBorder | row >= top.height - layerBorder | col <= layerBorder | col >= top.width - layerBorder);
    normal = top.width;
    % check the candidate point in the middle layer is above thresh 
    candidate = Get_Layer_Response(mid,row,col,normal);% lay tat ca det(H) cua mid
    treshold_fail = candidate < threshold;
    isLocalMaximum =(~bound_check_fail)&(~treshold_fail);
    for rr = -1:1
        for  cc = -1:1
              %  if any response in 3x3x3 is greater then the candidate is not a maximum
              check1=Get_Layer_Response(top,row + rr, col + cc, normal) >= candidate;
              check2=Get_Layer_Response(mid,row + rr, col + cc, normal) >= candidate;
              check3=Get_Layer_Response(bot,row + rr, col + cc, normal) >= candidate;
              check4=(rr ~= 0 || cc ~= 0);
              check_all = ~(check1 | (check4 & check2) | check3);
              isLocalMaximum=isLocalMaximum&check_all;
        end
    end
end

function layerResponse = Get_Layer_Response(layer,row, col,nomalize)
% tra ve 1 mang cac ptu co chi so trong mang index cua det(H)
    scale=fix(layer.width/nomalize);
    % Clamp to boundary 
    index=fix(scale*row) * layer.width + fix(scale*col)+1;
    index(index<1)=1; index(index>length(layer.responses))=length(layer.responses);
    layerResponse = layer.responses(index);
end

