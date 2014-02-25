%
% Evaluate our tests sets for 2009 
%

local_conf

mapmethods={ {'fft','snr'},...
             {'straight','snr'},...
             {'fft','mcd'}, ...
             {'straight','mcd'},...
             {'llr','llr'}, ...
             {'fft','log-mel'},...
             {'straight','log-mel'}};


if (matlabpool('size') == 0)
    matlabpool
end

tests={ ...
    struct( ...
        'name',                  'EH1_similarity',...
        'objective_resultfile',  'tests/2009/2009_EH1_objective_results_sim',...
        'testfilelist',          'tests/2009/2009_EH1_sim.test.scp',...
        'reffilelist',           'tests/2009/2009_EH1_sim.ref.scp',...
        'subjective_resultfile', 'tests/2009/2009_EH1_sim_mean.ascii',...
        'opinionmatrix',         'tests/2009/significancematrix_2009_EH1_sim.ascii',...
        'systems',               'BCDEHIJKLMOPQRSTW', ...
        'results',                []), ...
    struct( ...
        'name',                  'EH1_naturalness',...
        'objective_resultfile',  'tests/2009/2009_EH1_objective_results_nat',...
        'testfilelist',          'tests/2009/2009_EH1_nat.test.scp',...
        'reffilelist',           'tests/2009/2009_EH1_nat.ref.scp',...
        'subjective_resultfile', 'tests/2009/2009_EH1_nat_mean.ascii',...
        'opinionmatrix',         'tests/2009/significancematrix_2009_EH1_nat.ascii',...
        'systems',               'BCDEHIJKLMOPQRSTW', ...
        'results',                []), ...
    struct( ...
        'name',                  'ES1_similarity',...
        'objective_resultfile',  'tests/2009/2009_ES1_objective_results_sim',...
        'testfilelist',          'tests/2009/2009_ES1_sim.test.scp',...
        'reffilelist',           'tests/2009/2009_ES1_sim.ref.scp',...
        'subjective_resultfile', 'tests/2009/2009_ES1_sim_mean.ascii',...
        'opinionmatrix',         'tests/2009/significancematrix_2009_ES1_sim.ascii',...
        'systems',               'DHJLPSW', ...
        'results',                []), ...    
    struct( ...
        'name',                  'ES1_naturalness',...
        'objective_resultfile',  'tests/2009/2009_ES1_objective_results_nat',...
        'testfilelist',          'tests/2009/2009_ES1_nat.test.scp',...
        'reffilelist',           'tests/2009/2009_ES1_nat.ref.scp',...
        'subjective_resultfile', 'tests/2009/2009_ES1_nat_mean.ascii',...
        'opinionmatrix',         'tests/2009/significancematrix_2009_ES1_nat.ascii',...        
        'systems',               'DHJLPSW', ...
        'results',                []), ...    
    struct( ...
        'name',                  'MH__similarity',...
        'objective_resultfile',  'tests/2009/2009_MH_objective_results_sim',...
        'testfilelist',          'tests/2009/2009_MH_sim.test.scp',...
        'reffilelist',           'tests/2009/2009_MH_sim.ref.scp',...
        'subjective_resultfile', 'tests/2009/2009_MH_sim_mean.ascii',...
        'opinionmatrix',         'tests/2009/significancematrix_2009_MH_sim.ascii',...        
        'systems',               'CDFGILMNRVW', ...
        'results',                []), ...    
    struct( ...
        'name',                  'MH__naturalness',...
        'objective_resultfile',  'tests/2009/2009_MH_objective_results_nat',...
        'testfilelist',          'tests/2009/2009_MH_nat.test.scp',...
        'reffilelist',           'tests/2009/2009_MH_nat.ref.scp',...
        'subjective_resultfile', 'tests/2009/2009_MH_nat_mean.ascii',...
        'opinionmatrix',         'tests/2009/significancematrix_2009_MH_nat.ascii',...                
        'systems',               'CDFGILMNRVW', ...
        'results',                []), ...    
    struct( ...
        'name',                  'MS1_similarity',...
        'objective_resultfile',  'tests/2009/2009_MS1_objective_results_sim',...
        'testfilelist',          'tests/2009/2009_MS1_sim.test.scp',...
        'reffilelist',           'tests/2009/2009_MS1_sim.ref.scp',...
        'subjective_resultfile', 'tests/2009/2009_MS1_sim_mean.ascii',...
        'opinionmatrix',         'tests/2009/significancematrix_2009_MS1_sim.ascii',...
        'systems',               'DLMRVW', ...
        'results',                []), ...    
    struct( ...
        'name',                  'MS1_naturalness',...
        'objective_resultfile',  'tests/2009/2009_MS1_objective_results_nat',...
        'testfilelist',          'tests/2009/2009_MS1_nat.test.scp',...
        'reffilelist',           'tests/2009/2009_MS1_nat.ref.scp',...
        'subjective_resultfile', 'tests/2009/2009_MS1_nat_mean.ascii',...
        'opinionmatrix',         'tests/2009/significancematrix_2009_MS1_nat.ascii',...
        'systems',               'DLMRVW', ...
        'results',                []), ...        
    struct( ...
        'name',                  'MS2_naturalness',...
        'objective_resultfile',  '--devel/2009_EH1_objective_results_nat',...
        'testfilelist',          '--devel/2009_EH1_nat.ref.scp',...
        'reffilelist',           '--devel/2009_EH1_nat.test.scp',...
        'subjective_resultfile', '--tests/2009_subjective_eval_nat_means_only_num.txt',...
        'opinionmatrix',         'tests/significancematrix_2009_MS2_nat.ascii',...
        'systems',               'CDFLNRVW', ...
        'results',                []), ...
      };


    
for n=5:9 %length(tests)
    if exist(tests{n}.objective_resultfile, 'file') == 0;   
        [ objdata, test_runtime ] = obj_evaluation(BLIZZARD2009_RESULTDIR, tests{n}.reffilelist,tests{n}.testfilelist, mapmethods);
        save(tests{n}.objective_resultfile, 'objdata','-ascii');                      
        tests{n}.results=objdata;
    else      
        tests{n}.results=load(tests{n}.objective_resultfile);
        objdata=tests{n}.results;    
    end
    subjectivedata=load(tests{n}.subjective_resultfile);
    opinionmat= load(tests{n}.opinionmatrix);
    systemlist=tests{n}.systems;
    
    tests{n}.results=evaluate_wilcoxon(objdata, subjectivedata, opinionmat, ...
                               systemlist, 0);
end
