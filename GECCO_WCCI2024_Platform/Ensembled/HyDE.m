
function [Fit_and_p,FVr_bestmemit, fitMaxVector,gen] = ...
    HyDE(deParameters,caseStudyData,otherParameters,low_habitat_limit,up_habitat_limit)

%-----This is just for notational convenience and to keep the code uncluttered.--------
I_NP         = deParameters.I_NP;
F_weight     = deParameters.F_weight;
F_CR         = deParameters.F_CR;
I_D          = numel(up_habitat_limit); %Number of variables or dimension
deParameters.nVariables=I_D;
FVr_minbound = low_habitat_limit;
FVr_maxbound = up_habitat_limit;
I_itermax    = deParameters.I_itermax;

%Repair boundary method employed
BRM=deParameters.I_bnd_constr; %1: bring the value to bound violated
                               %2: repair in the allowed range

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
I_strategy   = deParameters.I_strategy; %important variable
fnc= otherParameters.fnc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----Check input variables---------------------------------------------
if (I_NP < 5)
   I_NP=5;
   fprintf(1,' I_NP increased to minimal value 5\n');
end
if ((F_CR < 0) || (F_CR > 1))
   F_CR=0.5;
   fprintf(1,'F_CR should be from interval [0,1]; set to default value 0.5\n');
end
if (I_itermax <= 0)
   I_itermax = 500;
   fprintf(1,'I_itermax should be > 0; set to default value 500\n');
end

%-----Initialize population and some arrays-------------------------------
%FM_pop = zeros(I_NP,I_D); %initialize FM_pop to gain speed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pre-allocation of loop variables
fitMaxVector = zeros(1,I_itermax);
% whos fitMaxVector
% fitMaxVector = nan(1,I_itermax);
% whos fitMaxVector
% limit iterations by threshold
gen = 1; %iterations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----FM_pop is a matrix of size I_NPx(I_D+1). It will be initialized------
%----with random values between the min and max values of the-------------
%----parameters-----------------------------------------------------------
% FLC modification - vectorization
minPositionsMatrix=repmat(FVr_minbound,I_NP,1);
maxPositionsMatrix=repmat(FVr_maxbound,I_NP,1);
deParameters.minPositionsMatrix=minPositionsMatrix;
deParameters.maxPositionsMatrix=maxPositionsMatrix;

% generate initial population.
rand('state',otherParameters.iRuns) %Guarantee same initial population
FM_pop=genpop(I_NP,I_D,minPositionsMatrix,maxPositionsMatrix);
%if nargin>5
%     noInitialSolutions = size(initialSolution,1);
%     FM_pop(1:noInitialSolutions,:)=initialSolution;
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%------Evaluate the best member after initialization----------------------
% Modified by FLC
[S_val,penalties,~]=feval(fnc,FM_pop,caseStudyData,otherParameters);
S_val=penalties;
[~,I_best_index] = min(S_val); % This mean that the best individual correspond to the best worst performance
FVr_bestmemit = FM_pop(I_best_index,:); % best member of current iteration
Fvr_bestPen = penalties(I_best_index);
fitMaxVector(1,gen) = S_val(I_best_index);
% The user can decide to save the mean, best, or any other value here

%------DE-Minimization---------------------------------------------
%------FM_popold is the population which has to compete. It is--------
%------static through one iteration. FM_pop is the newly--------------
%------emerging population.----------------------------------------
FVr_rot  = (0:1:I_NP-1);               % rotating index array (size I_NP)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%HYDE
if deParameters.I_strategy==3
        F_weight_old=repmat(F_weight,I_NP,3);
        F_weight= F_weight_old;
        F_CR_old=repmat(F_CR,I_NP,1);
        F_CR=F_CR_old;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
I_strategyVersion=deParameters.I_strategyVersion;

while gen<299  %%&&  fitIterationGap >= threshold
    %a = itr / MaxItr; % a value for gammaincinv function
    other.a=(I_itermax-gen)/I_itermax;
    other.lowerlimit=FVr_minbound; %lower limit of the problem
    other.upperlimit = FVr_maxbound; %upper limit of the problem
    
     if deParameters.I_strategy==3
                value_R=rand(I_NP,3);
                ind1=value_R<0.1;
                ind2=rand(I_NP,1)<0.1;
                F_weight(ind1)=0.1+rand(sum(sum(ind1)),1)*0.9;
                F_weight(~ind1)=F_weight_old(~ind1);
                F_CR(ind2)=rand(sum(ind2),1);
                F_CR(~ind2)=F_CR_old(~ind2);
     end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [FM_ui,FM_base,~]=generate_trial(I_strategy,F_weight, F_CR, FM_pop, FVr_bestmemit,I_NP, I_D, FVr_rot,I_strategyVersion,other);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 

    %% Boundary Control
    FM_ui=update(FM_ui,minPositionsMatrix,maxPositionsMatrix,BRM,FM_base);

    %Evaluation of new Pop
    [S_val_temp,penalties_temp,~]=feval(fnc,FM_ui,caseStudyData,otherParameters);
    S_val_temp=penalties_temp;
    %% Elitist Selection
    ind=find(S_val_temp<S_val);
    S_val(ind)=S_val_temp(ind);
    penalties(ind)=penalties_temp(ind);
    FM_pop(ind,:)=FM_ui(ind,:);
  
  
    %% update best results
    [S_bestval,I_best_index] = min(S_val);
    FVr_bestmemit = FM_pop(I_best_index,:); % best member of current iteration
    Fvr_bestPen = penalties(I_best_index);
    % store fitness evolution and obj fun evolution as well
    fitMaxVector(1,gen) = S_bestval;
    %S_bestval
    
     if deParameters.I_strategy==3 %jDE
        F_weight_old(ind,:)=F_weight(ind,:);
        F_CR_old(ind)=F_CR(ind);
     end
    
    if ismember(I_best_index,ind)
        fitMaxVector(:,gen)= S_val(I_best_index);
    elseif gen>1
        fitMaxVector(:,gen)=fitMaxVector(:,gen-1);
    end
    
    fprintf('Fitness value: %f\n',fitMaxVector(1,gen))
    fprintf('Generation: %d\n',gen)
    fprintf('pos Optima: %f\n',FVr_bestmemit)
    
    if S_bestval<1e-6
        break
    end

    gen=gen+1;
    %% store fitness evolution and obj fun evolution as well
    fitMaxVector(1,gen)=S_bestval;
    %S_bestval

end %---end while ((I_iter < I_itermax) ...
%p1=sum(Best_otherInfo.penSlackBusFinal);
FVr_bestmemit
Fvr_bestPen
Fit_and_p=[fitMaxVector(1,gen) Fvr_bestPen]; %;p2;p3;p4]


 
% VECTORIZED THE CODE INSTEAD OF USING FOR
function pop=genpop(a,b,lowMatrix,upMatrix)
pop=unifrnd(lowMatrix,upMatrix,a,b);

% VECTORIZED THE CODE INSTEAD OF USING FOR
function p=update(p,lowMatrix,upMatrix,BRM,FM_base)
switch BRM
    case 1 %Our method
        %[popsize,dim]=size(p);
        [idx] = find(p<lowMatrix);
        p(idx)=lowMatrix(idx);
        [idx] = find(p>upMatrix);
        p(idx)=upMatrix(idx);
    case 2 %Random reinitialization
        [idx] = [find(p<lowMatrix);find(p>upMatrix)];
        replace=unifrnd(lowMatrix(idx),upMatrix(idx),length(idx),1);
        p(idx)=replace;
    case 3 %Bounce Back
      [idx] = find(p<lowMatrix);
      p(idx)=unifrnd(lowMatrix(idx),FM_base(idx),length(idx),1);
        [idx] = find(p>upMatrix);
      p(idx)=unifrnd(FM_base(idx), upMatrix(idx),length(idx),1);
end

function [FM_ui,FM_base,msg]=generate_trial(method,F_weight, F_CR, FM_pop, FVr_bestmemit,I_NP,I_D,FVr_rot,I_strategyVersion,other)
    FM_popold = FM_pop;                  % save the old population
    FVr_ind = randperm(4);               % index pointer array
    FVr_a1  = randperm(I_NP);                   % shuffle locations of vectors
    FVr_rt  = rem(FVr_rot+FVr_ind(1),I_NP);     % rotate indices by ind(1) positions
    FVr_a2  = FVr_a1(FVr_rt+1);                 % rotate vector locations
    FVr_rt  = rem(FVr_rot+FVr_ind(2),I_NP);
    FVr_a3  = FVr_a2(FVr_rt+1);                
    FM_pm1 = FM_popold(FVr_a1,:);             % shuffled population 1
    FM_pm2 = FM_popold(FVr_a2,:);             % shuffled population 2
    FM_pm3 = FM_popold(FVr_a3,:);             % shuffled population 3
  
    if length(F_CR)==1  %Meaning the same F_CR for all individuals
        FM_mui = rand(I_NP,I_D) < F_CR;  % all random numbers < F_CR are 1, 0 otherwise
        FM_mpo = FM_mui < 0.5;    % inverse mask to FM_mui
    else %Meaning a different F_CR for each individual
        FM_mui = rand(I_NP,I_D) < repmat(F_CR,1,I_D);  % all random numbers < F_CR are 1, 0 otherwise
        FM_mpo = FM_mui < 0.5;    % inverse mask to FM_mui
    end

    switch method %different implementations available
        case 1 %DE/rand1
            FM_ui = FM_pm3 + F_weight*(FM_pm1 - FM_pm2);   % differential variation
            FM_ui = FM_popold.*FM_mpo + FM_ui.*FM_mui;     % crossover
            FM_base = FM_pm3;
            msg=' DE/rand/bin';
        case 2
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
            %VEC by FLC
            FM_bm=repmat(FVr_bestmemit,I_NP,1);
            FM_ui = FM_popold + F_weight*(FM_bm-FM_popold) + F_weight*(FM_pm1 - FM_pm2);
            FM_ui = FM_popold.*FM_mpo + FM_ui.*FM_mui;
            FM_base = FM_bm;
            msg=' DE/current-to-best/1';
        case 3 %jDEPerturbated_v3 v4... v7
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
            FM_bm=repmat(FVr_bestmemit,I_NP,1);
            if length(F_weight)==1  %Meaning the same F_weight for all individuals
                FM_ui = FM_popold + F_weight*(FM_bm-FM_popold) + F_weight*(FM_pm1 - FM_pm2);
            else
                if  I_strategyVersion==1 %Emulate Vortex Algorithm
                        a=other.a;
                        ginv = (1/0.1)*gammaincinv(0.1,a); % compute the new ginv value
                        r = ginv * ((other.upperlimit - other.lowerlimit) / 2); %decrease the radius
                        C = r.*randn(I_NP,I_D);
                        FM_ui = bsxfun(@plus, C, FM_bm(1,:));
                end
                
                if  I_strategyVersion==2 %HyDE-DF
                    a=other.a; %Linear decrease
                    %a=0;%other.a; %Linear decrease
                    
                    ginv=exp((1-(1/a^2))); %Exponential decreasing funtion
                    FM_ui = FM_popold + repmat(F_weight(:,3),1,I_D).*(FM_pm1 - FM_pm2)  + ginv*(repmat(F_weight(:,1),1,I_D).*(FM_bm.*(repmat(F_weight(:,2),1,I_D)+randn(I_NP,I_D))-FM_popold));   % differential variation
                end
                
                if  I_strategyVersion==3 %HyDE
                    FM_ui = FM_popold + repmat(F_weight(:,1),1,I_D).*(FM_bm.*(repmat(F_weight(:,2),1,I_D)+randn(I_NP,I_D))-FM_popold) + repmat(F_weight(:,3),1,I_D).*(FM_pm1 - FM_pm2);
                end
            end
            
            FM_ui = FM_popold.*FM_mpo + FM_ui.*FM_mui;
            FM_base = FM_bm;
            msg=' HyDE/current-to-best/1';   
    end
return

