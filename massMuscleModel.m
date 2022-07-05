% ----------------------------------------------------------------------- %
% The OpenSim API is a toolkit for musculoskeletal modeling and           %
% simulation. See http://opensim.stanford.edu and the NOTICE file         %
% for more information. OpenSim is developed at Stanford University       %
% and supported by the US National Institutes of Health (U54 GM072970,    %
% R24 HD065690) and by DARPA through the Warrior Web program.             %
%                                                                         %   
% Copyright (c) 2005-2012 Stanford University and the Authors             %
%                                                                         %   
% Licensed under the Apache License, Version 2.0 (the "License");         %
% you may not use this file except in compliance with the License.        %
% You may obtain a copy of the License at                                 %
% http://www.apache.org/licenses/LICENSE-2.0.                             %
%                                                                         % 
% Unless required by applicable law or agreed to in writing, software     %
% distributed under the License is distributed on an "AS IS" BASIS,       %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or         %
% implied. See the License for the specific language governing            %
% permissions and limitations under the License.                          %
% ----------------------------------------------------------------------- %

% OpenSimCreateTugOfWarModel.m - script to perform the same model building and
% simulation tasks as the MainExample from the SDK examples

% This example script creates a model similar to the TugofWar API example.
% Two muscles are created and attached to a block. Linear controllers are
% defined for the muscles.

%% Clean it up
clear; close; clc;

% Pull in the modeling classes straight from the OpenSim distribution
import org.opensim.modeling.*

%///////////////////////////////////////////
%// DEFINE BODIES AND JOINTS OF THE MODEL //
%///////////////////////////////////////////

% Create a blank model
model = Model();
model.setName('Mass-Muscle')

% Convenience - create a zero value Vec3
zeroVec3 = ArrayDouble.createVec3(0);

% Set gravity as 0 since there is no ground contact model in this version
% of the example
% model.setGravity(zeroVec3);

% GROUND BODY

% Get a reference to the model's ground body
ground = model.getGroundBody();

% Add display geometry to the ground to visualize in the GUI
ground.addDisplayGeometry('anchor1.vtp');
anchorGeom=ground.getDisplayer.getGeometrySet().get(0);
anchorGeom.getTransform().T(); %translation
anchorGeom.getTransform().R(); %rotation
newTranslation=Vec3(0,0,-0.35); % Magic numbers.
newTransform=Transform(newTranslation);
anchorGeom.setTransform(newTransform);

% "MASS" BODY

% Create a block Body with associate dimensions, mass properties, and DisplayGeometry
mass = Body();
mass.setName('Mass');
mass.setMass(20);
mass.setMassCenter(zeroVec3);
% Need to set inertia
mass.addDisplayGeometry('block.vtp');

% Make second block anchor

% FREE JOINT

% Create a new free joint with 6 degrees-of-freedom (coordinates) between the mass and ground bodies
% blockSideLength      = 0.1;
locationInParentVec3 = ArrayDouble.createVec3([0, -0.5, 0]);
massToGround         = FreeJoint('massToGround', ground, locationInParentVec3, zeroVec3, mass, zeroVec3, zeroVec3, false);

% Set bounds on coordinates
jointCoordinateSet=massToGround.getCoordinateSet();
angleRange 	  = [-pi/2, pi/2];
positionRange = [-2, 2];
jointCoordinateSet.get(0).setRange(angleRange);
jointCoordinateSet.get(1).setRange(angleRange);
jointCoordinateSet.get(2).setRange(angleRange);
jointCoordinateSet.get(3).setRange(positionRange);
jointCoordinateSet.get(4).setRange(positionRange);
jointCoordinateSet.get(5).setRange(positionRange);

% Add the mass body to the model
model.addBody(mass)

%///////////////////////////////////////
%// DEFINE FORCES ACTING ON THE MODEL //
%///////////////////////////////////////

% Set muscle parameters
maxIsometricForce  = 1000.0;
optimalFiberLength = 0.25;
tendonSlackLength  = 0.1;
pennationAngle 	   = 0.0;

% Create new muscle
muscle = Thelen2003Muscle();
muscle.setName('muscle')
muscle.setMaxIsometricForce(maxIsometricForce)
muscle.setOptimalFiberLength(optimalFiberLength)
muscle.setTendonSlackLength(tendonSlackLength);
muscle.setPennationAngleAtOptimalFiberLength(pennationAngle)

% Path for muscle
muscle.addNewPathPoint('muscle-point1', ground, ArrayDouble.createVec3([0,0,0]))
muscle.addNewPathPoint('muscle1-point2', mass, ArrayDouble.createVec3([0,0,0]))

% Add the two muscles (as forces) to the model
model.addForce(muscle)

%Set up Controller
initialTime = 0.0;
finalTime = 3.0;

muscleController = PrescribedController();
muscleController.setName('LinearRamp Controller')
muscleController.setActuators(model.updActuators())

% Define linear functions for the control values for the muscle
slopeAndIntercept=ArrayDouble(0.0, 2);

% Default settings
% Muscle control has slope of -1 starting at t = 0
slopeAndIntercept.setitem(0, -1.0/(finalTime-initialTime)); % Default
slopeAndIntercept.setitem(1,  1.0); % Default

% Set the indiviudal muscle control functions for the prescribed muscle controller
muscleController.prescribeControlForActuator('muscle', LinearFunction(slopeAndIntercept));

% Add the control set controller to the model
model.addController(muscleController);

model.disownAllComponents();
model.print('massMuscleModelController.osim');
