# This script segment is generated automatically by AutoPilot

set name mmult_accel_mul_62s_32s_62_1_1
if {${::AESL::PGuard_rtl_comp_handler}} {
	::AP::rtl_comp_handler $name BINDTYPE {op} TYPE {mul} IMPL {auto} LATENCY 0 ALLOW_PRAGMA 1
}


set id 9309
set name mmult_accel_mux_325_32_1_1
set corename simcore_mux
set op mux
set stage_num 1
set din0_width 32
set din0_signed 0
set din1_width 32
set din1_signed 0
set din2_width 32
set din2_signed 0
set din3_width 32
set din3_signed 0
set din4_width 32
set din4_signed 0
set din5_width 32
set din5_signed 0
set din6_width 32
set din6_signed 0
set din7_width 32
set din7_signed 0
set din8_width 32
set din8_signed 0
set din9_width 32
set din9_signed 0
set din10_width 32
set din10_signed 0
set din11_width 32
set din11_signed 0
set din12_width 32
set din12_signed 0
set din13_width 32
set din13_signed 0
set din14_width 32
set din14_signed 0
set din15_width 32
set din15_signed 0
set din16_width 32
set din16_signed 0
set din17_width 32
set din17_signed 0
set din18_width 32
set din18_signed 0
set din19_width 32
set din19_signed 0
set din20_width 32
set din20_signed 0
set din21_width 32
set din21_signed 0
set din22_width 32
set din22_signed 0
set din23_width 32
set din23_signed 0
set din24_width 32
set din24_signed 0
set din25_width 32
set din25_signed 0
set din26_width 32
set din26_signed 0
set din27_width 32
set din27_signed 0
set din28_width 32
set din28_signed 0
set din29_width 32
set din29_signed 0
set din30_width 32
set din30_signed 0
set din31_width 32
set din31_signed 0
set din32_width 5
set din32_signed 0
set dout_width 32
if {${::AESL::PGuard_rtl_comp_handler}} {
	::AP::rtl_comp_handler $name BINDTYPE {op} TYPE {mux} IMPL {auto} LATENCY 0 ALLOW_PRAGMA 1
}


set op mux
set corename Multiplexer
if {${::AESL::PGuard_autocg_gen} && ${::AESL::PGuard_autocg_ipmgen}} {
if {[info proc ::AESL_LIB_VIRTEX::xil_gen_pipemux] == "::AESL_LIB_VIRTEX::xil_gen_pipemux"} {
eval "::AESL_LIB_VIRTEX::xil_gen_pipemux { \
    id ${id} \
    name ${name} \
    corename ${corename} \
    op ${op} \
    reset_level 1 \
    sync_rst true \
    stage_num ${stage_num} \
    din0_width ${din0_width} \
    din0_signed ${din0_signed} \
    din1_width ${din1_width} \
    din1_signed ${din1_signed} \
    din2_width ${din2_width} \
    din2_signed ${din2_signed} \
    din3_width ${din3_width} \
    din3_signed ${din3_signed} \
    din4_width ${din4_width} \
    din4_signed ${din4_signed} \
    din5_width ${din5_width} \
    din5_signed ${din5_signed} \
    din6_width ${din6_width} \
    din6_signed ${din6_signed} \
    din7_width ${din7_width} \
    din7_signed ${din7_signed} \
    din8_width ${din8_width} \
    din8_signed ${din8_signed} \
    din9_width ${din9_width} \
    din9_signed ${din9_signed} \
    din10_width ${din10_width} \
    din10_signed ${din10_signed} \
    din11_width ${din11_width} \
    din11_signed ${din11_signed} \
    din12_width ${din12_width} \
    din12_signed ${din12_signed} \
    din13_width ${din13_width} \
    din13_signed ${din13_signed} \
    din14_width ${din14_width} \
    din14_signed ${din14_signed} \
    din15_width ${din15_width} \
    din15_signed ${din15_signed} \
    din16_width ${din16_width} \
    din16_signed ${din16_signed} \
    din17_width ${din17_width} \
    din17_signed ${din17_signed} \
    din18_width ${din18_width} \
    din18_signed ${din18_signed} \
    din19_width ${din19_width} \
    din19_signed ${din19_signed} \
    din20_width ${din20_width} \
    din20_signed ${din20_signed} \
    din21_width ${din21_width} \
    din21_signed ${din21_signed} \
    din22_width ${din22_width} \
    din22_signed ${din22_signed} \
    din23_width ${din23_width} \
    din23_signed ${din23_signed} \
    din24_width ${din24_width} \
    din24_signed ${din24_signed} \
    din25_width ${din25_width} \
    din25_signed ${din25_signed} \
    din26_width ${din26_width} \
    din26_signed ${din26_signed} \
    din27_width ${din27_width} \
    din27_signed ${din27_signed} \
    din28_width ${din28_width} \
    din28_signed ${din28_signed} \
    din29_width ${din29_width} \
    din29_signed ${din29_signed} \
    din30_width ${din30_width} \
    din30_signed ${din30_signed} \
    din31_width ${din31_width} \
    din31_signed ${din31_signed} \
    din32_width ${din32_width} \
    din32_signed ${din32_signed} \
    dout_width ${dout_width} \
}"
} else {
puts "@W \[IMPL-101\] Cannot find ::AESL_LIB_VIRTEX::xil_gen_pipemux, check your platform lib"
}
}


# clear list
if {${::AESL::PGuard_autoexp_gen}} {
    cg_default_interface_gen_dc_begin
    cg_default_interface_gen_bundle_begin
    AESL_LIB_XILADAPTER::native_axis_begin
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9344 \
    name gmemC \
    type other \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_gmemC \
    op interface \
    ports { m_axi_gmemC_AWVALID { O 1 bit } m_axi_gmemC_AWREADY { I 1 bit } m_axi_gmemC_AWADDR { O 64 vector } m_axi_gmemC_AWID { O 1 vector } m_axi_gmemC_AWLEN { O 32 vector } m_axi_gmemC_AWSIZE { O 3 vector } m_axi_gmemC_AWBURST { O 2 vector } m_axi_gmemC_AWLOCK { O 2 vector } m_axi_gmemC_AWCACHE { O 4 vector } m_axi_gmemC_AWPROT { O 3 vector } m_axi_gmemC_AWQOS { O 4 vector } m_axi_gmemC_AWREGION { O 4 vector } m_axi_gmemC_AWUSER { O 1 vector } m_axi_gmemC_WVALID { O 1 bit } m_axi_gmemC_WREADY { I 1 bit } m_axi_gmemC_WDATA { O 32 vector } m_axi_gmemC_WSTRB { O 4 vector } m_axi_gmemC_WLAST { O 1 bit } m_axi_gmemC_WID { O 1 vector } m_axi_gmemC_WUSER { O 1 vector } m_axi_gmemC_ARVALID { O 1 bit } m_axi_gmemC_ARREADY { I 1 bit } m_axi_gmemC_ARADDR { O 64 vector } m_axi_gmemC_ARID { O 1 vector } m_axi_gmemC_ARLEN { O 32 vector } m_axi_gmemC_ARSIZE { O 3 vector } m_axi_gmemC_ARBURST { O 2 vector } m_axi_gmemC_ARLOCK { O 2 vector } m_axi_gmemC_ARCACHE { O 4 vector } m_axi_gmemC_ARPROT { O 3 vector } m_axi_gmemC_ARQOS { O 4 vector } m_axi_gmemC_ARREGION { O 4 vector } m_axi_gmemC_ARUSER { O 1 vector } m_axi_gmemC_RVALID { I 1 bit } m_axi_gmemC_RREADY { O 1 bit } m_axi_gmemC_RDATA { I 32 vector } m_axi_gmemC_RLAST { I 1 bit } m_axi_gmemC_RID { I 1 vector } m_axi_gmemC_RFIFONUM { I 9 vector } m_axi_gmemC_RUSER { I 1 vector } m_axi_gmemC_RRESP { I 2 vector } m_axi_gmemC_BVALID { I 1 bit } m_axi_gmemC_BREADY { O 1 bit } m_axi_gmemC_BRESP { I 2 vector } m_axi_gmemC_BID { I 1 vector } m_axi_gmemC_BUSER { I 1 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9345 \
    name select_ln132_2 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_select_ln132_2 \
    op interface \
    ports { select_ln132_2 { I 64 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9346 \
    name sext_ln110_2 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_sext_ln110_2 \
    op interface \
    ports { sext_ln110_2 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9347 \
    name p_mid \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_p_mid \
    op interface \
    ports { p_mid { I 62 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9348 \
    name sext_ln110_3 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_sext_ln110_3 \
    op interface \
    ports { sext_ln110_3 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9349 \
    name trunc_ln \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_trunc_ln \
    op interface \
    ports { trunc_ln { I 62 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9350 \
    name trunc_ln2 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_trunc_ln2 \
    op interface \
    ports { trunc_ln2 { I 62 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9351 \
    name select_ln132_1 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_select_ln132_1 \
    op interface \
    ports { select_ln132_1 { I 64 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9352 \
    name sext_ln119 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_sext_ln119 \
    op interface \
    ports { sext_ln119 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9353 \
    name localC_1023 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_1023 \
    op interface \
    ports { localC_1023 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9354 \
    name localC_1022 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_1022 \
    op interface \
    ports { localC_1022 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9355 \
    name localC_1021 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_1021 \
    op interface \
    ports { localC_1021 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9356 \
    name localC_1020 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_1020 \
    op interface \
    ports { localC_1020 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9357 \
    name localC_1019 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_1019 \
    op interface \
    ports { localC_1019 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9358 \
    name localC_1018 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_1018 \
    op interface \
    ports { localC_1018 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9359 \
    name localC_1017 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_1017 \
    op interface \
    ports { localC_1017 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9360 \
    name localC_1016 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_1016 \
    op interface \
    ports { localC_1016 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9361 \
    name localC_1015 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_1015 \
    op interface \
    ports { localC_1015 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9362 \
    name localC_1014 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_1014 \
    op interface \
    ports { localC_1014 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9363 \
    name localC_1013 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_1013 \
    op interface \
    ports { localC_1013 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9364 \
    name localC_1012 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_1012 \
    op interface \
    ports { localC_1012 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9365 \
    name localC_1011 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_1011 \
    op interface \
    ports { localC_1011 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9366 \
    name localC_1010 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_1010 \
    op interface \
    ports { localC_1010 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9367 \
    name localC_1009 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_1009 \
    op interface \
    ports { localC_1009 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9368 \
    name localC_1008 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_1008 \
    op interface \
    ports { localC_1008 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9369 \
    name localC_1007 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_1007 \
    op interface \
    ports { localC_1007 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9370 \
    name localC_1006 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_1006 \
    op interface \
    ports { localC_1006 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9371 \
    name localC_1005 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_1005 \
    op interface \
    ports { localC_1005 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9372 \
    name localC_1004 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_1004 \
    op interface \
    ports { localC_1004 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9373 \
    name localC_1003 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_1003 \
    op interface \
    ports { localC_1003 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9374 \
    name localC_1002 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_1002 \
    op interface \
    ports { localC_1002 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9375 \
    name localC_1001 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_1001 \
    op interface \
    ports { localC_1001 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9376 \
    name localC_1000 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_1000 \
    op interface \
    ports { localC_1000 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9377 \
    name localC_999 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_999 \
    op interface \
    ports { localC_999 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9378 \
    name localC_998 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_998 \
    op interface \
    ports { localC_998 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9379 \
    name localC_997 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_997 \
    op interface \
    ports { localC_997 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9380 \
    name localC_996 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_996 \
    op interface \
    ports { localC_996 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9381 \
    name localC_995 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_995 \
    op interface \
    ports { localC_995 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9382 \
    name localC_994 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_994 \
    op interface \
    ports { localC_994 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9383 \
    name localC_993 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_993 \
    op interface \
    ports { localC_993 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9384 \
    name localC_992 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_992 \
    op interface \
    ports { localC_992 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9385 \
    name localC_991 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_991 \
    op interface \
    ports { localC_991 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9386 \
    name localC_990 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_990 \
    op interface \
    ports { localC_990 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9387 \
    name localC_989 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_989 \
    op interface \
    ports { localC_989 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9388 \
    name localC_988 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_988 \
    op interface \
    ports { localC_988 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9389 \
    name localC_987 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_987 \
    op interface \
    ports { localC_987 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9390 \
    name localC_986 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_986 \
    op interface \
    ports { localC_986 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9391 \
    name localC_985 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_985 \
    op interface \
    ports { localC_985 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9392 \
    name localC_984 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_984 \
    op interface \
    ports { localC_984 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9393 \
    name localC_983 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_983 \
    op interface \
    ports { localC_983 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9394 \
    name localC_982 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_982 \
    op interface \
    ports { localC_982 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9395 \
    name localC_981 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_981 \
    op interface \
    ports { localC_981 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9396 \
    name localC_980 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_980 \
    op interface \
    ports { localC_980 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9397 \
    name localC_979 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_979 \
    op interface \
    ports { localC_979 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9398 \
    name localC_978 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_978 \
    op interface \
    ports { localC_978 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9399 \
    name localC_977 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_977 \
    op interface \
    ports { localC_977 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9400 \
    name localC_976 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_976 \
    op interface \
    ports { localC_976 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9401 \
    name localC_975 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_975 \
    op interface \
    ports { localC_975 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9402 \
    name localC_974 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_974 \
    op interface \
    ports { localC_974 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9403 \
    name localC_973 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_973 \
    op interface \
    ports { localC_973 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9404 \
    name localC_972 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_972 \
    op interface \
    ports { localC_972 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9405 \
    name localC_971 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_971 \
    op interface \
    ports { localC_971 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9406 \
    name localC_970 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_970 \
    op interface \
    ports { localC_970 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9407 \
    name localC_969 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_969 \
    op interface \
    ports { localC_969 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9408 \
    name localC_968 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_968 \
    op interface \
    ports { localC_968 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9409 \
    name localC_967 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_967 \
    op interface \
    ports { localC_967 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9410 \
    name localC_966 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_966 \
    op interface \
    ports { localC_966 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9411 \
    name localC_965 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_965 \
    op interface \
    ports { localC_965 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9412 \
    name localC_964 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_964 \
    op interface \
    ports { localC_964 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9413 \
    name localC_963 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_963 \
    op interface \
    ports { localC_963 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9414 \
    name localC_962 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_962 \
    op interface \
    ports { localC_962 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9415 \
    name localC_961 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_961 \
    op interface \
    ports { localC_961 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9416 \
    name localC_960 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_960 \
    op interface \
    ports { localC_960 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9417 \
    name localC_959 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_959 \
    op interface \
    ports { localC_959 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9418 \
    name localC_958 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_958 \
    op interface \
    ports { localC_958 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9419 \
    name localC_957 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_957 \
    op interface \
    ports { localC_957 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9420 \
    name localC_956 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_956 \
    op interface \
    ports { localC_956 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9421 \
    name localC_955 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_955 \
    op interface \
    ports { localC_955 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9422 \
    name localC_954 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_954 \
    op interface \
    ports { localC_954 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9423 \
    name localC_953 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_953 \
    op interface \
    ports { localC_953 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9424 \
    name localC_952 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_952 \
    op interface \
    ports { localC_952 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9425 \
    name localC_951 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_951 \
    op interface \
    ports { localC_951 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9426 \
    name localC_950 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_950 \
    op interface \
    ports { localC_950 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9427 \
    name localC_949 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_949 \
    op interface \
    ports { localC_949 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9428 \
    name localC_948 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_948 \
    op interface \
    ports { localC_948 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9429 \
    name localC_947 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_947 \
    op interface \
    ports { localC_947 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9430 \
    name localC_946 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_946 \
    op interface \
    ports { localC_946 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9431 \
    name localC_945 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_945 \
    op interface \
    ports { localC_945 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9432 \
    name localC_944 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_944 \
    op interface \
    ports { localC_944 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9433 \
    name localC_943 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_943 \
    op interface \
    ports { localC_943 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9434 \
    name localC_942 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_942 \
    op interface \
    ports { localC_942 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9435 \
    name localC_941 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_941 \
    op interface \
    ports { localC_941 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9436 \
    name localC_940 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_940 \
    op interface \
    ports { localC_940 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9437 \
    name localC_939 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_939 \
    op interface \
    ports { localC_939 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9438 \
    name localC_938 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_938 \
    op interface \
    ports { localC_938 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9439 \
    name localC_937 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_937 \
    op interface \
    ports { localC_937 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9440 \
    name localC_936 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_936 \
    op interface \
    ports { localC_936 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9441 \
    name localC_935 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_935 \
    op interface \
    ports { localC_935 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9442 \
    name localC_934 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_934 \
    op interface \
    ports { localC_934 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9443 \
    name localC_933 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_933 \
    op interface \
    ports { localC_933 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9444 \
    name localC_932 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_932 \
    op interface \
    ports { localC_932 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9445 \
    name localC_931 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_931 \
    op interface \
    ports { localC_931 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9446 \
    name localC_930 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_930 \
    op interface \
    ports { localC_930 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9447 \
    name localC_929 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_929 \
    op interface \
    ports { localC_929 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9448 \
    name localC_928 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_928 \
    op interface \
    ports { localC_928 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9449 \
    name localC_927 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_927 \
    op interface \
    ports { localC_927 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9450 \
    name localC_926 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_926 \
    op interface \
    ports { localC_926 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9451 \
    name localC_925 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_925 \
    op interface \
    ports { localC_925 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9452 \
    name localC_924 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_924 \
    op interface \
    ports { localC_924 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9453 \
    name localC_923 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_923 \
    op interface \
    ports { localC_923 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9454 \
    name localC_922 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_922 \
    op interface \
    ports { localC_922 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9455 \
    name localC_921 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_921 \
    op interface \
    ports { localC_921 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9456 \
    name localC_920 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_920 \
    op interface \
    ports { localC_920 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9457 \
    name localC_919 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_919 \
    op interface \
    ports { localC_919 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9458 \
    name localC_918 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_918 \
    op interface \
    ports { localC_918 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9459 \
    name localC_917 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_917 \
    op interface \
    ports { localC_917 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9460 \
    name localC_916 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_916 \
    op interface \
    ports { localC_916 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9461 \
    name localC_915 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_915 \
    op interface \
    ports { localC_915 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9462 \
    name localC_914 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_914 \
    op interface \
    ports { localC_914 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9463 \
    name localC_913 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_913 \
    op interface \
    ports { localC_913 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9464 \
    name localC_912 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_912 \
    op interface \
    ports { localC_912 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9465 \
    name localC_911 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_911 \
    op interface \
    ports { localC_911 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9466 \
    name localC_910 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_910 \
    op interface \
    ports { localC_910 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9467 \
    name localC_909 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_909 \
    op interface \
    ports { localC_909 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9468 \
    name localC_908 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_908 \
    op interface \
    ports { localC_908 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9469 \
    name localC_907 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_907 \
    op interface \
    ports { localC_907 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9470 \
    name localC_906 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_906 \
    op interface \
    ports { localC_906 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9471 \
    name localC_905 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_905 \
    op interface \
    ports { localC_905 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9472 \
    name localC_904 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_904 \
    op interface \
    ports { localC_904 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9473 \
    name localC_903 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_903 \
    op interface \
    ports { localC_903 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9474 \
    name localC_902 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_902 \
    op interface \
    ports { localC_902 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9475 \
    name localC_901 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_901 \
    op interface \
    ports { localC_901 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9476 \
    name localC_900 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_900 \
    op interface \
    ports { localC_900 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9477 \
    name localC_899 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_899 \
    op interface \
    ports { localC_899 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9478 \
    name localC_898 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_898 \
    op interface \
    ports { localC_898 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9479 \
    name localC_897 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_897 \
    op interface \
    ports { localC_897 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9480 \
    name localC_896 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_896 \
    op interface \
    ports { localC_896 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9481 \
    name localC_895 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_895 \
    op interface \
    ports { localC_895 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9482 \
    name localC_894 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_894 \
    op interface \
    ports { localC_894 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9483 \
    name localC_893 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_893 \
    op interface \
    ports { localC_893 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9484 \
    name localC_892 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_892 \
    op interface \
    ports { localC_892 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9485 \
    name localC_891 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_891 \
    op interface \
    ports { localC_891 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9486 \
    name localC_890 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_890 \
    op interface \
    ports { localC_890 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9487 \
    name localC_889 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_889 \
    op interface \
    ports { localC_889 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9488 \
    name localC_888 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_888 \
    op interface \
    ports { localC_888 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9489 \
    name localC_887 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_887 \
    op interface \
    ports { localC_887 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9490 \
    name localC_886 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_886 \
    op interface \
    ports { localC_886 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9491 \
    name localC_885 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_885 \
    op interface \
    ports { localC_885 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9492 \
    name localC_884 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_884 \
    op interface \
    ports { localC_884 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9493 \
    name localC_883 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_883 \
    op interface \
    ports { localC_883 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9494 \
    name localC_882 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_882 \
    op interface \
    ports { localC_882 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9495 \
    name localC_881 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_881 \
    op interface \
    ports { localC_881 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9496 \
    name localC_880 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_880 \
    op interface \
    ports { localC_880 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9497 \
    name localC_879 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_879 \
    op interface \
    ports { localC_879 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9498 \
    name localC_878 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_878 \
    op interface \
    ports { localC_878 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9499 \
    name localC_877 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_877 \
    op interface \
    ports { localC_877 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9500 \
    name localC_876 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_876 \
    op interface \
    ports { localC_876 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9501 \
    name localC_875 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_875 \
    op interface \
    ports { localC_875 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9502 \
    name localC_874 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_874 \
    op interface \
    ports { localC_874 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9503 \
    name localC_873 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_873 \
    op interface \
    ports { localC_873 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9504 \
    name localC_872 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_872 \
    op interface \
    ports { localC_872 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9505 \
    name localC_871 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_871 \
    op interface \
    ports { localC_871 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9506 \
    name localC_870 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_870 \
    op interface \
    ports { localC_870 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9507 \
    name localC_869 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_869 \
    op interface \
    ports { localC_869 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9508 \
    name localC_868 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_868 \
    op interface \
    ports { localC_868 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9509 \
    name localC_867 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_867 \
    op interface \
    ports { localC_867 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9510 \
    name localC_866 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_866 \
    op interface \
    ports { localC_866 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9511 \
    name localC_865 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_865 \
    op interface \
    ports { localC_865 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9512 \
    name localC_864 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_864 \
    op interface \
    ports { localC_864 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9513 \
    name localC_863 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_863 \
    op interface \
    ports { localC_863 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9514 \
    name localC_862 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_862 \
    op interface \
    ports { localC_862 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9515 \
    name localC_861 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_861 \
    op interface \
    ports { localC_861 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9516 \
    name localC_860 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_860 \
    op interface \
    ports { localC_860 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9517 \
    name localC_859 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_859 \
    op interface \
    ports { localC_859 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9518 \
    name localC_858 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_858 \
    op interface \
    ports { localC_858 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9519 \
    name localC_857 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_857 \
    op interface \
    ports { localC_857 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9520 \
    name localC_856 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_856 \
    op interface \
    ports { localC_856 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9521 \
    name localC_855 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_855 \
    op interface \
    ports { localC_855 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9522 \
    name localC_854 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_854 \
    op interface \
    ports { localC_854 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9523 \
    name localC_853 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_853 \
    op interface \
    ports { localC_853 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9524 \
    name localC_852 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_852 \
    op interface \
    ports { localC_852 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9525 \
    name localC_851 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_851 \
    op interface \
    ports { localC_851 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9526 \
    name localC_850 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_850 \
    op interface \
    ports { localC_850 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9527 \
    name localC_849 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_849 \
    op interface \
    ports { localC_849 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9528 \
    name localC_848 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_848 \
    op interface \
    ports { localC_848 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9529 \
    name localC_847 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_847 \
    op interface \
    ports { localC_847 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9530 \
    name localC_846 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_846 \
    op interface \
    ports { localC_846 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9531 \
    name localC_845 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_845 \
    op interface \
    ports { localC_845 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9532 \
    name localC_844 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_844 \
    op interface \
    ports { localC_844 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9533 \
    name localC_843 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_843 \
    op interface \
    ports { localC_843 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9534 \
    name localC_842 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_842 \
    op interface \
    ports { localC_842 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9535 \
    name localC_841 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_841 \
    op interface \
    ports { localC_841 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9536 \
    name localC_840 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_840 \
    op interface \
    ports { localC_840 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9537 \
    name localC_839 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_839 \
    op interface \
    ports { localC_839 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9538 \
    name localC_838 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_838 \
    op interface \
    ports { localC_838 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9539 \
    name localC_837 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_837 \
    op interface \
    ports { localC_837 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9540 \
    name localC_836 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_836 \
    op interface \
    ports { localC_836 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9541 \
    name localC_835 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_835 \
    op interface \
    ports { localC_835 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9542 \
    name localC_834 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_834 \
    op interface \
    ports { localC_834 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9543 \
    name localC_833 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_833 \
    op interface \
    ports { localC_833 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9544 \
    name localC_832 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_832 \
    op interface \
    ports { localC_832 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9545 \
    name localC_831 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_831 \
    op interface \
    ports { localC_831 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9546 \
    name localC_830 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_830 \
    op interface \
    ports { localC_830 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9547 \
    name localC_829 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_829 \
    op interface \
    ports { localC_829 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9548 \
    name localC_828 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_828 \
    op interface \
    ports { localC_828 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9549 \
    name localC_827 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_827 \
    op interface \
    ports { localC_827 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9550 \
    name localC_826 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_826 \
    op interface \
    ports { localC_826 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9551 \
    name localC_825 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_825 \
    op interface \
    ports { localC_825 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9552 \
    name localC_824 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_824 \
    op interface \
    ports { localC_824 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9553 \
    name localC_823 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_823 \
    op interface \
    ports { localC_823 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9554 \
    name localC_822 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_822 \
    op interface \
    ports { localC_822 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9555 \
    name localC_821 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_821 \
    op interface \
    ports { localC_821 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9556 \
    name localC_820 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_820 \
    op interface \
    ports { localC_820 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9557 \
    name localC_819 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_819 \
    op interface \
    ports { localC_819 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9558 \
    name localC_818 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_818 \
    op interface \
    ports { localC_818 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9559 \
    name localC_817 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_817 \
    op interface \
    ports { localC_817 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9560 \
    name localC_816 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_816 \
    op interface \
    ports { localC_816 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9561 \
    name localC_815 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_815 \
    op interface \
    ports { localC_815 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9562 \
    name localC_814 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_814 \
    op interface \
    ports { localC_814 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9563 \
    name localC_813 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_813 \
    op interface \
    ports { localC_813 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9564 \
    name localC_812 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_812 \
    op interface \
    ports { localC_812 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9565 \
    name localC_811 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_811 \
    op interface \
    ports { localC_811 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9566 \
    name localC_810 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_810 \
    op interface \
    ports { localC_810 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9567 \
    name localC_809 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_809 \
    op interface \
    ports { localC_809 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9568 \
    name localC_808 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_808 \
    op interface \
    ports { localC_808 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9569 \
    name localC_807 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_807 \
    op interface \
    ports { localC_807 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9570 \
    name localC_806 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_806 \
    op interface \
    ports { localC_806 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9571 \
    name localC_805 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_805 \
    op interface \
    ports { localC_805 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9572 \
    name localC_804 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_804 \
    op interface \
    ports { localC_804 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9573 \
    name localC_803 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_803 \
    op interface \
    ports { localC_803 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9574 \
    name localC_802 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_802 \
    op interface \
    ports { localC_802 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9575 \
    name localC_801 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_801 \
    op interface \
    ports { localC_801 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9576 \
    name localC_800 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_800 \
    op interface \
    ports { localC_800 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9577 \
    name localC_799 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_799 \
    op interface \
    ports { localC_799 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9578 \
    name localC_798 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_798 \
    op interface \
    ports { localC_798 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9579 \
    name localC_797 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_797 \
    op interface \
    ports { localC_797 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9580 \
    name localC_796 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_796 \
    op interface \
    ports { localC_796 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9581 \
    name localC_795 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_795 \
    op interface \
    ports { localC_795 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9582 \
    name localC_794 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_794 \
    op interface \
    ports { localC_794 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9583 \
    name localC_793 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_793 \
    op interface \
    ports { localC_793 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9584 \
    name localC_792 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_792 \
    op interface \
    ports { localC_792 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9585 \
    name localC_791 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_791 \
    op interface \
    ports { localC_791 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9586 \
    name localC_790 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_790 \
    op interface \
    ports { localC_790 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9587 \
    name localC_789 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_789 \
    op interface \
    ports { localC_789 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9588 \
    name localC_788 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_788 \
    op interface \
    ports { localC_788 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9589 \
    name localC_787 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_787 \
    op interface \
    ports { localC_787 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9590 \
    name localC_786 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_786 \
    op interface \
    ports { localC_786 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9591 \
    name localC_785 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_785 \
    op interface \
    ports { localC_785 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9592 \
    name localC_784 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_784 \
    op interface \
    ports { localC_784 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9593 \
    name localC_783 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_783 \
    op interface \
    ports { localC_783 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9594 \
    name localC_782 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_782 \
    op interface \
    ports { localC_782 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9595 \
    name localC_781 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_781 \
    op interface \
    ports { localC_781 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9596 \
    name localC_780 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_780 \
    op interface \
    ports { localC_780 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9597 \
    name localC_779 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_779 \
    op interface \
    ports { localC_779 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9598 \
    name localC_778 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_778 \
    op interface \
    ports { localC_778 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9599 \
    name localC_777 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_777 \
    op interface \
    ports { localC_777 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9600 \
    name localC_776 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_776 \
    op interface \
    ports { localC_776 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9601 \
    name localC_775 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_775 \
    op interface \
    ports { localC_775 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9602 \
    name localC_774 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_774 \
    op interface \
    ports { localC_774 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9603 \
    name localC_773 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_773 \
    op interface \
    ports { localC_773 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9604 \
    name localC_772 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_772 \
    op interface \
    ports { localC_772 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9605 \
    name localC_771 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_771 \
    op interface \
    ports { localC_771 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9606 \
    name localC_770 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_770 \
    op interface \
    ports { localC_770 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9607 \
    name localC_769 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_769 \
    op interface \
    ports { localC_769 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9608 \
    name localC_768 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_768 \
    op interface \
    ports { localC_768 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9609 \
    name localC_767 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_767 \
    op interface \
    ports { localC_767 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9610 \
    name localC_766 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_766 \
    op interface \
    ports { localC_766 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9611 \
    name localC_765 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_765 \
    op interface \
    ports { localC_765 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9612 \
    name localC_764 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_764 \
    op interface \
    ports { localC_764 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9613 \
    name localC_763 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_763 \
    op interface \
    ports { localC_763 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9614 \
    name localC_762 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_762 \
    op interface \
    ports { localC_762 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9615 \
    name localC_761 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_761 \
    op interface \
    ports { localC_761 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9616 \
    name localC_760 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_760 \
    op interface \
    ports { localC_760 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9617 \
    name localC_759 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_759 \
    op interface \
    ports { localC_759 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9618 \
    name localC_758 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_758 \
    op interface \
    ports { localC_758 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9619 \
    name localC_757 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_757 \
    op interface \
    ports { localC_757 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9620 \
    name localC_756 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_756 \
    op interface \
    ports { localC_756 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9621 \
    name localC_755 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_755 \
    op interface \
    ports { localC_755 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9622 \
    name localC_754 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_754 \
    op interface \
    ports { localC_754 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9623 \
    name localC_753 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_753 \
    op interface \
    ports { localC_753 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9624 \
    name localC_752 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_752 \
    op interface \
    ports { localC_752 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9625 \
    name localC_751 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_751 \
    op interface \
    ports { localC_751 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9626 \
    name localC_750 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_750 \
    op interface \
    ports { localC_750 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9627 \
    name localC_749 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_749 \
    op interface \
    ports { localC_749 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9628 \
    name localC_748 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_748 \
    op interface \
    ports { localC_748 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9629 \
    name localC_747 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_747 \
    op interface \
    ports { localC_747 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9630 \
    name localC_746 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_746 \
    op interface \
    ports { localC_746 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9631 \
    name localC_745 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_745 \
    op interface \
    ports { localC_745 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9632 \
    name localC_744 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_744 \
    op interface \
    ports { localC_744 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9633 \
    name localC_743 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_743 \
    op interface \
    ports { localC_743 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9634 \
    name localC_742 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_742 \
    op interface \
    ports { localC_742 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9635 \
    name localC_741 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_741 \
    op interface \
    ports { localC_741 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9636 \
    name localC_740 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_740 \
    op interface \
    ports { localC_740 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9637 \
    name localC_739 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_739 \
    op interface \
    ports { localC_739 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9638 \
    name localC_738 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_738 \
    op interface \
    ports { localC_738 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9639 \
    name localC_737 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_737 \
    op interface \
    ports { localC_737 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9640 \
    name localC_736 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_736 \
    op interface \
    ports { localC_736 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9641 \
    name localC_735 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_735 \
    op interface \
    ports { localC_735 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9642 \
    name localC_734 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_734 \
    op interface \
    ports { localC_734 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9643 \
    name localC_733 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_733 \
    op interface \
    ports { localC_733 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9644 \
    name localC_732 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_732 \
    op interface \
    ports { localC_732 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9645 \
    name localC_731 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_731 \
    op interface \
    ports { localC_731 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9646 \
    name localC_730 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_730 \
    op interface \
    ports { localC_730 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9647 \
    name localC_729 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_729 \
    op interface \
    ports { localC_729 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9648 \
    name localC_728 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_728 \
    op interface \
    ports { localC_728 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9649 \
    name localC_727 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_727 \
    op interface \
    ports { localC_727 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9650 \
    name localC_726 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_726 \
    op interface \
    ports { localC_726 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9651 \
    name localC_725 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_725 \
    op interface \
    ports { localC_725 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9652 \
    name localC_724 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_724 \
    op interface \
    ports { localC_724 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9653 \
    name localC_723 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_723 \
    op interface \
    ports { localC_723 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9654 \
    name localC_722 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_722 \
    op interface \
    ports { localC_722 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9655 \
    name localC_721 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_721 \
    op interface \
    ports { localC_721 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9656 \
    name localC_720 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_720 \
    op interface \
    ports { localC_720 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9657 \
    name localC_719 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_719 \
    op interface \
    ports { localC_719 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9658 \
    name localC_718 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_718 \
    op interface \
    ports { localC_718 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9659 \
    name localC_717 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_717 \
    op interface \
    ports { localC_717 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9660 \
    name localC_716 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_716 \
    op interface \
    ports { localC_716 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9661 \
    name localC_715 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_715 \
    op interface \
    ports { localC_715 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9662 \
    name localC_714 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_714 \
    op interface \
    ports { localC_714 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9663 \
    name localC_713 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_713 \
    op interface \
    ports { localC_713 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9664 \
    name localC_712 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_712 \
    op interface \
    ports { localC_712 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9665 \
    name localC_711 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_711 \
    op interface \
    ports { localC_711 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9666 \
    name localC_710 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_710 \
    op interface \
    ports { localC_710 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9667 \
    name localC_709 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_709 \
    op interface \
    ports { localC_709 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9668 \
    name localC_708 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_708 \
    op interface \
    ports { localC_708 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9669 \
    name localC_707 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_707 \
    op interface \
    ports { localC_707 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9670 \
    name localC_706 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_706 \
    op interface \
    ports { localC_706 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9671 \
    name localC_705 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_705 \
    op interface \
    ports { localC_705 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9672 \
    name localC_704 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_704 \
    op interface \
    ports { localC_704 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9673 \
    name localC_703 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_703 \
    op interface \
    ports { localC_703 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9674 \
    name localC_702 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_702 \
    op interface \
    ports { localC_702 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9675 \
    name localC_701 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_701 \
    op interface \
    ports { localC_701 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9676 \
    name localC_700 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_700 \
    op interface \
    ports { localC_700 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9677 \
    name localC_699 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_699 \
    op interface \
    ports { localC_699 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9678 \
    name localC_698 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_698 \
    op interface \
    ports { localC_698 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9679 \
    name localC_697 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_697 \
    op interface \
    ports { localC_697 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9680 \
    name localC_696 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_696 \
    op interface \
    ports { localC_696 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9681 \
    name localC_695 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_695 \
    op interface \
    ports { localC_695 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9682 \
    name localC_694 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_694 \
    op interface \
    ports { localC_694 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9683 \
    name localC_693 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_693 \
    op interface \
    ports { localC_693 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9684 \
    name localC_692 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_692 \
    op interface \
    ports { localC_692 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9685 \
    name localC_691 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_691 \
    op interface \
    ports { localC_691 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9686 \
    name localC_690 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_690 \
    op interface \
    ports { localC_690 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9687 \
    name localC_689 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_689 \
    op interface \
    ports { localC_689 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9688 \
    name localC_688 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_688 \
    op interface \
    ports { localC_688 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9689 \
    name localC_687 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_687 \
    op interface \
    ports { localC_687 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9690 \
    name localC_686 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_686 \
    op interface \
    ports { localC_686 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9691 \
    name localC_685 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_685 \
    op interface \
    ports { localC_685 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9692 \
    name localC_684 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_684 \
    op interface \
    ports { localC_684 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9693 \
    name localC_683 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_683 \
    op interface \
    ports { localC_683 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9694 \
    name localC_682 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_682 \
    op interface \
    ports { localC_682 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9695 \
    name localC_681 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_681 \
    op interface \
    ports { localC_681 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9696 \
    name localC_680 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_680 \
    op interface \
    ports { localC_680 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9697 \
    name localC_679 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_679 \
    op interface \
    ports { localC_679 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9698 \
    name localC_678 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_678 \
    op interface \
    ports { localC_678 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9699 \
    name localC_677 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_677 \
    op interface \
    ports { localC_677 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9700 \
    name localC_676 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_676 \
    op interface \
    ports { localC_676 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9701 \
    name localC_675 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_675 \
    op interface \
    ports { localC_675 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9702 \
    name localC_674 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_674 \
    op interface \
    ports { localC_674 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9703 \
    name localC_673 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_673 \
    op interface \
    ports { localC_673 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9704 \
    name localC_672 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_672 \
    op interface \
    ports { localC_672 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9705 \
    name localC_671 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_671 \
    op interface \
    ports { localC_671 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9706 \
    name localC_670 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_670 \
    op interface \
    ports { localC_670 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9707 \
    name localC_669 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_669 \
    op interface \
    ports { localC_669 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9708 \
    name localC_668 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_668 \
    op interface \
    ports { localC_668 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9709 \
    name localC_667 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_667 \
    op interface \
    ports { localC_667 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9710 \
    name localC_666 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_666 \
    op interface \
    ports { localC_666 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9711 \
    name localC_665 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_665 \
    op interface \
    ports { localC_665 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9712 \
    name localC_664 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_664 \
    op interface \
    ports { localC_664 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9713 \
    name localC_663 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_663 \
    op interface \
    ports { localC_663 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9714 \
    name localC_662 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_662 \
    op interface \
    ports { localC_662 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9715 \
    name localC_661 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_661 \
    op interface \
    ports { localC_661 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9716 \
    name localC_660 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_660 \
    op interface \
    ports { localC_660 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9717 \
    name localC_659 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_659 \
    op interface \
    ports { localC_659 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9718 \
    name localC_658 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_658 \
    op interface \
    ports { localC_658 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9719 \
    name localC_657 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_657 \
    op interface \
    ports { localC_657 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9720 \
    name localC_656 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_656 \
    op interface \
    ports { localC_656 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9721 \
    name localC_655 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_655 \
    op interface \
    ports { localC_655 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9722 \
    name localC_654 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_654 \
    op interface \
    ports { localC_654 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9723 \
    name localC_653 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_653 \
    op interface \
    ports { localC_653 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9724 \
    name localC_652 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_652 \
    op interface \
    ports { localC_652 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9725 \
    name localC_651 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_651 \
    op interface \
    ports { localC_651 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9726 \
    name localC_650 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_650 \
    op interface \
    ports { localC_650 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9727 \
    name localC_649 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_649 \
    op interface \
    ports { localC_649 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9728 \
    name localC_648 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_648 \
    op interface \
    ports { localC_648 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9729 \
    name localC_647 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_647 \
    op interface \
    ports { localC_647 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9730 \
    name localC_646 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_646 \
    op interface \
    ports { localC_646 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9731 \
    name localC_645 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_645 \
    op interface \
    ports { localC_645 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9732 \
    name localC_644 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_644 \
    op interface \
    ports { localC_644 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9733 \
    name localC_643 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_643 \
    op interface \
    ports { localC_643 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9734 \
    name localC_642 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_642 \
    op interface \
    ports { localC_642 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9735 \
    name localC_641 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_641 \
    op interface \
    ports { localC_641 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9736 \
    name localC_640 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_640 \
    op interface \
    ports { localC_640 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9737 \
    name localC_639 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_639 \
    op interface \
    ports { localC_639 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9738 \
    name localC_638 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_638 \
    op interface \
    ports { localC_638 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9739 \
    name localC_637 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_637 \
    op interface \
    ports { localC_637 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9740 \
    name localC_636 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_636 \
    op interface \
    ports { localC_636 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9741 \
    name localC_635 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_635 \
    op interface \
    ports { localC_635 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9742 \
    name localC_634 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_634 \
    op interface \
    ports { localC_634 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9743 \
    name localC_633 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_633 \
    op interface \
    ports { localC_633 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9744 \
    name localC_632 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_632 \
    op interface \
    ports { localC_632 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9745 \
    name localC_631 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_631 \
    op interface \
    ports { localC_631 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9746 \
    name localC_630 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_630 \
    op interface \
    ports { localC_630 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9747 \
    name localC_629 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_629 \
    op interface \
    ports { localC_629 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9748 \
    name localC_628 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_628 \
    op interface \
    ports { localC_628 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9749 \
    name localC_627 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_627 \
    op interface \
    ports { localC_627 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9750 \
    name localC_626 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_626 \
    op interface \
    ports { localC_626 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9751 \
    name localC_625 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_625 \
    op interface \
    ports { localC_625 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9752 \
    name localC_624 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_624 \
    op interface \
    ports { localC_624 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9753 \
    name localC_623 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_623 \
    op interface \
    ports { localC_623 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9754 \
    name localC_622 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_622 \
    op interface \
    ports { localC_622 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9755 \
    name localC_621 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_621 \
    op interface \
    ports { localC_621 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9756 \
    name localC_620 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_620 \
    op interface \
    ports { localC_620 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9757 \
    name localC_619 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_619 \
    op interface \
    ports { localC_619 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9758 \
    name localC_618 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_618 \
    op interface \
    ports { localC_618 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9759 \
    name localC_617 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_617 \
    op interface \
    ports { localC_617 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9760 \
    name localC_616 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_616 \
    op interface \
    ports { localC_616 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9761 \
    name localC_615 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_615 \
    op interface \
    ports { localC_615 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9762 \
    name localC_614 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_614 \
    op interface \
    ports { localC_614 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9763 \
    name localC_613 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_613 \
    op interface \
    ports { localC_613 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9764 \
    name localC_612 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_612 \
    op interface \
    ports { localC_612 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9765 \
    name localC_611 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_611 \
    op interface \
    ports { localC_611 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9766 \
    name localC_610 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_610 \
    op interface \
    ports { localC_610 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9767 \
    name localC_609 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_609 \
    op interface \
    ports { localC_609 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9768 \
    name localC_608 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_608 \
    op interface \
    ports { localC_608 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9769 \
    name localC_607 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_607 \
    op interface \
    ports { localC_607 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9770 \
    name localC_606 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_606 \
    op interface \
    ports { localC_606 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9771 \
    name localC_605 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_605 \
    op interface \
    ports { localC_605 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9772 \
    name localC_604 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_604 \
    op interface \
    ports { localC_604 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9773 \
    name localC_603 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_603 \
    op interface \
    ports { localC_603 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9774 \
    name localC_602 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_602 \
    op interface \
    ports { localC_602 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9775 \
    name localC_601 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_601 \
    op interface \
    ports { localC_601 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9776 \
    name localC_600 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_600 \
    op interface \
    ports { localC_600 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9777 \
    name localC_599 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_599 \
    op interface \
    ports { localC_599 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9778 \
    name localC_598 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_598 \
    op interface \
    ports { localC_598 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9779 \
    name localC_597 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_597 \
    op interface \
    ports { localC_597 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9780 \
    name localC_596 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_596 \
    op interface \
    ports { localC_596 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9781 \
    name localC_595 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_595 \
    op interface \
    ports { localC_595 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9782 \
    name localC_594 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_594 \
    op interface \
    ports { localC_594 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9783 \
    name localC_593 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_593 \
    op interface \
    ports { localC_593 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9784 \
    name localC_592 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_592 \
    op interface \
    ports { localC_592 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9785 \
    name localC_591 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_591 \
    op interface \
    ports { localC_591 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9786 \
    name localC_590 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_590 \
    op interface \
    ports { localC_590 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9787 \
    name localC_589 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_589 \
    op interface \
    ports { localC_589 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9788 \
    name localC_588 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_588 \
    op interface \
    ports { localC_588 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9789 \
    name localC_587 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_587 \
    op interface \
    ports { localC_587 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9790 \
    name localC_586 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_586 \
    op interface \
    ports { localC_586 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9791 \
    name localC_585 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_585 \
    op interface \
    ports { localC_585 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9792 \
    name localC_584 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_584 \
    op interface \
    ports { localC_584 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9793 \
    name localC_583 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_583 \
    op interface \
    ports { localC_583 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9794 \
    name localC_582 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_582 \
    op interface \
    ports { localC_582 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9795 \
    name localC_581 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_581 \
    op interface \
    ports { localC_581 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9796 \
    name localC_580 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_580 \
    op interface \
    ports { localC_580 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9797 \
    name localC_579 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_579 \
    op interface \
    ports { localC_579 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9798 \
    name localC_578 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_578 \
    op interface \
    ports { localC_578 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9799 \
    name localC_577 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_577 \
    op interface \
    ports { localC_577 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9800 \
    name localC_576 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_576 \
    op interface \
    ports { localC_576 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9801 \
    name localC_575 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_575 \
    op interface \
    ports { localC_575 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9802 \
    name localC_574 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_574 \
    op interface \
    ports { localC_574 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9803 \
    name localC_573 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_573 \
    op interface \
    ports { localC_573 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9804 \
    name localC_572 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_572 \
    op interface \
    ports { localC_572 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9805 \
    name localC_571 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_571 \
    op interface \
    ports { localC_571 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9806 \
    name localC_570 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_570 \
    op interface \
    ports { localC_570 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9807 \
    name localC_569 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_569 \
    op interface \
    ports { localC_569 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9808 \
    name localC_568 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_568 \
    op interface \
    ports { localC_568 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9809 \
    name localC_567 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_567 \
    op interface \
    ports { localC_567 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9810 \
    name localC_566 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_566 \
    op interface \
    ports { localC_566 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9811 \
    name localC_565 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_565 \
    op interface \
    ports { localC_565 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9812 \
    name localC_564 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_564 \
    op interface \
    ports { localC_564 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9813 \
    name localC_563 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_563 \
    op interface \
    ports { localC_563 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9814 \
    name localC_562 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_562 \
    op interface \
    ports { localC_562 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9815 \
    name localC_561 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_561 \
    op interface \
    ports { localC_561 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9816 \
    name localC_560 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_560 \
    op interface \
    ports { localC_560 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9817 \
    name localC_559 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_559 \
    op interface \
    ports { localC_559 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9818 \
    name localC_558 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_558 \
    op interface \
    ports { localC_558 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9819 \
    name localC_557 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_557 \
    op interface \
    ports { localC_557 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9820 \
    name localC_556 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_556 \
    op interface \
    ports { localC_556 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9821 \
    name localC_555 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_555 \
    op interface \
    ports { localC_555 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9822 \
    name localC_554 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_554 \
    op interface \
    ports { localC_554 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9823 \
    name localC_553 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_553 \
    op interface \
    ports { localC_553 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9824 \
    name localC_552 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_552 \
    op interface \
    ports { localC_552 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9825 \
    name localC_551 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_551 \
    op interface \
    ports { localC_551 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9826 \
    name localC_550 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_550 \
    op interface \
    ports { localC_550 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9827 \
    name localC_549 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_549 \
    op interface \
    ports { localC_549 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9828 \
    name localC_548 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_548 \
    op interface \
    ports { localC_548 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9829 \
    name localC_547 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_547 \
    op interface \
    ports { localC_547 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9830 \
    name localC_546 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_546 \
    op interface \
    ports { localC_546 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9831 \
    name localC_545 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_545 \
    op interface \
    ports { localC_545 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9832 \
    name localC_544 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_544 \
    op interface \
    ports { localC_544 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9833 \
    name localC_543 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_543 \
    op interface \
    ports { localC_543 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9834 \
    name localC_542 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_542 \
    op interface \
    ports { localC_542 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9835 \
    name localC_541 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_541 \
    op interface \
    ports { localC_541 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9836 \
    name localC_540 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_540 \
    op interface \
    ports { localC_540 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9837 \
    name localC_539 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_539 \
    op interface \
    ports { localC_539 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9838 \
    name localC_538 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_538 \
    op interface \
    ports { localC_538 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9839 \
    name localC_537 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_537 \
    op interface \
    ports { localC_537 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9840 \
    name localC_536 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_536 \
    op interface \
    ports { localC_536 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9841 \
    name localC_535 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_535 \
    op interface \
    ports { localC_535 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9842 \
    name localC_534 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_534 \
    op interface \
    ports { localC_534 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9843 \
    name localC_533 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_533 \
    op interface \
    ports { localC_533 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9844 \
    name localC_532 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_532 \
    op interface \
    ports { localC_532 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9845 \
    name localC_531 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_531 \
    op interface \
    ports { localC_531 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9846 \
    name localC_530 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_530 \
    op interface \
    ports { localC_530 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9847 \
    name localC_529 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_529 \
    op interface \
    ports { localC_529 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9848 \
    name localC_528 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_528 \
    op interface \
    ports { localC_528 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9849 \
    name localC_527 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_527 \
    op interface \
    ports { localC_527 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9850 \
    name localC_526 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_526 \
    op interface \
    ports { localC_526 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9851 \
    name localC_525 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_525 \
    op interface \
    ports { localC_525 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9852 \
    name localC_524 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_524 \
    op interface \
    ports { localC_524 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9853 \
    name localC_523 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_523 \
    op interface \
    ports { localC_523 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9854 \
    name localC_522 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_522 \
    op interface \
    ports { localC_522 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9855 \
    name localC_521 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_521 \
    op interface \
    ports { localC_521 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9856 \
    name localC_520 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_520 \
    op interface \
    ports { localC_520 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9857 \
    name localC_519 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_519 \
    op interface \
    ports { localC_519 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9858 \
    name localC_518 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_518 \
    op interface \
    ports { localC_518 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9859 \
    name localC_517 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_517 \
    op interface \
    ports { localC_517 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9860 \
    name localC_516 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_516 \
    op interface \
    ports { localC_516 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9861 \
    name localC_515 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_515 \
    op interface \
    ports { localC_515 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9862 \
    name localC_514 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_514 \
    op interface \
    ports { localC_514 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9863 \
    name localC_513 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_513 \
    op interface \
    ports { localC_513 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9864 \
    name localC_512 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_512 \
    op interface \
    ports { localC_512 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9865 \
    name localC_511 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_511 \
    op interface \
    ports { localC_511 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9866 \
    name localC_510 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_510 \
    op interface \
    ports { localC_510 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9867 \
    name localC_509 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_509 \
    op interface \
    ports { localC_509 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9868 \
    name localC_508 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_508 \
    op interface \
    ports { localC_508 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9869 \
    name localC_507 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_507 \
    op interface \
    ports { localC_507 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9870 \
    name localC_506 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_506 \
    op interface \
    ports { localC_506 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9871 \
    name localC_505 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_505 \
    op interface \
    ports { localC_505 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9872 \
    name localC_504 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_504 \
    op interface \
    ports { localC_504 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9873 \
    name localC_503 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_503 \
    op interface \
    ports { localC_503 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9874 \
    name localC_502 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_502 \
    op interface \
    ports { localC_502 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9875 \
    name localC_501 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_501 \
    op interface \
    ports { localC_501 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9876 \
    name localC_500 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_500 \
    op interface \
    ports { localC_500 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9877 \
    name localC_499 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_499 \
    op interface \
    ports { localC_499 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9878 \
    name localC_498 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_498 \
    op interface \
    ports { localC_498 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9879 \
    name localC_497 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_497 \
    op interface \
    ports { localC_497 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9880 \
    name localC_496 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_496 \
    op interface \
    ports { localC_496 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9881 \
    name localC_495 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_495 \
    op interface \
    ports { localC_495 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9882 \
    name localC_494 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_494 \
    op interface \
    ports { localC_494 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9883 \
    name localC_493 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_493 \
    op interface \
    ports { localC_493 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9884 \
    name localC_492 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_492 \
    op interface \
    ports { localC_492 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9885 \
    name localC_491 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_491 \
    op interface \
    ports { localC_491 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9886 \
    name localC_490 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_490 \
    op interface \
    ports { localC_490 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9887 \
    name localC_489 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_489 \
    op interface \
    ports { localC_489 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9888 \
    name localC_488 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_488 \
    op interface \
    ports { localC_488 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9889 \
    name localC_487 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_487 \
    op interface \
    ports { localC_487 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9890 \
    name localC_486 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_486 \
    op interface \
    ports { localC_486 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9891 \
    name localC_485 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_485 \
    op interface \
    ports { localC_485 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9892 \
    name localC_484 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_484 \
    op interface \
    ports { localC_484 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9893 \
    name localC_483 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_483 \
    op interface \
    ports { localC_483 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9894 \
    name localC_482 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_482 \
    op interface \
    ports { localC_482 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9895 \
    name localC_481 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_481 \
    op interface \
    ports { localC_481 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9896 \
    name localC_480 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_480 \
    op interface \
    ports { localC_480 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9897 \
    name localC_479 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_479 \
    op interface \
    ports { localC_479 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9898 \
    name localC_478 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_478 \
    op interface \
    ports { localC_478 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9899 \
    name localC_477 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_477 \
    op interface \
    ports { localC_477 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9900 \
    name localC_476 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_476 \
    op interface \
    ports { localC_476 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9901 \
    name localC_475 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_475 \
    op interface \
    ports { localC_475 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9902 \
    name localC_474 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_474 \
    op interface \
    ports { localC_474 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9903 \
    name localC_473 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_473 \
    op interface \
    ports { localC_473 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9904 \
    name localC_472 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_472 \
    op interface \
    ports { localC_472 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9905 \
    name localC_471 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_471 \
    op interface \
    ports { localC_471 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9906 \
    name localC_470 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_470 \
    op interface \
    ports { localC_470 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9907 \
    name localC_469 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_469 \
    op interface \
    ports { localC_469 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9908 \
    name localC_468 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_468 \
    op interface \
    ports { localC_468 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9909 \
    name localC_467 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_467 \
    op interface \
    ports { localC_467 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9910 \
    name localC_466 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_466 \
    op interface \
    ports { localC_466 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9911 \
    name localC_465 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_465 \
    op interface \
    ports { localC_465 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9912 \
    name localC_464 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_464 \
    op interface \
    ports { localC_464 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9913 \
    name localC_463 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_463 \
    op interface \
    ports { localC_463 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9914 \
    name localC_462 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_462 \
    op interface \
    ports { localC_462 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9915 \
    name localC_461 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_461 \
    op interface \
    ports { localC_461 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9916 \
    name localC_460 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_460 \
    op interface \
    ports { localC_460 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9917 \
    name localC_459 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_459 \
    op interface \
    ports { localC_459 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9918 \
    name localC_458 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_458 \
    op interface \
    ports { localC_458 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9919 \
    name localC_457 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_457 \
    op interface \
    ports { localC_457 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9920 \
    name localC_456 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_456 \
    op interface \
    ports { localC_456 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9921 \
    name localC_455 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_455 \
    op interface \
    ports { localC_455 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9922 \
    name localC_454 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_454 \
    op interface \
    ports { localC_454 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9923 \
    name localC_453 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_453 \
    op interface \
    ports { localC_453 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9924 \
    name localC_452 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_452 \
    op interface \
    ports { localC_452 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9925 \
    name localC_451 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_451 \
    op interface \
    ports { localC_451 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9926 \
    name localC_450 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_450 \
    op interface \
    ports { localC_450 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9927 \
    name localC_449 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_449 \
    op interface \
    ports { localC_449 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9928 \
    name localC_448 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_448 \
    op interface \
    ports { localC_448 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9929 \
    name localC_447 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_447 \
    op interface \
    ports { localC_447 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9930 \
    name localC_446 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_446 \
    op interface \
    ports { localC_446 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9931 \
    name localC_445 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_445 \
    op interface \
    ports { localC_445 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9932 \
    name localC_444 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_444 \
    op interface \
    ports { localC_444 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9933 \
    name localC_443 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_443 \
    op interface \
    ports { localC_443 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9934 \
    name localC_442 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_442 \
    op interface \
    ports { localC_442 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9935 \
    name localC_441 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_441 \
    op interface \
    ports { localC_441 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9936 \
    name localC_440 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_440 \
    op interface \
    ports { localC_440 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9937 \
    name localC_439 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_439 \
    op interface \
    ports { localC_439 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9938 \
    name localC_438 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_438 \
    op interface \
    ports { localC_438 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9939 \
    name localC_437 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_437 \
    op interface \
    ports { localC_437 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9940 \
    name localC_436 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_436 \
    op interface \
    ports { localC_436 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9941 \
    name localC_435 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_435 \
    op interface \
    ports { localC_435 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9942 \
    name localC_434 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_434 \
    op interface \
    ports { localC_434 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9943 \
    name localC_433 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_433 \
    op interface \
    ports { localC_433 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9944 \
    name localC_432 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_432 \
    op interface \
    ports { localC_432 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9945 \
    name localC_431 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_431 \
    op interface \
    ports { localC_431 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9946 \
    name localC_430 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_430 \
    op interface \
    ports { localC_430 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9947 \
    name localC_429 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_429 \
    op interface \
    ports { localC_429 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9948 \
    name localC_428 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_428 \
    op interface \
    ports { localC_428 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9949 \
    name localC_427 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_427 \
    op interface \
    ports { localC_427 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9950 \
    name localC_426 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_426 \
    op interface \
    ports { localC_426 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9951 \
    name localC_425 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_425 \
    op interface \
    ports { localC_425 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9952 \
    name localC_424 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_424 \
    op interface \
    ports { localC_424 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9953 \
    name localC_423 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_423 \
    op interface \
    ports { localC_423 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9954 \
    name localC_422 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_422 \
    op interface \
    ports { localC_422 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9955 \
    name localC_421 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_421 \
    op interface \
    ports { localC_421 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9956 \
    name localC_420 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_420 \
    op interface \
    ports { localC_420 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9957 \
    name localC_419 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_419 \
    op interface \
    ports { localC_419 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9958 \
    name localC_418 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_418 \
    op interface \
    ports { localC_418 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9959 \
    name localC_417 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_417 \
    op interface \
    ports { localC_417 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9960 \
    name localC_416 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_416 \
    op interface \
    ports { localC_416 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9961 \
    name localC_415 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_415 \
    op interface \
    ports { localC_415 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9962 \
    name localC_414 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_414 \
    op interface \
    ports { localC_414 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9963 \
    name localC_413 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_413 \
    op interface \
    ports { localC_413 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9964 \
    name localC_412 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_412 \
    op interface \
    ports { localC_412 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9965 \
    name localC_411 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_411 \
    op interface \
    ports { localC_411 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9966 \
    name localC_410 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_410 \
    op interface \
    ports { localC_410 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9967 \
    name localC_409 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_409 \
    op interface \
    ports { localC_409 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9968 \
    name localC_408 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_408 \
    op interface \
    ports { localC_408 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9969 \
    name localC_407 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_407 \
    op interface \
    ports { localC_407 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9970 \
    name localC_406 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_406 \
    op interface \
    ports { localC_406 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9971 \
    name localC_405 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_405 \
    op interface \
    ports { localC_405 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9972 \
    name localC_404 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_404 \
    op interface \
    ports { localC_404 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9973 \
    name localC_403 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_403 \
    op interface \
    ports { localC_403 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9974 \
    name localC_402 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_402 \
    op interface \
    ports { localC_402 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9975 \
    name localC_401 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_401 \
    op interface \
    ports { localC_401 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9976 \
    name localC_400 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_400 \
    op interface \
    ports { localC_400 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9977 \
    name localC_399 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_399 \
    op interface \
    ports { localC_399 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9978 \
    name localC_398 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_398 \
    op interface \
    ports { localC_398 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9979 \
    name localC_397 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_397 \
    op interface \
    ports { localC_397 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9980 \
    name localC_396 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_396 \
    op interface \
    ports { localC_396 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9981 \
    name localC_395 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_395 \
    op interface \
    ports { localC_395 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9982 \
    name localC_394 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_394 \
    op interface \
    ports { localC_394 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9983 \
    name localC_393 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_393 \
    op interface \
    ports { localC_393 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9984 \
    name localC_392 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_392 \
    op interface \
    ports { localC_392 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9985 \
    name localC_391 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_391 \
    op interface \
    ports { localC_391 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9986 \
    name localC_390 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_390 \
    op interface \
    ports { localC_390 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9987 \
    name localC_389 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_389 \
    op interface \
    ports { localC_389 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9988 \
    name localC_388 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_388 \
    op interface \
    ports { localC_388 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9989 \
    name localC_387 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_387 \
    op interface \
    ports { localC_387 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9990 \
    name localC_386 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_386 \
    op interface \
    ports { localC_386 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9991 \
    name localC_385 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_385 \
    op interface \
    ports { localC_385 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9992 \
    name localC_384 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_384 \
    op interface \
    ports { localC_384 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9993 \
    name localC_383 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_383 \
    op interface \
    ports { localC_383 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9994 \
    name localC_382 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_382 \
    op interface \
    ports { localC_382 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9995 \
    name localC_381 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_381 \
    op interface \
    ports { localC_381 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9996 \
    name localC_380 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_380 \
    op interface \
    ports { localC_380 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9997 \
    name localC_379 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_379 \
    op interface \
    ports { localC_379 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9998 \
    name localC_378 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_378 \
    op interface \
    ports { localC_378 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 9999 \
    name localC_377 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_377 \
    op interface \
    ports { localC_377 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10000 \
    name localC_376 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_376 \
    op interface \
    ports { localC_376 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10001 \
    name localC_375 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_375 \
    op interface \
    ports { localC_375 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10002 \
    name localC_374 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_374 \
    op interface \
    ports { localC_374 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10003 \
    name localC_373 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_373 \
    op interface \
    ports { localC_373 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10004 \
    name localC_372 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_372 \
    op interface \
    ports { localC_372 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10005 \
    name localC_371 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_371 \
    op interface \
    ports { localC_371 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10006 \
    name localC_370 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_370 \
    op interface \
    ports { localC_370 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10007 \
    name localC_369 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_369 \
    op interface \
    ports { localC_369 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10008 \
    name localC_368 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_368 \
    op interface \
    ports { localC_368 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10009 \
    name localC_367 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_367 \
    op interface \
    ports { localC_367 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10010 \
    name localC_366 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_366 \
    op interface \
    ports { localC_366 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10011 \
    name localC_365 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_365 \
    op interface \
    ports { localC_365 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10012 \
    name localC_364 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_364 \
    op interface \
    ports { localC_364 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10013 \
    name localC_363 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_363 \
    op interface \
    ports { localC_363 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10014 \
    name localC_362 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_362 \
    op interface \
    ports { localC_362 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10015 \
    name localC_361 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_361 \
    op interface \
    ports { localC_361 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10016 \
    name localC_360 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_360 \
    op interface \
    ports { localC_360 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10017 \
    name localC_359 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_359 \
    op interface \
    ports { localC_359 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10018 \
    name localC_358 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_358 \
    op interface \
    ports { localC_358 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10019 \
    name localC_357 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_357 \
    op interface \
    ports { localC_357 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10020 \
    name localC_356 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_356 \
    op interface \
    ports { localC_356 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10021 \
    name localC_355 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_355 \
    op interface \
    ports { localC_355 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10022 \
    name localC_354 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_354 \
    op interface \
    ports { localC_354 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10023 \
    name localC_353 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_353 \
    op interface \
    ports { localC_353 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10024 \
    name localC_352 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_352 \
    op interface \
    ports { localC_352 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10025 \
    name localC_351 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_351 \
    op interface \
    ports { localC_351 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10026 \
    name localC_350 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_350 \
    op interface \
    ports { localC_350 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10027 \
    name localC_349 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_349 \
    op interface \
    ports { localC_349 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10028 \
    name localC_348 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_348 \
    op interface \
    ports { localC_348 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10029 \
    name localC_347 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_347 \
    op interface \
    ports { localC_347 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10030 \
    name localC_346 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_346 \
    op interface \
    ports { localC_346 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10031 \
    name localC_345 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_345 \
    op interface \
    ports { localC_345 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10032 \
    name localC_344 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_344 \
    op interface \
    ports { localC_344 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10033 \
    name localC_343 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_343 \
    op interface \
    ports { localC_343 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10034 \
    name localC_342 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_342 \
    op interface \
    ports { localC_342 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10035 \
    name localC_341 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_341 \
    op interface \
    ports { localC_341 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10036 \
    name localC_340 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_340 \
    op interface \
    ports { localC_340 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10037 \
    name localC_339 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_339 \
    op interface \
    ports { localC_339 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10038 \
    name localC_338 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_338 \
    op interface \
    ports { localC_338 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10039 \
    name localC_337 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_337 \
    op interface \
    ports { localC_337 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10040 \
    name localC_336 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_336 \
    op interface \
    ports { localC_336 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10041 \
    name localC_335 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_335 \
    op interface \
    ports { localC_335 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10042 \
    name localC_334 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_334 \
    op interface \
    ports { localC_334 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10043 \
    name localC_333 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_333 \
    op interface \
    ports { localC_333 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10044 \
    name localC_332 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_332 \
    op interface \
    ports { localC_332 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10045 \
    name localC_331 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_331 \
    op interface \
    ports { localC_331 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10046 \
    name localC_330 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_330 \
    op interface \
    ports { localC_330 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10047 \
    name localC_329 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_329 \
    op interface \
    ports { localC_329 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10048 \
    name localC_328 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_328 \
    op interface \
    ports { localC_328 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10049 \
    name localC_327 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_327 \
    op interface \
    ports { localC_327 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10050 \
    name localC_326 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_326 \
    op interface \
    ports { localC_326 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10051 \
    name localC_325 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_325 \
    op interface \
    ports { localC_325 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10052 \
    name localC_324 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_324 \
    op interface \
    ports { localC_324 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10053 \
    name localC_323 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_323 \
    op interface \
    ports { localC_323 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10054 \
    name localC_322 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_322 \
    op interface \
    ports { localC_322 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10055 \
    name localC_321 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_321 \
    op interface \
    ports { localC_321 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10056 \
    name localC_320 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_320 \
    op interface \
    ports { localC_320 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10057 \
    name localC_319 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_319 \
    op interface \
    ports { localC_319 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10058 \
    name localC_318 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_318 \
    op interface \
    ports { localC_318 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10059 \
    name localC_317 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_317 \
    op interface \
    ports { localC_317 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10060 \
    name localC_316 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_316 \
    op interface \
    ports { localC_316 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10061 \
    name localC_315 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_315 \
    op interface \
    ports { localC_315 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10062 \
    name localC_314 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_314 \
    op interface \
    ports { localC_314 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10063 \
    name localC_313 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_313 \
    op interface \
    ports { localC_313 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10064 \
    name localC_312 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_312 \
    op interface \
    ports { localC_312 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10065 \
    name localC_311 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_311 \
    op interface \
    ports { localC_311 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10066 \
    name localC_310 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_310 \
    op interface \
    ports { localC_310 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10067 \
    name localC_309 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_309 \
    op interface \
    ports { localC_309 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10068 \
    name localC_308 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_308 \
    op interface \
    ports { localC_308 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10069 \
    name localC_307 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_307 \
    op interface \
    ports { localC_307 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10070 \
    name localC_306 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_306 \
    op interface \
    ports { localC_306 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10071 \
    name localC_305 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_305 \
    op interface \
    ports { localC_305 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10072 \
    name localC_304 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_304 \
    op interface \
    ports { localC_304 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10073 \
    name localC_303 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_303 \
    op interface \
    ports { localC_303 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10074 \
    name localC_302 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_302 \
    op interface \
    ports { localC_302 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10075 \
    name localC_301 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_301 \
    op interface \
    ports { localC_301 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10076 \
    name localC_300 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_300 \
    op interface \
    ports { localC_300 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10077 \
    name localC_299 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_299 \
    op interface \
    ports { localC_299 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10078 \
    name localC_298 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_298 \
    op interface \
    ports { localC_298 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10079 \
    name localC_297 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_297 \
    op interface \
    ports { localC_297 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10080 \
    name localC_296 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_296 \
    op interface \
    ports { localC_296 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10081 \
    name localC_295 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_295 \
    op interface \
    ports { localC_295 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10082 \
    name localC_294 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_294 \
    op interface \
    ports { localC_294 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10083 \
    name localC_293 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_293 \
    op interface \
    ports { localC_293 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10084 \
    name localC_292 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_292 \
    op interface \
    ports { localC_292 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10085 \
    name localC_291 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_291 \
    op interface \
    ports { localC_291 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10086 \
    name localC_290 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_290 \
    op interface \
    ports { localC_290 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10087 \
    name localC_289 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_289 \
    op interface \
    ports { localC_289 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10088 \
    name localC_288 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_288 \
    op interface \
    ports { localC_288 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10089 \
    name localC_287 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_287 \
    op interface \
    ports { localC_287 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10090 \
    name localC_286 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_286 \
    op interface \
    ports { localC_286 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10091 \
    name localC_285 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_285 \
    op interface \
    ports { localC_285 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10092 \
    name localC_284 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_284 \
    op interface \
    ports { localC_284 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10093 \
    name localC_283 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_283 \
    op interface \
    ports { localC_283 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10094 \
    name localC_282 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_282 \
    op interface \
    ports { localC_282 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10095 \
    name localC_281 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_281 \
    op interface \
    ports { localC_281 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10096 \
    name localC_280 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_280 \
    op interface \
    ports { localC_280 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10097 \
    name localC_279 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_279 \
    op interface \
    ports { localC_279 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10098 \
    name localC_278 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_278 \
    op interface \
    ports { localC_278 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10099 \
    name localC_277 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_277 \
    op interface \
    ports { localC_277 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10100 \
    name localC_276 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_276 \
    op interface \
    ports { localC_276 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10101 \
    name localC_275 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_275 \
    op interface \
    ports { localC_275 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10102 \
    name localC_274 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_274 \
    op interface \
    ports { localC_274 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10103 \
    name localC_273 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_273 \
    op interface \
    ports { localC_273 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10104 \
    name localC_272 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_272 \
    op interface \
    ports { localC_272 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10105 \
    name localC_271 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_271 \
    op interface \
    ports { localC_271 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10106 \
    name localC_270 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_270 \
    op interface \
    ports { localC_270 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10107 \
    name localC_269 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_269 \
    op interface \
    ports { localC_269 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10108 \
    name localC_268 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_268 \
    op interface \
    ports { localC_268 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10109 \
    name localC_267 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_267 \
    op interface \
    ports { localC_267 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10110 \
    name localC_266 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_266 \
    op interface \
    ports { localC_266 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10111 \
    name localC_265 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_265 \
    op interface \
    ports { localC_265 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10112 \
    name localC_264 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_264 \
    op interface \
    ports { localC_264 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10113 \
    name localC_263 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_263 \
    op interface \
    ports { localC_263 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10114 \
    name localC_262 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_262 \
    op interface \
    ports { localC_262 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10115 \
    name localC_261 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_261 \
    op interface \
    ports { localC_261 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10116 \
    name localC_260 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_260 \
    op interface \
    ports { localC_260 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10117 \
    name localC_259 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_259 \
    op interface \
    ports { localC_259 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10118 \
    name localC_258 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_258 \
    op interface \
    ports { localC_258 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10119 \
    name localC_257 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_257 \
    op interface \
    ports { localC_257 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10120 \
    name localC_256 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_256 \
    op interface \
    ports { localC_256 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10121 \
    name localC_255 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_255 \
    op interface \
    ports { localC_255 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10122 \
    name localC_254 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_254 \
    op interface \
    ports { localC_254 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10123 \
    name localC_253 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_253 \
    op interface \
    ports { localC_253 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10124 \
    name localC_252 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_252 \
    op interface \
    ports { localC_252 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10125 \
    name localC_251 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_251 \
    op interface \
    ports { localC_251 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10126 \
    name localC_250 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_250 \
    op interface \
    ports { localC_250 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10127 \
    name localC_249 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_249 \
    op interface \
    ports { localC_249 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10128 \
    name localC_248 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_248 \
    op interface \
    ports { localC_248 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10129 \
    name localC_247 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_247 \
    op interface \
    ports { localC_247 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10130 \
    name localC_246 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_246 \
    op interface \
    ports { localC_246 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10131 \
    name localC_245 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_245 \
    op interface \
    ports { localC_245 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10132 \
    name localC_244 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_244 \
    op interface \
    ports { localC_244 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10133 \
    name localC_243 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_243 \
    op interface \
    ports { localC_243 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10134 \
    name localC_242 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_242 \
    op interface \
    ports { localC_242 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10135 \
    name localC_241 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_241 \
    op interface \
    ports { localC_241 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10136 \
    name localC_240 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_240 \
    op interface \
    ports { localC_240 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10137 \
    name localC_239 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_239 \
    op interface \
    ports { localC_239 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10138 \
    name localC_238 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_238 \
    op interface \
    ports { localC_238 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10139 \
    name localC_237 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_237 \
    op interface \
    ports { localC_237 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10140 \
    name localC_236 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_236 \
    op interface \
    ports { localC_236 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10141 \
    name localC_235 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_235 \
    op interface \
    ports { localC_235 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10142 \
    name localC_234 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_234 \
    op interface \
    ports { localC_234 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10143 \
    name localC_233 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_233 \
    op interface \
    ports { localC_233 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10144 \
    name localC_232 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_232 \
    op interface \
    ports { localC_232 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10145 \
    name localC_231 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_231 \
    op interface \
    ports { localC_231 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10146 \
    name localC_230 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_230 \
    op interface \
    ports { localC_230 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10147 \
    name localC_229 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_229 \
    op interface \
    ports { localC_229 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10148 \
    name localC_228 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_228 \
    op interface \
    ports { localC_228 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10149 \
    name localC_227 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_227 \
    op interface \
    ports { localC_227 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10150 \
    name localC_226 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_226 \
    op interface \
    ports { localC_226 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10151 \
    name localC_225 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_225 \
    op interface \
    ports { localC_225 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10152 \
    name localC_224 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_224 \
    op interface \
    ports { localC_224 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10153 \
    name localC_223 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_223 \
    op interface \
    ports { localC_223 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10154 \
    name localC_222 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_222 \
    op interface \
    ports { localC_222 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10155 \
    name localC_221 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_221 \
    op interface \
    ports { localC_221 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10156 \
    name localC_220 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_220 \
    op interface \
    ports { localC_220 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10157 \
    name localC_219 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_219 \
    op interface \
    ports { localC_219 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10158 \
    name localC_218 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_218 \
    op interface \
    ports { localC_218 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10159 \
    name localC_217 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_217 \
    op interface \
    ports { localC_217 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10160 \
    name localC_216 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_216 \
    op interface \
    ports { localC_216 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10161 \
    name localC_215 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_215 \
    op interface \
    ports { localC_215 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10162 \
    name localC_214 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_214 \
    op interface \
    ports { localC_214 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10163 \
    name localC_213 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_213 \
    op interface \
    ports { localC_213 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10164 \
    name localC_212 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_212 \
    op interface \
    ports { localC_212 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10165 \
    name localC_211 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_211 \
    op interface \
    ports { localC_211 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10166 \
    name localC_210 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_210 \
    op interface \
    ports { localC_210 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10167 \
    name localC_209 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_209 \
    op interface \
    ports { localC_209 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10168 \
    name localC_208 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_208 \
    op interface \
    ports { localC_208 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10169 \
    name localC_207 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_207 \
    op interface \
    ports { localC_207 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10170 \
    name localC_206 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_206 \
    op interface \
    ports { localC_206 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10171 \
    name localC_205 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_205 \
    op interface \
    ports { localC_205 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10172 \
    name localC_204 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_204 \
    op interface \
    ports { localC_204 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10173 \
    name localC_203 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_203 \
    op interface \
    ports { localC_203 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10174 \
    name localC_202 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_202 \
    op interface \
    ports { localC_202 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10175 \
    name localC_201 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_201 \
    op interface \
    ports { localC_201 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10176 \
    name localC_200 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_200 \
    op interface \
    ports { localC_200 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10177 \
    name localC_199 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_199 \
    op interface \
    ports { localC_199 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10178 \
    name localC_198 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_198 \
    op interface \
    ports { localC_198 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10179 \
    name localC_197 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_197 \
    op interface \
    ports { localC_197 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10180 \
    name localC_196 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_196 \
    op interface \
    ports { localC_196 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10181 \
    name localC_195 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_195 \
    op interface \
    ports { localC_195 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10182 \
    name localC_194 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_194 \
    op interface \
    ports { localC_194 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10183 \
    name localC_193 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_193 \
    op interface \
    ports { localC_193 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10184 \
    name localC_192 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_192 \
    op interface \
    ports { localC_192 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10185 \
    name localC_191 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_191 \
    op interface \
    ports { localC_191 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10186 \
    name localC_190 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_190 \
    op interface \
    ports { localC_190 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10187 \
    name localC_189 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_189 \
    op interface \
    ports { localC_189 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10188 \
    name localC_188 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_188 \
    op interface \
    ports { localC_188 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10189 \
    name localC_187 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_187 \
    op interface \
    ports { localC_187 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10190 \
    name localC_186 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_186 \
    op interface \
    ports { localC_186 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10191 \
    name localC_185 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_185 \
    op interface \
    ports { localC_185 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10192 \
    name localC_184 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_184 \
    op interface \
    ports { localC_184 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10193 \
    name localC_183 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_183 \
    op interface \
    ports { localC_183 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10194 \
    name localC_182 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_182 \
    op interface \
    ports { localC_182 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10195 \
    name localC_181 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_181 \
    op interface \
    ports { localC_181 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10196 \
    name localC_180 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_180 \
    op interface \
    ports { localC_180 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10197 \
    name localC_179 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_179 \
    op interface \
    ports { localC_179 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10198 \
    name localC_178 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_178 \
    op interface \
    ports { localC_178 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10199 \
    name localC_177 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_177 \
    op interface \
    ports { localC_177 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10200 \
    name localC_176 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_176 \
    op interface \
    ports { localC_176 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10201 \
    name localC_175 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_175 \
    op interface \
    ports { localC_175 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10202 \
    name localC_174 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_174 \
    op interface \
    ports { localC_174 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10203 \
    name localC_173 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_173 \
    op interface \
    ports { localC_173 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10204 \
    name localC_172 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_172 \
    op interface \
    ports { localC_172 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10205 \
    name localC_171 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_171 \
    op interface \
    ports { localC_171 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10206 \
    name localC_170 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_170 \
    op interface \
    ports { localC_170 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10207 \
    name localC_169 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_169 \
    op interface \
    ports { localC_169 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10208 \
    name localC_168 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_168 \
    op interface \
    ports { localC_168 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10209 \
    name localC_167 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_167 \
    op interface \
    ports { localC_167 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10210 \
    name localC_166 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_166 \
    op interface \
    ports { localC_166 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10211 \
    name localC_165 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_165 \
    op interface \
    ports { localC_165 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10212 \
    name localC_164 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_164 \
    op interface \
    ports { localC_164 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10213 \
    name localC_163 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_163 \
    op interface \
    ports { localC_163 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10214 \
    name localC_162 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_162 \
    op interface \
    ports { localC_162 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10215 \
    name localC_161 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_161 \
    op interface \
    ports { localC_161 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10216 \
    name localC_160 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_160 \
    op interface \
    ports { localC_160 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10217 \
    name localC_159 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_159 \
    op interface \
    ports { localC_159 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10218 \
    name localC_158 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_158 \
    op interface \
    ports { localC_158 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10219 \
    name localC_157 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_157 \
    op interface \
    ports { localC_157 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10220 \
    name localC_156 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_156 \
    op interface \
    ports { localC_156 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10221 \
    name localC_155 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_155 \
    op interface \
    ports { localC_155 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10222 \
    name localC_154 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_154 \
    op interface \
    ports { localC_154 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10223 \
    name localC_153 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_153 \
    op interface \
    ports { localC_153 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10224 \
    name localC_152 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_152 \
    op interface \
    ports { localC_152 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10225 \
    name localC_151 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_151 \
    op interface \
    ports { localC_151 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10226 \
    name localC_150 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_150 \
    op interface \
    ports { localC_150 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10227 \
    name localC_149 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_149 \
    op interface \
    ports { localC_149 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10228 \
    name localC_148 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_148 \
    op interface \
    ports { localC_148 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10229 \
    name localC_147 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_147 \
    op interface \
    ports { localC_147 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10230 \
    name localC_146 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_146 \
    op interface \
    ports { localC_146 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10231 \
    name localC_145 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_145 \
    op interface \
    ports { localC_145 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10232 \
    name localC_144 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_144 \
    op interface \
    ports { localC_144 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10233 \
    name localC_143 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_143 \
    op interface \
    ports { localC_143 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10234 \
    name localC_142 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_142 \
    op interface \
    ports { localC_142 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10235 \
    name localC_141 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_141 \
    op interface \
    ports { localC_141 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10236 \
    name localC_140 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_140 \
    op interface \
    ports { localC_140 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10237 \
    name localC_139 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_139 \
    op interface \
    ports { localC_139 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10238 \
    name localC_138 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_138 \
    op interface \
    ports { localC_138 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10239 \
    name localC_137 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_137 \
    op interface \
    ports { localC_137 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10240 \
    name localC_136 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_136 \
    op interface \
    ports { localC_136 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10241 \
    name localC_135 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_135 \
    op interface \
    ports { localC_135 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10242 \
    name localC_134 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_134 \
    op interface \
    ports { localC_134 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10243 \
    name localC_133 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_133 \
    op interface \
    ports { localC_133 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10244 \
    name localC_132 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_132 \
    op interface \
    ports { localC_132 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10245 \
    name localC_131 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_131 \
    op interface \
    ports { localC_131 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10246 \
    name localC_130 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_130 \
    op interface \
    ports { localC_130 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10247 \
    name localC_129 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_129 \
    op interface \
    ports { localC_129 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10248 \
    name localC_128 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_128 \
    op interface \
    ports { localC_128 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10249 \
    name localC_127 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_127 \
    op interface \
    ports { localC_127 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10250 \
    name localC_126 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_126 \
    op interface \
    ports { localC_126 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10251 \
    name localC_125 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_125 \
    op interface \
    ports { localC_125 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10252 \
    name localC_124 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_124 \
    op interface \
    ports { localC_124 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10253 \
    name localC_123 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_123 \
    op interface \
    ports { localC_123 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10254 \
    name localC_122 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_122 \
    op interface \
    ports { localC_122 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10255 \
    name localC_121 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_121 \
    op interface \
    ports { localC_121 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10256 \
    name localC_120 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_120 \
    op interface \
    ports { localC_120 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10257 \
    name localC_119 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_119 \
    op interface \
    ports { localC_119 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10258 \
    name localC_118 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_118 \
    op interface \
    ports { localC_118 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10259 \
    name localC_117 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_117 \
    op interface \
    ports { localC_117 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10260 \
    name localC_116 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_116 \
    op interface \
    ports { localC_116 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10261 \
    name localC_115 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_115 \
    op interface \
    ports { localC_115 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10262 \
    name localC_114 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_114 \
    op interface \
    ports { localC_114 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10263 \
    name localC_113 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_113 \
    op interface \
    ports { localC_113 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10264 \
    name localC_112 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_112 \
    op interface \
    ports { localC_112 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10265 \
    name localC_111 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_111 \
    op interface \
    ports { localC_111 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10266 \
    name localC_110 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_110 \
    op interface \
    ports { localC_110 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10267 \
    name localC_109 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_109 \
    op interface \
    ports { localC_109 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10268 \
    name localC_108 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_108 \
    op interface \
    ports { localC_108 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10269 \
    name localC_107 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_107 \
    op interface \
    ports { localC_107 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10270 \
    name localC_106 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_106 \
    op interface \
    ports { localC_106 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10271 \
    name localC_105 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_105 \
    op interface \
    ports { localC_105 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10272 \
    name localC_104 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_104 \
    op interface \
    ports { localC_104 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10273 \
    name localC_103 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_103 \
    op interface \
    ports { localC_103 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10274 \
    name localC_102 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_102 \
    op interface \
    ports { localC_102 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10275 \
    name localC_101 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_101 \
    op interface \
    ports { localC_101 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10276 \
    name localC_100 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_100 \
    op interface \
    ports { localC_100 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10277 \
    name localC_99 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_99 \
    op interface \
    ports { localC_99 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10278 \
    name localC_98 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_98 \
    op interface \
    ports { localC_98 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10279 \
    name localC_97 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_97 \
    op interface \
    ports { localC_97 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10280 \
    name localC_96 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_96 \
    op interface \
    ports { localC_96 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10281 \
    name localC_95 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_95 \
    op interface \
    ports { localC_95 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10282 \
    name localC_94 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_94 \
    op interface \
    ports { localC_94 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10283 \
    name localC_93 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_93 \
    op interface \
    ports { localC_93 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10284 \
    name localC_92 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_92 \
    op interface \
    ports { localC_92 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10285 \
    name localC_91 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_91 \
    op interface \
    ports { localC_91 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10286 \
    name localC_90 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_90 \
    op interface \
    ports { localC_90 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10287 \
    name localC_89 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_89 \
    op interface \
    ports { localC_89 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10288 \
    name localC_88 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_88 \
    op interface \
    ports { localC_88 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10289 \
    name localC_87 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_87 \
    op interface \
    ports { localC_87 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10290 \
    name localC_86 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_86 \
    op interface \
    ports { localC_86 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10291 \
    name localC_85 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_85 \
    op interface \
    ports { localC_85 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10292 \
    name localC_84 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_84 \
    op interface \
    ports { localC_84 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10293 \
    name localC_83 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_83 \
    op interface \
    ports { localC_83 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10294 \
    name localC_82 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_82 \
    op interface \
    ports { localC_82 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10295 \
    name localC_81 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_81 \
    op interface \
    ports { localC_81 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10296 \
    name localC_80 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_80 \
    op interface \
    ports { localC_80 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10297 \
    name localC_79 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_79 \
    op interface \
    ports { localC_79 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10298 \
    name localC_78 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_78 \
    op interface \
    ports { localC_78 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10299 \
    name localC_77 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_77 \
    op interface \
    ports { localC_77 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10300 \
    name localC_76 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_76 \
    op interface \
    ports { localC_76 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10301 \
    name localC_75 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_75 \
    op interface \
    ports { localC_75 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10302 \
    name localC_74 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_74 \
    op interface \
    ports { localC_74 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10303 \
    name localC_73 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_73 \
    op interface \
    ports { localC_73 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10304 \
    name localC_72 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_72 \
    op interface \
    ports { localC_72 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10305 \
    name localC_71 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_71 \
    op interface \
    ports { localC_71 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10306 \
    name localC_70 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_70 \
    op interface \
    ports { localC_70 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10307 \
    name localC_69 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_69 \
    op interface \
    ports { localC_69 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10308 \
    name localC_68 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_68 \
    op interface \
    ports { localC_68 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10309 \
    name localC_67 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_67 \
    op interface \
    ports { localC_67 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10310 \
    name localC_66 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_66 \
    op interface \
    ports { localC_66 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10311 \
    name localC_65 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_65 \
    op interface \
    ports { localC_65 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10312 \
    name localC_64 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_64 \
    op interface \
    ports { localC_64 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10313 \
    name localC_63 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_63 \
    op interface \
    ports { localC_63 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10314 \
    name localC_62 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_62 \
    op interface \
    ports { localC_62 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10315 \
    name localC_61 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_61 \
    op interface \
    ports { localC_61 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10316 \
    name localC_60 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_60 \
    op interface \
    ports { localC_60 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10317 \
    name localC_59 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_59 \
    op interface \
    ports { localC_59 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10318 \
    name localC_58 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_58 \
    op interface \
    ports { localC_58 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10319 \
    name localC_57 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_57 \
    op interface \
    ports { localC_57 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10320 \
    name localC_56 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_56 \
    op interface \
    ports { localC_56 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10321 \
    name localC_55 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_55 \
    op interface \
    ports { localC_55 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10322 \
    name localC_54 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_54 \
    op interface \
    ports { localC_54 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10323 \
    name localC_53 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_53 \
    op interface \
    ports { localC_53 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10324 \
    name localC_52 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_52 \
    op interface \
    ports { localC_52 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10325 \
    name localC_51 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_51 \
    op interface \
    ports { localC_51 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10326 \
    name localC_50 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_50 \
    op interface \
    ports { localC_50 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10327 \
    name localC_49 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_49 \
    op interface \
    ports { localC_49 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10328 \
    name localC_48 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_48 \
    op interface \
    ports { localC_48 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10329 \
    name localC_47 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_47 \
    op interface \
    ports { localC_47 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10330 \
    name localC_46 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_46 \
    op interface \
    ports { localC_46 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10331 \
    name localC_45 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_45 \
    op interface \
    ports { localC_45 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10332 \
    name localC_44 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_44 \
    op interface \
    ports { localC_44 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10333 \
    name localC_43 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_43 \
    op interface \
    ports { localC_43 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10334 \
    name localC_42 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_42 \
    op interface \
    ports { localC_42 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10335 \
    name localC_41 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_41 \
    op interface \
    ports { localC_41 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10336 \
    name localC_40 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_40 \
    op interface \
    ports { localC_40 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10337 \
    name localC_39 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_39 \
    op interface \
    ports { localC_39 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10338 \
    name localC_38 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_38 \
    op interface \
    ports { localC_38 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10339 \
    name localC_37 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_37 \
    op interface \
    ports { localC_37 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10340 \
    name localC_36 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_36 \
    op interface \
    ports { localC_36 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10341 \
    name localC_35 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_35 \
    op interface \
    ports { localC_35 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10342 \
    name localC_34 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_34 \
    op interface \
    ports { localC_34 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10343 \
    name localC_33 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_33 \
    op interface \
    ports { localC_33 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10344 \
    name localC_32 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_32 \
    op interface \
    ports { localC_32 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10345 \
    name localC_31 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_31 \
    op interface \
    ports { localC_31 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10346 \
    name localC_30 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_30 \
    op interface \
    ports { localC_30 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10347 \
    name localC_29 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_29 \
    op interface \
    ports { localC_29 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10348 \
    name localC_28 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_28 \
    op interface \
    ports { localC_28 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10349 \
    name localC_27 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_27 \
    op interface \
    ports { localC_27 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10350 \
    name localC_26 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_26 \
    op interface \
    ports { localC_26 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10351 \
    name localC_25 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_25 \
    op interface \
    ports { localC_25 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10352 \
    name localC_24 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_24 \
    op interface \
    ports { localC_24 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10353 \
    name localC_23 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_23 \
    op interface \
    ports { localC_23 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10354 \
    name localC_22 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_22 \
    op interface \
    ports { localC_22 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10355 \
    name localC_21 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_21 \
    op interface \
    ports { localC_21 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10356 \
    name localC_20 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_20 \
    op interface \
    ports { localC_20 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10357 \
    name localC_19 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_19 \
    op interface \
    ports { localC_19 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10358 \
    name localC_18 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_18 \
    op interface \
    ports { localC_18 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10359 \
    name localC_17 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_17 \
    op interface \
    ports { localC_17 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10360 \
    name localC_16 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_16 \
    op interface \
    ports { localC_16 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10361 \
    name localC_15 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_15 \
    op interface \
    ports { localC_15 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10362 \
    name localC_14 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_14 \
    op interface \
    ports { localC_14 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10363 \
    name localC_13 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_13 \
    op interface \
    ports { localC_13 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10364 \
    name localC_12 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_12 \
    op interface \
    ports { localC_12 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10365 \
    name localC_11 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_11 \
    op interface \
    ports { localC_11 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10366 \
    name localC_10 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_10 \
    op interface \
    ports { localC_10 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10367 \
    name localC_9 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_9 \
    op interface \
    ports { localC_9 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10368 \
    name localC_8 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_8 \
    op interface \
    ports { localC_8 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10369 \
    name localC_7 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_7 \
    op interface \
    ports { localC_7 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10370 \
    name localC_6 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_6 \
    op interface \
    ports { localC_6 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10371 \
    name localC_5 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_5 \
    op interface \
    ports { localC_5 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10372 \
    name localC_4 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_4 \
    op interface \
    ports { localC_4 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10373 \
    name localC_3 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_3 \
    op interface \
    ports { localC_3 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10374 \
    name localC_2 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_2 \
    op interface \
    ports { localC_2 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10375 \
    name localC_1 \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC_1 \
    op interface \
    ports { localC_1 { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10376 \
    name localC \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_localC \
    op interface \
    ports { localC { I 32 vector } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 10377 \
    name C \
    type other \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_C \
    op interface \
    ports { C { I 64 vector } } \
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


