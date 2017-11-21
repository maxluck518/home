module top(/*vlog_aide:auto_port*/);

//Power
input		AVDD33;
input		AVDD18;
input		AVSS;
input		IPP20UA;
input		ICC20UA;
input		PU;

//Register	I/F
/*vlog_aide:auto_inf RegisterInf begin*/
input		POR_RESET;
input		SYS_CLK;
input	[3:0]	REG_ADDR;
input	[31:0]	REG_WDAT;
input	[3:0]	REG_WBE;
input		REG_WE;
input		REG_RE;
input	[31:0]	REG_RDAT_IN;
output	[31:0]	REG_RDAT_OUT;
/*vlog_aide:auto_inf RegisterInf end*/
//Clock
input		TXCLK30M_IN;
input		TXCLK60M_IN;
input		TXCLK120M_IN;
input		TXCLK240M_IN;
input		TXCLKB_IN;
input		TXCLK_IN;
input		CLK100K ;
input		RXCLK1P92GP;
input		RXCLK1P92GN;
output		RXCLK1P92GP_OUT ;
output		RXCLK1P92GN_OUT ;
output		SUSPEND_PLL;
input		PLL_LOCK;

/*vlog_aide:auto_inf UtmiInf begin*/
//UTMI+	Serial	Mode
input		FSLSSERIALMODE;
input		TX_ENABLE_N;
input		TX_SE0;
input		TX_DAT;
output		RX_RCV;
output		RX_DM;
output		RX_DP;

//UTMI+	Control
input		DATABUS16_8;
input		UTMI_RESET;
output		CLK_OUT;
output		CLK_OUT_FREERUN;
output	[1:0]	LINE_STATE;
input	[1:0]	XCVRSELECT;
input		TERM_SELECT;
input	[1:0]	OP_MODE;
input		SUSPENDM;
output		HOST_DISCONNECT;
input		TX_BITSTUFF_EN;
input		DM_PULLDOWN;
input		DP_PULLDOWN;

inout		DP;
inout		DM;

//UTMI+	TX
input	[15:0]	DATA_IN;
input		TX_VALIDH;
input		TX_VALID;
output		TX_READY;

//UTMI+	RX
output	[15:0]	DATA_OUT;
output		RX_ACTIVE;
output		RX_VALIDH;
output		RX_VALID;
output		RX_ERROR;
/*vlog_aide:auto_inf UtmiInf end*/

//Scan	&	test
/*vlog_aide:auto_inf ScanInf begin*/
input		IDDQ_TEST;
input		SCAN_TEST;
input		SCANCK;
input		SCN;
input	[13:0]	SI;
output	[13:0]	SO;
output		TEST_PIN;
output	[15:0]	PHY_MON;
/*vlog_aide:auto_inf ScanInf end*/

//Misc
/*vlog_aide:auto_inf MiscInf begin*/
input		VBUS_ON;
input		PD18_VDDR_G;
output		PD18_VDDR_G_OUT;
input	[ 3:0]	IMP_SEL_FS ;
input		VG_IN_PHASE;
output		VG_OUT_PHASE;
input	[7:0]	RESERVE_IN;
output	[7:0]	RESERVE_OUT;
/*vlog_aide:auto_inf MiscInf end*/

endmodule
