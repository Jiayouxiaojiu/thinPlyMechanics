function[projectName]=rve_mesh_create_project(folder,matDBfolder,index,modType,fiberArrangement,isInner,isUpperBounded,isLowerBounded,isCohesive,crackType,...
                                                                          element,order,optimize,layup,...
                                                                          phi,Rf,Vff,tratio,theta,deltatheta,dT,interfaceFriction,epsxx,fiberType,matrixType,matPropAlg,solverChoice,unitConvFactor,...
                                                                          f1,f2,f3,N1,N2,N3,N4,N5,N6,...
                                                                          requestDAT,requestFIL,requestODB)
%%
%==============================================================================
% Copyright (c) 2016 Universit� de Lorraine & Lule� tekniska universitet
% Author: Luca Di Stasio <luca.distasio@gmail.com>
%                        <luca.distasio@ingpec.eu>
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 
% 
% Redistributions of source code must retain the above copyright
% notice, this list of conditions and the following disclaimer.
% Redistributions in binary form must reproduce the above copyright
% notice, this list of conditions and the following disclaimer in
% the documentation and/or other materials provided with the distribution
% Neither the name of the Universit� de Lorraine or Lule� tekniska universitet
% nor the names of its contributors may be used to endorse or promote products
% derived from this software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
%==============================================================================
%
%  DESCRIPTION
%  
%  A script to generate the project files for RVE Finite Elements
%  Simulations:
%
%   .json
%   .csv
%   .tex
%   .inp
%
%  unitConvFactor(1)  => length
%  unitConvFactor(2)  => mass
%  unitConvFactor(3)  => time
%  unitConvFactor(4)  => electric current
%  unitConvFactor(5)  => thermodynamic temperature
%  unitConvFactor(6)  => amount of substance
%  unitConvFactor(7)  => luminous intensity
%  unitConvFactor(8)  => density
%  unitConvFactor(9)  => pressure/stress
%  unitConvFactor(10) => thermal expansion
%  unitConvFactor(11) => thermal conductivity
%  unitConvFactor(12) => specific heat capacity
%  unitConvFactor(13) => fracture toughness
%  unitConvFactor(14) => interface stiffness
%  unitConvFactor(15) => force
%
%%

%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%-                     Preliminary Calculations                          -%
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%%
nodesTOT = 0;

if modType == 2
  nodesTOT = (N1 + 1)*(N1 + 1) + 4*N1*(N2 + N3 + 1) + 4*N1*(N4 + N5) + 2*(N1 + 1)*(N6 + 1);
else
  nodesTOT = (N1 + 1)*(N1 + 1) + 4*N1*(N2 + N3 + 1) + 4*N1*(N4 + N5);
end

elTOT = 0;

if modType == 2
  elTOT = N1*N1 + 4*N1*(N2 + N3 + N4 + N5) + 2*N1*N6
else
  elTOT = N1*N1 + 4*N1*(N2 + N3 + N4 + N5)
end


    
model = strcat("VL4FC-2DmmTPL-IC-",num2str(modType), "-",num2str(fiberArrangement), "-", num2str(isInner), "-",... 
		num2str(isUpperBounded), "-", num2str(isLowerBounded), "-",num2str(isCohesive), "-", num2str(crackType), "-",...
		num2str(element), "-", num2str(order), "-", num2str(optimize),"-", num2str(layup), "-", num2str(phi), "-",...
		num2str(Rf), "-",num2str(Vff), "-", num2str(tratio), "-", num2str(theta), "-",num2str(deltatheta), "-",...
		num2str(dT), "-",num2str(interfaceFriction), "-", num2str(epsxx), "-",num2str(fiberType), "-",...
		num2str(matrixType), "-",num2str(matPropAlg), "-", num2str(solverChoice), "-",num2str(f1), "-",...
		num2str(f2), "-", num2str(f3), "-",num2str(N1), "-", num2str(N2), "-", num2str(N3), "-",num2str(N4), "-",...
		num2str(N5), "-", num2str(N6), "-",num2str(nodesTOT), "-",num2str(elTOT));

%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%-                        Mesh Generation                                -%
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%%
[nodes,edges,elements,...
    fiberN,matrixN,part6bot,part6up,...
    fiberEl,matrixEl,cohesiveEl,boundedBot,boundedUp,...
    gammaNo1,gammaNo2,gammaNo3,gammaNo4,gammaEl1,gammaEl2,gammaEl3,gammaEl4,...
    NintUpNine,NintUpZero,NintBotNine,NintBotZero,NintUpNineCorners,NintUpZeroCorners,NintBotNineCorners,NintBotZeroCorners,...
    NbotRight,NbotLeft,NupRight,NupLeft,EintUpNine,EintUpZero,EintBotNine,EintBotZero,EbotRight,EbotLeft,EupRight,EupLeft,...
    Ncorners,Ndown,Nright,Nup,Nleft,Edown,Eright,Eup,Eleft] = rve_mesh(fiberArrangement,isUpperBounded,isLowerBounded,isCohesive,crackType,...
                                                                          element,order,optimize,...
                                                                          Rf,Vff,tratio,theta,deltatheta,...
                                                                          f1,f2,f3,N1,N2,N3,N4,N5,N6);

%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%-                      Mesh Quality Analysis                            -%
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%-                          I/O settings                                 -%
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%%
projectName = '';

if ~checkIndex(folder,strcat(index,'.csv'),model)
    projectName = incrementName(folder,strcat(index,'.csv'));
    createWD(folder,projectName);
    fileId = fopen(fullfile(folder,strcat(index,'.csv')),'a');
    fprintf(fileId,'%s',strcat(projectName,',',model));
    fprintf(fileId,'\n');
    fclose(fileId);
else
    projectName = strcat('A model with this set of parameters already exists. See: ',getModelFolder(folder,strcat(index,'.csv'),model));
    return
end

%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%-                        Write .inp file                                -%
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%%
% create the filepath
abqpath = fullfile(folder,projectName,'abqinp',strcat(projectName,'.inp'));

% create the file
abqinpID = fopen(abqpath,'w');
fclose(abqinpID);

%% HEADER SECTION

% write header
isPeriodic = 0;
isHomogeneousOnLower = 0;
isHomogeneousOnUpper = 0;
isSymmOnLower = 0;
isSymmOnUpper = 0;
isFreeOnLower = 0;
isFreeOnUpper = 0;
switch modType
    case 1
        modeltype = 'Isolated RVE with homogeneous boundary conditions';
        plyThickness = 'Not Applicable';
    case 2
        modeltype = 'Bounded RVE';
        plyThickness = num2str(tratio);
    case 3
        modeltype = 'Periodic RVE';
        plyThickness = 'Not Applicable';
        isPeriodic = 1;
    case 4
        modeltype = 'Isolated RVE with rigidity constraints';
        plyThickness = 'Not Applicable';
    otherwise
        modeltype = 'Isolated RVE';
        plyThickness = 'Not Applicable';    
end
if isInner
    switch layup
        case 1
            stackingSequence = '[[phi]_n,90,[phi]_n]';
            if ~isPeriodic
                if ~isUpperBounded
                    isHomogeneousOnUpper = 1;
                end
                if ~isLowerBounded
                    isHomogeneousOnLower = 1;
                end
            end
        case 2
            stackingSequence = '[[phi]_n,90]_S';
            if ~isPeriodic
                if isUpperBounded
                    isSymmOnLower = 1;
                end
                if isLowerBounded
                    isSymmOnUpper = 1;
                end
            end
        otherwise
            stackingSequence = '[[phi]_n,90,[phi]_n]';
            if ~isPeriodic
                if ~isUpperBounded
                    isHomogeneousOnUpper = 1;
                end
                if ~isLowerBounded
                    isHomogeneousOnLower = 1;
                end
            end
    end
else
    switch layup
        case 1
            stackingSequence = '[90,[phi]_n]';
            if ~isPeriodic
                if isUpperBounded
                    isFreeOnLower = 1;
                end
                if isLowerBounded
                    isFreeOnUpper = 1;
                end
            end
        case 2
            stackingSequence = '[90,[phi]_n]_S';
            if ~isPeriodic
                if isUpperBounded
                    isFreeOnLower = 1;
                    isSymmOnUpper = 1;
                end
                if isLowerBounded
                    isFreeOnUpper = 1;
                    isSymmOnLower = 1;
                end
            end
        otherwise
            stackingSequence = '[90,[phi]_n]';
            if ~isPeriodic
                if isUpperBounded
                    isFreeOnLower = 1;
                end
                if isLowerBounded
                    isFreeOnUpper = 1;
                end
            end
    end
end
switch fiberType
    case 1
        fiber = 'Carbon Fiber';
    case 2
        fiber = 'Glass Fiber';
    otherwise
        fiber = 'Carbon Fiber';
end
switch matrixType
    case 1
        matrix = 'Epoxy';
    case 2
        matrix = 'HDPE';
    otherwise
        matrix = 'Epoxy';
end
switch matPropAlg
    case 1
        lamPropAlg = 'Rule of Mixtures';
    case 2
        lamPropAlg = 'Halpsin-Tsai Method';
    case 3
        lamPropAlg = 'Hashin Method';
    otherwise
        lamPropAlg = 'Rule of Mixtures';
end
switch solverChoice
    case 1
        solvers = 'Virtual Crack Closure Method';
    case 2
        solvers = 'Cohesive Elements Method';
    case 3
        solvers = 'CZM & XFEM';
    otherwise
        if isCohesive
            solvers = 'Cohesive Elements Method';
        else
            solvers = 'Virtual Crack Closure Method';
        end
end
if element==1
    eltype = 'Quadrilateral';
elseif element==2
    eltype = 'Triangular';
else
    eltype = 'NA';
end
if order==1
    elorder = '1st';
elseif order==2
    elorder = '2nd';
else
    elorder = 'NA';
end
if dT~=0
    if isCohesive
       if element==1 && order==1
          elId = 'CPE4T & COH2D4';
       elseif element==1 && order==2
          elId = 'CPE8T & COH2D4';
       elseif element==2 && order==1
          elId = 'CPE3T & COH2D4';
       elseif element==1 && order==1
          elId = 'CPE6MT & COH2D4';
       else
          elId = 'NA'; 
       end
    else
       if element==1 && order==1
          elId = 'CPE4T';
       elseif element==1 && order==2
          elId = 'CPE8T';
       elseif element==2 && order==1
          elId = 'CPE3T';
       elseif element==1 && order==1
          elId = 'CPE6MT';
       else
          elId = 'NA'; 
       end
    end
else
    if isCohesive
       if element==1 && order==1
          elId = 'CPE4 & COH2D4';
       elseif element==1 && order==2
          elId = 'CPE8 & COH2D4';
       elseif element==2 && order==1
          elId = 'CPE3 & COH2D4';
       elseif element==2 && order==2
          elId = 'CPE6 & COH2D4';
       else
          elId = 'NA'; 
       end
    else
       if element==1 && order==1
          elId = 'CPE4';
       elseif element==1 && order==2
          elId = 'CPE8';
       elseif element==2 && order==1
          elId = 'CPE3';
       elseif element==2 && order==2
          elId = 'CPE6';
       else
          elId = 'NA'; 
       end
    end
end

if optimize
    meshOptimization = 'Optimized';
else
    meshOptimization = 'Basic';
end

header ={'--                                                                                                                                                                --'; ...
         '--                                        MECHANICS OF EXTREME THIN PLIES IN FIBER REINFORCED COMPOSITE LAMINATES                                                 --'; ...
         '--                                                                                                                                                                --'; ...
         '--                                    2D PLANE STRAIN MICROMECHANICAL PARAMETRIC SIMULATION OF REFERENCE VOLUME ELEMENTS                                          --'; ...
         '--                                                                                                                                                                --'; ...
         '--                                                                                                                                                                --'; ...
         '--------------------------------------------------------------------------------------------------------------------------------------------------------------------'; ...
         '--                                                                                                                             --'; ...
         strcat('--                      Model Code: ',model,'  --'); ...
         strcat('--                        RVE Type: ',modeltype,'  --'); ...
         strcat('--                 Space Dimension: ','2D','  --'); ...
         '--                                                                                                                             --'; ...
         strcat('--               Stacking Sequence: ',stackingSequence,'  --'); ...
         strcat('--         Modeled Ply Angle [deg]: ','90 deg','  --'); ...
         strcat('--        Bounding Ply Angle [deg]: ',num2str(phi*180/pi),' deg','  --'); ...
         '--                                                                                                                             --'; ...
         strcat('--        Fiber radius Rf[10e-6 m]: ',num2str(Rf),'  --'); ...
         strcat('--    Side helf length L [10e-6 m]: ',num2str(0.5*Rf*sqrt(pi/Vff)),'  --'); ...
         strcat('--                  L/Rf [10e-6 m]: ',num2str(0.5*sqrt(pi/Vff)),'  --'); ...
         strcat('--          Fiber radius [10e-6 m]: ',num2str(Rf),'  --'); ...
         strcat('--       Fiber Volume Fraction [-]: ',num2str(Vff),'  --'); ...
         strcat('--       Plies Thickness Ratio [-]: ',plyThickness,'  --'); ...
         strcat('--    Crack Angular Position [deg]: ',num2str(theta*180/pi),' deg','  --'); ...
         strcat('--    Crack Angular Aperture [deg]: ',num2str(deltatheta*180/pi),' deg','  --'); ...
         '--                                                                                                                             --'; ...
         strcat('--            Applied Axial Strain: ',num2str(epsxx),'  --'); ...
         '--                                                                                                                             --'; ...
         strcat('--        Applied Temperature Jump: ',num2str(dT),'  --'); ...
         '--                                                                                                                             --'; ...
         strcat('--                           Fiber: ',fiber,'  --'); ...
         strcat('--                          Matrix: ',matrix,'  --'); ...
         strcat('--     Lamina Properties Algorithm: ',lamPropAlg,'  --'); ...
         '--                                                                                                                             --'; ...
         strcat('--                       Solver(s): ',solvers,'  --'); ...
         '--                                                                                                                             --'; ...
         strcat('--                 Elements'' Type: ',eltype,'  --'); ...
         strcat('--                Elements'' Order: ',elorder,'  --'); ...
         strcat('--                   Elements'' ID: ',elId,'  --'); ...
         '--                                                                                                                             --'; ...
         strcat('--                   Mesh optimization: ',meshOptimization,'  --'); ...
         strcat('--                                  f1: ',num2str(f1),'  --'); ...
         strcat('--                                  f2: ',num2str(f2),'  --'); ...
         strcat('--                                  f3: ',num2str(f3),'  --'); ...
         strcat('--                              Nalpha: ',num2str(N1),'  --'); ...
         strcat('--                               Nbeta: ',num2str(N2),'  --'); ...
         strcat('--                              Ngamma: ',num2str(N3),'  --'); ...
         strcat('--                              Ndelta: ',num2str(N4),'  --'); ...
         strcat('--                                Neps: ',num2str(N5),'  --'); ...
         strcat('--                               Nzeta: ',num2str(N6),'  --'); ...
         strcat('--               Total Number of Nodes: ',num2str(nodesTOT),'  --'); ...
         strcat('--            Total Number of Elements: ',num2str(elTOT),'  --'); ...
         strcat('-- Angular discretization at interface: ',num2str(360/(4*N1)),' deg  --'); ...
         '--                                                                                                                             --'; ...
         '--      Conversion factor of units of measurement with respect to SI   --'; ...
         strcat('--                             length, SI [m]: ',num2str(unitConvFactor(1), '%10.5e'),'  --'); ...
         strcat('--                              mass, SI [kg]: ',num2str(unitConvFactor(2), '%10.5e'),'  --'); ...
         strcat('--                               time, SI [s]: ',num2str(unitConvFactor(3), '%10.5e'),'  --'); ...
         strcat('--                              force, SI [N]: ',num2str(unitConvFactor(15), '%10.5e'),'  --'); ...
         strcat('--                   electric current, SI [A]: ',num2str(unitConvFactor(4), '%10.5e'),'  --'); ...
         strcat('--          thermodynamic temperature, SI [K]: ',num2str(unitConvFactor(5), '%10.5e'),'  --'); ...
         strcat('--              amount of substance, SI [mol]: ',num2str(unitConvFactor(6), '%10.5e'),'  --'); ...
         strcat('--                luminous intensity, SI [cd]: ',num2str(unitConvFactor(7), '%10.5e'),'  --'); ...
         strcat('--                       density, SI [kg/m^3]: ',num2str(unitConvFactor(8), '%10.5e'),'  --'); ...
         strcat('--                   pressure/stress, SI [Pa]: ',num2str(unitConvFactor(9), '%10.5e'),'  --'); ...
         strcat('--            thermal expansion, SI [m/(m*K)]: ',num2str(unitConvFactor(10), '%10.5e'),'  --'); ...
         strcat('--         thermal conductivity, SI [W/(m*K)]: ',num2str(unitConvFactor(11), '%10.5e'),'  --'); ...
         strcat('--      specific heat capacity, SI [J/(kg*K)]: ',num2str(unitConvFactor(12), '%10.5e'),'  --'); ...
         strcat('--            energy release rate, SI [J/m^2]: ',num2str(unitConvFactor(13), '%10.5e'),'  --'); ...
         strcat('--            interface stiffness, SI [N/m^3]: ',num2str(unitConvFactor(14), '%10.5e'),'  --'); ...
         '--                                                                                                                             --'; ...
         '--                                                                                                                             --'};
     
writeABQheader(abqpath,header);

%write license
holder = 'Universit� de Lorraine or Lule� tekniska universitet';
author = 'Luca Di Stasio';

writeABQlicense(abqpath,holder,author);

%write heading

writeABQheading(abqpath,{'2D Plane Strain Micromechanical Simulation of RVEs'},'none');

% write preprint
contact = 'YES';
echo = 'NO';
history = 'YES';
model = 'YES';
parsubstitution =  'YES';
parvalues = 'YES'; 
massprop = 'NO';

writeABQpreprint(abqpath,contact,echo,history,model,parsubstitution,parvalues,massprop,{},'none');

% start mesh section
writeABQmeshsec(abqpath);

%% NODES SECTION

% start nodes section
writeABQnodesec(abqpath);

% generates all nodes
writeABQnodegen(abqpath,1,1,nodes,'All-Nodes');

% assign nodes to node sets
writeABQnodeset(abqpath,1,(1:length(matrixN))','Matrix-Nodes');

writeABQnodeset(abqpath,1,length(matrixN)+(1:length(fiberN))','Fiber-Nodes');

if isCohesive
    writeABQnodeset(abqpath,1,gammaNo1,'FiberSurface-Nodes');
    writeABQnodeset(abqpath,1,gammaNo3,'MatrixSurfaceAtFiberInterface-Nodes');
else
    writeABQnodeset(abqpath,1,gammaNo1,'Gamma1-Nodes');
    writeABQnodeset(abqpath,1,gammaNo2,'Gamma2-Nodes');
    writeABQnodeset(abqpath,1,gammaNo3,'Gamma3-Nodes');
    writeABQnodeset(abqpath,1,gammaNo4,'Gamma4-Nodes');
    writeABQnodeset(abqpath,2,{'Gamma1-Nodes','Gamma2-Nodes'},'FiberSurface-Nodes');
    writeABQnodeset(abqpath,2,{'Gamma3-Nodes','Gamma4-Nodes'},'MatrixSurfaceAtFiberInterface-Nodes');
end

writeABQnodeset(abqpath,1,Ncorners(1),'SW-CornerNode');
writeABQnodeset(abqpath,1,Ncorners(2),'SE-CornerNode');
writeABQnodeset(abqpath,1,Ncorners(3),'NE-CornerNode');
writeABQnodeset(abqpath,1,Ncorners(4),'NW-CornerNode');
writeABQnodeset(abqpath,1,Ncorners,'CornerNodes');
writeABQnodeset(abqpath,1,Ndown,'LowerSide-Nodes-without-Corners');
writeABQnodeset(abqpath,1,Nright,'RightSide-Nodes-without-Corners');
writeABQnodeset(abqpath,1,Nup,'UpperSide-Nodes-without-Corners');
writeABQnodeset(abqpath,1,Nleft(end:-1:1),'LeftSide-Nodes-without-Corners');
writeABQnodeset(abqpath,2,{'LowerSide-Nodes-without-Corners';'SW-CornerNode';'SE-CornerNode'},'LowerSide-Nodes-with-Corners');
writeABQnodeset(abqpath,2,{'RightSide-Nodes-without-Corners';'SE-CornerNode';'NE-CornerNode'},'RightSide-Nodes-with-Corners');
writeABQnodeset(abqpath,2,{'UpperSide-Nodes-without-Corners';'NW-CornerNode';'NE-CornerNode'},'UpperSide-Nodes-with-Corners');
writeABQnodeset(abqpath,2,{'LeftSide-Nodes-without-Corners';'SW-CornerNode';'NW-CornerNode'},'LeftSide-Nodes-with-Corners');

if isUpperBounded
    writeABQnodeset(abqpath,1,part6up,'UpperPly-Nodes');
    writeABQnodeset(abqpath,1,NintUpNineCorners(1),'SW-UpperPly-CornerNode');
    writeABQnodeset(abqpath,1,NintUpNineCorners(2),'SE-UpperPly-CornerNode');
    writeABQnodeset(abqpath,1,NintUpZeroCorners(1),'NW-Matrix-CornerNode');
    writeABQnodeset(abqpath,1,NintUpZeroCorners(2),'NE-Matrix-CornerNode');
    writeABQnodeset(abqpath,1,NintUpNine,'LowerSide-UpperPly-Nodes-without-Corners');
    writeABQnodeset(abqpath,1,NintUpZero,'UpperSide-Matrix-Nodes-without-Corners');
    writeABQnodeset(abqpath,1,NupRight,'RightSide-UpperPly-Nodes-without-Corners');
    writeABQnodeset(abqpath,1,NupLeft,'LeftSide-UpperPly-Nodes-without-Corners');
    writeABQnodeset(abqpath,2,{'LowerSide-UpperPly-Nodes-without-Corners';'SW-UpperPly-CornerNode';'SE-UpperPly-CornerNode'},'LowerSide-UpperPly-Nodes-with-Corners');
    writeABQnodeset(abqpath,2,{'UpperSide-Matrix-Nodes-without-Corners';'NW-Matrix-CornerNode';'NE-Matrix-CornerNode'},'UpperSide-Matrix-Nodes-with-Corners');

end
if isLowerBounded
    writeABQnodeset(abqpath,1,part6bot,'LowerPly-Nodes');
    writeABQnodeset(abqpath,1,NintBotNineCorners(1),'NW-LowerPly-CornerNode');
    writeABQnodeset(abqpath,1,NintBotNineCorners(2),'NE-LowerPly-CornerNode');
    writeABQnodeset(abqpath,1,NintBotZeroCorners(1),'SW-Matrix-CornerNode');
    writeABQnodeset(abqpath,1,NintBotZeroCorners(2),'SE-Matrix-CornerNode');
    writeABQnodeset(abqpath,1,NintBotNine,'UpperSide-LowerPly-Nodes-without-Corners');
    writeABQnodeset(abqpath,1,NintBotZero,'LowerSide-Matrix-Nodes-without-Corners');
    writeABQnodeset(abqpath,1,NbotRight,'RightSide-LowerPly-Nodes-without-Corners');
    writeABQnodeset(abqpath,1,NbotLeft,'LeftSide-LowerPly-Nodes-without-Corners');
    writeABQnodeset(abqpath,2,{'UpperSide-LowerPly-Nodes-without-Corners';'NW-LowerPly-CornerNode';'NE-LowerPly-CornerNode'},'UpperSide-LowerPly-Nodes-with-Corners');
    writeABQnodeset(abqpath,2,{'LowerSide-Matrix-Nodes-without-Corners';'SW-Matrix-CornerNode';'SE-Matrix-CornerNode'},'LowerSide-Matrix-Nodes-with-Corners');
end

if isUpperBounded && isLowerBounded
    writeABQnodeset(abqpath,2,{'UpperPly-Nodes';'LowerPly-Nodes'},'BoundingPlies-Nodes');
end

%% ELEMENTS SECTION

% start elements part
writeABQelsec(abqpath);

if dT~=0
   if element==1 && order==1
      elTypeId = 'CPE4T';
   elseif element==1 && order==2
      elTypeId = 'CPE8T';
   elseif element==2 && order==1
      elTypeId = 'CPE3T';
   elseif element==2 && order==2
      elTypeId = 'CPE6MT';
   else
      elTypeId = 'CPE4T'; 
   end
else
   if element==1 && order==1
      elTypeId = 'CPE4';
   elseif element==1 && order==2
      elTypeId = 'CPE8';
   elseif element==2 && order==1
      elTypeId = 'CPE3';
   elseif element==2 && order==2
      elTypeId = 'CPE6';
   else
      elTypeId = 'CPE4'; 
   end
end

writeABQelgen(abqpath,1,1,matrixEl,elTypeId,'Matrix-Elements');

if isCohesive
    writeABQelgen(abqpath,length(matrixEl)+1,1,cohesiveEl,'COH2D4','Cohesive-Elements');
    writeABQelgen(abqpath,length(matrixEl)+length(cohesiveEl)+1,1,fiberEl,elTypeId,'Fiber-Elements');
    if isUpperBounded && isLowerBounded
        writeABQelgen(abqpath,length(matrixEl)+length(cohesiveEl)+length(fiberEl)+1,1,boundedUp,elTypeId,'UpperPly-Elements');
        writeABQelgen(abqpath,length(matrixEl)+length(cohesiveEl)+length(fiberEl)+length(boundedUp)+1,1,boundedBot,elTypeId,'LowerPly-Elements');
        writeABQelementset(abqpath,2,{'UpperPly-Elements';'LowerPly-Elements'},'BoundingPlies-Elements');
        writeABQelementset(abqpath,2,{'Matrix-Elements';'Cohesive-Elements';'Fiber-Elements';'UpperPly-Elements';'LowerPly-Elements'},'All-Elements');
        writeABQelementset(abqpath,1,EintUpNine,'UpperPlyLowerSurface-Elements');
        writeABQelementset(abqpath,1,EintUpZero,'MatrixSurfaceAtUpperPlyInterface-Elements');
        writeABQelementset(abqpath,1,EintBotNine,'LowerPlyUpperSurface-Elements');
        writeABQelementset(abqpath,1,EintBotZero,'MatrixSurfaceAtLowerPlyInterface-Elements');
    elseif isUpperBounded
        writeABQelgen(abqpath,length(matrixEl)+length(cohesiveEl)+length(fiberEl)+1,1,boundedUp,elTypeId,'UpperPly-Elements');
        writeABQelementset(abqpath,2,{'Matrix-Elements';'Cohesive-Elements';'Fiber-Elements';'UpperPly-Elements'},'All-Elements');
        writeABQelementset(abqpath,1,EintUpNine,'UpperPlyLowerSurface-Elements');
        writeABQelementset(abqpath,1,EintUpZero,'MatrixSurfaceAtUpperPlyInterface-Elements');
    elseif isLowerBounded
        writeABQelgen(abqpath,length(matrixEl)+length(cohesiveEl)+length(fiberEl)+1,1,boundedBot,elTypeId,'LowerPly-Elements');
        writeABQelementset(abqpath,2,{'Matrix-Elements';'Cohesive-Elements';'Fiber-Elements';'LowerPly-Elements'},'All-Elements');
        writeABQelementset(abqpath,1,EintBotNine,'LowerPlyUpperSurface-Elements');
        writeABQelementset(abqpath,1,EintBotZero,'MatrixSurfaceAtLowerPlyInterface-Elements');
    else
        writeABQelementset(abqpath,2,{'Matrix-Elements';'Cohesive-Elements';'Fiber-Elements'},'All-Elements');
    end
    writeABQelementset(abqpath,1,gammaEl1,'FiberSurface-Elements');
    writeABQelementset(abqpath,1,gammaEl3,'MatrixSurfaceAtFiberInterface-Elements');
else
    writeABQelgen(abqpath,length(matrixEl)+1,1,fiberEl,elTypeId,'Fiber-Elements');
    if isUpperBounded && isLowerBounded
        writeABQelgen(abqpath,length(matrixEl)+length(fiberEl)+1,1,boundedUp,elTypeId,'UpperPly-Elements');
        writeABQelgen(abqpath,length(matrixEl)+length(fiberEl)+length(boundedUp)+1,1,boundedBot,elTypeId,'LowerPly-Elements');
        writeABQelementset(abqpath,2,{'UpperPly-Elements';'LowerPly-Elements'},'BoundingPlies-Elements');
        writeABQelementset(abqpath,2,{'Matrix-Elements';'Fiber-Elements';'UpperPly-Elements';'LowerPly-Elements'},'All-Elements');
        writeABQelementset(abqpath,1,EintUpNine,'UpperPlyLowerSurface-Elements');
        writeABQelementset(abqpath,1,EintUpZero,'MatrixSurfaceAtUpperPlyInterface-Elements');
        writeABQelementset(abqpath,1,EintBotNine,'LowerPlyUpperSurface-Elements');
        writeABQelementset(abqpath,1,EintBotZero,'MatrixSurfaceAtLowerPlyInterface-Elements');
    elseif isUpperBounded
        writeABQelgen(abqpath,length(matrixEl)+length(fiberEl)+1,1,boundedUp,elTypeId,'UpperPly-Elements');
        writeABQelementset(abqpath,2,{'Matrix-Elements';'Fiber-Elements';'UpperPly-Elements'},'All-Elements');
        writeABQelementset(abqpath,1,EintUpNine,'UpperPlyLowerSurface-Elements');
        writeABQelementset(abqpath,1,EintUpZero,'MatrixSurfaceAtUpperPlyInterface-Elements');
    elseif isLowerBounded
        writeABQelgen(abqpath,length(matrixEl)+length(fiberEl)+1,1,boundedBot,elTypeId,'LowerPly-Elements');
        writeABQelementset(abqpath,2,{'Matrix-Elements';'Fiber-Elements';'LowerPly-Elements'},'All-Elements');
        writeABQelementset(abqpath,1,EintBotNine,'LowerPlyUpperSurface-Elements');
        writeABQelementset(abqpath,1,EintBotZero,'MatrixSurfaceAtLowerPlyInterface-Elements');
    else
        writeABQelementset(abqpath,2,{'Matrix-Elements';'Fiber-Elements'},'All-Elements');
    end
    writeABQelementset(abqpath,1,[gammaEl1;gammaEl2],'FiberSurface-Elements');
    writeABQelementset(abqpath,1,[gammaEl3;gammaEl4],'MatrixSurfaceAtFiberInterface-Elements');
end

%% MATERIAL SECTION

%  unitConvFactor(1)  => length
%  unitConvFactor(2)  => mass
%  unitConvFactor(3)  => time
%  unitConvFactor(4)  => electric current
%  unitConvFactor(5)  => thermodynamic temperature
%  unitConvFactor(6)  => amount of substance
%  unitConvFactor(7)  => luminous intensity
%  unitConvFactor(8)  => density
%  unitConvFactor(9)  => pressure/stress
%  unitConvFactor(10) => thermal expansion
%  unitConvFactor(11) => thermal conductivity
%  unitConvFactor(12) => specific heat capacity
%  unitConvFactor(13) => fracture toughness
%  unitConvFactor(14) => interface stiffness

writeABQmatsec(abqpath);

switch fiberType
    case 1
        fiberProps = getValuesFromCSV(matDBfolder,strcat('CF','.csv'),2,0,9);
        fiberUnitConv = getValuesFromCSV(matDBfolder,strcat('CF','.csv'),1,0,9);
    case 2
        fiberProps = getValuesFromCSV(matDBfolder,strcat('GF','.csv'),2,0,9);
        fiberUnitConv = getValuesFromCSV(matDBfolder,strcat('GF','.csv'),1,0,9);
    otherwise
        fiberProps = getValuesFromCSV(matDBfolder,strcat('CF','.csv'),2,0,9);
        fiberUnitConv = getValuesFromCSV(matDBfolder,strcat('CF','.csv'),1,0,9);
end
switch matrixType
    case 1
        matrixProps = getValuesFromCSV(matDBfolder,strcat('EP','.csv'),2,0,9);
        matrixUnitConv = getValuesFromCSV(matDBfolder,strcat('EP','.csv'),1,0,9);
    case 2
        matrixProps = getValuesFromCSV(matDBfolder,strcat('HDPE','.csv'),2,0,9);
        matrixUnitConv = getValuesFromCSV(matDBfolder,strcat('HDPE','.csv'),1,0,9);
    otherwise
        matrixProps = getValuesFromCSV(matDBfolder,strcat('EP','.csv'),2,0,9);
        matrixUnitConv = getValuesFromCSV(matDBfolder,strcat('EP','.csv'),1,0,9);
end

rhof    = fiberProps(1)*fiberUnitConv(1);
E1f     = fiberProps(2)*fiberUnitConv(2);
E2f     = fiberProps(3)*fiberUnitConv(3);
G12f    = fiberProps(4)*fiberUnitConv(4);
nu12f   = fiberProps(5)*fiberUnitConv(5);
nu23f   = fiberProps(6)*fiberUnitConv(6);
alpha1f = fiberProps(7)*fiberUnitConv(7);
alpha2f = fiberProps(8)*fiberUnitConv(8);

rhom    = matrixProps(1)*matrixUnitConv(1);
E1m     = matrixProps(2)*matrixUnitConv(2);
E2m     = matrixProps(3)*matrixUnitConv(3);
G12m    = matrixProps(4)*matrixUnitConv(4);
nu12m   = matrixProps(5)*matrixUnitConv(5);
nu23m   = matrixProps(6)*matrixUnitConv(6);
alpha1m = matrixProps(7)*matrixUnitConv(7);
alpha2m = matrixProps(8)*matrixUnitConv(8);
        
switch matPropAlg
    case 1
        %Rule of Mixtures
        [rhoc,E1,E2,nu12,nu21,G12,nu23,G23,alpha1,alpha2]=RoM(Vff,rhof,E1f,E2f,nu12f,alpha1f,rhom,E1m,E2m,nu12m,alpha1m);
    case 2
        %Halpsin-Tsai Method
        [rhoc,E1,E2,nu12,nu21,G12,nu23,G23,alpha1,alpha2]=HalpinTsai(Vff,rhof,E1f,E2f,nu12f,alpha1f,rhom,E1m,E2m,nu12m,alpha1m);
    case 3
        %Hashin Method
        [rhoc,E1,E2,nu12,nu21,G12,nu23,G23,alpha1,alpha2]=Hashin(Vff,rhof,E1f,E2f,nu12f,nu23f,alpha1f,alpha2f,rhom,E1m,E2m,nu12m,alpha1m);
    otherwise
        %Rule of Mixtures
        [rhoc,E1,E2,nu12,nu21,G12,nu23,G23,alpha1,alpha2]=RoM(Vff,rhof,E1f,E2f,nu12f,alpha1f,rhom,E1m,E2m,nu12m,alpha1m);
end

% fiber
switch fiberType
    case 1 % carbon
        writeABQorientation(abqpath,'Fiber-Orientation','NODES','none','RECTANGULAR',{strcat(num2str(Ncorners(2)),', ',num2str(Ncorners(4)),', ',num2str(Ncorners(1)))},'SE node (point a), NW node (point b), SW node (point c)');
        
        writeABQsolidsection(abqpath,'none','Fiber-Elements','Carbon-Fiber','none','Fiber-Orientation','Fiber-SectionControls','none','none','none','none',{'1.0'},'none');

        writeABQsectioncontrols(abqpath,'Fiber-SectionControls','none','none','none','none','none','ENHANCED','none','none','none','none','none','none','none','none',...
                                'none','none',{},'none');

        writeABQmaterial(abqpath,'Carbon-Fiber','none','none','none',{},'none');

        writeABQelastic(abqpath,'none','none','none','ENGINEERING CONSTANTS',...
                        {strcat(num2str(E2f*unitConvFactor(9), '%10.5e'),', ',num2str(E2f*unitConvFactor(9), '%10.5e'),', ',num2str(E1f*unitConvFactor(9), '%10.5e'),...
                        ', ',num2str(nu23f, '%10.5e'),', ',num2str((E2f/E1f)*nu12f, '%10.5e'),', ',num2str((E2f/E1f)*nu12f, '%10.5e'),...
                        ', ',num2str((0.5*E2f/(1+nu23f))*unitConvFactor(9), '%10.5e'),', ',num2str(G12f*unitConvFactor(9), '%10.5e'));...
                        num2str(G12f*unitConvFactor(9), '%10.5e')},...
                        'E2f E2f E1f nu23f nu21f nu31f G23f G21f G31f');

        writeABQdensity(abqpath,'none','none',{num2str(rhof*unitConvFactor(8), '%10.5e')},'rhof');

        writeABQexpansion(abqpath,'none','none','none','ORTHO','none','none',...
                          {strcat(num2str(alpha2f*unitConvFactor(10), '%10.5e'),', ',num2str(alpha2f*unitConvFactor(10), '%10.5e'),', ',num2str(alpha1f*unitConvFactor(10), '%10.5e'))},'alpha22f, alpha22f, alpha11f');

       %writeABQconductivity(abqpath,'none','none','ORTHO',...
       %                    {strcat(num2str(k22f*unitConvFactor(11), '%10.5e'),', ',num2str(k22f*unitConvFactor(11), '%10.5e'),', ',num2str(k11f*unitConvFactor(11), '%10.5e'))},'k22f, k22f, k11f');

       %writeABQspecificheat(abqpath,'none','none','none',{num2str(cvff*unitConvFactor(12), '%10.5e')},'cv');
       
    case 2 % glass
        writeABQsolidsection(abqpath,'none','Fiber-Elements','Glass-Fiber','none','none','Fiber-SectionControls','none','none','none','none',{'1.0'},'none');
        
        writeABQsectioncontrols(abqpath,'Fiber-SectionControls','none','none','none','none','none','ENHANCED','none','none','none','none','none','none','none','none',...
                                'none','none',{},'none');

        writeABQmaterial(abqpath,'Glass-Fiber','none','none','none',{},'none');

        writeABQelastic(abqpath,'none','none','none','ISOTROPIC',{strcat(num2str(E1f*unitConvFactor(9), '%10.5e'),', ',num2str(nu12f, '%10.5e'))},'Ef nuf');

        writeABQdensity(abqpath,'none','none',{num2str(rhof*unitConvFactor(8), '%10.5e')},'rhof');

        writeABQexpansion(abqpath,'none','none','none','ISO','none','none',{strcat(num2str(alpha1f*unitConvFactor(10), '%10.5e'))},'alphaf');
        
    otherwise
        writeABQorientation(abqpath,'Fiber-Orientation','NODES','none','RECTANGULAR',{strcat(num2str(Ncorners(2)),', ',num2str(Ncorners(4)),', ',num2str(Ncorners(1)))},'SE node (point a), NW node (point b), SW node (point c)');
        
        writeABQsolidsection(abqpath,'none','Fiber-Elements','Carbon-Fiber','none','Fiber-Orientation','Fiber-SectionControls','none','none','none','none',{'1.0'},'none');

        writeABQsectioncontrols(abqpath,'Fiber-SectionControls','none','none','none','none','none','ENHANCED','none','none','none','none','none','none','none','none',...
                                'none','none',{},'none');

        writeABQmaterial(abqpath,'Carbon-Fiber','none','none','none',{},'none');

        writeABQelastic(abqpath,'none','none','none','ENGINEERING CONSTANTS',...
                        {strcat(num2str(E2f*unitConvFactor(9), '%10.5e'),', ',num2str(E2f*unitConvFactor(9), '%10.5e'),', ',num2str(E1f*unitConvFactor(9), '%10.5e'),...
                        ', ',num2str(nu23f, '%10.5e'),', ',num2str((E2f/E1f)*nu12f, '%10.5e'),', ',num2str((E2f/E1f)*nu12f, '%10.5e'),...
                        ', ',num2str((0.5*E2f/(1+nu23f))*unitConvFactor(9), '%10.5e'),', ',num2str(G12f*unitConvFactor(9), '%10.5e'));...
                        num2str(G12f*unitConvFactor(9), '%10.5e')},...
                        'E2f E2f E1f nu23f nu21f nu31f G23f G21f G31f');

        writeABQdensity(abqpath,'none','none',{num2str(rhof*unitConvFactor(8), '%10.5e')},'rhof');

        writeABQexpansion(abqpath,'none','none','none','ORTHO','none','none',...
                          {strcat(num2str(alpha2f*unitConvFactor(10), '%10.5e'),', ',num2str(alpha2f*unitConvFactor(10), '%10.5e'),', ',num2str(alpha1f*unitConvFactor(10), '%10.5e'))},'alpha22f, alpha22f, alpha11f');
end

% matrix

writeABQsolidsection(abqpath,'none','Matrix-Elements','Matrix','none','none','Matrix-SectionControls','none','none','none','none',{'1.0'},'none');

writeABQsectioncontrols(abqpath,'Matrix-SectionControls','none','none','none','none','none','ENHANCED','none','none','none','none','none','none','none','none',...
                                'none','none',{},'none');

writeABQmaterial(abqpath,'Matrix','none','none','none',{},'none');

writeABQelastic(abqpath,'none','none','none','ISOTROPIC',{strcat(num2str(E1m*unitConvFactor(9), '%10.5e'),', ',num2str(nu12m, '%10.5e'))},'Em num');

writeABQdensity(abqpath,'none','none',{num2str(rhom*unitConvFactor(8), '%10.5e')},'rhom');

writeABQexpansion(abqpath,'none','none','none','ISO','none','none',{strcat(num2str(alpha1m*unitConvFactor(10), '%10.5e'))},'alpham');

if solverChoice==3 || solverChoice==4 %CZM & XFEM or VCCT & XFEM
    
    switch matrixType
        case 1
            matrixDamageProps = getValuesFromCSV(matDBfolder,strcat('EP','.csv'),5,0,6);
            matrixDamageUnitConv = getValuesFromCSV(matDBfolder,strcat('EP','.csv'),4,0,6);
        case 2
            matrixDamageProps = getValuesFromCSV(matDBfolder,strcat('HDPE','.csv'),5,0,6);
            matrixDamageUnitConv = getValuesFromCSV(matDBfolder,strcat('HDPE','.csv'),4,0,6);
        otherwise
            matrixDamageProps = getValuesFromCSV(matDBfolder,strcat('EP','.csv'),5,0,6);
            matrixDamageUnitConv = getValuesFromCSV(matDBfolder,strcat('EP','.csv'),4,0,6);
    end
    
    matrixMaxT1 = matrixDamageProps(1)*matrixDamageUnitConv(1);
    matrixMaxT2 = matrixDamageProps(2)*matrixDamageUnitConv(2);
    matrixMaxT3 = matrixDamageProps(3)*matrixDamageUnitConv(3);
    matrixGIc   = matrixDamageProps(4)*matrixDamageUnitConv(4);
    matrixGIIc  = matrixDamageProps(5)*matrixDamageUnitConv(5);
    matrixGIIIc = matrixDamageProps(6)*matrixDamageUnitConv(6);
    matrixEta   = matrixDamageProps(7)*matrixDamageUnitConv(7);

    writeABQdamageinitiation(abqpath,'QUADS','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none',...
                             {strcat(num2str(matrixMaxT1*unitConvFactor(9), '%10.5e'),', ',num2str(matrixMaxT2*unitConvFactor(9), '%10.5e'),', ',num2str(matrixMaxT3*unitConvFactor(9), '%10.5e'))},...
                             'maxT-normal maxT-in-plane-shear maxT-out-of-plane-shear');

    writeABQdamageevolution(abqpath,'ENERGY','none','none','none','BK','ENERGY',num2str(matrixEta, '%10.5e'),'LINEAR',...
                            {strcat(num2str(matrixGIc*unitConvFactor(13), '%10.5e'),', ',num2str(matrixGIIc*unitConvFactor(13), '%10.5e'),', ',num2str(matrixGIIIc*unitConvFactor(13), '%10.5e'))},...
                            'GIc GIIc GIIIc');
end

% bounding plies

if isUpperBounded || isLowerBounded
    
    % compute properties
    Qloc = locallaminaQ(E1,E2,nu12,nu21,G12);
    Q = laminaQ(phi,E1,E2,nu12,G12,nu23,G23);
    %E1,E2,nu12,nu21,G12,nu23,G23
    lamD1111 = Q(1,1);
    lamD1122 = Q(1,2);
    lamD1133 = Qloc(1,2);
    lamD1112 = Q(1,3);
    lamD2222 = Q(2,2);
    lamD2233 = E2*(nu23+(E2/E1)*nu12^2)/((1+nu23)*(1-nu23-2*(E2/E1)*nu12^2));
    lamD2212 = Q(2,3);
    lamD3333 = Qloc(2,2);
    lamD1212 = Q(3,3);
    lamD1313 = G23;
    lamD2323 = G23;
    
    D1111 = lamD1111;
    D1122 = lamD1133;
    D2222 = lamD3333;
    D1133 = lamD1122;
    D2233 = lamD2233;
    D3333 = lamD2222;
    D1112 = 0;
    D2212 = 0;
    D3312 = 0;
    D1212 = lamD1313;
    D1113 = lamD1112;
    D2213 = 0;
    D3313 = lamD2212;
    D1213 = 0;
    D1313 = lamD1212;
    D1123 = 0;
    D2223 = 0;
    D3323 = 0;
    D1223 = 0;
    D1323 = 0;
    D2323 = lamD2323;
    
    % write to file
    
    writeABQorientation(abqpath,'BoundingPly-Orientation','NODES','none','RECTANGULAR',{strcat(num2str(Ncorners(2)),', ',num2str(Ncorners(4)),', ',num2str(Ncorners(1)))},'SE node (point a), NW node (point b), SW node (point c)');
    
    if isUpperBounded && isLowerBounded
        writeABQsolidsection(abqpath,'none','BoundingPlies-Elements','BoundingPly','none','BoundingPly-Orientation','BoundingPly-SectionControls','none','none','none','none',{'1.0'},'none');
    elseif isUpperBounded
        writeABQsolidsection(abqpath,'none','UpperPly-Elements','BoundingPly','none','BoundingPly-Orientation','BoundingPly-SectionControls','none','none','none','none',{'1.0'},'none');    
    else
        writeABQsolidsection(abqpath,'none','LowerPly-Elements','BoundingPly','none','BoundingPly-Orientation','BoundingPly-SectionControls','none','none','none','none',{'1.0'},'none');    
    end
    
    writeABQsectioncontrols(abqpath,'BoundingPly-SectionControls','none','none','none','none','none','ENHANCED','none','none','none','none','none','none','none','none',...
                                'none','none',{},'none');
    
    writeABQmaterial(abqpath,'BoundingPly','none','none','none',{},'none');

    writeABQelastic(abqpath,'none','none','none','ANISOTROPIC',...
                     {strcat(num2str(D1111*unitConvFactor(9), '%10.5e'),', ',num2str(D1122*unitConvFactor(9), '%10.5e'),', ',num2str(D2222*unitConvFactor(9), '%10.5e'),', ',...
                             num2str(D1133*unitConvFactor(9), '%10.5e'),', ',num2str(D2233*unitConvFactor(9), '%10.5e'),', ',num2str(D3333*unitConvFactor(9), '%10.5e'),', ',...
                             num2str(D1112*unitConvFactor(9), '%10.5e'),', ',num2str(D2212*unitConvFactor(9), '%10.5e'));...
                      strcat(num2str(D3312*unitConvFactor(9), '%10.5e'),', ',num2str(D1212*unitConvFactor(9), '%10.5e'),', ',num2str(D1113*unitConvFactor(9), '%10.5e'),', ',...
                             num2str(D2213*unitConvFactor(9), '%10.5e'),', ',num2str(D3313*unitConvFactor(9), '%10.5e'),', ',num2str(D1213*unitConvFactor(9), '%10.5e'),', ',...
                             num2str(D1313*unitConvFactor(9), '%10.5e'),', ',num2str(D1123*unitConvFactor(9), '%10.5e'));...
                      strcat(num2str(D2223*unitConvFactor(9), '%10.5e'),', ',num2str(D3323*unitConvFactor(9), '%10.5e'),', ',num2str(D1223*unitConvFactor(9), '%10.5e'),', ',...
                             num2str(D1323*unitConvFactor(9), '%10.5e'),', ',num2str(D2323*unitConvFactor(9), '%10.5e'))},...
                     strcat('Abaqus: D1111 D1122 D2222 D1133 D2233 D3333 D1112 D2212\n**        D3312 D1212 D1113 D2213 D3313 D1213 D1313 D1123\n**        D2223 D3323 D1223 D1323 D2323\n',...
                         '** Lamina: D1111 D1133 D3333 D1122 D2233 D2222     0     0\n**            0 D1313 D1112     0 D2212     0 D1212     0\n**            0     0     0     0 D2323'));


    writeABQdensity(abqpath,'none','none',{num2str(rhoc*unitConvFactor(8), '%10.5e')},'rhoLam');

    writeABQexpansion(abqpath,'none','none','none','ORTHO','none','none',...
                          {strcat(num2str(alpha1*unitConvFactor(10), '%10.5e'),', ',num2str(alpha2*unitConvFactor(10), '%10.5e'),', ',num2str(alpha2*unitConvFactor(10), '%10.5e'))},'alpha1Lam, alpha2Lam, alpha2Lam');
                            
end

if matrixType==1 && fiberType==1
    cohesiveDamageProps = getValuesFromCSV(matDBfolder,strcat('EP-CF-interface','.csv'),2,0,9);
    cohesiveDamageUnitConv = getValuesFromCSV(matDBfolder,strcat('EP-CF-interface','.csv'),1,0,9);
elseif matrixType==1 && fiberType==2
    cohesiveDamageProps = getValuesFromCSV(matDBfolder,strcat('EP-GF-interface','.csv'),2,0,9);
    cohesiveDamageUnitConv = getValuesFromCSV(matDBfolder,strcat('EP-GF-interface','.csv'),1,0,9);
elseif matrixType==2 && fiberType==1
    cohesiveDamageProps = getValuesFromCSV(matDBfolder,strcat('HDPE-CF-interface','.csv'),2,0,9);
    cohesiveDamageUnitConv = getValuesFromCSV(matDBfolder,strcat('HDPE-CF-interface','.csv'),1,0,9);
elseif matrixType==2 && fiberType==2
    cohesiveDamageProps = getValuesFromCSV(matDBfolder,strcat('HDPE-GF-interface','.csv'),2,0,9);
    cohesiveDamageUnitConv = getValuesFromCSV(matDBfolder,strcat('HDPE-GF-interface','.csv'),1,0,9); 
else
    cohesiveDamageProps = getValuesFromCSV(matDBfolder,strcat('EP-CF-interface','.csv'),2,0,9);
    cohesiveDamageUnitConv = getValuesFromCSV(matDBfolder,strcat('EP-CF-interface','.csv'),1,0,9);
end

% Load Fiber/Matrix Interface Properties

Eint1 = cohesiveDamageProps(1)*cohesiveDamageUnitConv(1);
Eint2 = cohesiveDamageProps(2)*cohesiveDamageUnitConv(2);
Eint3 = cohesiveDamageProps(3)*cohesiveDamageUnitConv(3);
maxT1 = cohesiveDamageProps(4)*cohesiveDamageUnitConv(4);
maxT2 = cohesiveDamageProps(5)*cohesiveDamageUnitConv(5);
maxT3 = cohesiveDamageProps(6)*cohesiveDamageUnitConv(6);
GIc   = cohesiveDamageProps(7)*cohesiveDamageUnitConv(7);
GIIc  = cohesiveDamageProps(8)*cohesiveDamageUnitConv(8);
GIIIc = cohesiveDamageProps(9)*cohesiveDamageUnitConv(9);
eta   = cohesiveDamageProps(10)*cohesiveDamageUnitConv(10);
    
%% SURFACE AND FRACTURE SECTION

writeABQsurfacesec(abqpath);

if element==1 % quadrilaterals
    % fiber surface
    writeABQsurface(abqpath,'Fiber-Surface','none','none','none','none','none','none','none','none','ELEMENT','none','none','none','none',...
                    {'FiberSurface-Elements, S1'},'fiber surface');

    % matrix surface at fiber interface
    writeABQsurface(abqpath,'Matrix-AtFiberInterface-Surface','none','none','none','none','none','none','none','none','ELEMENT','none','none','none','none',...
                    {'MatrixSurfaceAtFiberInterface-Elements, S3'},'matrix surface at fiber interface');
else % triangles
    % fiber surface
    writeABQsurface(abqpath,'Fiber-Surface','none','none','none','none','none','none','none','none','ELEMENT','none','none','none','none',...
                    {'FiberSurface-Elements'},'fiber surface');

    % matrix surface at fiber interface
    writeABQsurface(abqpath,'Matrix-AtFiberInterface-Surface','none','none','none','none','none','none','none','none','ELEMENT','none','none','none','none',...
                    {'MatrixSurfaceAtFiberInterface-Elements'},'matrix surface at fiber interface');
end

if isUpperBounded
    % upper side matrix surface
    writeABQsurface(abqpath,'Matrix-AtUpperPlyInterface-Surface','none','none','none','none','none','none','none','YES','ELEMENT','none','none','none','none',...
                    {'MatrixSurfaceAtUpperPlyInterface-Elements'},'upper side matrix surface');

    % upper ply surface at matrix interface
    writeABQsurface(abqpath,'UpperPly-AtMatrixInterface-Surface','none','none','none','none','none','none','none','YES','ELEMENT','none','none','none','none',...
                    {'UpperPlyLowerSurface-Elements'},'upper ply surface at matrix interface');
    % tie constraint
    writeABQtie(abqpath,'UpperTieConstraint','none','none','YES','none','none','none','none','SURFACE TO SURFACE',...
                {'Matrix-AtUpperPlyInterface-Surface';'UpperPly-AtMatrixInterface-Surface'},'tie constraint between matrix (slave) and upper ply (master)');
end

if isLowerBounded
    % upper side matrix surface
    writeABQsurface(abqpath,'Matrix-AtLowerPlyInterface-Surface','none','none','none','none','none','none','none','YES','ELEMENT','none','none','none','none',...
                    {'MatrixSurfaceAtLowerPlyInterface-Elements'},'upper side matrix surface');
    % upper ply surface at matrix interface
    writeABQsurface(abqpath,'LowerPly-AtMatrixInterface-Surface','none','none','none','none','none','none','none','YES','ELEMENT','none','none','none','none',...
                    {'LowerPlyUpperSurface-Elements'},'upper ply surface at matrix interface');
    % tie constraint
    writeABQtie(abqpath,'LowerTieConstraint','none','none','YES','none','none','none','none','SURFACE TO SURFACE',...
                {'Matrix-AtLowerPlyInterface-Surface';'LowerPly-AtMatrixInterface-Surface'},'tie constraint between matrix (slave) and upper ply (master)');
end

%Fiber/Matrix Interface Contact Interaction Definition

writeABQcontactpair(abqpath,'FiberMatrixFractInterface','none','none','none','none','none','none','none','SMALL SLIDING','none','none','none','none','none','SURFACE TO SURFACE',...
                             {'Matrix-AtFiberInterface-Surface, Fiber-Surface'},'slave, master');

writeABQsurfaceinteraction(abqpath,'FiberMatrixFractInterface','none','none','none','none','none','none',{'1.0'},'Out-of-plane thickness of the surface');

writeABQfriction(abqpath,'none','none','none','0.005','none','none','none','none','none','none','none','none','none',{num2str(interfaceFriction, '%10.5e')},'friction coefficient');


if solverChoice==2 || solverChoice==3 %Cohesive Elements Method
    
    writeABQcohesivesection(abqpath,'Cohesive-Elements','FiberMatrixInterface','TRACTION SEPARATION','CohesiveLayer-Controls','none','none','SPECIFIED',{'1.0';'1.0'},'Fiber/Matrix Interface Cohesive Properties');

    writeABQsectioncontrols(abqpath,'CohesiveLayer-Controls','none','none','none','none','YES','none','none','none','none','none','1.0','none','none','none','none','none',{},'none');

    writeABQmaterial(abqpath,'FiberMatrixInterface','none','none','none',{},'none');

    writeABQelastic(abqpath,'none','none','none','TRACTION',...
                    {strcat(num2str(Eint1*unitConvFactor(14), '%10.5e'),', ',num2str(Eint2*unitConvFactor(14), '%10.5e'),', ',num2str(Eint3*unitConvFactor(14), '%10.5e'))},'Einterface Einterface Einterface');

    writeABQdamageinitiation(abqpath,'QUADS','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none',...
                             {strcat(num2str(maxT1*unitConvFactor(9), '%10.5e'),', ',num2str(maxT2*unitConvFactor(9), '%10.5e'),', ',num2str(maxT3*unitConvFactor(9), '%10.5e'))},...
                             'maxT-normal maxT-in-plane-shear maxT-out-of-plane-shear');

    writeABQdamageevolution(abqpath,'ENERGY','none','none','none','BK','ENERGY',num2str(eta, '%10.5e'),'LINEAR',...
                            {strcat(num2str(GIc*unitConvFactor(13), '%10.5e'),', ',num2str(GIIc*unitConvFactor(13), '%10.5e'),', ',num2str(GIIIc*unitConvFactor(13), '%10.5e'))},...
                            'GIc GIIc GIIIc');
end

if solverChoice==3 || solverChoice==4 %CZM & XFEM or VCCT & XFEM
    
    writeABQenrichment(abqpath,'Matrix-Elements','MatrixFracture','none','MatrixCracks-Surfaces','PROPAGATION CRACK',{},'none');
    
    writeABQsurfaceinteraction(abqpath,'MatrixCracks-Surfaces','none','none','none','none','none','none',{'1.0'},'Out-of-plane thickness');
    
    writeABQsurfacebehavior(abqpath,'none','none','none','none','none',{},'');
    
    if solverChoice==4
        writeABQfracturecriterion(abqpath,'none','none','VCCT','none','BK','none','MTS','none','none','0.2','0.0',...
                                  {strcat(num2str(matrixGIc*unitConvFactor(13), '%10.5e'),', ',num2str(matrixGIIc*unitConvFactor(13), '%10.5e'),', ',num2str(matrixGIIIc*unitConvFactor(13), '%10.5e'),', ',num2str(matrixEta, '%10.5e'))},...
                                   'GIc GIIc GIIIc eta');
    end

    %writeABQsurface(abqpath,'MatrixCrackInterfaces','none','none','none','none','none','none','none','none','XFEM','none','none','none','none',{'MatrixFracture'},'enriched sets');
    
end

%% BOUNDARY CONDITIONS SECTION
 
writeABQbcsec(abqpath);
    
if modType==3 % Periodic boundary condition
    
    writeABQequation(abqpath,'none',{'UpperSide-Nodes-without-Corners,1,1,LowerSide-Nodes-without-Corners,1,-1'},'none');
    
    writeABQequation(abqpath,'none',{'LeftSide-Nodes-with-Corners,2,1,RightSide-Nodes-with-Corners,2,-1'},'none');
    
    writeABQequation(abqpath,'none',{'UpperSide-Nodes-without-Corners,2,1,LowerSide-Nodes-without-Corners,2,-1'},'none');

elseif modType==4 % Only rigidity constraints (MPC)
    if isHomogeneousOnUpper
        
        writeABQmpc(abqpath,'none','none','none',...
                    {strcat('SLIDER, UpperSide-Nodes-without-Corners, NW-CornerNode, NE-CornerNode')},...
                    'MPC type, node numbers or node sets');

                
    elseif isSymmOnUpper
        
        writeABQboundary(abqpath,'none','none','none','none','none','none','none','none','none','none','none','none',...
                         {'UpperSide-Nodes-without-Corners,YSYMM';...
                          'NW-CornerNode,YSYMM';...
                          'NE-CornerNode,YSYMM'},'none');
                      
    end
    if isHomogeneousOnLower
        
        writeABQmpc(abqpath,'none','none','none',...
                    {strcat('SLIDER, LowerSide-Nodes-without-Corners, SW-CornerNode, SE-CornerNode')},...
                    'MPC type, node numbers or node sets');

               
    elseif isSymmOnLower
        
        writeABQboundary(abqpath,'none','none','none','none','none','none','none','none','none','none','none','none',...
                         {'LowerSide-Nodes-without-Corners,YSYMM';...
                          'SW-CornerNode,YSYMM';...
                          'SE-CornerNode,YSYMM'},'none');
        
    end    
else
    if isHomogeneousOnUpper
        
%         writeABQmpc(abqpath,'none','none','none',...
%                     {strcat('SLIDER, UpperSide-Nodes-without-Corners, NW-CornerNode, NE-CornerNode')},...
%                     'MPC type, node numbers or node sets');

        equationData = {};
        for i=1:length(Nup)
            offset = length(equationData);
            equationData{offset+1,1} = {'2'};
            equationData{offset+2,1} = {strcat(num2str(Nup(i)),',1,1,',num2str(Ncorners(3)),',1,',num2str(-nodes(Nup(i),1)/nodes(Ncorners(3),1)))};
        end
           
        writeABQequation(abqpath,'none',equationData,'none');

        clear equationData
        
        equationData = {};
        for i=1:length(Nup)
            offset = length(equationData);
            equationData{offset+1,1} = {'2'};
            equationData{offset+2,1} = {strcat(num2str(Nup(i)),',2,1,',num2str(Ncorners(3)),',2,-1')};
        end
           
        writeABQequation(abqpath,'none',equationData,'none');

        clear equationData
        
    elseif isSymmOnUpper
        
        writeABQboundary(abqpath,'none','none','none','none','none','none','none','none','none','none','none','none',...
                         {'UpperSide-Nodes-without-Corners,YSYMM';...
                          'NW-CornerNode,YSYMM';...
                          'NE-CornerNode,YSYMM'},'none');
                      
    end
    if isHomogeneousOnLower
        
%         writeABQmpc(abqpath,'none','none','none',...
%                     {strcat('SLIDER, LowerSide-Nodes-without-Corners, SW-CornerNode, SE-CornerNode')},...
%                     'MPC type, node numbers or node sets');

        equationData = {};
        for i=1:length(Ndown)
            offset = length(equationData);
            equationData{offset+1,1} = {'2'};
            equationData{offset+2,1} = {strcat(num2str(Ndown(i)),',1,1,',num2str(Ncorners(2)),',1,',num2str(-nodes(Ndown(i),1)/nodes(Ncorners(2),1)))};
        end

        writeABQequation(abqpath,'none',equationData,'none');

        clear equationData
        
        equationData = {};
        for i=1:length(Ndown)
            offset = length(equationData);
            equationData{offset+1,1} = {'2'};
            equationData{offset+2,1} = {strcat(num2str(Ndown(i)),',2,1,',num2str(Ncorners(2)),',2,-1')};
        end

        writeABQequation(abqpath,'none',equationData,'none');

        clear equationData
        
    elseif isSymmOnLower
        
        writeABQboundary(abqpath,'none','none','none','none','none','none','none','none','none','none','none','none',...
                         {'LowerSide-Nodes-without-Corners,YSYMM';...
                          'SW-CornerNode,YSYMM';...
                          'SE-CornerNode,YSYMM'},'none');
        
    end
end

%% INITIAL CONDITIONS SECTION

if solverChoice==1 || solverChoice==4
    
    writeABQicsec(abqpath);

    writeABQinitialconditions(abqpath,'CONTACT','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none','none',...
                          {'Matrix-AtFiberInterface-Surface,Fiber-Surface,Gamma3-Nodes'},'none');

end

%% LOAD SECTION

writeABQloadsec(abqpath);

writeABQstep(abqpath,'RAMP','YES','none','none','10000','LoadStep','YES','none','none','none',{},'none');

writeABQstatic(abqpath,'none','none','none','none','none','none','none','none','none',...
               {'1e-4,1.0,1e-8,1e-2'},...
               'Initial time increment, Time period of the step, Minimum time increment allowed, Maximum time increment allowed');

boundaryData ={strcat('RightSide-Nodes-without-Corners,1,,',num2str(epsxx*nodes(Ncorners(2),1)));...
               strcat('SE-CornerNode,1,,',num2str(epsxx*nodes(Ncorners(2),1)));...
               strcat('NE-CornerNode,1,,',num2str(epsxx*nodes(Ncorners(2),1)));...
               strcat('LeftSide-Nodes-without-Corners,1,,',num2str(-epsxx*nodes(Ncorners(2),1)));...
               strcat('SW-CornerNode,1,,',num2str(-epsxx*nodes(Ncorners(2),1)));...
               strcat('NW-CornerNode,1,,',num2str(-epsxx*nodes(Ncorners(2),1)))};

if isUpperBounded
    offset = length(boundaryData);
    boundaryData{offset+1,1} = strcat('RightSide-UpperPly-Nodes-without-Corners,1,,',num2str(epsxx*nodes(Ncorners(2),1)));
    boundaryData{offset+2,1} = strcat('SE-UpperPly-CornerNode,1,,',num2str(epsxx*nodes(Ncorners(2),1)));
    boundaryData{offset+3,1} = strcat('NE-Matrix-CornerNode,1,,',num2str(epsxx*nodes(Ncorners(2),1)));
    boundaryData{offset+4,1} = strcat('LeftSide-UpperPly-Nodes-without-Corners,1,,',num2str(-epsxx*nodes(Ncorners(2),1)));
    boundaryData{offset+5,1} = strcat('SW-UpperPly-CornerNode,1,,',num2str(-epsxx*nodes(Ncorners(2),1)));
    boundaryData{offset+6,1} = strcat('NW-Matrix-CornerNode,1,,',num2str(-epsxx*nodes(Ncorners(2),1)));
end
if isLowerBounded
    offset = length(boundaryData);
    boundaryData{offset+1,1} = strcat('RightSide-LowerPly-Nodes-without-Corners,1,,',num2str(epsxx*nodes(Ncorners(2),1)));
    boundaryData{offset+2,1} = strcat('NE-LowerPly-CornerNode,1,,',num2str(epsxx*nodes(Ncorners(2),1)));
    boundaryData{offset+3,1} = strcat('SE-Matrix-CornerNode,1,,',num2str(epsxx*nodes(Ncorners(2),1)));
    boundaryData{offset+4,1} = strcat('LeftSide-LowerPly-Nodes-without-Corners,1,,',num2str(-epsxx*nodes(Ncorners(2),1)));
    boundaryData{offset+5,1} = strcat('NW-LowerPly-CornerNode,1,,',num2str(-epsxx*nodes(Ncorners(2),1)));
    boundaryData{offset+6,1} = strcat('SW-Matrix-CornerNode,1,,',num2str(-epsxx*nodes(Ncorners(2),1)));
end

writeABQboundary(abqpath,'none','none','none','none','none','MOD','none','none','DISPLACEMENT','none','none','none',boundaryData,'');

if dT~=0
    writeABQtemperature(abqpath,'none','none','MOD','none','none','none','none','none','none','none','none','none','none','none','none',...
                        {strcat('All-Nodes,',num2str(dT))},'');
end

if solverChoice==1 %VCCT
    
    writeABQdebond(abqpath,'Fiber-Surface','Matrix-AtFiberInterface-Surface','none','none','BOTH','none',{},'');
    
    writeABQfracturecriterion(abqpath,'none','none','VCCT','none','BK','none','none','none','none','none','none',...
                              {strcat(num2str(GIc*unitConvFactor(13), '%10.5e'),', ',num2str(GIIc*unitConvFactor(13), '%10.5e'),', ',num2str(GIIIc*unitConvFactor(13), '%10.5e'),',',num2str(eta, '%10.5e'))},...
                              'GIc GIIc GIIIc eta');
                          
elseif solverChoice==3 %CZM & XFEM
    
    writeABQenrichmentactivation(abqpath,'MatrixFracture','ON','none',{},'');
    
elseif solverChoice==4 %VCCT & XFEM
    
    writeABQdebond(abqpath,'Fiber-Surface','Matrix-AtFiberInterface-Surface','none','none','BOTH','none',{},'');
    
    writeABQfracturecriterion(abqpath,'none','none','VCCT','none','BK','none','none','none','none','none','none',...
                              {strcat(num2str(GIc*unitConvFactor(13), '%10.5e'),', ',num2str(GIIc*unitConvFactor(13), '%10.5e'),', ',num2str(GIIIc*unitConvFactor(13), '%10.5e'),',',num2str(eta, '%10.5e'))},...
                              'GIc GIIc GIIIc eta');
                          
    writeABQenrichmentactivation(abqpath,'MatrixFracture','ON','none',{},'');
    
end

%% OUTPUT SECTION

writeABQoutsec(abqpath);

% output to .fil

if requestFIL
    writeABQfileformat(abqpath,'ASCII','none',{},'');

    writeABQcontactfile(abqpath,'none','Fiber-Surface','none','Matrix-AtFiberInterface-Surface',{},'none');

    if isLowerBounded
        writeABQcontactfile(abqpath,'none','LowerPly-AtMatrixInterface-Surface','none','Matrix-AtLowerPlyInterface-Surface',{},'none');
    end
    if isUpperBounded
        writeABQcontactfile(abqpath,'none','UpperPly-AtMatrixInterface-Surface','none','Matrix-AtUpperPlyInterface-Surface',{},'none');
    end

    writeABQelfile(abqpath,'YES','Matrix-Elements','none','none','none','none','none',{'COORD,S,SP,SINV,E,EP,NE,NEP';'LE,LEP,EE,EEP,IE,IEP,THE,THEP';'ENER,TEMP'},'none');

    writeABQelfile(abqpath,'YES','Fiber-Elements','none','none','none','none','none',{'COORD,S,SP,SINV,E,EP,NE,NEP';'LE,LEP,EE,EEP,IE,IEP,THE,THEP';'ENER,TEMP'},'none');

    if isLowerBounded
        writeABQelfile(abqpath,'YES','LowerPly-Elements','none','none','none','none','none',{'COORD,S,SP,SINV,E,EP,NE,NEP';'LE,LEP,EE,EEP,IE,IEP,THE,THEP';'ENER,TEMP'},'none');
    end
    if isUpperBounded
        writeABQelfile(abqpath,'YES','UpperPly-Elements','none','none','none','none','none',{'COORD,S,SP,SINV,E,EP,NE,NEP';'LE,LEP,EE,EEP,IE,IEP,THE,THEP';'ENER,TEMP'},'none');
    end
    if isCohesive
        writeABQelfile(abqpath,'YES','Cohesive-Elements','none','none','none','none','none',{'DMICRT'},'none');
        writeABQelfile(abqpath,'YES','Cohesive-Elements','none','none','none','none','none',{'SDEG'},'none');
        writeABQelfile(abqpath,'YES','Cohesive-Elements','none','none','none','none','none',{'STATUS'},'none');
    end

    writeABQenergyfile(abqpath,'Matrix-Elements','none',{},'none');
    writeABQenergyfile(abqpath,'Fiber-Elements','none',{},'none');
    if isLowerBounded
        writeABQenergyfile(abqpath,'LowerPly-Elements','none',{},'none');
    end
    if isLowerBounded
        writeABQenergyfile(abqpath,'UpperPly-Elements','none',{},'none');
    end

    writeABQnodefile(abqpath,'none','YES','none','none','All-Nodes',{'COORD,U,RF,CF,TF,VF'},'none');

    if dT~=0
        writeABQnodefile(abqpath,'none','YES','none','none','All-Nodes',{'NT'},'none');
    end
end

% output to .dat

if requestDAT
    writeABQcontactprint(abqpath,'none','Fiber-Surface','none','Matrix-AtFiberInterface-Surface','none','none',{},'none');

    if isLowerBounded
        writeABQcontactprint(abqpath,'none','LowerPly-AtMatrixInterface-Surface','none','Matrix-AtLowerPlyInterface-Surface','none','none',{},'none');
    end
    if isUpperBounded
        writeABQcontactprint(abqpath,'none','UpperPly-AtMatrixInterface-Surface','none','Matrix-AtUpperPlyInterface-Surface','none','none',{},'none');
    end

    % Abaqus accepts max 9 output requests in a single table
    writeABQelprint(abqpath,'Matrix-Elements','none','none','none','none','none','none','none',{'COORD'},'none');
    writeABQelprint(abqpath,'Matrix-Elements','none','none','none','none','none','none','none',{'S'},'none');
    writeABQelprint(abqpath,'Matrix-Elements','none','none','none','none','none','none','none',{'SP'},'none');
    writeABQelprint(abqpath,'Matrix-Elements','none','none','none','none','none','none','none',{'SINV'},'none');
    writeABQelprint(abqpath,'Matrix-Elements','none','none','none','none','none','none','none',{'E'},'none');
    writeABQelprint(abqpath,'Matrix-Elements','none','none','none','none','none','none','none',{'EP'},'none');
    writeABQelprint(abqpath,'Matrix-Elements','none','none','none','none','none','none','none',{'NE'},'none');
    writeABQelprint(abqpath,'Matrix-Elements','none','none','none','none','none','none','none',{'NEP'},'none');
    writeABQelprint(abqpath,'Matrix-Elements','none','none','none','none','none','none','none',{'LE'},'none');
    writeABQelprint(abqpath,'Matrix-Elements','none','none','none','none','none','none','none',{'LEP'},'none');
    writeABQelprint(abqpath,'Matrix-Elements','none','none','none','none','none','none','none',{'EE'},'none');
    writeABQelprint(abqpath,'Matrix-Elements','none','none','none','none','none','none','none',{'EEP'},'none');
    writeABQelprint(abqpath,'Matrix-Elements','none','none','none','none','none','none','none',{'IE'},'none');
    writeABQelprint(abqpath,'Matrix-Elements','none','none','none','none','none','none','none',{'IEP'},'none');
    writeABQelprint(abqpath,'Matrix-Elements','none','none','none','none','none','none','none',{'THE'},'none');
    writeABQelprint(abqpath,'Matrix-Elements','none','none','none','none','none','none','none',{'THEP'},'none');
    writeABQelprint(abqpath,'Matrix-Elements','none','none','none','none','none','none','none',{'ENER'},'none');
    writeABQelprint(abqpath,'Matrix-Elements','none','none','none','none','none','none','none',{'TEMP'},'none');

    writeABQelprint(abqpath,'Fiber-Elements','none','none','none','none','none','none','none',{'COORD'},'none');
    writeABQelprint(abqpath,'Fiber-Elements','none','none','none','none','none','none','none',{'S'},'none');
    writeABQelprint(abqpath,'Fiber-Elements','none','none','none','none','none','none','none',{'SP'},'none');
    writeABQelprint(abqpath,'Fiber-Elements','none','none','none','none','none','none','none',{'SINV'},'none');
    writeABQelprint(abqpath,'Fiber-Elements','none','none','none','none','none','none','none',{'E'},'none');
    writeABQelprint(abqpath,'Fiber-Elements','none','none','none','none','none','none','none',{'EP'},'none');
    writeABQelprint(abqpath,'Fiber-Elements','none','none','none','none','none','none','none',{'NE'},'none');
    writeABQelprint(abqpath,'Fiber-Elements','none','none','none','none','none','none','none',{'NEP'},'none');
    writeABQelprint(abqpath,'Fiber-Elements','none','none','none','none','none','none','none',{'LE'},'none');
    writeABQelprint(abqpath,'Fiber-Elements','none','none','none','none','none','none','none',{'LEP'},'none');
    writeABQelprint(abqpath,'Fiber-Elements','none','none','none','none','none','none','none',{'EE'},'none');
    writeABQelprint(abqpath,'Fiber-Elements','none','none','none','none','none','none','none',{'EEP'},'none');
    writeABQelprint(abqpath,'Fiber-Elements','none','none','none','none','none','none','none',{'IE'},'none');
    writeABQelprint(abqpath,'Fiber-Elements','none','none','none','none','none','none','none',{'IEP'},'none');
    writeABQelprint(abqpath,'Fiber-Elements','none','none','none','none','none','none','none',{'THE'},'none');
    writeABQelprint(abqpath,'Fiber-Elements','none','none','none','none','none','none','none',{'THEP'},'none');
    writeABQelprint(abqpath,'Fiber-Elements','none','none','none','none','none','none','none',{'ENER'},'none');
    writeABQelprint(abqpath,'Fiber-Elements','none','none','none','none','none','none','none',{'TEMP'},'none');

    if isLowerBounded
        writeABQelprint(abqpath,'LowerPly-Elements','none','none','none','none','none','none','none',{'COORD'},'none');
        writeABQelprint(abqpath,'LowerPly-Elements','none','none','none','none','none','none','none',{'S'},'none');
        writeABQelprint(abqpath,'LowerPly-Elements','none','none','none','none','none','none','none',{'SP'},'none');
        writeABQelprint(abqpath,'LowerPly-Elements','none','none','none','none','none','none','none',{'SINV'},'none');
        writeABQelprint(abqpath,'LowerPly-Elements','none','none','none','none','none','none','none',{'E'},'none');
        writeABQelprint(abqpath,'LowerPly-Elements','none','none','none','none','none','none','none',{'EP'},'none');
        writeABQelprint(abqpath,'LowerPly-Elements','none','none','none','none','none','none','none',{'NE'},'none');
        writeABQelprint(abqpath,'LowerPly-Elements','none','none','none','none','none','none','none',{'NEP'},'none');
        writeABQelprint(abqpath,'LowerPly-Elements','none','none','none','none','none','none','none',{'LE'},'none');
        writeABQelprint(abqpath,'LowerPly-Elements','none','none','none','none','none','none','none',{'LEP'},'none');
        writeABQelprint(abqpath,'LowerPly-Elements','none','none','none','none','none','none','none',{'EE'},'none');
        writeABQelprint(abqpath,'LowerPly-Elements','none','none','none','none','none','none','none',{'EEP'},'none');
        writeABQelprint(abqpath,'LowerPly-Elements','none','none','none','none','none','none','none',{'IE'},'none');
        writeABQelprint(abqpath,'LowerPly-Elements','none','none','none','none','none','none','none',{'IEP'},'none');
        writeABQelprint(abqpath,'LowerPly-Elements','none','none','none','none','none','none','none',{'THE'},'none');
        writeABQelprint(abqpath,'LowerPly-Elements','none','none','none','none','none','none','none',{'THEP'},'none');
        writeABQelprint(abqpath,'LowerPly-Elements','none','none','none','none','none','none','none',{'ENER'},'none');
        writeABQelprint(abqpath,'LowerPly-Elements','none','none','none','none','none','none','none',{'TEMP'},'none');
    end
    if isUpperBounded
        writeABQelprint(abqpath,'UpperPly-Elements','none','none','none','none','none','none','none',{'COORD'},'none');
        writeABQelprint(abqpath,'UpperPly-Elements','none','none','none','none','none','none','none',{'S'},'none');
        writeABQelprint(abqpath,'UpperPly-Elements','none','none','none','none','none','none','none',{'SP'},'none');
        writeABQelprint(abqpath,'UpperPly-Elements','none','none','none','none','none','none','none',{'SINV'},'none');
        writeABQelprint(abqpath,'UpperPly-Elements','none','none','none','none','none','none','none',{'E'},'none');
        writeABQelprint(abqpath,'UpperPly-Elements','none','none','none','none','none','none','none',{'EP'},'none');
        writeABQelprint(abqpath,'UpperPly-Elements','none','none','none','none','none','none','none',{'NE'},'none');
        writeABQelprint(abqpath,'UpperPly-Elements','none','none','none','none','none','none','none',{'NEP'},'none');
        writeABQelprint(abqpath,'UpperPly-Elements','none','none','none','none','none','none','none',{'LE'},'none');
        writeABQelprint(abqpath,'UpperPly-Elements','none','none','none','none','none','none','none',{'LEP'},'none');
        writeABQelprint(abqpath,'UpperPly-Elements','none','none','none','none','none','none','none',{'EE'},'none');
        writeABQelprint(abqpath,'UpperPly-Elements','none','none','none','none','none','none','none',{'EEP'},'none');
        writeABQelprint(abqpath,'UpperPly-Elements','none','none','none','none','none','none','none',{'IE'},'none');
        writeABQelprint(abqpath,'UpperPly-Elements','none','none','none','none','none','none','none',{'IEP'},'none');
        writeABQelprint(abqpath,'UpperPly-Elements','none','none','none','none','none','none','none',{'THE'},'none');
        writeABQelprint(abqpath,'UpperPly-Elements','none','none','none','none','none','none','none',{'THEP'},'none');
        writeABQelprint(abqpath,'UpperPly-Elements','none','none','none','none','none','none','none',{'ENER'},'none');
        writeABQelprint(abqpath,'UpperPly-Elements','none','none','none','none','none','none','none',{'TEMP'},'none');
    end
    if isCohesive
        writeABQelprint(abqpath,'Cohesive-Elements','none','none','none','none','none','none','none',{'MAXSCRT'},'none');
        writeABQelprint(abqpath,'Cohesive-Elements','none','none','none','none','none','none','none',{'QUADSCRT'},'none');
        writeABQelprint(abqpath,'Cohesive-Elements','none','none','none','none','none','none','none',{'DMICRT'},'none');
        writeABQelprint(abqpath,'Cohesive-Elements','none','none','none','none','none','none','none',{'SDEG'},'none');
        writeABQelprint(abqpath,'Cohesive-Elements','none','none','none','none','none','none','none',{'STATUS'},'none');
    end

    writeABQenergyprint(abqpath,'Matrix-Elements','none',{},'none');
    writeABQenergyprint(abqpath,'Fiber-Elements','none',{},'none');
    if isLowerBounded
        writeABQenergyprint(abqpath,'LowerPly-Elements','none',{},'none');
    end
    if isLowerBounded
        writeABQenergyprint(abqpath,'UpperPly-Elements','none',{},'none');
    end

    writeABQnodeprint(abqpath,'none','YES','none','none','All-Nodes','NO','NO',{'COORD'},'none');
    writeABQnodeprint(abqpath,'none','YES','none','none','All-Nodes','NO','NO',{'U,RF'},'none');
    writeABQnodeprint(abqpath,'none','YES','none','none','All-Nodes','NO','NO',{'CF,TF'},'none');

    if dT~=0
        writeABQnodeprint(abqpath,'none','YES','none','none','All-Nodes','NO','NO',{'NT'},'none');
    end
end

% output to .odb

if requestODB
    
    writeABQoutput(abqpath,'YES','none','none','none','none','none','none','none','none','none','none','none','none',{},'none');

    writeABQoutput(abqpath,'none','FIELD','none','none','none','FieldData','10','none','none','none','none','ALL','none',{},'none');

    writeABQoutput(abqpath,'none','none','HISTORY','none','none','HistoryData','none','none','none','none','none','none','none',{},'none');

    writeABQcontactoutput(abqpath,'none','none','none','none','none','ALL','Fiber-Surface','Matrix-AtFiberInterface-Surface',{},'none');

    if isUpperBounded
        writeABQcontactoutput(abqpath,'none','none','none','none','none','ALL','UpperPly-AtMatrixInterface-Surface','Matrix-AtUpperPlyInterface-Surface',{},'none');
    end
    if isLowerBounded
        writeABQcontactoutput(abqpath,'none','none','none','none','none','ALL','LowerPly-AtMatrixInterface-Surface','Matrix-AtLowerPlyInterface-Surface',{},'none');
    end

    if isCohesive
        writeABQelementoutput(abqpath,'Cohesive-Elements','none','YES','none','none','none','none',{'MAXSCRT,QUADSCRT,DMICRT,SDEG,STATUS'},'none');
    else
        writeABQcontactoutput(abqpath,'none','none','none','none','none','none','Fiber-Surface','Matrix-AtFiberInterface-Surface',{'DBT,DBS,DBSF,BDSTAT,CSDMG,OPENBC,CRSTS,ENRRT,EFENRRTR'},'none');
    end

    if solverChoice==3 || solverChoice==4
        writeABQnodeoutput(abqpath,'Matrix-Nodes','none','none','none','none',{'PHILSM,PSILSM'},'none');
        %if element==1 && order==1
            %writeABQcontactoutput(abqpath,'none','none','MatrixCrackInterfaces','none','none','none','none','none',{'CRKDISP,CSDMG,CRKSTRESS'},'none');
        %end
        writeABQelementoutput(abqpath,'Matrix-Elements','none','YES','none','none','none','none',{'STATUSXFEM'},'none');
    end

    if solverChoice==4
        writeABQelementoutput(abqpath,'Matrix-Elements','none','YES','none','none','none','none',{'ENRRTXFEM'},'none');
    end

    writeABQnodeoutput(abqpath,'RightSide-Nodes-without-Corners','none','none','none','none',{'U,RF'},'none');
    writeABQnodeoutput(abqpath,'SE-CornerNode','none','none','none','none',{'U,RF'},'none');
    writeABQnodeoutput(abqpath,'NE-CornerNode','none','none','none','none',{'U,RF'},'none');
    writeABQnodeoutput(abqpath,'LeftSide-Nodes-without-Corners','none','none','none','none',{'U,RF'},'none');
    writeABQnodeoutput(abqpath,'SW-CornerNode','none','none','none','none',{'U,RF'},'none');
    writeABQnodeoutput(abqpath,'NW-CornerNode','none','none','none','none',{'U,RF'},'none');

    if isUpperBounded
        writeABQnodeoutput(abqpath,'RightSide-UpperPly-Nodes-without-Corners','none','none','none','none',{'U,RF'},'none');
        writeABQnodeoutput(abqpath,'SE-UpperPly-CornerNode','none','none','none','none',{'U,RF'},'none');
        writeABQnodeoutput(abqpath,'NE-Matrix-CornerNode','none','none','none','none',{'U,RF'},'none');
        writeABQnodeoutput(abqpath,'LeftSide-UpperPly-Nodes-without-Corners','none','none','none','none',{'U,RF'},'none');
        writeABQnodeoutput(abqpath,'SW-UpperPly-CornerNode','none','none','none','none',{'U,RF'},'none');
        writeABQnodeoutput(abqpath,'NW-Matrix-CornerNode','none','none','none','none',{'U,RF'},'none');
    end
    if isLowerBounded
        writeABQnodeoutput(abqpath,'RightSide-LowerPly-Nodes-without-Corners','none','none','none','none',{'U,RF'},'none');
        writeABQnodeoutput(abqpath,'NE-LowerPly-CornerNode','none','none','none','none',{'U,RF'},'none');
        writeABQnodeoutput(abqpath,'SE-Matrix-CornerNode','none','none','none','none',{'U,RF'},'none');
        writeABQnodeoutput(abqpath,'LeftSide-LowerPly-Nodes-without-Corners','none','none','none','none',{'U,RF'},'none');
        writeABQnodeoutput(abqpath,'NW-LowerPly-CornerNode','none','none','none','none',{'U,RF'},'none');
        writeABQnodeoutput(abqpath,'SW-Matrix-CornerNode','none','none','none','none',{'U,RF'},'none');
    end

end

writeABQendstep(abqpath);

%%
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%-                        Write .json files                              -%
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%

jsonID = fopen(fullfile(folder,projectName,'json',strcat(projectName,'.json')),'w');
fclose(jsonID);

%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%-                        Write .csv files                               -%
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%

csvID = fopen(fullfile(folder,projectName,'csv',strcat(projectName,'.csv')),'w');
fclose(csvID);

%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%-                        Write .tex files                               -%
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%

latexID = fopen(fullfile(folder,projectName,'latex',strcat(projectName,'.tex')),'w');
fclose(latexID);

%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%-                        Write .pdf files                               -%
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
