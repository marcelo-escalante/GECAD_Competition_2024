function [Fit_and_p,FVr_bestmemit, fitMaxVector] = ...
    HyDEexplotaition(deParameters,caseStudyData,otherParameters,low_habitat_limit,up_habitat_limit,sol,gen,fitVector)

% Define search space
x_range = low_habitat_limit; % Range for variable x
y_range = up_habitat_limit; % Range for variable y

% Parameters
num_iterations = 1000; % Number of iterations
wave_width_x=10;
wave_width_y=500;

% Initialize variables
% x_best = rand() * (x_range(2) - x_range(1)) + x_range(1); % Random initial x
% y_best = rand() * (y_range(2) - y_range(1)) + y_range(1); % Random initial y
% f_best = fun(x_best, y_best); % Objective function value at initial point

fnc= otherParameters.fnc;

x_best = sol(1); % Random initial x
y_best = sol(2); % Random initial y
[f_best,penalties,~]=feval(fnc,sol,caseStudyData,otherParameters);
%f_best = fitVector(end); % Objective function value at initial point

% Main loop
iter = 1;
%for iter = 1:num_iterations
    % Generate neighboring points
    x_neighbors = x_best - wave_width_x + wave_width_x * rand(1, 20);
    y_neighbors = y_best - wave_width_y + 2 * wave_width_y * rand(1, 100);
    
    % Clip neighbors to search space
    x_neighbors = max(min(x_neighbors, x_range(2)), x_range(1));
    y_neighbors = max(min(y_neighbors, y_range(2)), y_range(1));
    
    % Evaluate objective function at neighbors
    %f_neighbors = fun(x_neighbors, y_neighbors);
    i=1;
        for ia=1:20
            for ib=1:100
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
    
    % Display progress
    fprintf('Iteration %d: Best solution = %.4f, %.4f, f(x, y) = %.4f\n', iter, x_best, y_best, f_best);

fitMaxVector=[fitVector f_best];
Fit_and_p=f_best;
FVr_bestmemit=[x_best y_best];

%end