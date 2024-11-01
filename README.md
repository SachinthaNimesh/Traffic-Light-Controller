# Traffic Light Controller
<center>
  <img  width="457" alt="image" src="https://github.com/user-attachments/assets/7523bed4-baf1-4c4a-a256-1129766c73b8">
</center>

## Overview
An advanced VHDL-based traffic light control system featuring intelligent sensor integration and adaptive signal management.

## Features
- 🚗 Dual-sensor traffic detection (pedestrian and vehicle)
- 🔄 Dynamic state machine architecture
- ⏱️ Configurable signal timing
- 🔍 Ultrasonic sensor input processing

## System Architecture
- Two-way traffic signal control (main road and pedestrian crossing)
- Independent state management for each signal
- Automatic mode transitions based on sensor inputs

## Technical Specifications
- **Language**: VHDL
- **Components**: 
  - Sensor Control Module
  - Traffic Control State Machine
- **Sensor Processing**: 
  - Echo signal interpretation
  - Trigger signal generation
- **State Management**:
  - Main Road States: Green → Yellow → Red
  - Pedestrian Crossing States: Red → Green → Yellow

## Workflow
1. Sensor detects traffic/pedestrian presence
2. Triggers appropriate signal state transition
3. Manages signal duration based on traffic conditions
4. Ensures safe and efficient traffic flow

## Usage
Clone the repository and integrate with your FPGA development environment.
