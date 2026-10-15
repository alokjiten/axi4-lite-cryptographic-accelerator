# AXI4-Lite Based Cryptographic Accelerator

## Overview
A Verilog-based cryptographic accelerator integrating an AES-128 encryption core with an AXI4-Lite slave interface. The design uses memory-mapped registers and an FSM to control encryption and retrieve ciphertext.

## Architecture
- AXI4-Lite slave interface
- AES-128 encryption core
- Plaintext, key, control, status, and ciphertext registers
- FSM with IDLE, RUN, and DONE states

## Source Files
- `axi_aes_top.v` — Top-level design
- `aes_core.v` — AES encryption core
- `aes_ks.v` — AES key schedule
- `aes_sbox.v` — AES substitution box

## Tools
- Verilog HDL
- Xilinx Vivado Design Suite

## Verification
Behavioral simulation was performed in Vivado to examine AXI4-Lite transactions, FSM transitions, and AES encryption. Refer to the project report for the documented waveforms and results.

## Project Report
See `AXI4_Lite_Cryptographic_Accelerator_Report.pdf` for the architecture, design methodology, and verification details.

## Author
Alok Jiten Rao

Electronics and Telecommunication Engineering, VSSUT Burla
