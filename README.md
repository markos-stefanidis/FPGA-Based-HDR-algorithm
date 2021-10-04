# FPGA-Based-HDR-algorithm
Hardware implementation of HDR image producing algorithm

The goal of this project is to design and implement an FPGA based HDR algorithm, that produces HDR images from LDR CMOS sensor.
As for now, this design succesfully streams live video from CMOS Camera OV7670 to VGA monitor.

This implementation is designed to work with LatticeMico32/DSP Development board that features a Lattice ECP2-50 FPGA.

The OV7670 CMOS camera is able to produce 640x480 frames at 30fps, using RGB565 output format. As the VGA operates at 60fps, frame buffering is essential. The Lattice ECP2-50 has available 387kbit of EBR, not enough to store a frame, so an off-chip memory is needed.

This implementation includes a DDR Memory Controller designed to be used with Infineon DDR-SDRAM, at 133MHz, CL = 2. This DDR DIMM has a 64bit data bus but, as the Mico32 board has a DDR socket with 32bit data bus, half the memory can be used.

To simulate any of the Verilog files, you need to map and compile Lattice libraries into Modelsim and then simulate with the following command:
```
vsim -L ovi_ecp2 <test_bench_name>
```

Test benches are not yet uploaded, but will be in time.
