#!/bin/bash

OUTDIR=jec_test6_TRKv6p1_l2l3_ak4

JETTYPE=ak4puppi

ERA=Phase2HLTTDRsimPF_V1_MC

#JRA_NoPU=${CMSSW_BASE}/src/JMETriggerAnalysis/NTuplizers/test/jra_TRKv06p1_TICL/Phase2HLTTDR_QCD_PtFlat15to7000_14TeV_NoPU.root
#JRA_PU=${CMSSW_BASE}/src/JMETriggerAnalysis/NTuplizers/test/jra_TRKv06p1_TICL/Phase2HLTTDR_QCD_PtFlat15to7000_14TeV_PU.root
#JRA_PU=/eos/cms/store/group/phys_jetmet/saparede/phase2_hlt_jec/jra_ntuples/dec04_1M/flatpu_1M.root
JRA_PU=/eos/cms/store/group/dpg_trigger/comm_trigger/TriggerStudiesGroup/Upgrade/JetMET_PhaseII/JMETriggerAnalysis_phase2/ntuples/outputJRA_hltPhase2_210117/HLT_TRKv06p1/Phase2HLTTDR_QCD_PtFlat15to7000_14TeV_PU.root

# ----------------------------------------

set -e

mkdir -p ${OUTDIR}
cd ${OUTDIR}
unset OUTDIR

### pre-processing
#if [ ! -f step0.done ]; then
#  echo "mkdir -p jraNTuples && \\
#${CMSSW_BASE}/src/JetMETAnalysis/JetAnalyzers/scripts/renameJRADirs.py -v 2 -i ${JRA_NoPU} -o jraNTuples/NoPU.root && \\
#${CMSSW_BASE}/src/JetMETAnalysis/JetAnalyzers/scripts/renameJRADirs.py -v 2 -i ${JRA_PU} -o jraNTuples/PU.root" > step0.sh
#  source step0.sh && touch step0.done
#fi
#
### L1
#if [ ! -f step1.done ]; then
#  echo "jet_synchtest_x -algo1 ${JETTYPE} -algo2 ${JETTYPE} -basepath jraNTuples -sampleNoPU NoPU.root -samplePU PU.root" > step1.sh
#  source step1.sh && touch step1.done
#fi
#
#if [ ! -f step2.done ]; then
#  echo "mkdir -p plots_step2 && jet_synchplot_x -algo1 ${JETTYPE} -algo2 ${JETTYPE} -inputDir ./ -outputFormat .png -fixedRange false -tdr true -outDir ./plots_step2" > step2.sh
#  source step2.sh && touch step2.done
#fi
#
#if [ ! -f step3.done ]; then
#  echo "jet_synchfit_x  -algo1 ${JETTYPE} -algo2 ${JETTYPE} -era ${ERA}" > step3.sh
#  source step3.sh && touch step3.done
#fi
#
#if [ ! -f step4.done ]; then
#  echo "mkdir -p plots_step4 && jet_synchplot_x -algo1 ${JETTYPE} -algo2 ${JETTYPE} -inputDir ./ -outputFormat .png -fixedRange false -tdr true -outDir ./plots_step4" > step4.sh
#  source step4.sh && touch step4.done
#fi
#
#if [ ! -f step5.done ]; then
#  echo "jet_apply_jec_x -algs ${JETTYPE} -input jraNTuples/PU.root -era ${ERA} -levels 1 -jecpath ./ -L1FastJet true" > step5.sh
#  source step5.sh && touch step5.done
#fi
#
## L2+L3

## pre-processing
if [ ! -f step0.done ]; then
  echo "mkdir -p jraNTuples && \\
${CMSSW_BASE}/src/JetMETAnalysis/JetAnalyzers/scripts/renameJRADirs.py -v 2 -i ${JRA_PU} -o jraNTuples/PU.root" > step0.sh
  source step0.sh && touch step0.done
fi

## L2+L3
if [ ! -f step6.done ]; then
  echo "jet_response_analyzer_x ${CMSSW_BASE}/src/JetMETAnalysis/JetAnalyzers/config/jra_hltPhase2_${JETTYPE}.config -input jraNTuples/PU.root -algs ${JETTYPE}:0.1 -nbinsabsrsp 0 -nbinsetarsp 0 -nbinsphirsp 0 -nbinsrelrsp 200 -doflavor false -output histogram_${JETTYPE}_step6.root -useweight false -nrefmax 20 -relrspmin 0.0 -relrspmax 5.0" > step6.sh
  source step6.sh && touch step6.done
fi

if [ ! -f step7.done ]; then
  echo "jet_l2_correction_x -input histogram_${JETTYPE}_step6.root -algs ${JETTYPE} -era ${ERA} -output l2p3.root -outputDir ./ -makeCanvasVariable AbsCorVsJetPt:JetEta -l2l3 true -batch true -histMet median -l2pffit standard -maxFitIter 50 -ptclipfit true" > step7.sh
  source step7.sh && touch step7.done
fi

if [ ! -f step8.done ]; then
  echo "mkdir -p plots_step8 && jet_correction_analyzer_x -evtmax 0 -inputFilename jraNTuples/PU.root -algs ${JETTYPE} -drmax 0.1 -L1FastJet false -useweight false -path ./ -era ${ERA} -levels 2 -outputDir ./plots_step8 -nbinsrelrsp 200 -relrspmin 0.0 -relrspmax 5.0 -nrefmax 20" > step8.sh
  source step8.sh && touch step8.done
fi

if [ ! -f step9.done ]; then
  echo "jet_draw_closure_x -path plots_step8 -filename Closure_${JETTYPE} -histMet median -outputDir plots_step9 -draw_guidelines true -doPt true -doEta true -doRatioPt false -doRatioEta false" > step9.sh
  source step9.sh && touch step9.done
fi

# prefix to dummy JEC .txt files
TXTFILE_PREFIX=/afs/cern.ch/work/m/missirol/public/phase2/JESC/Phase2HLTTDR_V5_MC/Phase2HLTTDR_V5_MC_

if [ -f ${ERA}_L2Relative_AK4PUPPI.txt ]; then
  mkdir -p jesc
  cp ${TXTFILE_PREFIX}L1FastJet_AK4PFPuppiHLT.txt jesc/${ERA}_L1FastJet_AK4PFPuppiHLT.txt
  mv ${ERA}_L2Relative_AK4PUPPI.txt jesc/${ERA}_L2Relative_AK4PFPuppiHLT.txt
  cp ${TXTFILE_PREFIX}L3Absolute_AK4PFPuppiHLT.txt jesc/${ERA}_L3Absolute_AK4PFPuppiHLT.txt
fi

if [ -f ${ERA}_L2Relative_AK8PUPPI.txt ]; then
  mkdir -p jesc
  cp ${TXTFILE_PREFIX}L1FastJet_AK8PFPuppiHLT.txt jesc/${ERA}_L1FastJet_AK8PFPuppiHLT.txt
  mv ${ERA}_L2Relative_AK8PUPPI.txt jesc/${ERA}_L2Relative_AK8PFPuppiHLT.txt
  cp ${TXTFILE_PREFIX}L3Absolute_AK8PFPuppiHLT.txt jesc/${ERA}_L3Absolute_AK8PFPuppiHLT.txt
fi
