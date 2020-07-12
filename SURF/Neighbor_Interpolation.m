function [ipts, np] = Neighbor_Interpolation(r, c, t, m, b, ipts,np)
% input:
%   r = row
%   c = col
%   t = top layer
%   m = mid layer
%   b = bot layer

    D = FastHessian_BuildDerivative(r, c, t, m, b);
    H = FastHessian_BuildHessian(r, c, t, m, b);

    %get the offsets from the interpolation: tinh phan bu
    Of = - H\D;
    O=[ Of(1, 1), Of(2, 1), Of(3, 1) ];

    %get the step distance between filters
    filterStep = fix((m.filter - b.filter));

    %If point is sufficiently close to the actual extremum: phan bu phai
    %nho hon 0.5
    if (abs(O(1)) < 0.5 && abs(O(2)) < 0.5 && abs(O(3)) < 0.5)
        np=np+1;
        ipts(np).x = double(((c + O(1))) * t.step);
        ipts(np).y = double(((r + O(2))) * t.step);
        ipts(np).scale = double(((2/15) * (m.filter + O(3) * filterStep)));
        ipts(np).laplacian = fix(Get_Laplacian(m,r,c,t));
    end

end

function D=FastHessian_BuildDerivative(r,c,t,m,b)
    dx = (Get_Response(m,r, c + 1, t) - Get_Response(m,r, c - 1, t)) / 2;
    dy = (Get_Response(m,r + 1, c, t) - Get_Response(m,r - 1, c, t)) / 2;
    ds = (Get_Response(t,r, c) - Get_Response(b,r, c, t)) / 2;
    D = [dx;dy;ds];
end

function H=FastHessian_BuildHessian(r, c, t, m, b)
    v = Get_Response(m, r, c, t);
    dxx = Get_Response(m,r, c + 1, t) + Get_Response(m,r, c - 1, t) - 2 * v;
    dyy = Get_Response(m,r + 1, c, t) + Get_Response(m,r - 1, c, t) - 2 * v;
    dss = Get_Response(t,r, c) + Get_Response(b,r, c, t) - 2 * v;
    dxy = (Get_Response(m,r + 1, c + 1, t) - Get_Response(m,r + 1, c - 1, t) - Get_Response(m,r - 1, c + 1, t) + Get_Response(m,r - 1, c - 1, t)) / 4;
    dxs = (Get_Response(t,r, c + 1) - Get_Response(t,r, c - 1) - Get_Response(b,r, c + 1, t) + Get_Response(b,r, c - 1, t)) / 4;
    dys = (Get_Response(t,r + 1, c) - Get_Response(t,r - 1, c) - Get_Response(b,r + 1, c, t) + Get_Response(b,r - 1, c, t)) / 4;

    H = zeros(3,3);
    H(1, 1) = dxx;
    H(1, 2) = dxy;
    H(1, 3) = dxs;
    H(2, 1) = dxy;
    H(2, 2) = dyy;
    H(2, 3) = dys;
    H(3, 1) = dxs;
    H(3, 2) = dys;
    H(3, 3) = dss;
end

function response = Get_Response(a,row, column,b)
    if(nargin<4)
        scale=1;
    else
        scale=fix(a.width/b.width);
    end

    response=a.responses(fix(scale*row) * a.width + fix(scale*column)+1);
end

function laplacian = Get_Laplacian(a,row, column,b)
    if(nargin<4)
        scale=1;
    else
        scale=fix(a.width/b.width);
    end
    laplacian=a.laplacian(fix(scale*row) * a.width + fix(scale*column)+1);
end

