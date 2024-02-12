# 3 EZO Sensors Node

This node supports 3 sensors from the [Atlas Scientific EZO range](https://atlas-scientific.com/embedded-solutions/), which contains sensors and interface circuits for:

- Humidity
- pH
- ORP
- Dissolved Oxygen
- Conductivity (EC)
- Temperature
- Flow

## Hardware

The node uses a [Whitebox T3 Raspberry Pi Hat](https://www.whiteboxes.ch/shop/whitebox-t3-for-raspberry-pi/) which supports 2 fully isolated interfaces and 1 non-isolated.

![](images/whiteboxes-t3.png)



This is combined with the Raspberry Pi Base-plate and a custom front panel to make the node.

![](images/3-sensors-node.png)

The front panel contains just the power connector, the sensor sockets are accessible through the side of the case. The  design is available in file `3-sensors-front-panel.scad` or `3-sensors-fronf-panel.stl`

![](images/3-sensors-front-panel.png)



This is the circuit-diagram of the node hardware:



![](images/3-sensors-circuit.png)



## Firmware (Node-Type)

Each sensor type its own set of commands and therefore its own driver. Different node-types can be created for different combinations of drivers.

#### PH_EC_TEMP_SENSORS

This node-type supports:

- a pH sensor (EZO_PH)
- an EC sensor (EZO_EC)
- a temperature sensor (EZO_RTD)

For each semsor there is 

- a `value` metric that publishes changes to the measured value
- a set of `calibration` metrics. These vary according to sensor type

EC

| Metric                          | Type    | Direction | Description                |
| ------------------------------- | ------- | --------- | -------------------------- |
| `/sensors/ec/value`             | double  | read      | Publishes ec value changes |
| `/sensors/ec/calibration/dry`   | double  | write     | Dry value calibration      |
| `/sensors/ec/calibration/low`   | double  | write     | Low ec value  calibration  |
| `/sensors/ec/calibration/high`  | double  | write     | High ec value calibration  |
| `/sensors/ec/calibration/clear` | boolean | write     | Clear calibration          |



pH

| Metric                          | Type    | Direction | Description                |
| ------------------------------- | ------- | --------- | -------------------------- |
| `/sensors/ph/value`             | double  | read      | Publishes ph value changes |
| `/sensors/ph/calibration/low`   | double  | write     | Low  ph value calibration  |
| `/sensors/ph/calibration/mid`   | double  | write     | Mid ph value calibration   |
| `/sensors/ph/calibration/high`  | double  | write     | High ph value calibration  |
| `/sensors/ec/calibration/clear` | boolean | write     | Clear calibration          |



Temp

| Metric                          | Type    | Direction | Description                   |
| ------------------------------- | ------- | --------- | ----------------------------- |
| `/sensors/rtd/value`            | double  | read      | Publishes temperature changes |
| `/sensors/rtd/calibration/temp` | double  | write     | Temperature calibration       |
| `/sensors/ec/calibration/clear` | boolean | write     | Clear calibration             |
