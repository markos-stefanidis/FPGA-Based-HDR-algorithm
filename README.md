# FPGA-Based-HDR-algorithm
This project aims to produce High Dynamic Range (HDR) Images from three Low Dynamic Range (LDR) Images in real time. These images where captured using an OV-7670 CMOS sensor, able to stream live video of VGA (640x480) resolution at 30 frames per second. The color encoding of the images is RGB565.

This implementation is designed to work with Nexys A7 Development board.

### Modes of operation
The system has two modes of operation; HDR enabled and HDR disabled. When HDR is enabled, HDR live video will be streamed to the connected VGA Monitor. When HDR is disabled, the original live video captured from the OV-7670 sensor will be streamed, with the cameras auto exposure feature enabled.  

### Transfering images to PC
The system is able to transfer images to a connected PC via UART. When HDR is enabled, four pictures will be transfered, that of low exposure time, medium exposure time, high exposure time and the HDR image produced by those three. When HDR is disabled, only one image will be transfered. A Python script is provided, which reads the data from the serial port and and saves them as images.
