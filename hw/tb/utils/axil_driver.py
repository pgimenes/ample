
import cocotb
from cocotb.triggers import RisingEdge

class AXILDriver:
    def __init__(self, dut):
        self.dut = dut

    async def axil_write(self, address, data):
        # Reset signals
        self.dut.host_axil_awvalid.value = 0
        self.dut.host_axil_awaddr.value = 0
        self.dut.host_axil_wvalid.value = 0
        self.dut.host_axil_wdata.value = 0
        self.dut.host_axil_bready.value = 0

        await RisingEdge(self.dut.regbank_clk)

        # AW phase
        self.dut.host_axil_awvalid.value = 1
        self.dut.host_axil_awaddr.value = address
        # Wait to accept address
        while(True):
            await RisingEdge(self.dut.regbank_clk)
            if (self.dut.host_axil_awready.value):
                break

        self.dut.host_axil_awvalid.value = 0

        # W phase
        self.dut.host_axil_wvalid.value = 1
        self.dut.host_axil_wdata.value = data
        # Wait to accept data
        while(True):
            await RisingEdge(self.dut.regbank_clk)
            if (self.dut.host_axil_wready.value):
                break

        self.dut.host_axil_wvalid.value = 0
        self.dut.host_axil_bready.value = 1
        while(True):
            await RisingEdge(self.dut.regbank_clk)
            if (self.dut.host_axil_bvalid.value):
                break

    async def axil_read(self, address):
        self.dut.host_axil_arvalid.value = 0
        self.dut.host_axil_araddr.value = 0
        self.dut.host_axil_arprot.value = 0
        self.dut.host_axil_rready.value = 0

        await RisingEdge(self.dut.regbank_clk)

        # AR phase
        self.dut.host_axil_arvalid.value = 1
        self.dut.host_axil_araddr.value = address

        # Wait to accept address
        while(True):
            await RisingEdge(self.dut.regbank_clk)
            if (self.dut.host_axil_arready.value):
                break

        # R phase
        self.dut.host_axil_arvalid.value = 0
        self.dut.host_axil_rready.value = 1

        # Wait to accept data
        while(True):
            await RisingEdge(self.dut.regbank_clk)
            if (self.dut.host_axil_rvalid.value):
                return self.dut.host_axil_rdata.value

    async def reset_axi_interface(self):
        self.dut.host_axil_awvalid.value = 0
        self.dut.host_axil_awaddr.value = 0
        self.dut.host_axil_awprot.value = 0
        self.dut.host_axil_wvalid.value = 0
        self.dut.host_axil_wdata.value = 0
        self.dut.host_axil_wstrb.value = 15
        self.dut.host_axil_bready.value = 0
        self.dut.host_axil_arvalid.value = 0
        self.dut.host_axil_araddr.value = 0
        self.dut.host_axil_arprot.value = 0
        self.dut.host_axil_rready.value = 0