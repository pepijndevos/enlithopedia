from pybricks.hubs import InventorHub
from pybricks.pupdevices import Motor, ColorSensor, UltrasonicSensor
from pybricks.parameters import Button, Color, Direction, Port, Side, Stop, Icon
from pybricks.robotics import DriveBase
from pybricks.tools import wait, StopWatch

hub = InventorHub()

carriage = Motor(Port.A)

while True:
    pressed = hub.buttons.pressed()
    if Button.LEFT in pressed:
        carriage.run(1000)
    elif Button.RIGHT in pressed:
        carriage.run(-1000)
    else:
        carriage.brake()
    wait(10)