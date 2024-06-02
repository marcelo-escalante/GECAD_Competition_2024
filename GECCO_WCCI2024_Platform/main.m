%% TEAM: UNAL-KU-SW
% Cooperation of Universidad Nacional de Colombia (UNAL), KHALIFA UNIVERSITY (KU) and SWITCHING BATTERY company
%% TEAM MEMBERS: 
% Marcelo Antonio Escalante Marrugo, mescalante@unal.edu.co, student at UNAL
% Sergio Rivera, srriverar@unal.edu.co, professor at UN
% Ameena Al Sumaiti, ameena.alsumaiti@ku.ac.ae, professor at KU
% Kannappan Chettiar, kc@switchingbattery.com, CEO SWITCHING BATTERY

clc;clear all;close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GECAD GECCO and WCCI 2024 Competition: Evolutionary Computation in the Energy Domain: Optimal PV System Allocation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath('functions') %Necessary functions to run the algorithms (encrypted)
tTotalTime=tic; % lets track total computational time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Select testbed
Select_testbed=1; %Only 1 track in 2024
%Testbed 1: Optimal PV Allocation   
DB=Select_testbed;
% 1: Case study testbed 1

Select_algorithm=2;
%1: DE algorithm (test algorithm)
%2: Your algorithm

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load MH parameters (e.g., get MH parameters from DEparameters.m file)
switch Select_algorithm
     case 1
          addpath('HyDE')
          algorithm='HyDE-alg'; %'The participants should include their algorithm here'
          DEparameters %Function defined by the participant
          No_solutions=deParameters.I_NP; %Notice that some algorithms are limited to one individual
        case 2
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          addpath('CombinationSeed')
          algorithm='CombinationAlg'; %'The participants should include their algorithm here'
          DEparameters %Function defined by the participant
          No_solutions=deParameters.I_NP; %Notice that some algorithms are limited to one individual
          SearchAgents_no=5; % Number of search agents
          N=SearchAgents_no;
          Function_name='F2'; % Name of the test function that can be from F1 to F23 (Table 3,4,5 in the paper)
          Max_iteration=100; % Maximum numbef of iterations
          Max_iter=Max_iteration;
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    otherwise
          fprintf(1,'No algorithm selected\n');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load Data base 
[caseStudyData, DB_name]=callDatabase(DB);
noRuns=10; %this can be changed but final results should be based on 10 trials

%% Label of the algorithm and the case study
Tag.algorithm=algorithm;
Tag.DB=DB_name;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set other parameters
otherParameters =setOtherParameters(caseStudyData,No_solutions, Select_testbed);
%% Set lower/upper bounds of variables 
[lowerB,upperB] = setVariablesBounds(caseStudyData,otherParameters, Select_testbed);
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Call the MH for optimizationclear 
ResDB=struc([]);
for iRuns=1:noRuns %Number of trails
       tOpt=tic;
       rand('state',sum(noRuns*100*clock))% ensure stochastic indpt trials
       otherParameters.iRuns=iRuns;      
        
       switch Select_algorithm
              case 1
                  [ResDB(iRuns).Fit_and_p, ...
                  ResDB(iRuns).sol, ...
                  ResDB(iRuns).fitVector,gen]= ...                    
                  HyDE(deParameters,caseStudyData,otherParameters,lowerB,upperB);  

              case 2     
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Load details of the selected benchmark function
                        [lb,ub,dim,fobj]=Get_Functions_details(Function_name);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        [ResDB(iRuns).Fit_and_p, ...
                         ResDB(iRuns).sol, ...
                         ResDB(iRuns).fitVector]= ...
                         EnsembledMethod(lb,ub,dim,fobj,SearchAgents_no,Max_iteration,N,caseStudyData,otherParameters);   
       end 
            
            ResDB(iRuns).tOpt=toc(tOpt); % time of each trial
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% Save the results and stats
            Save_results
        
end

%% End of MH Optimization (done internally in the fitness evaluation)
for j=1:noRuns
      lower_violations=ResDB(j).sol<lowerB;
      upper_violations=ResDB(j).sol>upperB;
      many_low(j)=sum(lower_violations);
      many_up(j)=sum(upper_violations);
      fprintf('lower_violations : %d .\n', many_low(j));
      fprintf('upper_violations : %d .\n', many_up(j));
end

tTotalTime=toc(tTotalTime); %Total time