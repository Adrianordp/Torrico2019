reseta
s = tf('s');

% Example 1 ---------------------------------------------------------------
Tsim = 60;

Ts = 0.1;
z = tf('z',Ts);
P1s = (-s+1)/(2*s+1)/(3*s+1)*exp(-s);
step(P1s,Tsim)

P1z = c2d(P1s,Ts);
d = P1z.InputDelay;

[A,B,C,D]  = tf2ss(P1z.num{1},P1z.den{1});
A = A';
buff = B';
B = C';
C = buff;

beta = [0.92 0.92];

alphaf = 0;
betaf = 0.89;
beta1 = 0.9;
beta2 = 0.9;
beta3 = 0.74;
delta = 0.00000000001;
p  = round(roots(P1z.den{1})*1e8)/1e8;
nz = 2;

K = acker(A,B,beta)
Kr = inv(C/(eye(size(A))+B*K-A)*B);
F = Kr*(1-betaf)^2*z^2/(z-betaf)^2*(1-alphaf*z^-1)^nz/(1-alphaf)^nz;

syms v0 v1 v2
vv  = [v0 v1 v2]';

Z   = 1;
V1  = (v0 + v1*Z^-1 + v2*Z^-2)/(1-beta1*Z^-1)/(1-beta2*Z^-1)/(1-beta3*Z^-1);
S1  = 1 + (K - Z^-d*V1 *C)*((eye(size(A))*Z - A)\B);

Z   = p(1);
Vp1 = (v0 + v1*Z^-1 + v2*Z^-2)/(1-beta1*Z^-1)/(1-beta2*Z^-1)/(1-beta3*Z^-1);
Sp1 = 1 + (K - Z^-d*Vp1*C)*((eye(size(A))*Z - A)\B);

Z   = p(2);
Vp2 = (v0 + v1*Z^-1 + v2*Z^-2)/(1-beta1*Z^-1)/(1-beta2*Z^-1)/(1-beta3*Z^-1);
Sp2 = 1 + (K - Z^-d*Vp2*C)*((eye(size(A))*Z - A)\B);

V = solve(S1==0,Sp1==0,Sp2==0,v0,v1,v2);
v0 = eval(V.v0);
v1 = eval(V.v1);
v2 = eval(V.v2);
V = (v0*z^3 + v1*z^2 + v2*z)/(z-beta1)/(z-beta2)/(z-beta3);
sim('Torrico2019Simu')