function r=pbRandAtoB(a,b,rows,cols)
%
%   function r=pbRandAtoB(a,b,rows,cols)
%
%   Returns uniform random numbers on the interval a to b
%

    r = a + (b-a).*rand(rows,cols);

return
