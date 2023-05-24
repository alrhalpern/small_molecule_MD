clear all

% CHANGE THESE VARIABLES TO BE RELEVANT TO YOUR EXPERIMENT
dir = ["C:\Users\doubl\Documents\Tutorial\download-files"]   % Set directory where your data is stored (aka My_Data\download_files)
files = ["AMP-ATP-charmm"]                                 %File you want to extract
save_location = ["C:\Users\doubl\Documents\Tutorial"]   %Where you want to save the extracted data
pb = 40     % specify periodic box size
numruns = 100             % Specify how many seperate runs on the cluster

% PROBABLY DONT MESS WITH THIS STUFF
goodruns = 0;   %   variable to count how many runs are actually independent (The cluster can mess up it's random number generation sometimes)
currentfile = files   % renaming to "avoid confusion"
runs = [currentfile+"_step6_production"]    % initialize matrix and then loop to make the filenames for each run
for i = 2:numruns    
    runs = [runs; currentfile+"_"+string(i)+"_step6_production"];  %generates a matrix of all the file names, may need to tweak if your file names are weird
    %runs = [runs; currentfile+"-"+string(i)];
end
file = 'step6_production';     
targetdir = dir  %
cd(targetdir)
pdb = readpdb(currentfile+"_step4_input.pdb");      % this line of code opens the data
%psf = readpsf('step4_input.psf'); 
if sum(string(pdb.resname(:,:))=='WAT ')==0           % Conditional thing for which water model is being used (WAT or TIP3P), if you use something else you will have to add more options
nonwaters = find(string(pdb.resname) ~= "TIP3")     %find all molecules which aren't water
waters = find(string(pdb.resname) == "TIP3")        % find all waters
else
    nonwaters = find(string(pdb.resname) ~= "WAT ")     %find all molecules which aren't water
    waters = find(string(pdb.resname) == "WAT ") 
end
    atoms = [nonwaters]';                % determine atoms of non-water molecules and of "control" waters

    % now we load in the relevant data from all the other simulation repeats. 
for i = 1:numruns
        if exist('trj','var')==0  %check if theres a matrix for storing data in
            trj = readdcd([char(runs(i)) '.dcd'], atoms);    %if not, make one including the first run
            goodruns = goodruns + 1;          
            runstart(goodruns) = 1;     % store the starting timestep of this experiment
            runend(goodruns) = length(trj);          %store the ending timestep of this experiment
        else
            try
                tmptrj = readdcd([char(runs(i)) '.dcd'],atoms);  %if yes, add the data onto the end of matrix
                sim1 = find(tmptrj(80,1)==trj(:,1));            %a few lines of code to check that the run was truly independent (had randomized starting velocities)
                sim2 = find(tmptrj(80,100)==trj(:,100));         % NOTE: This may be a problem if you have VERY short/small simulations - try reducing 80 -> 20, and 100 -> 30 (these refer to simulation frames and molecule coordinates respectively)
                if sum(sim2==sim1)<1
                    goodruns = goodruns + 1;          
                    runstart(goodruns) = runend(goodruns-1)+1;     % store the starting timestep of this experiment
                    trj = [trj;tmptrj];
                    runend(goodruns) = length(trj);          %store the ending timestep of this experiment
                end
            catch
                "Error in file " + i
            end
        end
%     end
i
end

length(runstart)
length(trj)*10/1000
runstart_end = [runstart;runend];  %this combines the start and endpoints of all the seperate simulations into one matrix


% specify which molecules are of interest  (DELETE MOL2 IF ONLY USING ONE
% MOLECULE. ADD MORE MOLS IF NECESSARY)
resnames = string(pdb.resname);
mol1 = find(resnames == resnames(1))
notmol1 = find(resnames ~= resnames(1));
mol2 = find(resnames == resnames(notmol1(1)))
%Other methods of identifying molecules - can be useful in other places
% mol1 = find(pdb.resname(:,2)=='C'); %specify letters of molecule name which distinguish it
% mol2 = find(pdb.resname(:,2)=='T');        
%find(string(pdb.name) == " O2'")  %specify name of a specific atom
cd(save_location)
if isfile(currentfile+".mat")
    "ERROR: Did not save as file with same name already exists"
else
save(currentfile)
end