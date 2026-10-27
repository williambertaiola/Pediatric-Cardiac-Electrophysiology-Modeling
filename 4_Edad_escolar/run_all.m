%% RUN ALL — 60 SIMULATIONS FOR NEONATE

clear; close all; clc;

global param_name mult

% 12 PARAMETERS TO VARY
param_list = {'PCa','GpCa','GK1','Jrel','GKr','GKs','GNa','Gncx','Pnak','GNaL','Gto','Gserca'};

% MULTIPLIERS: baseline, +15%, -15%, +30%, -30%
mult_list = [1.00, 1.15, 0.85, 1.30, 0.70];

results   = {};   % cell array per le righe
sim_count = 0;

n_param = numel(param_list);
n_mult  = numel(mult_list);
n_total = n_param * n_mult;

for p = 1:n_param
    param_name = param_list{p};

    for k = 1:n_mult
        mult = mult_list(k);

        sim_count = sim_count + 1;

        fprintf('Running simulation %2d of %2d — %s × %.2f\n', ...
            sim_count, n_total, param_name, mult);

        try
            % Esegue la simulazione e restituisce la struct con i biomarcatori
            biomarkers = main();

            % Aggiunge una riga alla lista dei risultati
            results(end+1,:) = { ...
                param_name, mult, ...
                biomarkers.APD90,  ...
                biomarkers.CaTD90, ...
                biomarkers.RMP,    ...
                biomarkers.Triang, ...
                biomarkers.INa_peak, ...
                biomarkers.IKr_peak, ...
                biomarkers.IKs_peak, ...
                biomarkers.Ito_peak, ...
                biomarkers.ICaL_peak };

        catch ME
            warning('Simulation %d FAILED for %s × %.2f: %s', ...
                sim_count, param_name, mult, ME.message);

            % In caso di errore, salviamo NaN per tenere la riga allineata
            results(end+1,:) = { ...
                param_name, mult, ...
                NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN };
        end
    end
end

% CREA LA TABELLA
T = cell2table(results, ...
    'VariableNames', { ...
    'Parameter','Multiplier', ...
    'APD90','CaTD90','RMP','Triang', ...
    'INa_peak','IKr_peak','IKs_peak','Ito_peak','ICaL_peak'});

% SALVA IN EXCEL
% se vuoi sovrascrivere il file vecchio, metti lo stesso nome
outFile = 'Edad_escolar_simulations_recalc.xlsx';
writetable(T, outFile);

fprintf('\n=== ALL %d SIMULATIONS COMPLETED ===\nSaved in %s\n', sim_count, outFile);