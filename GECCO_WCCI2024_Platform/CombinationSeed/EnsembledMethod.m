%% TEAM: UNAL-KU-SB
% Cooperation of Universidad Nacional de Colombia (UNAL), KHALIFA UNIVERSITY (KU) and SWITCHING BATTERY company
%% TEAM MEMBERS: 
% Marcelo Antonio Escalante Marrugo, mescalante@unal.edu.co, student at UNAL
% Sergio Rivera, srriverar@unal.edu.co, professor at UN
% Ameena Al Sumaiti, ameena.alsumaiti@ku.ac.ae, professor at KU
% Kannappan Chettiar, kc@switchingbattery.com, CEO SWITCHING BATTERY

function [Fit_and_p,FVr_bestmemit, fitMaxVector] = EnsembledMethod(lb,ub,dim,fobj,SearchAgents_no,Max_iteration,N,caseStudyData,otherParameters)

                        % seed from algorithms CHIMP, TAPSO, MPSO, ALO, MFO
                        [ABest_scoreChimp,ABest_posChimp,Chimp_curve]=Chimp(SearchAgents_no,Max_iteration,lb,ub,dim,fobj,caseStudyData,otherParameters);
                        [TACPSO_gBestScore,TACPSO_gBest,TACPSO_cg_curve]=TACPSO(N,Max_iteration,lb,ub,dim,fobj,caseStudyData,otherParameters);
                        [MPSO_gBestScore,MPSO_gBest,MPSO_cg_curve]=MPSO(N,Max_iteration,lb,ub,dim,fobj,caseStudyData,otherParameters);
                        [Best_scoreALO,Best_posALO,cg_curveALO]=ALO(SearchAgents_no,Max_iteration,lb,ub,dim,fobj,caseStudyData,otherParameters);
                        [Best_scoreMFO,Best_posMFO,cg_curveMFO]=MFO(SearchAgents_no,Max_iteration,lb,ub,dim,fobj,caseStudyData,otherParameters);

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
              
                        [Fit_and_p, ...
                         sol, ...
                         fitVector]= ...                    
                         HyDEexplotaition(caseStudyData,otherParameters,lb,ub,sol,fitVector,ABest_posChimp,TACPSO_gBest,MPSO_gBest,Best_posALO,Best_posMFO);
        
                        [Fit_and_p, ...
                         FVr_bestmemit, ...
                         fitMaxVector]= ...
                         HyDE(caseStudyData,otherParameters,lb,ub,ABest_posChimp,TACPSO_gBest,MPSO_gBest,Best_posALO,Best_posMFO,sol,fitVector);

end
