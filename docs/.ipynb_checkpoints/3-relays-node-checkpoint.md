

# 3 Relays Node

## Hardware

This node is based around a [Waveshare 11638 RPi Relay Board](https://www.waveshare.com/wiki/RPi_Relay_Board). This has 3 optically isolated relays capable of switching 250V AC @ 5A or 30V DC at 5A, however this hardware configuration only switching up to 30V DC is supported.

![](images/waveshare-relays.png)



This is combined with the Raspberry Pi Base-plate and a custom front panel to make the node.

![](images/3-relays-tower.png)



The front panel design is available in file `3-relays-front-panel.scad` or `3-relays-front-panel.stl`

![](images/3-relays-front-panel.png)



This is the circuit dagram of the node hardware. 



![](images/3-relays-circuit.png)





## Node Types

### 3_RELAYS

This is simple node-type that simply changes the states of the 3 relays, and can be  used to control pumps, valves, lights etc.

The relays are identified and 'green', 'yellow' and 'blue' to match the colour coding on the hardware.

There are 3 metrics, one for each pump.

| Metric                 | Type    | Direction | Description        |
| ---------------------- | ------- | --------- | ------------------ |
| `/relays/green/state`  | boolean | write     | Green relay state  |
| `/relays/yellow/state` | boolean | write     | Yellow relay state |
| `/relays/blue/state`   | boolean | write     | Blue relay state   |



3-RELAYS.yaml

This is the node definition file:

```yaml
type : "3_RELAYS"
name : "3 relays controller"
description : "3 relays controller, 'Green', 'Yellow', 'Blue' "
image: ""

drivers:
  - name : "green"
    type: "gpio_digital_out"
    config:
      type: "gpioDigitalOut"
      pin: 26
      activeHigh: false
      initialState : LOW
      shutdownState : LOW

  - name : "yellow"
    type: "gpio_digital_out"

    config:
      type: "gpioDigitalOut"
      pin: 20
      activeHigh: false
      initialState : LOW
      shutdownState : LOW

  - name : "blue"
    type: "gpio_digital_out"

    config:
      type: "gpioDigitalOut"
      pin: 21
      activeHigh: false
      initialState : LOW
      shutdownState : LOW

metrics:
  - metricName: "/relays/green/state"
    type: "boolean"
    direction: "write"
    description: "Green relay state"
    driver: "green"
    function: "state"

  - metricName: "/relays/yellow/state"
    type: "boolean"
    direction: "write"
    description: "Yellow relay state"
    driver: "yellow"
    function: "state"

  - metricName: "/relays/blue/state"
    type: "boolean"
    direction: "write"
    description: "Blue relay state"
    driver: "blue"
    function: "state"
```



### 3_DOSING_PUMPS

This node-type is designed for controlling 3 peristatic pumps. It supports 

- operation by duration - where the pump will run for a given time in milliseconds
- operation by volume- where the pump will dispense a specific volume of liquid. This requires the pump to be calibrated amd a metric is provided for this.

As before the  pumps are identified and 'green', 'yellow' and 'blue' to match the colour coding on the hardware.

There are 3 groups of metrics:

Green

| Metric                      | Type   | Direction | Description                               |
| --------------------------- | ------ | --------- | ----------------------------------------- |
| `/dosers/green/duration`    | int64  | write     | Duration dose (in milliseconds)           |
| `/dosers/green/volume`      | int64  | write     | Volume dose (volume in millilitres)       |
| `/dosers/green/calibration` | double | write     | Dose calibration (millilitres per second) |



Yellow

| Metric                       | Type   | Direction | Description                               |
| ---------------------------- | ------ | --------- | ----------------------------------------- |
| `/dosers/yellow/duration`    | int64  | write     | Duration dose (in milliseconds)           |
| `/dosers/yellow/volume`      | int64  | write     | Volume dose (volume in millilitres)       |
| `/dosers/yellow/calibration` | double | write     | Dose calibration (millilitres per second) |



Blue

| Metric                     | Type   | Direction | Description                               |
| -------------------------- | ------ | --------- | ----------------------------------------- |
| `/dosers/blue/duration`    | int64  | write     | Duration dose (in milliseconds)           |
| `/dosers/blue/volume`      | int64  | write     | Volume dose (volume in millilitres)       |
| `/dosers/blue/calibration` | double | write     | Dose calibration (millilitres per second) |



3_DOSING_PUMPS.yaml

This is the node 

```yaml
type : "3_DOSING_PUMPS"
name : "3 dosing pumps"
description : "3 Dosing pumps controller, 'Green', 'Yellow', 'Blue' "
image: ""

drivers:
  - name : "green"
    type: "gpio_dosing_pump"

    config:
      type : "gpioDigitalOut"
      pin: 37
      activeHigh: false
      initialState : LOW
      shutdownState : LOW

  - name : "yellow"
    type: "gpio_dosing_pump"

    config:
      type : "gpioDigitalOut"
      pin: 38
      activeHigh: false
      initialState : LOW
      shutdownState : LOW

  - name : "blue"
    type: "gpio_dosing_pump"

    config:
      type : "gpioDigitalOut"
      pin: 40
      activeHigh: false
      initialState: LOW
      shutdownState: LOW

metrics :
    - metricName: "/dosers/green/duration"
      type: "int64"
      direction: "write"
      description: "Duration dose (in milliseconds)"
      driver: "green"
      function: "doseduration"

    - metricName: "/dosers/green/volume"
      type: "int64"
      direction: "write"
      description: "Volume dose (volume in millilitres)"
      driver: "green"
      function: "dosevolume"

    - metricName: "/dosers/green/calibration"
      type: "double"
      direction: "write"
      description: "Dose calibration (millilitres per second)"
      driver: "green"
      function: "calibrate"

    - metricName: "/dosers/yellow/duration"
      type: "int64"
      direction: "write"
      description: "Duration dose (in milliseconds)"
      driver: "yellow"
      function: "doseduration"

    - metricName: "/dosers/yellow/volume"
      type: "int64"
      direction: "write"
      description: "Volume dose (volume in millilitres)"
      driver: "yellow"
      function: "dosevolume"

    - metricName: "/dosers/yellow/calibration"
      type: "double"
      direction: "write"
      description: "Dose calibration (millilitres per second)"
      driver: "yellow"
      function: "calibrate"

    - metricName: "/dosers/blue/duration"
      type: "int64"
      direction: "write"
      description: "Duration dose (in milliseconds)"
      driver: "blue"
      function: "doseduration"

    - metricName: "/dosers/blue/volume"
      type: "int64"
      direction: "write"
      description: "Volume dose (volume in millilitres)"
      driver: "blue"
      function: "dosevolume"

    - metricName: "/dosers/blue/calibration"
      type: "double"
      direction: "write"
      description: "Dose calibration (millilitres per second)"
      driver: "blue"
      function: "calibrate"
```

