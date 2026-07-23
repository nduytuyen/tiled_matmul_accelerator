set moduleName mmult_accel_Pipeline_VITIS_LOOP_120_2
set isTopModule 0
set isCombinational 0
set isDatapathOnly 0
set isPipelined 1
set pipeline_type none
set FunctionProtocol ap_ctrl_hs
set isOneStateSeq 0
set ProfileFlag 0
set StallSigGenFlag 0
set isEnableWaveformDebug 1
set hasInterrupt 0
set C_modelName {mmult_accel_Pipeline_VITIS_LOOP_120_2}
set C_modelType { void 0 }
set C_modelArgList {
	{ gmemB int 8 regular {axi_master 0}  }
	{ current_block_M int 32 regular  }
	{ mul_ln110 int 64 regular  }
	{ zext_ln119 int 31 regular  }
	{ zext_ln110 int 32 regular  }
	{ B int 64 regular  }
	{ j_block int 64 regular  }
	{ B_bram int 8 regular {array 196608 { 3 0 } 0 1 }  }
}
set C_modelArgMapList {[ 
	{ "Name" : "gmemB", "interface" : "axi_master", "bitwidth" : 8, "direction" : "READONLY", "bitSlice":[ {"cElement": [{"cName": "B","offset": { "type": "dynamic","port_name": "B","bundle": "control"},"direction": "READONLY"}]}]} , 
 	{ "Name" : "current_block_M", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "mul_ln110", "interface" : "wire", "bitwidth" : 64, "direction" : "READONLY"} , 
 	{ "Name" : "zext_ln119", "interface" : "wire", "bitwidth" : 31, "direction" : "READONLY"} , 
 	{ "Name" : "zext_ln110", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "B", "interface" : "wire", "bitwidth" : 64, "direction" : "READONLY"} , 
 	{ "Name" : "j_block", "interface" : "wire", "bitwidth" : 64, "direction" : "READONLY"} , 
 	{ "Name" : "B_bram", "interface" : "memory", "bitwidth" : 8, "direction" : "WRITEONLY"} ]}
# RTL Port declarations: 
set portNum 62
set portList { 
	{ ap_clk sc_in sc_logic 1 clock -1 } 
	{ ap_rst sc_in sc_logic 1 reset -1 active_high_sync } 
	{ ap_start sc_in sc_logic 1 start -1 } 
	{ ap_done sc_out sc_logic 1 predone -1 } 
	{ ap_idle sc_out sc_logic 1 done -1 } 
	{ ap_ready sc_out sc_logic 1 ready -1 } 
	{ m_axi_gmemB_AWVALID sc_out sc_logic 1 signal 0 } 
	{ m_axi_gmemB_AWREADY sc_in sc_logic 1 signal 0 } 
	{ m_axi_gmemB_AWADDR sc_out sc_lv 64 signal 0 } 
	{ m_axi_gmemB_AWID sc_out sc_lv 1 signal 0 } 
	{ m_axi_gmemB_AWLEN sc_out sc_lv 32 signal 0 } 
	{ m_axi_gmemB_AWSIZE sc_out sc_lv 3 signal 0 } 
	{ m_axi_gmemB_AWBURST sc_out sc_lv 2 signal 0 } 
	{ m_axi_gmemB_AWLOCK sc_out sc_lv 2 signal 0 } 
	{ m_axi_gmemB_AWCACHE sc_out sc_lv 4 signal 0 } 
	{ m_axi_gmemB_AWPROT sc_out sc_lv 3 signal 0 } 
	{ m_axi_gmemB_AWQOS sc_out sc_lv 4 signal 0 } 
	{ m_axi_gmemB_AWREGION sc_out sc_lv 4 signal 0 } 
	{ m_axi_gmemB_AWUSER sc_out sc_lv 1 signal 0 } 
	{ m_axi_gmemB_WVALID sc_out sc_logic 1 signal 0 } 
	{ m_axi_gmemB_WREADY sc_in sc_logic 1 signal 0 } 
	{ m_axi_gmemB_WDATA sc_out sc_lv 8 signal 0 } 
	{ m_axi_gmemB_WSTRB sc_out sc_lv 1 signal 0 } 
	{ m_axi_gmemB_WLAST sc_out sc_logic 1 signal 0 } 
	{ m_axi_gmemB_WID sc_out sc_lv 1 signal 0 } 
	{ m_axi_gmemB_WUSER sc_out sc_lv 1 signal 0 } 
	{ m_axi_gmemB_ARVALID sc_out sc_logic 1 signal 0 } 
	{ m_axi_gmemB_ARREADY sc_in sc_logic 1 signal 0 } 
	{ m_axi_gmemB_ARADDR sc_out sc_lv 64 signal 0 } 
	{ m_axi_gmemB_ARID sc_out sc_lv 1 signal 0 } 
	{ m_axi_gmemB_ARLEN sc_out sc_lv 32 signal 0 } 
	{ m_axi_gmemB_ARSIZE sc_out sc_lv 3 signal 0 } 
	{ m_axi_gmemB_ARBURST sc_out sc_lv 2 signal 0 } 
	{ m_axi_gmemB_ARLOCK sc_out sc_lv 2 signal 0 } 
	{ m_axi_gmemB_ARCACHE sc_out sc_lv 4 signal 0 } 
	{ m_axi_gmemB_ARPROT sc_out sc_lv 3 signal 0 } 
	{ m_axi_gmemB_ARQOS sc_out sc_lv 4 signal 0 } 
	{ m_axi_gmemB_ARREGION sc_out sc_lv 4 signal 0 } 
	{ m_axi_gmemB_ARUSER sc_out sc_lv 1 signal 0 } 
	{ m_axi_gmemB_RVALID sc_in sc_logic 1 signal 0 } 
	{ m_axi_gmemB_RREADY sc_out sc_logic 1 signal 0 } 
	{ m_axi_gmemB_RDATA sc_in sc_lv 8 signal 0 } 
	{ m_axi_gmemB_RLAST sc_in sc_logic 1 signal 0 } 
	{ m_axi_gmemB_RID sc_in sc_lv 1 signal 0 } 
	{ m_axi_gmemB_RFIFONUM sc_in sc_lv 11 signal 0 } 
	{ m_axi_gmemB_RUSER sc_in sc_lv 1 signal 0 } 
	{ m_axi_gmemB_RRESP sc_in sc_lv 2 signal 0 } 
	{ m_axi_gmemB_BVALID sc_in sc_logic 1 signal 0 } 
	{ m_axi_gmemB_BREADY sc_out sc_logic 1 signal 0 } 
	{ m_axi_gmemB_BRESP sc_in sc_lv 2 signal 0 } 
	{ m_axi_gmemB_BID sc_in sc_lv 1 signal 0 } 
	{ m_axi_gmemB_BUSER sc_in sc_lv 1 signal 0 } 
	{ current_block_M sc_in sc_lv 32 signal 1 } 
	{ mul_ln110 sc_in sc_lv 64 signal 2 } 
	{ zext_ln119 sc_in sc_lv 31 signal 3 } 
	{ zext_ln110 sc_in sc_lv 32 signal 4 } 
	{ B sc_in sc_lv 64 signal 5 } 
	{ j_block sc_in sc_lv 64 signal 6 } 
	{ B_bram_address1 sc_out sc_lv 18 signal 7 } 
	{ B_bram_ce1 sc_out sc_logic 1 signal 7 } 
	{ B_bram_we1 sc_out sc_logic 1 signal 7 } 
	{ B_bram_d1 sc_out sc_lv 8 signal 7 } 
}
set NewPortList {[ 
	{ "name": "ap_clk", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "clock", "bundle":{"name": "ap_clk", "role": "default" }} , 
 	{ "name": "ap_rst", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "reset", "bundle":{"name": "ap_rst", "role": "default" }} , 
 	{ "name": "ap_start", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "start", "bundle":{"name": "ap_start", "role": "default" }} , 
 	{ "name": "ap_done", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "predone", "bundle":{"name": "ap_done", "role": "default" }} , 
 	{ "name": "ap_idle", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "done", "bundle":{"name": "ap_idle", "role": "default" }} , 
 	{ "name": "ap_ready", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "ready", "bundle":{"name": "ap_ready", "role": "default" }} , 
 	{ "name": "m_axi_gmemB_AWVALID", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemB", "role": "AWVALID" }} , 
 	{ "name": "m_axi_gmemB_AWREADY", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemB", "role": "AWREADY" }} , 
 	{ "name": "m_axi_gmemB_AWADDR", "direction": "out", "datatype": "sc_lv", "bitwidth":64, "type": "signal", "bundle":{"name": "gmemB", "role": "AWADDR" }} , 
 	{ "name": "m_axi_gmemB_AWID", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemB", "role": "AWID" }} , 
 	{ "name": "m_axi_gmemB_AWLEN", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "gmemB", "role": "AWLEN" }} , 
 	{ "name": "m_axi_gmemB_AWSIZE", "direction": "out", "datatype": "sc_lv", "bitwidth":3, "type": "signal", "bundle":{"name": "gmemB", "role": "AWSIZE" }} , 
 	{ "name": "m_axi_gmemB_AWBURST", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "gmemB", "role": "AWBURST" }} , 
 	{ "name": "m_axi_gmemB_AWLOCK", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "gmemB", "role": "AWLOCK" }} , 
 	{ "name": "m_axi_gmemB_AWCACHE", "direction": "out", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "gmemB", "role": "AWCACHE" }} , 
 	{ "name": "m_axi_gmemB_AWPROT", "direction": "out", "datatype": "sc_lv", "bitwidth":3, "type": "signal", "bundle":{"name": "gmemB", "role": "AWPROT" }} , 
 	{ "name": "m_axi_gmemB_AWQOS", "direction": "out", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "gmemB", "role": "AWQOS" }} , 
 	{ "name": "m_axi_gmemB_AWREGION", "direction": "out", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "gmemB", "role": "AWREGION" }} , 
 	{ "name": "m_axi_gmemB_AWUSER", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemB", "role": "AWUSER" }} , 
 	{ "name": "m_axi_gmemB_WVALID", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemB", "role": "WVALID" }} , 
 	{ "name": "m_axi_gmemB_WREADY", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemB", "role": "WREADY" }} , 
 	{ "name": "m_axi_gmemB_WDATA", "direction": "out", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "gmemB", "role": "WDATA" }} , 
 	{ "name": "m_axi_gmemB_WSTRB", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemB", "role": "WSTRB" }} , 
 	{ "name": "m_axi_gmemB_WLAST", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemB", "role": "WLAST" }} , 
 	{ "name": "m_axi_gmemB_WID", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemB", "role": "WID" }} , 
 	{ "name": "m_axi_gmemB_WUSER", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemB", "role": "WUSER" }} , 
 	{ "name": "m_axi_gmemB_ARVALID", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemB", "role": "ARVALID" }} , 
 	{ "name": "m_axi_gmemB_ARREADY", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemB", "role": "ARREADY" }} , 
 	{ "name": "m_axi_gmemB_ARADDR", "direction": "out", "datatype": "sc_lv", "bitwidth":64, "type": "signal", "bundle":{"name": "gmemB", "role": "ARADDR" }} , 
 	{ "name": "m_axi_gmemB_ARID", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemB", "role": "ARID" }} , 
 	{ "name": "m_axi_gmemB_ARLEN", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "gmemB", "role": "ARLEN" }} , 
 	{ "name": "m_axi_gmemB_ARSIZE", "direction": "out", "datatype": "sc_lv", "bitwidth":3, "type": "signal", "bundle":{"name": "gmemB", "role": "ARSIZE" }} , 
 	{ "name": "m_axi_gmemB_ARBURST", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "gmemB", "role": "ARBURST" }} , 
 	{ "name": "m_axi_gmemB_ARLOCK", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "gmemB", "role": "ARLOCK" }} , 
 	{ "name": "m_axi_gmemB_ARCACHE", "direction": "out", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "gmemB", "role": "ARCACHE" }} , 
 	{ "name": "m_axi_gmemB_ARPROT", "direction": "out", "datatype": "sc_lv", "bitwidth":3, "type": "signal", "bundle":{"name": "gmemB", "role": "ARPROT" }} , 
 	{ "name": "m_axi_gmemB_ARQOS", "direction": "out", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "gmemB", "role": "ARQOS" }} , 
 	{ "name": "m_axi_gmemB_ARREGION", "direction": "out", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "gmemB", "role": "ARREGION" }} , 
 	{ "name": "m_axi_gmemB_ARUSER", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemB", "role": "ARUSER" }} , 
 	{ "name": "m_axi_gmemB_RVALID", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemB", "role": "RVALID" }} , 
 	{ "name": "m_axi_gmemB_RREADY", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemB", "role": "RREADY" }} , 
 	{ "name": "m_axi_gmemB_RDATA", "direction": "in", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "gmemB", "role": "RDATA" }} , 
 	{ "name": "m_axi_gmemB_RLAST", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemB", "role": "RLAST" }} , 
 	{ "name": "m_axi_gmemB_RID", "direction": "in", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemB", "role": "RID" }} , 
 	{ "name": "m_axi_gmemB_RFIFONUM", "direction": "in", "datatype": "sc_lv", "bitwidth":11, "type": "signal", "bundle":{"name": "gmemB", "role": "RFIFONUM" }} , 
 	{ "name": "m_axi_gmemB_RUSER", "direction": "in", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemB", "role": "RUSER" }} , 
 	{ "name": "m_axi_gmemB_RRESP", "direction": "in", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "gmemB", "role": "RRESP" }} , 
 	{ "name": "m_axi_gmemB_BVALID", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemB", "role": "BVALID" }} , 
 	{ "name": "m_axi_gmemB_BREADY", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemB", "role": "BREADY" }} , 
 	{ "name": "m_axi_gmemB_BRESP", "direction": "in", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "gmemB", "role": "BRESP" }} , 
 	{ "name": "m_axi_gmemB_BID", "direction": "in", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemB", "role": "BID" }} , 
 	{ "name": "m_axi_gmemB_BUSER", "direction": "in", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemB", "role": "BUSER" }} , 
 	{ "name": "current_block_M", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "current_block_M", "role": "default" }} , 
 	{ "name": "mul_ln110", "direction": "in", "datatype": "sc_lv", "bitwidth":64, "type": "signal", "bundle":{"name": "mul_ln110", "role": "default" }} , 
 	{ "name": "zext_ln119", "direction": "in", "datatype": "sc_lv", "bitwidth":31, "type": "signal", "bundle":{"name": "zext_ln119", "role": "default" }} , 
 	{ "name": "zext_ln110", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "zext_ln110", "role": "default" }} , 
 	{ "name": "B", "direction": "in", "datatype": "sc_lv", "bitwidth":64, "type": "signal", "bundle":{"name": "B", "role": "default" }} , 
 	{ "name": "j_block", "direction": "in", "datatype": "sc_lv", "bitwidth":64, "type": "signal", "bundle":{"name": "j_block", "role": "default" }} , 
 	{ "name": "B_bram_address1", "direction": "out", "datatype": "sc_lv", "bitwidth":18, "type": "signal", "bundle":{"name": "B_bram", "role": "address1" }} , 
 	{ "name": "B_bram_ce1", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "B_bram", "role": "ce1" }} , 
 	{ "name": "B_bram_we1", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "B_bram", "role": "we1" }} , 
 	{ "name": "B_bram_d1", "direction": "out", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "B_bram", "role": "d1" }}  ]}

set RtlHierarchyInfo {[
	{"ID" : "0", "Level" : "0", "Path" : "`AUTOTB_DUT_INST", "Parent" : "", "Child" : ["1", "2"],
		"CDFG" : "mmult_accel_Pipeline_VITIS_LOOP_120_2",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1", "real_start" : "0",
		"Pipeline" : "None", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "0",
		"VariableLatency" : "1", "ExactLatency" : "-1", "EstimateLatencyMin" : "-1", "EstimateLatencyMax" : "-1",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"IsBlackBox" : "0",
		"Port" : [
			{"Name" : "gmemB", "Type" : "MAXI", "Direction" : "I",
				"BlockSignal" : [
					{"Name" : "gmemB_blk_n_R", "Type" : "RtlSignal"},
					{"Name" : "gmemB_blk_n_AR", "Type" : "RtlSignal"}]},
			{"Name" : "current_block_M", "Type" : "None", "Direction" : "I"},
			{"Name" : "mul_ln110", "Type" : "None", "Direction" : "I"},
			{"Name" : "zext_ln119", "Type" : "None", "Direction" : "I"},
			{"Name" : "zext_ln110", "Type" : "None", "Direction" : "I"},
			{"Name" : "B", "Type" : "None", "Direction" : "I"},
			{"Name" : "j_block", "Type" : "None", "Direction" : "I"},
			{"Name" : "B_bram", "Type" : "Memory", "Direction" : "O"}],
		"Loop" : [
			{"Name" : "copy_B_block_VITIS_LOOP_120_2", "PipelineType" : "UPC",
				"LoopDec" : {"FSMBitwidth" : "1", "FirstState" : "ap_ST_fsm_pp0_stage0", "FirstStateIter" : "ap_enable_reg_pp0_iter1", "FirstStateBlock" : "ap_block_pp0_stage0_subdone", "LastState" : "ap_ST_fsm_pp0_stage0", "LastStateIter" : "ap_enable_reg_pp0_iter10", "LastStateBlock" : "ap_block_pp0_stage0_subdone", "QuitState" : "ap_ST_fsm_pp0_stage0", "QuitStateIter" : "ap_enable_reg_pp0_iter10", "QuitStateBlock" : "ap_block_pp0_stage0_subdone", "OneDepthLoop" : "0", "has_ap_ctrl" : "1", "has_continue" : "0"}}]},
	{"ID" : "1", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.mul_31ns_32ns_63_1_1_U6", "Parent" : "0"},
	{"ID" : "2", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.flow_control_loop_pipe_sequential_init_U", "Parent" : "0"}]}


set ArgLastReadFirstWriteLatency {
	mmult_accel_Pipeline_VITIS_LOOP_120_2 {
		gmemB {Type I LastRead 9 FirstWrite -1}
		current_block_M {Type I LastRead 0 FirstWrite -1}
		mul_ln110 {Type I LastRead 0 FirstWrite -1}
		zext_ln119 {Type I LastRead 0 FirstWrite -1}
		zext_ln110 {Type I LastRead 0 FirstWrite -1}
		B {Type I LastRead 0 FirstWrite -1}
		j_block {Type I LastRead 0 FirstWrite -1}
		B_bram {Type O LastRead -1 FirstWrite 10}}}

set hasDtUnsupportedChannel 0

set PerformanceInfo {[
	{"Name" : "Latency", "Min" : "-1", "Max" : "-1"}
	, {"Name" : "Interval", "Min" : "-1", "Max" : "-1"}
]}

set PipelineEnableSignalInfo {[
	{"Pipeline" : "0", "EnableSignal" : "ap_enable_pp0"}
]}

set Spec2ImplPortList { 
	 { m_axi {  { m_axi_gmemB_AWVALID VALID 1 1 }  { m_axi_gmemB_AWREADY READY 0 1 }  { m_axi_gmemB_AWADDR ADDR 1 64 }  { m_axi_gmemB_AWID ID 1 1 }  { m_axi_gmemB_AWLEN SIZE 1 32 }  { m_axi_gmemB_AWSIZE BURST 1 3 }  { m_axi_gmemB_AWBURST LOCK 1 2 }  { m_axi_gmemB_AWLOCK CACHE 1 2 }  { m_axi_gmemB_AWCACHE PROT 1 4 }  { m_axi_gmemB_AWPROT QOS 1 3 }  { m_axi_gmemB_AWQOS REGION 1 4 }  { m_axi_gmemB_AWREGION USER 1 4 }  { m_axi_gmemB_AWUSER DATA 1 1 }  { m_axi_gmemB_WVALID VALID 1 1 }  { m_axi_gmemB_WREADY READY 0 1 }  { m_axi_gmemB_WDATA FIFONUM 1 8 }  { m_axi_gmemB_WSTRB STRB 1 1 }  { m_axi_gmemB_WLAST LAST 1 1 }  { m_axi_gmemB_WID ID 1 1 }  { m_axi_gmemB_WUSER DATA 1 1 }  { m_axi_gmemB_ARVALID VALID 1 1 }  { m_axi_gmemB_ARREADY READY 0 1 }  { m_axi_gmemB_ARADDR ADDR 1 64 }  { m_axi_gmemB_ARID ID 1 1 }  { m_axi_gmemB_ARLEN SIZE 1 32 }  { m_axi_gmemB_ARSIZE BURST 1 3 }  { m_axi_gmemB_ARBURST LOCK 1 2 }  { m_axi_gmemB_ARLOCK CACHE 1 2 }  { m_axi_gmemB_ARCACHE PROT 1 4 }  { m_axi_gmemB_ARPROT QOS 1 3 }  { m_axi_gmemB_ARQOS REGION 1 4 }  { m_axi_gmemB_ARREGION USER 1 4 }  { m_axi_gmemB_ARUSER DATA 1 1 }  { m_axi_gmemB_RVALID VALID 0 1 }  { m_axi_gmemB_RREADY READY 1 1 }  { m_axi_gmemB_RDATA FIFONUM 0 8 }  { m_axi_gmemB_RLAST LAST 0 1 }  { m_axi_gmemB_RID ID 0 1 }  { m_axi_gmemB_RFIFONUM LEN 0 11 }  { m_axi_gmemB_RUSER DATA 0 1 }  { m_axi_gmemB_RRESP RESP 0 2 }  { m_axi_gmemB_BVALID VALID 0 1 }  { m_axi_gmemB_BREADY READY 1 1 }  { m_axi_gmemB_BRESP RESP 0 2 }  { m_axi_gmemB_BID ID 0 1 }  { m_axi_gmemB_BUSER DATA 0 1 } } }
	current_block_M { ap_none {  { current_block_M in_data 0 32 } } }
	mul_ln110 { ap_none {  { mul_ln110 in_data 0 64 } } }
	zext_ln119 { ap_none {  { zext_ln119 in_data 0 31 } } }
	zext_ln110 { ap_none {  { zext_ln110 in_data 0 32 } } }
	B { ap_none {  { B in_data 0 64 } } }
	j_block { ap_none {  { j_block in_data 0 64 } } }
	B_bram { ap_memory {  { B_bram_address1 MemPortADDR2 1 18 }  { B_bram_ce1 MemPortCE2 1 1 }  { B_bram_we1 MemPortWE2 1 1 }  { B_bram_d1 MemPortDIN2 1 8 } } }
}
