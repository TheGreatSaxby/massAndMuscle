
maxNumCompThreads(1);

prompt1 = {'Max Isometric Force (Default = 1000)', 'Optimal Fiber Length (Default = 0.25)',...
    'Tendon Slack Length (Default = 0.1)', 'Pennation Angle (Default = 0)'};

prompt2 = {'Translation X (Default = 0)', 'Translation Y (Default = 0)', 'Translation Z (Default = -0.35)',...
    'Object Mass (Default = 20)', 'Location in parent X (Default = 0)' , 'Location in parent Y (Default = -0.5)',...
    'Location in parent Z (Default = 0)',  'Position range start (Default = -2)',...
    'Position range end (Default = 2)', 'Analysis time (Default = 3)',...
    'Linear functions for the control values for the muscle, Initial (Default = -1)',...
    'linear functions for the control values for the muscle, Secondary (Default = 1)'};


dlg_title = 'Set muscle parameters';
dims = [1 80];
definput = {'1000','0.25','0.1','0'};
answer1 = inputdlg(prompt1,dlg_title,dims,definput);

dlg_title = 'Set analysis parameters';
definput = {'0','0','-0.35','20','0','-0.5','0','-2','2','3','-1','1'};
answer2 = inputdlg(prompt2,dlg_title,dims,definput);

analysisParameters = str2double(answer2);
muscleParameters = str2double(answer1);

clear dlg_title answer1 answer2 prompt1 prompt2

massMuscleModel
massMuscle_CompleteRunVisualize

a = readtable(['massMuscle_states_degrees.mot'],'FileType','text','ReadVariableNames',true);
Time = a.time;
Velocity = a.massToGround_yTranslation_u;
Acceleration = 0; 
Acceleration(2:height(a),1) = diff(Velocity(:))./diff(Time(:));
mass = analysisParameters(4);
MuscleForce = mass * (Acceleration + 9.81);

plotMuscleSimulationResults

h6=subplot(3,2,6);
plot(Time, MuscleForce, 'r');
ylabel('Muscle force (m/s^2)');
xlabel('Simulation time (s)');

