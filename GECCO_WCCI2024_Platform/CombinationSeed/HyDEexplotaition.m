%% TEAM: UNAL-KU-SW
% Cooperation of Universidad Nacional de Colombia (UNAL), KHALIFA UNIVERSITY (KU) and SWITCHING BATTERY company
%% TEAM MEMBERS: 
% Marcelo Antonio Escalante Marrugo, mescalante@unal.edu.co, student at UNAL
% Sergio Rivera, srriverar@unal.edu.co, professor at UN
% Ameena Al Sumaiti, ameena.alsumaiti@ku.ac.ae, professor at KU
% Kannappan Chettiar, kc@switchingbattery.com, CEO SWITCHING BATTERY

function [Fit_and_p,FVr_bestmemit,fitVector] = ...
    HyDEexplotaition(caseStudyData,otherParameters,low_habitat_limit,up_habitat_limit,sol,fitVector,ABest_posChimp,TACPSO_gBest,MPSO_gBest,Best_posALO,Best_posMFO)

% Define search space
x_range = [low_habitat_limit(1) up_habitat_limit(1)]; % Range for variable x
y_range = [low_habitat_limit(2) up_habitat_limit(2)]; % Range for variable y

% Parameters
%num_iterations = 1000; % Number of iterations
%tuning
wave_width_x=1;
wave_width_y=15;
number_waves_x=15;% POR 2, +-
number_waves_y=40;% POR 2, +-

% Initialize variables
% x_best = rand() * (x_range(2) - x_range(1)) + x_range(1); % Random initial x
% y_best = rand() * (y_range(2) - y_range(1)) + y_range(1); % Random initial y
% f_best = fun(x_best, y_best); % Objective function value at initial point

fnc= otherParameters.fnc;

x_best = sol(1); % Random initial x
y_best = sol(2); % Random initial y
[f_best,penalties,~]=feval(fnc,sol,caseStudyData,otherParameters);
%f_best = fitVector(end); % Objective function value at initial point
x_best_values=[ABest_posChimp(1) TACPSO_gBest(1) MPSO_gBest(1) Best_posALO(1) Best_posMFO(1)];
y_best_values=[ABest_posChimp(2) TACPSO_gBest(2) MPSO_gBest(2) Best_posALO(2) Best_posMFO(2)];

x_neighbors=min(x_best_values);
y_neighbors=min(y_best_values);
[f_new,penalties,~]=feval(fnc,[x_neighbors y_neighbors],caseStudyData,otherParameters);
if f_new < f_best
        f_best = f_new;
        x_best = x_neighbors;
        y_best = y_neighbors;
end

x_neighbors=max(x_best_values);
y_neighbors=max(y_best_values);
[f_new,penalties,~]=feval(fnc,[x_neighbors y_neighbors],caseStudyData,otherParameters);
if f_new < f_best
        f_best = f_new;
        x_best = x_neighbors;
        y_best = y_neighbors;
end

x_neighbors=max(x_best_values);
y_neighbors=min(y_best_values);
[f_new,penalties,~]=feval(fnc,[x_neighbors y_neighbors],caseStudyData,otherParameters);
if f_new < f_best
        f_best = f_new;
        x_best = x_neighbors;
        y_best = y_neighbors;
end

x_neighbors=min(x_best_values);
y_neighbors=max(y_best_values);
[f_new,penalties,~]=feval(fnc,[x_neighbors y_neighbors],caseStudyData,otherParameters);
if f_new < f_best
        f_best = f_new;
        x_best = x_neighbors;
        y_best = y_neighbors;
end

% x_best=x_neighbors;
% y_best=y_neighbors;

iter=1;
% Main loop
%for iter = 1:num_iterations
    % Generate neighboring points
    %x_neighbors = x_best - wave_width_x + wave_width_x * rand(1, 20);
    wavesX=1;
    for i=1:number_waves_x
        x_neighbors(wavesX)=x_best+(i*wave_width_x);
        wavesX=wavesX+1;
        x_neighbors(wavesX)=x_best-(i*wave_width_x);
        wavesX=wavesX+1;
    end
    %y_neighbors = y_best - wave_width_y + 2 * wave_width_y * rand(1, number_waves_y);
    wavesY=1;
    for i=1:number_waves_y
        y_neighbors(wavesY)=y_best+(i*wave_width_y);
        wavesY=wavesY+1;
        y_neighbors(wavesY)=y_best-(i*wave_width_y);
        wavesY=wavesY+1;
    end

    % Clip neighbors to search space
    x_neighbors = max(min(x_neighbors, x_range(2)), x_range(1));
    y_neighbors = max(min(y_neighbors, y_range(2)), y_range(1));

    % Clip neighbors reemplazar repetidos

    valores_repetidos = unique(x_neighbors(diff(sort(x_neighbors)) == 0));
    if valores_repetidos 
        % Valor repetido que deseas reemplazar
        valor_repetido = valores_repetidos(1);
        % Número fijo con el que deseas reemplazar el valor repetido
        numero_fijo = x_best;
        % Encontrar los índices del valor repetido en el vector
        indices_repetidos = find(x_neighbors == valor_repetido);
        if ~isempty(indices_repetidos)
            x_neighbors(indices_repetidos(1)) = numero_fijo;
        end
    end
    %x_neighbors = reemplazar_repetidos(x_neighbors, x_range(1), x_range(2));
    %y_neighbors = reemplazar_repetidos(y_neighbors, y_range(1), y_range(2));
    
    % Evaluate objective function at neighbors
    %f_neighbors = fun(x_neighbors, y_neighbors);
        i=1;
        for ia=1:2*number_waves_x
            for ib=1:2*number_waves_y
            [f_neighbors(i),penalties,~]=feval(fnc,[x_neighbors(ia) y_neighbors(ib)],caseStudyData,otherParameters);
            f_y(i)=ib;
            f_x(i)=ia;
            i=i+1;
            end
        end
    
        % Update best solution
    [f_new, idx] = min(f_neighbors);
    f_new
    idx
    if f_new < f_best
        f_best = f_new;
        x_best = x_neighbors(f_x(idx));
        y_best = y_neighbors(f_y(idx));
    end
    
fitVector=[fitVector f_best];
Fit_and_p=f_best;
FVr_bestmemit=[x_best y_best];


    % Display progress
    fprintf('Iteration %d: Best solution = %.4f, %.4f, f(x, y) = %.4f\n', iter, x_best, y_best, f_best);
%end