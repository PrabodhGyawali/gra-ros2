# Welcome to the Gryphon Racing Formula Student AI Wiki!

This wiki serves as the central hub for documentation, timelines, and module-specific guides. Whether you're a new recruit exploring the project or a veteran debugging a node, use the navigation sidebar or the pages below to dive in.

For code and setup, clone the repo: [GryphonRacingAI/gra-ros2](https://github.com/GryphonRacingAI/gra-ros2) (dev branch). Follow the README for Ubuntu 24.04 + ROS 2 Jazzy installation.

## Competition Overview
Formula Student AI (FS-AI) challenges teams to build fully autonomous vehicles. Key highlights relevant to our software focus:

- **Classes**: We're in DDT, borrowing the ADS-DV vehicle to concentrate on controllers and sensors.
- **Events**:
  - **Static**: Design Presentation, Business Plan, Real-World Autonomous (integration of AVs in transport).
  - **Dynamic**: Acceleration, Skid Pad, Sprint Track (Endurance) – mirroring standard FS but fully autonomous.
- **Guidelines**: Emphasize safety, innovation, and real-world applicability. Full rules and deadlines at [IMechE FS-AI](https://www.imeche.org/events/formula-student/team-information/fs-ai). Register early and review cost reports.

New members: Skim the rules first to understand judging criteria (e.g., autonomy reliability scores 40% of dynamic events).

## Getting Started for New Members
Congrats on joining! We're in early stages. Here's your onboarding path:

1. **Read Essentials**:
   - Competition rules (above) – 30 mins.
   - [Timeline and Gantt Chart](/Timeline-and-Gantt-chart) – Our 2026 plan.
   - [FAQs](/FAQs) – Common hurdles like ROS setup.
   - Create a Github Issue if you run into any issues

2. **Set Up Your Environment** (1-2 hours):
   - Dual-boot Ubuntu 24.04 #TODO: ref to README.md
   - Use our Apptainer container (for uni machines). #TODO: ref to README.md of apptainer subfolder


3. **Run Your First Sim** (Test perception):
   - Launch simulator: `ros2 launch simulation dynamic_event.launch.py event:=skidpad`
   - Add perception: `ros2 launch ultralytics_ros predict_with_cloud.launch.xml yolo_model:=conev11n.pt`
   - Expected: Gazebo spawns ADS-DV on track; YOLO detects cones on camera feed.

4. **Learn Core Concepts**:
   - **ROS 2 Basics**: [Official Tutorials](https://docs.ros.org/en/jazzy/Tutorials.html) – Dedicated a week to complete Intermediate tutorials
   - **Our Stack**: Perception (YOLO-based cone detection) is live; we're building SLAM, Planning & Control next.


5. **Contribute Early**:
   #TODO: reference CONTRIBUTING.md docs which will have instructions

## High-Level Architecture #TODO: move to separate page
Our ROS 2 stack follows a modular pipeline: Sensors → Perception → SLAM → Planning → Control → Actuators (in sim/real).

```mermaid
graph TD
    A[Sensors<br/>(ZED2i Camera, IMU)] --> B[Perception<br/>(YOLO Cone Detection)]
    B --> C[SLAM<br/>(Localization & Mapping)]
    C --> D[Path Planning<br/>(Global/Local Paths)]
    D --> E[Control<br/>(MPC/PID for Steering/Throttle)]
    E --> F[Actuators<br/>(Vehicle Model in Gazebo)]
    G[Simulation<br/>(Gazebo Harmonic + Tracks)] -.->|Feedback Loop| A
    H[CI/CD<br/>(e2e Tests)] -.->|Validate| G

    style B fill:#e1f5fe
    style C fill:#f3e5f5
    style D fill:#e8f5e8
    style E fill:#fff3e0
```