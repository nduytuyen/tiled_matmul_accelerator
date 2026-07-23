# This script segment is generated automatically by AutoPilot

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
    id 5 \
    name A_bram \
    reset_level 1 \
    sync_rst true \
    dir O \
    corename A_bram \
    op interface \
    ports { A_bram_address1 { O 16 vector } A_bram_ce1 { O 1 bit } A_bram_we1 { O 1 bit } A_bram_d1 { O 8 vector } } \
} "
} else {
puts "@W \[IMPL-110\] Cannot find bus interface model in the library. Ignored generation of bus interface for 'A_bram'"
}
}


# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 1 \
    name gmemA \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_gmemA \
    op interface \
    ports { m_axi_gmemA_AWVALID { O 1 bit } m_axi_gmemA_AWREADY { I 1 bit } m_axi_gmemA_AWADDR { O 64 vector } m_axi_gmemA_AWID { O 1 vector } m_axi_gmemA_AWLEN { O 32 vector } m_axi_gmemA_AWSIZE { O 3 vector } m_axi_gmemA_AWBURST { O 2 vector } m_axi_gmemA_AWLOCK { O 2 vector } m_axi_gmemA_AWCACHE { O 4 vector } m_axi_gmemA_AWPROT { O 3 vector } m_axi_gmemA_AWQOS { O 4 vector } m_axi_gmemA_AWREGION { O 4 vector } m_axi_gmemA_AWUSER { O 1 vector } m_axi_gmemA_WVALID { O 1 bit } m_axi_gmemA_WREADY { I 1 bit } m_axi_gmemA_WDATA { O 8 vector } m_axi_gmemA_WSTRB { O 1 vector } m_axi_gmemA_WLAST { O 1 bit } m_axi_gmemA_WID { O 1 vector } m_axi_gmemA_WUSER { O 1 vector } m_axi_gmemA_ARVALID { O 1 bit } m_axi_gmemA_ARREADY { I 1 bit } m_axi_gmemA_ARADDR { O 64 vector } m_axi_gmemA_ARID { O 1 vector } m_axi_gmemA_ARLEN { O 32 vector } m_axi_gmemA_ARSIZE { O 3 vector } m_axi_gmemA_ARBURST { O 2 vector } m_axi_gmemA_ARLOCK { O 2 vector } m_axi_gmemA_ARCACHE { O 4 vector } m_axi_gmemA_ARPROT { O 3 vector } m_axi_gmemA_ARQOS { O 4 vector } m_axi_gmemA_ARREGION { O 4 vector } m_axi_gmemA_ARUSER { O 1 vector } m_axi_gmemA_RVALID { I 1 bit } m_axi_gmemA_RREADY { O 1 bit } m_axi_gmemA_RDATA { I 8 vector } m_axi_gmemA_RLAST { I 1 bit } m_axi_gmemA_RID { I 1 vector } m_axi_gmemA_RFIFONUM { I 11 vector } m_axi_gmemA_RUSER { I 1 vector } m_axi_gmemA_RRESP { I 2 vector } m_axi_gmemA_BVALID { I 1 bit } m_axi_gmemA_BREADY { O 1 bit } m_axi_gmemA_BRESP { I 2 vector } m_axi_gmemA_BID { I 1 vector } m_axi_gmemA_BUSER { I 1 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 2 \
    name A \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_A \
    op interface \
    ports { A { I 64 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 3 \
    name K \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_K \
    op interface \
    ports { K { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 4 \
    name mul_ln96_1 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_mul_ln96_1 \
    op interface \
    ports { mul_ln96_1 { I 64 vector } } \
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


