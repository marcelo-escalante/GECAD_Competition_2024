clear all 
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath('functions') %Necessary functions to run the algorithms (encrypted)
tTotalTime=tic; % lets track total computational time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Select testbed
Select_testbed=1; %Only 1 track in 2024
%Testbed 1: Optimal PV Allocation   
DB=Select_testbed;
% 1: Case study testbed 1

SearchAgents_no=5; % Number of search agents
N=SearchAgents_no;
Function_name='F2'; % Name of the test function that can be from F1 to F23 (Table 3,4,5 in the paper)

Max_iteration=100; % Maximum numbef of iterations
Max_iter=Max_iteration;

global caseStudyData
global otherParameters
global fnc


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load Data base 
[caseStudyData, DB_name]=callDatabase(DB);
noRuns=1; %this can be changed but final results should be based on 10 trials

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set other parameters
No_solutions=SearchAgents_no;
otherParameters =setOtherParameters(caseStudyData,No_solutions, Select_testbed);
%% Set lower/upper bounds of variables 
[lowerB,upperB] = setVariablesBounds(caseStudyData,otherParameters, Select_testbed);
fnc= otherParameters.fnc;

% Load details of the selected benchmark function
[lb,ub,dim,fobj]=Get_Functions_details(Function_name);

[ABest_scoreChimp,ABest_posChimp,Chimp_curve]=Chimp(SearchAgents_no,Max_iteration,lb,ub,dim,fobj);
[TACPSO_gBestScore,TACPSO_gBest,TACPSO_cg_curve]=TACPSO(N,Max_iteration,lb,ub,dim,fobj);
[MPSO_gBestScore,MPSO_gBest,MPSO_cg_curve]=MPSO(N,Max_iteration,lb,ub,dim,fobj);
[Best_scoreALO,Best_posALO,cg_curveALO]=ALO(SearchAgents_no,Max_iteration,lb,ub,dim,fobj);
[Best_scoreMFO,Best_posMFO,cg_curveMFO]=MFO(SearchAgents_no,Max_iteration,lb,ub,dim,fobj);


best=ABest_scoreChimp;
fitVector=Chimp_curve;
sol=ABest_posChimp;
if TACPSO_gBestScore<best
best=TACPSO_gBestScore;
fitVector=TACPSO_cg_curve;
sol=TACPSO_gBest;
end
if MPSO_gBestScore<best
best=MPSO_gBestScore;
fitVector=MPSO_cg_curve;
sol=MPSO_gBest;
end
if Best_scoreALO<best
best=Best_scoreALO;
fitVector=cg_curveALO;
sol=Best_posALO;
end
if Best_scoreMFO<best
best=Best_scoreMFO;
fitVector=cg_curveMFO;
sol=Best_posMFO;
end

% figure('Position',[500 500 660 290])
% semilogy(MPSO_cg_curve,'Color','g')
% hold on
% semilogy(TACPSO_cg_curve,'Color','y')
% hold on
% semilogy(Chimp_curve,'--r')
% hold on
% semilogy(cg_curveALO,'--c')
% hold on
% semilogy(cg_curveMFO,'--k')
% 
% title('Objective space')
% xlabel('Iteration');
% ylabel('Best score obtained so far');
% 
% axis tight
% grid on
% box on
% legend('MPSO','TACPSO','Chimp','ALO','MFO')

display(['The best optimal value of the objective funciton found by TACPSO is : ', num2str(TACPSO_gBestScore)]);
display(['The best decision variables with TACPSO are : ', num2str(TACPSO_gBest)]);

display(['The best optimal value of the objective funciton found by MPSO is : ', num2str(MPSO_gBestScore)]);
display(['The best decision variable with MPSO are : ', num2str(MPSO_gBest)]);

display(['The best optimal value of the objective funciton found by Chimp is : ', num2str(ABest_scoreChimp)]);
display(['The best decision variable with Chimp are : ', num2str(ABest_posChimp)]);

display(['The best optimal value of the objective funciton found by ALO is : ', num2str(Best_scoreALO)]);
display(['The best odecision variable with ALO are : ', num2str(Best_posALO)]);

display(['The best optimal value of the objective funciton found by MFO is : ', num2str(Best_scoreMFO)]);
display(['The best odecision variable with MFO are : ', num2str(Best_posMFO)]);


fnc= otherParameters.fnc;

                  [Fit_and_p, ...
                  sol, ...
                  fitVector]= ...                    
                  HyDEexplotaition(caseStudyData,otherParameters,lowerB,upperB,sol,fitVector);

                  [Fit_and_p, ...
                  sol, ...
                  fitVector]= ...
                  HyDE(caseStudyData,otherParameters,lowerB,upperB,ABest_posChimp,TACPSO_gBest,MPSO_gBest,Best_posALO,Best_posMFO,sol,fnc);

Fit_and_p
sol