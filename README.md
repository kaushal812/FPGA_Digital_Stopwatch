# FPGA Digital Stopwatch

**Author:** Kaushal Mangesh Posnak  
**Class:** FyMsc Electronics  
**Subject:** ELS-512 Electronics Practical-II

## Overview
This project is a fully functional digital stopwatch designed for FPGA implementation (Basys 3). It tracks time in **HH:MM:SS** format using a 100 MHz system clock. The design utilizes a Finite State Machine (FSM) to handle Start, Stop, and Reset functionalities.

## Objectives
* **Time Base:** Generate a precise 1-second tick from a 100 MHz high-frequency clock.
* **FSM Control:** Implement a Moore Machine with IDLE, RUNNING, and STOPPED states.
* **BCD Counting:** Cascade counters for Seconds, Minutes, and Hours.
* **Verilog Implementation:** Synthesizable code for FPGA deployment.

## System Architecture
The system consists of three main blocks:
1.  **Clock Divider:** Converts 100 MHz to 1 Hz.
2.  **FSM Controller:** Manages state transitions based on user inputs.
3.  **Time Counters:** Six 4-bit BCD counters handling the time logic (rolling over at 59 seconds and 59 minutes).

### Finite State Machine (FSM)
* **IDLE (00):** Initial state, count held at 00:00:00.
* **RUNNING (01):** Active state, increments timer every second.
* **STOPPED (10):** Paused state, holds current value.

## Simulation Results
The design was verified using a Verilog testbench. 
* **Reset:** Forces all outputs to 0.
* **Start:** Transitions FSM to RUNNING; counter increments every 100,000,000 clock cycles.
* **Stop:** Freezes the counter values.
* **Rollover:** Correctly handles transitions (e.g., 00:00:59 -> 00:01:00).

## How to Run
1.  Clone this repository.
2.  Open the files in Vivado or ModelSim.
3.  Compile `src/stopwatch.v` and `tb/stopwatch_tb.v`.
4.  Run the simulation to view the waveforms.

## References
Based on the activity "VERILOG Programming" for subject ELS-512.
