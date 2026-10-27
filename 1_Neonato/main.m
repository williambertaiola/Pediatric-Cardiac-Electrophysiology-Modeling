function biomarkers = main()

global param_name mult

%% INITIAL CONDITIONS (unchanged)
v=-87; nai=7; nass=nai; ki=145; kss=ki;
cai=1e-4; cass=cai; cansr=1.2; cajsr=cansr;
m=0; hf=1; hs=1; j=1; hsp=1; jp=1;
mL=0; hL=1; hLp=1; a=0; iF=1; iS=1;
ap=0; iFp=1; iSp=1; d=0; ff=1; fs=1;
fcaf=1; fcas=1; jca=1; nca=0; ffp=1; fcafp=1;
xrf=0; xrs=0; xs1=0; xs2=0; xk1=1;
Jrelnp=0; Jrelp=0; CaMKt=0;

X0=[v nai nass ki kss cai cass cansr cajsr m hf hs j hsp jp ...
    mL hL hLp a iF iS ap iFp iSp d ff fs fcaf fcas jca nca ...
    ffp fcafp xrf xrs xs1 xs2 xk1 Jrelnp Jrelp CaMKt]';

%% SIMULATION SETTINGS
CL = 500;      % ms
beats = 1000;     % beats to reach steady state

options = [];

for n = 1:beats
    [time, X] = ode15s(@model_ORdmm, [0 CL], X0, options, 1);   % flag_ode = 1
    X0 = X(end,:);
end

%% EXTRACT LAST BEAT
v  = X(:,1);
cai= X(:,6);

% currents for peaks
INa=[]; IKr=[]; IKs=[]; Ito=[]; ICaL=[]; INaL=[];

for i = 1:length(X)
    out = model_ORdmm(time(i), X(i,:), 0);   % flag_ode = 0 → correnti
    INa(i)  = out(1);
    INaL(i) = out(2);
    Ito(i)  = out(3);
    ICaL(i) = out(4);
    IKr(i)  = out(5);
    IKs(i)  = out(6);
end

% ============================================================
% Calcolo dei biomarcatori sull'ultimo battito simulato
% ============================================================

t_ap   = time;
v_ap   = v;
cai_ap = cai;

% APD90 e APD30
[APD90, ~, ~, Vr, ~, ~]  = APD(t_ap, v_ap, 90);
[APD50, ~, ~, ~,  ~, ~]  = APD(t_ap, v_ap, 50);

RMP     = Vr;
Triang  = APD90 - APD50;

% CaTD90
[CaTD90, ~, ~, ~, ~, ~] = CaTD(t_ap, cai_ap, 90);

% Peak currents
INa_peak  = min(INa);
IKr_peak  = max(IKr);
IKs_peak  = max(IKs);
Ito_peak  = max(Ito);
ICaL_peak = min(ICaL);

% OUTPUT STRUCT
biomarkers = struct( ...
    'APD90',    APD90, ...
    'CaTD90',   CaTD90, ...
    'RMP',      RMP, ...
    'Triang',   Triang, ...
    'INa_peak', INa_peak, ...
    'IKr_peak', IKr_peak, ...
    'IKs_peak', IKs_peak, ...
    'Ito_peak', Ito_peak, ...
    'ICaL_peak',ICaL_peak, ...
    'INa',INa, ...
    'INaL',INaL, ...
    'IKr',IKr, ...
    'IKs',IKs, ...
    'Ito',Ito, ...
    'ICaL', ICaL, ...
    'Time',time, ...
    'Cai',cai, ...
    'AP',v);

end