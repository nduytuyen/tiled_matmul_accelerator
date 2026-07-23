set SynModuleInfo {
  {SRCNAME mmult_accel_Pipeline_copy_A_VITIS_LOOP_97_1 MODELNAME mmult_accel_Pipeline_copy_A_VITIS_LOOP_97_1 RTLNAME mmult_accel_mmult_accel_Pipeline_copy_A_VITIS_LOOP_97_1
    SUBMODULES {
      {MODELNAME mmult_accel_flow_control_loop_pipe_sequential_init RTLNAME mmult_accel_flow_control_loop_pipe_sequential_init BINDTYPE interface TYPE internal_upc_flow_control INSTNAME mmult_accel_flow_control_loop_pipe_sequential_init_U}
    }
  }
  {SRCNAME mmult_accel_Pipeline_VITIS_LOOP_120_2 MODELNAME mmult_accel_Pipeline_VITIS_LOOP_120_2 RTLNAME mmult_accel_mmult_accel_Pipeline_VITIS_LOOP_120_2
    SUBMODULES {
      {MODELNAME mmult_accel_mul_31ns_32ns_63_1_1 RTLNAME mmult_accel_mul_31ns_32ns_63_1_1 BINDTYPE op TYPE mul IMPL auto LATENCY 0 ALLOW_PRAGMA 1}
    }
  }
  {SRCNAME mmult_accel_Pipeline_loadA_VITIS_LOOP_171_4 MODELNAME mmult_accel_Pipeline_loadA_VITIS_LOOP_171_4 RTLNAME mmult_accel_mmult_accel_Pipeline_loadA_VITIS_LOOP_171_4}
  {SRCNAME mmult_accel_Pipeline_loadB_VITIS_LOOP_186_5 MODELNAME mmult_accel_Pipeline_loadB_VITIS_LOOP_186_5 RTLNAME mmult_accel_mmult_accel_Pipeline_loadB_VITIS_LOOP_186_5}
  {SRCNAME mmult_accel_Pipeline_compute MODELNAME mmult_accel_Pipeline_compute RTLNAME mmult_accel_mmult_accel_Pipeline_compute
    SUBMODULES {
      {MODELNAME mmult_accel_mux_325_8_1_1 RTLNAME mmult_accel_mux_325_8_1_1 BINDTYPE op TYPE mux IMPL auto LATENCY 0 ALLOW_PRAGMA 1}
      {MODELNAME mmult_accel_mac_muladd_8s_8s_32s_32_4_1 RTLNAME mmult_accel_mac_muladd_8s_8s_32s_32_4_1 BINDTYPE op TYPE all IMPL dsp48 LATENCY 3 ALLOW_PRAGMA 1}
    }
  }
  {SRCNAME mmult_accel_Pipeline_writeC_VITIS_LOOP_220_8 MODELNAME mmult_accel_Pipeline_writeC_VITIS_LOOP_220_8 RTLNAME mmult_accel_mmult_accel_Pipeline_writeC_VITIS_LOOP_220_8
    SUBMODULES {
      {MODELNAME mmult_accel_mul_62s_32s_62_1_1 RTLNAME mmult_accel_mul_62s_32s_62_1_1 BINDTYPE op TYPE mul IMPL auto LATENCY 0 ALLOW_PRAGMA 1}
      {MODELNAME mmult_accel_mux_325_32_1_1 RTLNAME mmult_accel_mux_325_32_1_1 BINDTYPE op TYPE mux IMPL auto LATENCY 0 ALLOW_PRAGMA 1}
    }
  }
  {SRCNAME mmult_accel MODELNAME mmult_accel RTLNAME mmult_accel IS_TOP 1
    SUBMODULES {
      {MODELNAME mmult_accel_mul_32s_32s_32_1_1 RTLNAME mmult_accel_mul_32s_32s_32_1_1 BINDTYPE op TYPE mul IMPL auto LATENCY 0 ALLOW_PRAGMA 1}
      {MODELNAME mmult_accel_mul_32ns_32ns_64_1_1 RTLNAME mmult_accel_mul_32ns_32ns_64_1_1 BINDTYPE op TYPE mul IMPL auto LATENCY 0 ALLOW_PRAGMA 1}
      {MODELNAME mmult_accel_mul_28ns_28ns_118_1_1 RTLNAME mmult_accel_mul_28ns_28ns_118_1_1 BINDTYPE op TYPE mul IMPL auto LATENCY 0 ALLOW_PRAGMA 1}
      {MODELNAME mmult_accel_A_bram_RAM_2P_BRAM_1R1W RTLNAME mmult_accel_A_bram_RAM_2P_BRAM_1R1W BINDTYPE storage TYPE ram_2p IMPL bram LATENCY 2 ALLOW_PRAGMA 1}
      {MODELNAME mmult_accel_B_bram_RAM_2P_BRAM_1R1W RTLNAME mmult_accel_B_bram_RAM_2P_BRAM_1R1W BINDTYPE storage TYPE ram_2p IMPL bram LATENCY 2 ALLOW_PRAGMA 1}
      {MODELNAME mmult_accel_gmemA_m_axi RTLNAME mmult_accel_gmemA_m_axi BINDTYPE interface TYPE adapter IMPL m_axi}
      {MODELNAME mmult_accel_gmemB_m_axi RTLNAME mmult_accel_gmemB_m_axi BINDTYPE interface TYPE adapter IMPL m_axi}
      {MODELNAME mmult_accel_gmemC_m_axi RTLNAME mmult_accel_gmemC_m_axi BINDTYPE interface TYPE adapter IMPL m_axi}
      {MODELNAME mmult_accel_control_s_axi RTLNAME mmult_accel_control_s_axi BINDTYPE interface TYPE interface_s_axilite}
    }
  }
}
