function [critic, actor, cr, rmse, model, episodes] = dyna_mlac_pendulum(varargin)
%DYNA_MLAC_PENDULUM Runs the dyna-mlac algorithim on the pendulum swing-up.
%   DYNA_MLAC_PENDULUM(E, S) learns during E episodes,
%   doing S model steps per real step.
%
%   DYNA_MLAC_PENDULUM(..., 'verbose', true) sets the output to verbose
%   DYNA_MLAC_PENDULUM(..., 'steps', S) sets the total steps per iteration
%   See LEARN for more params.
%
%   C = DYNA_MLAC_PENDULUM(...) return a handle to the Critic
%   [C, A] = DYNA_MLAC_PENDULUM(...) also returns a handle to the Actor
%   [C, A, CR] = DYNA_MLAC_PENDULUM(...) also returns the learning curve.
%   [C, A, CR, E] = DYNA_MLAC_PENDULUM(...) also returns the error curve.
%
%   EXAMPLES:
%      [critic, actor, cr, rmse] = dyna_mlac_pendulum(100, 10);
%  
%   AUTHOR:
%       Bruno Costa <doravante2@gmail.com>

    % Argument parsing
    p = inputParser;
    expectedModes = {'episode','performance'};
    p.addParameter('mode','episode',...
                 @(x) any(validatestring(x,expectedModes)));
             
    p.addParameter('steps', 2, @isnumeric);
    p.addOptional('episodes', 100, @isnumeric);
    
    p.addOptional('performance', -900, @isnumeric);
    p.addOptional('trialsInARow', 3, @isnumeric);
    
    p.addOptional('verbose', false, @islogical);
    p.addOptional('figure', false, @islogical);
    p.parse(varargin{:});
    args = p.Results;
    
    % Initialize environment
    spec = env_mops_sim('init');
    
    % Normalization factor used in observations
    norm_factor   = [ pi/10, pi ];
    
    javaSpec = br.ufrj.ppgi.rl.Specification;

    javaSpec.setActorAlpha(0.05);
    javaSpec.setActorMemory(2000);
    javaSpec.setActorNeighbors(25);
    javaSpec.setActorMin(spec.action_min);
    javaSpec.setActorMax(spec.action_max);
    javaSpec.setActorValuesToRebuildTree(1);
    
    javaSpec.setCriticInitialValue(0);
    javaSpec.setCriticAlpha(0.3);
    javaSpec.setCriticMemory(2000);
    javaSpec.setCriticNeighbors(15);
    javaSpec.setCriticValuesToRebuildTree(1);

    javaSpec.setObservationDimensions(spec.observation_dims);
    javaSpec.setActionDimensions(spec.action_dims);

    javaSpec.setExplorationRate(3);
    javaSpec.setProcessModelExplorationRate(3);
    javaSpec.setLamda(0.65);
    javaSpec.setGamma(0.97);
    javaSpec.setSd(1.0);
    
    javaSpec.setProcessModelMemory(100);
    javaSpec.setProcessModelNeighbors(10);
    javaSpec.setProcessModelValuesToRebuildTree(1);
    javaSpec.setObservationMinValue(spec.observation_min ./ norm_factor);
    javaSpec.setObservationMaxValue(spec.observation_max ./ norm_factor);
    
    javaSpec.setProcessModelCrossLimit(10);
    javaSpec.setProcessModelUpperBound([20 0]);
    javaSpec.setProcessModelThreshold(1.0);
        
    javaSpec.setProcessModelStepsPerEpisode(args.steps);
    javaSpec.setProcessModelCriticAlpha(javaSpec.getCriticAlpha()/1000);
    javaSpec.setProcessModelActorAplha(javaSpec.getActorAlpha()/1000);
    javaSpec.setProcessModelGamma(0.97);
    javaSpec.setProcessModelIterationsWithoutLearning(0);
    javaSpec.setRewardRange((spec.reward_max - spec.reward_min)/100);
       
    agent = br.ufrj.ppgi.rl.ac.DynaMLAC;
    agent.init(javaSpec);
    
    [critic, actor, cr, rmse, episodes] = learn('mops_sim', norm_factor, agent, args); 
    model = agent.getProcessModel();
end