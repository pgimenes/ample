NDContentPage.OnToolTipsLoaded({133:"<div class=\"NDToolTip TClass LSystemVerilog\"><div class=\"TTSummary\">The xil_seq_item_pull_port#(REQ,RSP) class is extends from xil_sqr_if_base. It inherits all these variables and functions of xil_sqr_if_base.</div></div>",367:"<div class=\"NDToolTip TType LSystemVerilog\"><div class=\"TTSummary\">Xilinx AXI VIP Interger unsigned data type</div></div>",391:"<div class=\"NDToolTip TType LSystemVerilog\"><div class=\"TTSummary\">Xilinx AXI VIP Boolean data type</div></div>",413:"<div class=\"NDToolTip TFunction LSystemVerilog\"><div id=\"NDPrototype413\" class=\"NDPrototype WideForm CStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">function void</span> set_bready_gen(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PModifierQualifier first\">input&nbsp;</td><td class=\"PType\">axi_ready_gen_t&nbsp;</td><td class=\"PName last\">new_gen</td></tr></table></td><td class=\"PAfterParameters\">);</td></tr></table></div><div class=\"TTSummary\">Sets bready of the AXI master write driver. There are three ways for bready generation in AXI master write driver.</div></div>",516:"<div class=\"NDToolTip TClass LSystemVerilog\"><div class=\"TTSummary\">The axi_transaction class is the base class of AXI protocol. It inherits all the methods of xil_sequence_item.</div></div>",631:"<div class=\"NDToolTip TClass LSystemVerilog\"><div class=\"TTSummary\">AXI VIF Proxy Class. It has virtual interface for AXI VIP interface.</div></div>",714:"<div class=\"NDToolTip TClass LSystemVerilog\"><div class=\"TTSummary\">AXI Master Write Driver class.</div></div>",747:"<div class=\"NDToolTip TClass LSystemVerilog\"><div class=\"TTSummary\">AXI Ready generation class.</div></div>",960:"<div class=\"NDToolTip TFunction LSystemVerilog\"><div id=\"NDPrototype960\" class=\"NDPrototype WideForm CStyle\"><table><tr><td class=\"PBeforeParameters\">task send_bready(</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PModifierQualifier first\">input&nbsp;</td><td class=\"PType\">axi_ready_gen&nbsp;</td><td class=\"PName last\">t</td></tr></table></td><td class=\"PAfterParameters\">);</td></tr></table></div><div class=\"TTSummary\">Sends the ready structure to the axi_mst_wr_driver for controlling the READY channel.&nbsp; Usually user would create a new axi_ready_gen by calling create_ready of axi_mst_wr_driver, either randomize the bready or set it up manually. Then it calls send to send the bready to axi_mst_wr_driver.</div></div>",1000:"<div class=\"NDToolTip TFunction LSystemVerilog\"><div id=\"NDPrototype1000\" class=\"NDPrototype WideForm CStyle\"><table><tr><td class=\"PBeforeParameters\"><span class=\"SHKeyword\">function void</span> set_forward_progress_timeout_value (</td><td class=\"PParametersParentCell\"><table class=\"PParameters\"><tr><td class=\"PModifierQualifier first\">input&nbsp;</td><td class=\"PType\">xil_axi_uint&nbsp;</td><td class=\"PName last\">new_timeout</td></tr></table></td><td class=\"PAfterParameters\">);</td></tr></table></div><div class=\"TTSummary\">Sets the number of cycles that the driver will wait for AW/W/B accepted until it will flag a watch dog error of the axi_mst_wr_driver. Default value is 50000. Setting this to a very large value will cause a hung simulation to continue for a longer time.&nbsp; Setting this to a very small number may not allow enough time for simulation to respond.</div></div>"});