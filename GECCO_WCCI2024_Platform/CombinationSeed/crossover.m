function child=crossover(best1,best2)

for i=1:numel(best1)
    if rand>0.5
        child(i)=best1(i);
    else
        child(i)=best2(i);
    end
end