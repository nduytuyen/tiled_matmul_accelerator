set moduleName mmult_accel_Pipeline_copy_A_VITIS_LOOP_97_1
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
set C_modelName {mmult_accel_Pipeline_copy_A_VITIS_LOOP_97_1}
set C_modelType { void 0 }
set C_modelArgList {
	{ gmemA int 8 regular {axi_master 0}  }
	{ A int 64 regular  }
	{ K int 32 regular  }
	{ mul_ln96_1 int 64 regular  }
	{ A_bram int 8 regular {array 49152 { 3 0 } 0 1 } {global 1}  }
}
set C_modelArgMapList {[ 
	{ "Name" : "gmemA", "interface" : "axi_master", "bitwidth" : 8, "direction" : "READONLY", "bitSlice":[ {"cElement": [{"cName": "A","offset": { "type": "dynamic","port_name": "A","bundle": "control"},"direction": "READONLY"}]}]} , 
 	{ "Name" : "A", "interface" : "wire", "bitwidth" : 64, "direction" : "READONLY"} , 
 	{ "Name" : "K", "interface" : "wire", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "mul_ln96_1", "interface" : "wire", "bitwidth" : 64, "direction" : "READONLY"} , 
 	{ "Name" : "A_bram", "interface" : "memory", "bitwidth" : 8, "direction" : "WRITEONLY", "extern" : 0} ]}
# RTL Port declarations: 
set portNum 59
set portList { 
	{ ap_clk sc_in sc_logic 1 clock -1 } 
	{ ap_rst sc_in sc_logic 1 reset -1 active_high_sync } 
	{ ap_start sc_in sc_logic 1 start -1 } 
	{ ap_done sc_out sc_logic 1 predone -1 } 
	{ ap_idle sc_out sc_logic 1 done -1 } 
	{ ap_ready sc_out sc_logic 1 ready -1 } 
	{ m_axi_gmemA_AWVALID sc_out sc_logic 1 signal 0 } 
	{ m_axi_gmemA_AWREADY sc_in sc_logic 1 signal 0 } 
	{ m_axi_gmemA_AWADDR sc_out sc_lv 64 signal 0 } 
	{ m_axi_gmemA_AWID sc_out sc_lv 1 signal 0 } 
	{ m_axi_gmemA_AWLEN sc_out sc_lv 32 signal 0 } 
	{ m_axi_gmemA_AWSIZE sc_out sc_lv 3 signal 0 } 
	{ m_axi_gmemA_AWBURST sc_out sc_lv 2 signal 0 } 
	{ m_axi_gmemA_AWLOCK sc_out sc_lv 2 signal 0 } 
	{ m_axi_gmemA_AWCACHE sc_out sc_lv 4 signal 0 } 
	{ m_axi_gmemA_AWPROT sc_out sc_lv 3 signal 0 } 
	{ m_axi_gmemA_AWQOS sc_out sc_lv 4 signal 0 } 
	{ m_axi_gmemA_AWREGION sc_out sc_lv 4 signal 0 } 
	{ m_axi_gmemA_AWUSER sc_out sc_lv 1 signal 0 } 
	{ m_axi_gmemA_WVALID sc_out sc_logic 1 signal 0 } 
	{ m_axi_gmemA_WREADY sc_in sc_logic 1 signal 0 } 
	{ m_axi_gmemA_WDATA sc_out sc_lv 8 signal 0 } 
	{ m_axi_gmemA_WSTRB sc_out sc_lv 1 signal 0 } 
	{ m_axi_gmemA_WLAST sc_out sc_logic 1 signal 0 } 
	{ m_axi_gmemA_WID sc_out sc_lv 1 signal 0 } 
	{ m_axi_gmemA_WUSER sc_out sc_lv 1 signal 0 } 
	{ m_axi_gmemA_ARVALID sc_out sc_logic 1 signal 0 } 
	{ m_axi_gmemA_ARREADY sc_in sc_logic 1 signal 0 } 
	{ m_axi_gmemA_ARADDR sc_out sc_lv 64 signal 0 } 
	{ m_axi_gmemA_ARID sc_out sc_lv 1 signal 0 } 
	{ m_axi_gmemA_ARLEN sc_out sc_lv 32 signal 0 } 
	{ m_axi_gmemA_ARSIZE sc_out sc_lv 3 signal 0 } 
	{ m_axi_gmemA_ARBURST sc_out sc_lv 2 signal 0 } 
	{ m_axi_gmemA_ARLOCK sc_out sc_lv 2 signal 0 } 
	{ m_axi_gmemA_ARCACHE sc_out sc_lv 4 signal 0 } 
	{ m_axi_gmemA_ARPROT sc_out sc_lv 3 signal 0 } 
	{ m_axi_gmemA_ARQOS sc_out sc_lv 4 signal 0 } 
	{ m_axi_gmemA_ARREGION sc_out sc_lv 4 signal 0 } 
	{ m_axi_gmemA_ARUSER sc_out sc_lv 1 signal 0 } 
	{ m_axi_gmemA_RVALID sc_in sc_logic 1 signal 0 } 
	{ m_axi_gmemA_RREADY sc_out sc_logic 1 signal 0 } 
	{ m_axi_gmemA_RDATA sc_in sc_lv 8 signal 0 } 
	{ m_axi_gmemA_RLAST sc_in sc_logic 1 signal 0 } 
	{ m_axi_gmemA_RID sc_in sc_lv 1 signal 0 } 
	{ m_axi_gmemA_RFIFONUM sc_in sc_lv 11 signal 0 } 
	{ m_axi_gmemA_RUSER sc_in sc_lv 1 signal 0 } 
	{ m_axi_gmemA_RRESP sc_in sc_lv 2 signal 0 } 
	{ m_axi_gmemA_BVALID sc_in sc_logic 1 signal 0 } 
	{ m_axi_gmemA_BREADY sc_out sc_logic 1 signal 0 } 
	{ m_axi_gmemA_BRESP sc_in sc_lv 2 signal 0 } 
	{ m_axi_gmemA_BID sc_in sc_lv 1 signal 0 } 
	{ m_axi_gmemA_BUSER sc_in sc_lv 1 signal 0 } 
	{ A sc_in sc_lv 64 signal 1 } 
	{ K sc_in sc_lv 32 signal 2 } 
	{ mul_ln96_1 sc_in sc_lv 64 signal 3 } 
	{ A_bram_address1 sc_out sc_lv 16 signal 4 } 
	{ A_bram_ce1 sc_out sc_logic 1 signal 4 } 
	{ A_bram_we1 sc_out sc_logic 1 signal 4 } 
	{ A_bram_d1 sc_out sc_lv 8 signal 4 } 
}
set NewPortList {[ 
	{ "name": "ap_clk", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "clock", "bundle":{"name": "ap_clk", "role": "default" }} , 
 	{ "name": "ap_rst", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "reset", "bundle":{"name": "ap_rst", "role": "default" }} , 
 	{ "name": "ap_start", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "start", "bundle":{"name": "ap_start", "role": "default" }} , 
 	{ "name": "ap_done", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "predone", "bundle":{"name": "ap_done", "role": "default" }} , 
 	{ "name": "ap_idle", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "done", "bundle":{"name": "ap_idle", "role": "default" }} , 
 	{ "name": "ap_ready", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "ready", "bundle":{"name": "ap_ready", "role": "default" }} , 
 	{ "name": "m_axi_gmemA_AWVALID", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemA", "role": "AWVALID" }} , 
 	{ "name": "m_axi_gmemA_AWREADY", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemA", "role": "AWREADY" }} , 
 	{ "name": "m_axi_gmemA_AWADDR", "direction": "out", "datatype": "sc_lv", "bitwidth":64, "type": "signal", "bundle":{"name": "gmemA", "role": "AWADDR" }} , 
 	{ "name": "m_axi_gmemA_AWID", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemA", "role": "AWID" }} , 
 	{ "name": "m_axi_gmemA_AWLEN", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "gmemA", "role": "AWLEN" }} , 
 	{ "name": "m_axi_gmemA_AWSIZE", "direction": "out", "datatype": "sc_lv", "bitwidth":3, "type": "signal", "bundle":{"name": "gmemA", "role": "AWSIZE" }} , 
 	{ "name": "m_axi_gmemA_AWBURST", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "gmemA", "role": "AWBURST" }} , 
 	{ "name": "m_axi_gmemA_AWLOCK", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "gmemA", "role": "AWLOCK" }} , 
 	{ "name": "m_axi_gmemA_AWCACHE", "direction": "out", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "gmemA", "role": "AWCACHE" }} , 
 	{ "name": "m_axi_gmemA_AWPROT", "direction": "out", "datatype": "sc_lv", "bitwidth":3, "type": "signal", "bundle":{"name": "gmemA", "role": "AWPROT" }} , 
 	{ "name": "m_axi_gmemA_AWQOS", "direction": "out", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "gmemA", "role": "AWQOS" }} , 
 	{ "name": "m_axi_gmemA_AWREGION", "direction": "out", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "gmemA", "role": "AWREGION" }} , 
 	{ "name": "m_axi_gmemA_AWUSER", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemA", "role": "AWUSER" }} , 
 	{ "name": "m_axi_gmemA_WVALID", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemA", "role": "WVALID" }} , 
 	{ "name": "m_axi_gmemA_WREADY", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemA", "role": "WREADY" }} , 
 	{ "name": "m_axi_gmemA_WDATA", "direction": "out", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "gmemA", "role": "WDATA" }} , 
 	{ "name": "m_axi_gmemA_WSTRB", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemA", "role": "WSTRB" }} , 
 	{ "name": "m_axi_gmemA_WLAST", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemA", "role": "WLAST" }} , 
 	{ "name": "m_axi_gmemA_WID", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemA", "role": "WID" }} , 
 	{ "name": "m_axi_gmemA_WUSER", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemA", "role": "WUSER" }} , 
 	{ "name": "m_axi_gmemA_ARVALID", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemA", "role": "ARVALID" }} , 
 	{ "name": "m_axi_gmemA_ARREADY", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemA", "role": "ARREADY" }} , 
 	{ "name": "m_axi_gmemA_ARADDR", "direction": "out", "datatype": "sc_lv", "bitwidth":64, "type": "signal", "bundle":{"name": "gmemA", "role": "ARADDR" }} , 
 	{ "name": "m_axi_gmemA_ARID", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemA", "role": "ARID" }} , 
 	{ "name": "m_axi_gmemA_ARLEN", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "gmemA", "role": "ARLEN" }} , 
 	{ "name": "m_axi_gmemA_ARSIZE", "direction": "out", "datatype": "sc_lv", "bitwidth":3, "type": "signal", "bundle":{"name": "gmemA", "role": "ARSIZE" }} , 
 	{ "name": "m_axi_gmemA_ARBURST", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "gmemA", "role": "ARBURST" }} , 
 	{ "name": "m_axi_gmemA_ARLOCK", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "gmemA", "role": "ARLOCK" }} , 
 	{ "name": "m_axi_gmemA_ARCACHE", "direction": "out", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "gmemA", "role": "ARCACHE" }} , 
 	{ "name": "m_axi_gmemA_ARPROT", "direction": "out", "datatype": "sc_lv", "bitwidth":3, "type": "signal", "bundle":{"name": "gmemA", "role": "ARPROT" }} , 
 	{ "name": "m_axi_gmemA_ARQOS", "direction": "out", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "gmemA", "role": "ARQOS" }} , 
 	{ "name": "m_axi_gmemA_ARREGION", "direction": "out", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "gmemA", "role": "ARREGION" }} , 
 	{ "name": "m_axi_gmemA_ARUSER", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemA", "role": "ARUSER" }} , 
 	{ "name": "m_axi_gmemA_RVALID", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemA", "role": "RVALID" }} , 
 	{ "name": "m_axi_gmemA_RREADY", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemA", "role": "RREADY" }} , 
 	{ "name": "m_axi_gmemA_RDATA", "direction": "in", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "gmemA", "role": "RDATA" }} , 
 	{ "name": "m_axi_gmemA_RLAST", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemA", "role": "RLAST" }} , 
 	{ "name": "m_axi_gmemA_RID", "direction": "in", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemA", "role": "RID" }} , 
 	{ "name": "m_axi_gmemA_RFIFONUM", "direction": "in", "datatype": "sc_lv", "bitwidth":11, "type": "signal", "bundle":{"name": "gmemA", "role": "RFIFONUM" }} , 
 	{ "name": "m_axi_gmemA_RUSER", "direction": "in", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemA", "role": "RUSER" }} , 
 	{ "name": "m_axi_gmemA_RRESP", "direction": "in", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "gmemA", "role": "RRESP" }} , 
 	{ "name": "m_axi_gmemA_BVALID", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemA", "role": "BVALID" }} , 
 	{ "name": "m_axi_gmemA_BREADY", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemA", "role": "BREADY" }} , 
 	{ "name": "m_axi_gmemA_BRESP", "direction": "in", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "gmemA", "role": "BRESP" }} , 
 	{ "name": "m_axi_gmemA_BID", "direction": "in", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemA", "role": "BID" }} , 
 	{ "name": "m_axi_gmemA_BUSER", "direction": "in", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "gmemA", "role": "BUSER" }} , 
 	{ "name": "A", "direction": "in", "datatype": "sc_lv", "bitwidth":64, "type": "signal", "bundle":{"name": "A", "role": "default" }} , 
 	{ "name": "K", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "K", "role": "default" }} , 
 	{ "name": "mul_ln96_1", "direction": "in", "datatype": "sc_lv", "bitwidth":64, "type": "signal", "bundle":{"name": "mul_ln96_1", "role": "default" }} , 
 	{ "name": "A_bram_address1", "direction": "out", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "A_bram", "role": "address1" }} , 
 	{ "name": "A_bram_ce1", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "A_bram", "role": "ce1" }} , 
 	{ "name": "A_bram_we1", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "A_bram", "role": "we1" }} , 
 	{ "name": "A_bram_d1", "direction": "out", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "A_bram", "role": "d1" }}  ]}

set RtlHierarchyInfo {[
	{"ID" : "0", "Level" : "0", "Path" : "`AUTOTB_DUT_INST", "Parent" : "", "Child" : ["1"],
		"CDFG" : "mmult_accel_Pipeline_copy_A_VITIS_LOOP_97_1",
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
			{"Name" : "gmemA", "Type" : "MAXI", "Direction" : "I",
				"BlockSignal" : [
					{"Name" : "gmemA_blk_n_R", "Type" : "RtlSignal"}]},
			{"Name" : "A", "Type" : "None", "Direction" : "I"},
			{"Name" : "K", "Type" : "None", "Direction" : "I"},
			{"Name" : "mul_ln96_1", "Type" : "None", "Direction" : "I"},
			{"Name" : "A_bram", "Type" : "Memory", "Direction" : "O"}],
		"Loop" : [
			{"Name" : "copy_A_VITIS_LOOP_97_1", "PipelineType" : "UPC",
				"LoopDec" : {"FSMBitwidth" : "1", "FirstState" : "ap_ST_fsm_pp0_stage0", "FirstStateIter" : "ap_enable_reg_pp0_iter1", "FirstStateBlock" : "ap_block_pp0_stage0_subdone", "LastState" : "ap_ST_fsm_pp0_stage0", "LastStateIter" : "ap_enable_reg_pp0_iter3", "LastStateBlock" : "ap_block_pp0_stage0_subdone", "QuitState" : "ap_ST_fsm_pp0_stage0", "QuitStateIter" : "ap_enable_reg_pp0_iter2", "QuitStateBlock" : "ap_block_pp0_stage0_subdone", "OneDepthLoop" : "0", "has_ap_ctrl" : "1", "has_continue" : "0"}}]},
	{"ID" : "1", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.flow_control_loop_pipe_sequential_init_U", "Parent" : "0"}]}


set ArgLastReadFirstWriteLatency {
	mmult_accel_Pipeline_copy_A_VITIS_LOOP_97_1 {
		gmemA {Type I LastRead 2 FirstWrite -1}
		A {Type I LastRead 0 FirstWrite -1}
		K {Type I LastRead 0 FirstWrite -1}
		mul_ln96_1 {Type I LastRead 0 FirstWrite -1}
		A_bram {Type O LastRead -1 FirstWrite 3}}}

set hasDtUnsupportedChannel 0

set PerformanceInfo {[
	{"Name" : "Latency", "Min" : "-1", "Max" : "-1"}
	, {"Name" : "Interval", "Min" : "-1", "Max" : "-1"}
]}

set PipelineEnableSignalInfo {[
	{"Pipeline" : "0", "EnableSignal" : "ap_enable_pp0"}
]}

set Spec2ImplPortList { 
	 { m_axi {  { m_axi_gmemA_AWVALID VALID 1 1 }  { m_axi_gmemA_AWREADY READY 0 1 }  { m_axi_gmemA_AWADDR ADDR 1 64 }  { m_axi_gmemA_AWID ID 1 1 }  { m_axi_gmemA_AWLEN SIZE 1 32 }  { m_axi_gmemA_AWSIZE BURST 1 3 }  { m_axi_gmemA_AWBURST LOCK 1 2 }  { m_axi_gmemA_AWLOCK CACHE 1 2 }  { m_axi_gmemA_AWCACHE PROT 1 4 }  { m_axi_gmemA_AWPROT QOS 1 3 }  { m_axi_gmemA_AWQOS REGION 1 4 }  { m_axi_gmemA_AWREGION USER 1 4 }  { m_axi_gmemA_AWUSER DATA 1 1 }  { m_axi_gmemA_WVALID VALID 1 1 }  { m_axi_gmemA_WREADY READY 0 1 }  { m_axi_gmemA_WDATA FIFONUM 1 8 }  { m_axi_gmemA_WSTRB STRB 1 1 }  { m_axi_gmemA_WLAST LAST 1 1 }  { m_axi_gmemA_WID ID 1 1 }  { m_axi_gmemA_WUSER DATA 1 1 }  { m_axi_gmemA_ARVALID VALID 1 1 }  { m_axi_gmemA_ARREADY READY 0 1 }  { m_axi_gmemA_ARADDR ADDR 1 64 }  { m_axi_gmemA_ARID ID 1 1 }  { m_axi_gmemA_ARLEN SIZE 1 32 }  { m_axi_gmemA_ARSIZE BURST 1 3 }  { m_axi_gmemA_ARBURST LOCK 1 2 }  { m_axi_gmemA_ARLOCK CACHE 1 2 }  { m_axi_gmemA_ARCACHE PROT 1 4 }  { m_axi_gmemA_ARPROT QOS 1 3 }  { m_axi_gmemA_ARQOS REGION 1 4 }  { m_axi_gmemA_ARREGION USER 1 4 }  { m_axi_gmemA_ARUSER DATA 1 1 }  { m_axi_gmemA_RVALID VALID 0 1 }  { m_axi_gmemA_RREADY READY 1 1 }  { m_axi_gmemA_RDATA FIFONUM 0 8 }  { m_axi_gmemA_RLAST LAST 0 1 }  { m_axi_gmemA_RID ID 0 1 }  { m_axi_gmemA_RFIFONUM LEN 0 11 }  { m_axi_gmemA_RUSER DATA 0 1 }  { m_axi_gmemA_RRESP RESP 0 2 }  { m_axi_gmemA_BVALID VALID 0 1 }  { m_axi_gmemA_BREADY READY 1 1 }  { m_axi_gmemA_BRESP RESP 0 2 }  { m_axi_gmemA_BID ID 0 1 }  { m_axi_gmemA_BUSER DATA 0 1 } } }
	A { ap_none {  { A in_data 0 64 } } }
	K { ap_none {  { K in_data 0 32 } } }
	mul_ln96_1 { ap_none {  { mul_ln96_1 in_data 0 64 } } }
	A_bram { ap_memory {  { A_bram_address1 MemPortADDR2 1 16 }  { A_bram_ce1 MemPortCE2 1 1 }  { A_bram_we1 MemPortWE2 1 1 }  { A_bram_d1 MemPortDIN2 1 8 } } }
}
