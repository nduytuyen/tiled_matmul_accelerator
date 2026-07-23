# This script segment is generated automatically by AutoPilot

set name mmult_accel_mul_31ns_32ns_63_1_1
if {${::AESL::PGuard_rtl_comp_handler}} {
	::AP::rtl_comp_handler $name BINDTYPE {op} TYPE {mul} IMPL {auto} LATENCY 0 ALLOW_PRAGMA 1
}


# clear list
if {${::AESL::PGuard_autoexp_gen}} {
    cg_default_interface_gen_dc_begin
    cg_default_interface_gen_bundle_begin
    AESL_LIB_XILADAPTER::native_axis_begin
}

# XIL_BRAM:
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc ::AESL_LIB_XILADAPTER::xil_bram_gen] == "::AESL_LIB_XILADAPTER::xil_bram_gen"} {
eval "::AESL_LIB_XILADAPTER::xil_bram_gen { \
    id 15 \
    name B_bram \
    reset_level 1 \
    sync_rst true \
    dir O \
    corename B_bram \
    op interface \
    ports { B_bram_address1 { O 18 vector } B_bram_ce1 { O 1 bit } B_bram_we1 { O 1 bit } B_bram_d1 { O 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'B_bram'"
}
}


# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 8 \
    name gmemB \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_gmemB \
    op interface \
    ports { m_axi_gmemB_AWVALID { O 1 bit } m_axi_gmemB_AWREADY { I 1 bit } m_axi_gmemB_AWADDR { O 64 vector } m_axi_gmemB_AWID { O 1 vector } m_axi_gmemB_AWLEN { O 32 vector } m_axi_gmemB_AWSIZE { O 3 vector } m_axi_gmemB_AWBURST { O 2 vector } m_axi_gmemB_AWLOCK { O 2 vector } m_axi_gmemB_AWCACHE { O 4 vector } m_axi_gmemB_AWPROT { O 3 vector } m_axi_gmemB_AWQOS { O 4 vector } m_axi_gmemB_AWREGION { O 4 vector } m_axi_gmemB_AWUSER { O 1 vector } m_axi_gmemB_WVALID { O 1 bit } m_axi_gmemB_WREADY { I 1 bit } m_axi_gmemB_WDATA { O 8 vector } m_axi_gmemB_WSTRB { O 1 vector } m_axi_gmemB_WLAST { O 1 bit } m_axi_gmemB_WID { O 1 vector } m_axi_gmemB_WUSER { O 1 vector } m_axi_gmemB_ARVALID { O 1 bit } m_axi_gmemB_ARREADY { I 1 bit } m_axi_gmemB_ARADDR { O 64 vector } m_axi_gmemB_ARID { O 1 vector } m_axi_gmemB_ARLEN { O 32 vector } m_axi_gmemB_ARSIZE { O 3 vector } m_axi_gmemB_ARBURST { O 2 vector } m_axi_gmemB_ARLOCK { O 2 vector } m_axi_gmemB_ARCACHE { O 4 vector } m_axi_gmemB_ARPROT { O 3 vector } m_axi_gmemB_ARQOS { O 4 vector } m_axi_gmemB_ARREGION { O 4 vector } m_axi_gmemB_ARUSER { O 1 vector } m_axi_gmemB_RVALID { I 1 bit } m_axi_gmemB_RREADY { O 1 bit } m_axi_gmemB_RDATA { I 8 vector } m_axi_gmemB_RLAST { I 1 bit } m_axi_gmemB_RID { I 1 vector } m_axi_gmemB_RFIFONUM { I 11 vector } m_axi_gmemB_RUSER { I 1 vector } m_axi_gmemB_RRESP { I 2 vector } m_axi_gmemB_BVALID { I 1 bit } m_axi_gmemB_BREADY { O 1 bit } m_axi_gmemB_BRESP { I 2 vector } m_axi_gmemB_BID { I 1 vector } m_axi_gmemB_BUSER { I 1 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9 \
    name current_block_M \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_current_block_M \
    op interface \
    ports { current_block_M { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10 \
    name mul_ln110 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_mul_ln110 \
    op interface \
    ports { mul_ln110 { I 64 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 11 \
    name zext_ln119 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_zext_ln119 \
    op interface \
    ports { zext_ln119 { I 31 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 12 \
    name zext_ln110 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_zext_ln110 \
    op interface \
    ports { zext_ln110 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 13 \
    name B \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_B \
    op interface \
    ports { B { I 64 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 14 \
    name j_block \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_j_block \
    op interface \
    ports { j_block { I 64 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id -1 \
    name ap_ctrl \
    type ap_ctrl \
    reset_level 1 \
    sync_rst true \
    corename ap_ctrl \
    op interface \
    ports { ap_start { I 1 bit } ap_ready { O 1 bit } ap_done { O 1 bit } ap_idle { O 1 bit } } \
} "
}


# Adapter definition:
set PortName ap_clk
set DataWd 1 
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc cg_default_interface_gen_clock] == "cg_default_interface_gen_clock"} {
eval "cg_default_interface_gen_clock { \
    id -2 \
    name ${PortName} \
    reset_level 1 \
    sync_rst true \
    corename apif_ap_clk \
    data_wd ${DataWd} \
    op interface \
}"
} else {
puts "@W \[IMPL-113\] Cannot find bus interface model in the library. Ignored generation of bus interface for '${PortName}'"
}
}


# Adapter definition:
set PortName ap_rst
set DataWd 1 
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc cg_default_interface_gen_reset] == "cg_default_interface_gen_reset"} {
eval "cg_default_interface_gen_reset { \
    id -3 \
    name ${PortName} \
    reset_level 1 \
    sync_rst true \
    corename apif_ap_rst \
    data_wd ${DataWd} \
    op interface \
}"
} else {
puts "@W \[IMPL-114\] Cannot find bus interface model in the library. Ignored generation of bus interface for '${PortName}'"
}
}



# merge
if {${::AESL::PGuard_autoexp_gen}} {
    cg_default_interface_gen_dc_end
    cg_default_interface_gen_bundle_end
    AESL_LIB_XILADAPTER::native_axis_end
}


# flow_control definition:
set InstName mmult_accel_flow_control_loop_pipe_sequential_init_U
set CompName mmult_accel_flow_control_loop_pipe_sequential_init
set name flow_control_loop_pipe_sequential_init
if {${::AESL::PGuard_autocg_gen} && ${::AESL::PGuard_autocg_ipmgen}} {
if {[info proc ::AESL_LIB_VIRTEX::xil_gen_UPC_flow_control] == "::AESL_LIB_VIRTEX::xil_gen_UPC_flow_control"} {
eval "::AESL_LIB_VIRTEX::xil_gen_UPC_flow_control { \
    name ${name} \
    prefix mmult_accel_ \
}"
} else {
puts "@W \[IMPL-107\] Cannot find ::AESL_LIB_VIRTEX::xil_gen_UPC_flow_control, check your platform lib"
}
}


if {${::AESL::PGuard_rtl_comp_handler}} {
	::AP::rtl_comp_handler $CompName BINDTYPE interface TYPE internal_upc_flow_control INSTNAME $InstName
}


