rclc
clear all
close all
%% === PARAMETRI DA CAMBIARE SOLO QUI ===
ageNames  = {'Neonato','Lactante','Nino_preescolar','Edad_escolar','Adolescente'};  % nomi delle età
fileNames = {'Neonato_1Hz.xlsx','Lactante_1Hz.xlsx','Nino_preescolar_1Hz.xlsx','Edad_escolar_1Hz.xlsx','Adolescente_1Hz.xlsx'}; % stessi ordine

%% === IMPORT ===
data = struct();      % per accedere con data.Neonate, data.Infant, ecc.
T_all = table();      % tabella unica con tutte le età

for i = 1:numel(ageNames)
    age  = ageNames{i};
    file = fileNames{i};

    T = readtable(file, 'Sheet', 1);   % se serve cambia Sheet

    % aggiungo colonna Age
    T.Age = repmat(string(age), height(T), 1);

    % salvo nella struttura
    data.(age) = T;

    % concateno nella tabella globale
    T_all = [T_all; T];
end

T_all.Age = categorical(T_all.Age);
T_all.Parameter = categorical(T_all.Parameter);

disp(T_all(1:5,:));


%% === LISTA BIOMARCATORI (automatico) ===
biomNames = T_all.Properties.VariableNames;
biomNames = biomNames(~ismember(biomNames, {'Parameter','Multiplier','Age'}));

% Copia tabella dove aggiungiamo colonne Delta_* e Z_*
T_met = T_all;

% Preallocazione colonne Δ% e Z
for b = 1:numel(biomNames)
    T_met.(['Delta_' biomNames{b}]) = NaN(height(T_met),1);
    T_met.(['Z_'     biomNames{b}]) = NaN(height(T_met),1);
end

%% === Calcolo Δ% per ogni riga rispetto al baseline (Multiplier==1, stessa Age & Parameter) ===
for i = 1:height(T_met)
    age_i   = T_met.Age(i);
    param_i = T_met.Parameter(i);
    mult_i  = T_met.Multiplier(i);

    % riga(i) con multiplier = 1 (baseline) stessa età & parametro
    idxBase = (T_met.Age==age_i) & (T_met.Parameter==param_i) & (T_met.Multiplier==1);

    if ~any(idxBase)
        continue;  % se non esiste baseline, salto
    end

    for b = 1:numel(biomNames)
        biom = biomNames{b};

        baseVal = T_met.(biom)(idxBase);
        thisVal = T_met.(biom)(i);

        if mult_i == 1
            delta = 0;  % baseline → Δ% = 0
        else
            delta = 100 * (thisVal - baseVal) / baseVal;
        end

        T_met.(['Delta_' biom])(i) = delta;
    end
end

%% === Calcolo z-score per età (mu, sigma presi dai baseline Multiplier = 1) ===
idxBase = (T_met.Multiplier == 1);
ages = categories(T_met.Age);

% strutture con mu(age).(biom) e sigma(age).(biom)
mu    = struct();
sigma = struct();

for a = 1:numel(ages)
    age = ages{a};
    idxAgeBase = idxBase & (T_met.Age == age);

    for b = 1:numel(biomNames)
        biom = biomNames{b};
        vals = T_met.(biom)(idxAgeBase);

        mu.(age).(biom)    = mean(vals,'omitnan');
        sigma.(age).(biom) = std(vals,'omitnan');
    end
end

% assegnazione z-score a ogni riga
for i = 1:height(T_met)
    age_i = char(T_met.Age(i));

    for b = 1:numel(biomNames)
        biom = biomNames{b};
        m  = mu.(age_i).(biom);
        sd = sigma.(age_i).(biom);

        if sd == 0 || isnan(sd)
            z = NaN;
        else
            z = (T_met.(biom)(i) - m) / sd;
        end

        T_met.(['Z_' biom])(i) = z;
    end
end
%% === Sensitivity plot ===
ageSel  = 'Neonato';   % cambia età
biomSel = 'APD90';     % cambia biomarcatore

T_age = T_met(T_met.Age == ageSel, :);

params = categories(T_age.Parameter);

figure; hold on;
for p = 1:numel(params)
    idxP = (T_age.Parameter == params{p});
    mult = T_age.Multiplier(idxP);
    dval = T_age.(['Delta_' biomSel])(idxP);

    % ---> ORDINA I PUNTI PER MULTIPLIER <---
    [mult_sorted, ord] = sort(mult);     % ord è l'indice di riordinamento
    dval_sorted = dval(ord);             % riordino anche i valori

    plot(mult_sorted, dval_sorted, '-o', 'DisplayName', params{p});
end

xlabel('Multiplier');
ylabel(['\Delta% ' biomSel]);
title([ageSel ' - Sensitivity (' biomSel ')']);
legend('Location','best');
grid on;
hold off;

%% === Boxplot biomarcatore per parametro (una età) ===
ageSel  = 'Neonato';
biomSel = 'APD90';

T_age = T_met(T_met.Age == ageSel, :);

figure;
boxplot(T_age.(biomSel), T_age.Parameter);
ylabel(biomSel);
title([ageSel ' - ' biomSel ' per parametro']);
grid on;

%% === HEATMAP SENSITIVITY TIPO TRENOR (basata su Δ%) ===
ageSel   = 'Neonato';          % scegli età
keyBioms = {'APD90','Triang','CaTD90','ICaL_peak'};  % se vuoi, usa i tuoi

T_age = T_met(T_met.Age == ageSel & T_met.Multiplier ~= 1, :);

params = categories(T_age.Parameter);
nP = numel(params);
nB = numel(keyBioms);

% Matrice: righe = parametri, colonne = biomarcatori chiave
S_delta = zeros(nP, nB);

for p = 1:nP
    idxP = (T_age.Parameter == params{p});
    for b = 1:nB
        biom    = keyBioms{b};
        dcol    = ['Delta_' biom];
        vals    = abs(T_age.(dcol)(idxP));     % |Δ%|
        S_delta(p,b) = max(vals, [], 'omitnan');  % massimo effetto di quel parametro su quel biom
    end
end

% --- Normalizzazione per biomarcatore (colonna) → 0–1 ---
RelSens = S_delta ./ max(S_delta, [], 1);   % relative sensitivity

figure;
imagesc(RelSens, [0 1]);   % scala fissa 0–1
colorbar;
colormap parula;

set(gca,'XTick',1:nB,'XTickLabel',keyBioms,'XTickLabelRotation',45);
set(gca,'YTick',1:nP,'YTickLabel',params);

xlabel('Biomarker');
ylabel('Parameter');
title(['Relative sensitivity (max|\Delta%| normalizzato) - ' ageSel]);

% % (Opzionale) scrivi le percentuali sulle celle più "forti"
% hold on;
% for p = 1:nP
%     for b = 1:nB
%         val = RelSens(p,b);
%         if val > 0.3   % soglia per non scrivere ovunque
%             text(b, p, sprintf('%.0f%%', 100*val), ...
%                 'HorizontalAlignment','center', ...
%                 'Color','w', 'FontSize',8, 'FontWeight','bold');
%         end
%     end
% end
hold off;


%% === 1. IMPOSTA BIOMARCATORI CHIAVE E SOGLIE ===
keyBioms = {'APD90','Triang','CaTD90','ICaL_peak'};

% soglia variazione percentuale (in modulo)
th_delta = struct();
th_delta.APD90     = 20;
th_delta.Triang    = 20;
th_delta.CaTD90    = 20;
th_delta.ICaL_peak = 15;

% soglia z-score (in modulo)
th_z = struct();
th_z.APD90     = 2;
th_z.Triang    = 2;
th_z.CaTD90    = 2;
th_z.ICaL_peak = 2;

%% === 2. CREA COLONNE FLAG DI RISCHIO PER OGNI BIOM ===
for b = 1:numel(keyBioms)
    biom = keyBioms{b};
    colDelta = ['Delta_' biom];
    colZ     = ['Z_'     biom];
    colRisk  = ['Risk_'  biom];

    d = abs(T_met.(colDelta));
    z = abs(T_met.(colZ));

    T_met.(colRisk) = (d >= th_delta.(biom)) & (z >= th_z.(biom));
end

%% === 3. FLAG DI RISCHIO GLOBALE (se uno qualsiasi è a rischio) ===
isRiskGlobal = false(height(T_met),1);
for b = 1:numel(keyBioms)
    colRisk = ['Risk_' keyBioms{b}];
    isRiskGlobal = isRiskGlobal | T_met.(colRisk);
end
T_met.Risk_Global = isRiskGlobal;


%% === SCATTER: Δ% APD90 vs Multiplier, con punti a rischio in rosso ===
ageSel   = 'Neonato';    % cambia età
paramSel = 'PCa';        % cambia parametro
biomSel  = 'APD90';      % cambia biomarcatore

colDelta = ['Delta_' biomSel];
colRisk  = ['Risk_'  biomSel];

idx = (T_met.Age == ageSel) & (T_met.Parameter == paramSel);

mult = T_met.Multiplier(idx);
dval = T_met.(colDelta)(idx);
risk = T_met.(colRisk)(idx);

figure; hold on;
scatter(mult(~risk), dval(~risk), 60, 'filled');           % non rischiosi
scatter(mult(risk),  dval(risk),  80, 'filled', 'r');      % rischiosi
yline(0,'k--');

xlabel('Multiplier');
ylabel(['\Delta% ' biomSel]);
title([ageSel ' - ' char(paramSel) ' (' biomSel ')']);
legend({'Safe','Risk'},'Location','best');
grid on; hold off;


%% === BARPLOT: FRAZIONE DI RIGHE A RISCHIO PER PARAMETRO (GLOBAL RISK) ===
ageSel = 'Neonato';

T_age = T_met(T_met.Age == ageSel, :);
params = categories(T_age.Parameter);
nP = numel(params);

fracRisk = zeros(nP,1);

for p = 1:nP
    idxP = (T_age.Parameter == params{p});
    nTot = sum(idxP);
    nR   = sum(T_age.Risk_Global(idxP));
    fracRisk(p) = nR / nTot;
end

figure;
bar(fracRisk);
set(gca,'XTick',1:nP,'XTickLabel',params,'XTickLabelRotation',45);
ylabel('Frazione condizioni a rischio');
ylim([0 1]);
title(['Rischio globale per parametro - ' ageSel]);
grid on;


%% === HEATMAP: |Z| MAX PER PARAMETRO / BIOMARCATORI CHIAVE ===
ageSel = 'Neonato';

T_age = T_met(T_met.Age == ageSel & T_met.Multiplier ~= 1, :);
params = categories(T_age.Parameter);
nP = numel(params);
nB = numel(keyBioms);

Zmax_key = zeros(nP, nB);

for p = 1:nP
    idxP = (T_age.Parameter == params{p});
    for b = 1:nB
        biom = keyBioms{b};
        zcol = ['Z_' biom];
        Zmax_key(p,b) = max(abs(T_age.(zcol)(idxP)), [], 'omitnan');
    end
end

figure;
imagesc(Zmax_key);
colorbar;
colormap parula;

set(gca,'XTick',1:nB,'XTickLabel',keyBioms,'XTickLabelRotation',45);
set(gca,'YTick',1:nP,'YTickLabel',params);

xlabel('Biomarker');
ylabel('Parameter');
title(['|Z|_{max} biomarcatori chiave - ' ageSel]);