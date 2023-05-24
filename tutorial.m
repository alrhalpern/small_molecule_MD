%% EXAMPLES FOR DISTANCE MEASUREMENT
%basic distance measurement
x1 = alldistances(trj,mol2,mol1,pb);
mindists = min(x1);  %the closest distance between each molecule at each time point
sum(mindists<5)/length(mindists)*100   % this returns the percentage of time <x angstroms
%% Example of plotting
figure;histogram(mindists,500,'Normalization','pdf')
xlabel("Proximity (Angstroms)")
ylabel("Proportion of simulation")
title("Proximity")

%%
% examples of how to identify molecules in different ways
%mol1 = find(string(pdb.name)==" P  ")
%mol1 = find(string(pdb.name)==" O1 " & string(pdb.resname)=="ACP ")
%mol2 = find((string(pdb.name)==" H1 "  | string(pdb.name)==" H2 ")& string(pdb.resname)=="ADP ")
%mol2 = find(string(pdb.name)==" P2 " & string(pdb.resname)=="ADP ")
%mol2 = find(string(pdb.name)==" C3 " & string(pdb.resname)=="GDP " | string(pdb.name)==" C2 " & string(pdb.resname)=="GDP ")
%mol2 = find(string(pdb.name)==" O6 " | string(pdb.name)==" O7 " | string(pdb.name)==" O8 ")
% mol1 = find(string(pdb.resname)=="APC ")
% mol2 = find(string(pdb.resname)=="GLY " & string(pdb.name)==" CA ")
% mol1 = mol2(1)
%mol2 = mol2(1:10)
%mol2 = find(string(pdb.name(nonwaters,:))=="FE3P")
% mol2 = mol1(1:40)
% mol1 = mol1(41:end)

%% BOOTSTRAP

alldists =mindists;
runsused = goodruns;
runstart_ends = runstart_end;%[runstart;runend];

OPi = 0
for L = [5]
        OPi = OPi+1
        for i = 1:runsused   % loop to calculate time at <x !CAN CHANGE! angstroms for each experiment run
            if size(alldists,1)>1
                preboot(i) = (sum(sum(alldists(:,runstart_ends(1,i):runstart_ends(2,i))<L))/(runstart_ends(2,i)-runstart_ends(1,i)) *100)/size(alldists,1);
                %preboot(i) = (sum(sum(alldists(:,runstart_ends(1,i):runstart_ends(2,i))<L+step&alldists(:,runstart_ends(1,i):runstart_ends(2,i))>L))/(runstart_ends(2,i)-runstart_ends(1,i)) *100)/size(alldists,1);
            else
                preboot(i) = (sum(alldists(:,runstart_ends(1,i):runstart_ends(2,i))<L)/(runstart_ends(2,i)-runstart_ends(1,i)) *100)/size(alldists,1);
                %preboot(i) = (sum(alldists(:,runstart_ends(1,i):runstart_ends(2,i))<L+step&alldists(:,runstart_ends(1,i):runstart_ends(2,i))>L)/(runstart_ends(2,i)-runstart_ends(1,i)) *100)/size(alldists,1);
            end

        end 
    bootvals = bootstrp(100000,@mean,preboot); %inbuilt matlab bootstrap function (100000 pseudorepeats)
    x = sort(bootvals);   %sort pseudo experiments ready for confidence interval
    outs(OPi,:) = [mean(preboot) mean(preboot)-x(2.5/100*100000) x(97.5/100*100000)-mean(preboot)]   % [mean value, lower error bar, upper error bar]
end

%% Distance measurements for LARGE numbers of atoms/molecules

mol1 = find(resnames == resnames(1))
notmol1 = find(resnames ~= resnames(1));
mol2 = find(resnames == resnames(notmol1(1)))
mol1(end) = []
sectstarts = [1:size(trj,2):length(trj)]
sectends = [sectstarts(2:end)-1,length(trj)]
x1 = []
if sectends(end)-sectstarts(end)<size(trj,2)
    sectends(end-1) = []
    sectstarts(end) = []
end
time = 0;
 f = waitbar(0);
for i = 1:length(sectstarts)
    start = tic
    y = alldistances(trj(sectstarts(i):sectends(i),:),mol2,mol1,pb);
    x1 = [x1,min(y)];
    time = time+toc(start)
    percent = (i/length(sectstarts))*100
    waitbar(percent/100,f,"step " + string(i)+ "/"+string(length(sectstarts))+"    "+ string(((100-percent)/(percent/time))/60)+" minutes remaing")
end
figure;histogram(x1,500,'Normalization','pdf')
save(curfile+"_surfs",'x1')
mindists = x1;

%% Volume of molecule estimation
resnames = string(pdb.resname);
mol1 = find(resnames == resnames(1))
notmol1 = find(resnames ~= resnames(1));
mol2 = find(resnames == resnames(notmol1(1)))
mol = mol1
%mol1 = mol2
volvals=[]
volhist = []
for t = 1:150
    t
coord = [];
frame = randi(length(trj));
for i = 1:length(mol)
    coord(i,:) = trj(frame,mol(i)*3-2:mol(i)*3);
end
atomval = 0;
for n = 1:100000

x = rand*50-25;
y = rand*50-25;
z = rand*50-25;
%x^2+y^2+z^2;
%x1 = alldistances(trj(1:mol1(end)*3),mol1(1),mol1(2:end),pb)
atomval = atomval+any(sqrt(sum(([coord+[x,y,z]]).^2,2))<5);
volhist(n) = sum(atomval)/n;
end
%figure;plot(volhist);
volvals(t) = volhist(end);
%4*pi*25*surfhist(end)
end
figure;plot(volvals)
volvals = sort(volvals);
[mean(volvals) volvals(floor(0.95*t))-mean(volvals) mean(volvals)-volvals(ceil(0.05*t))]



%% MEASURE DISTANCE BETWEEN ATOMS
function [alldists] = alldistances(trajectory,molecule1,molecule2,periodicbox)
trj = trajectory;
mol1 = molecule1;
mol2 = molecule2;
pb = periodicbox;
counter = 0;
t = 0;
x = zeros(length(mol1)*length(mol2),length(trj));
for i = 1:length(mol1)
    for j = 1:length(mol2)
        tic
        counter = counter+1;  %nested loop to compare atoms from molecule 1 against each atom in molecule 2
        x(counter,:) = atomdistance(trj,mol1(i),mol2(j),pb);
        
        t = t + toc
        %tremaining = t*((length(mol1)*length(mol2))-counter)/(length(mol1)*length(mol2))
        percent = counter/(length(mol1)*length(mol2))*100
        tremaining = (100-percent)/(percent/t)
    end
end
alldists = x;
end
%%   ATOMDISTANCE FUNCTION
% Distance between two specific atoms
function [moldists] = atomdistance(trajectory,atom1,atom2,periodicbox)
trj = trajectory;
atomid1 = atom1;
atomid2 = atom2;
pb = periodicbox;
alldists = zeros(length(trj),27);
counter =0;
for i = -1:1
    
    for j = -1:1
        for k = -1:1
            counter = counter+1;
            %boxid(counter,:) = [i,j,k];
            boxmod = [i,j,k].*pb;
            dist = trj(:,atomid1*3-2:atomid1*3)-(trj(:,atomid2*3-2:atomid2*3)+boxmod);
            alldists(:,counter) = sum(dist.^2,2).^0.5;
        end
    end
end
moldists= min(alldists,[],2);
end
