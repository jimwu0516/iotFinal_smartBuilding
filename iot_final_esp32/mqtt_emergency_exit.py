#mqtt_emergency_exit.py
from machine import Pin
import time
from umqtt.simple import MQTTClient

class EmergencyExitSensor:
    def __init__(self, gpio_pin):
        self.gpio_pin = gpio_pin
        self.p = Pin(self.gpio_pin, Pin.IN)

    def send_emergency_status(self):
        v = self.p.value()
        time.sleep(1)
        return v 
