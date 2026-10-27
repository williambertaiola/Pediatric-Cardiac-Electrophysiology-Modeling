
function [CaTDxx,t10_90,Acai,dCadt_max,cai_syst,cai_diast]=CaTD(t,cai,xx)
%function [CaTDxx,Acai,tp,rtxx,cai_syst,cai_diast]=CaTD(t,cai,xx)
% Inputs (only 1 AP):
%	t: vector time
%	cai: vector cai
%	xx: % of recovery
% Outputs:    
%	CaTD at different recovery % (xx, eg 90%)
%	t10_90: the 10% to 90% rise time
%	Other parameters: amplitude (Acai), max upstroke (dCadt_max), cai_diast, cai_syst
% Example: [CaTD80,t10_90,Acai,dCadt_max,cai_syst,cai_diast]=CaTD(time,cai,80);
    
[cai_syst, cai_sys_index]=max(cai); 
[cai_diast, cai_diast_index]=min(cai);
Acai=cai_syst-cai_diast;

%Derivative of CaT
dCadt=diff(cai)./diff(t);


[dCadt_max, dCadt_max_index]=max(dCadt);
t_dmax=t(dCadt_max_index);
% figure
% plot(t(1:end-1),dCadt)

%CaTD
cat_xxrec=cai_syst-(xx/100)*Acai;
cat_rec=cai(cai_sys_index:end); %Attention: there is a change of indexes. I fix it here (*)
[dif,catxx_index_cut]=min(abs(cat_rec-cat_xxrec)); 
catxx_index=catxx_index_cut+(cai_sys_index-1); %(*)
t_catxx = interp1(cai(cai_sys_index:end),t(cai_sys_index:end),cat_xxrec);
CaTDxx=t_catxx-t_dmax;

%Rise time: t10%-90% 
cat_10up=cai_diast+(10/100)*Acai;
cat_90up=cai_syst-(10/100)*Acai;
cat_up=cai(1:cai_sys_index);
[dif,cat10_index]=min(abs(cat_up-cat_10up));
[dif,cat90_index]=min(abs(cat_up-cat_90up));
%t10_90=t(cat90_index)-t(cat10_index);%Low accuracy
t_cat10up=interp1(cai(1:cai_sys_index),t(1:cai_sys_index),cat_10up);
t_cat90up=interp1(cai(1:cai_sys_index),t(1:cai_sys_index),cat_90up);
t10_90=t_cat90up-t_cat10up;

%Time to peak (TP)
%tp=t(cai_sys_index)-t_dmax;
tstim=0;
tp=t(cai_sys_index)-tstim; %only valid if stim starts at t=0 ms.

%TP to xx% decay
rtxx=t_catxx-t(cai_sys_index);



[dCadt_min, dCadt_min_index]=min(dCadt);
t_dmin=t(dCadt_min_index);

end