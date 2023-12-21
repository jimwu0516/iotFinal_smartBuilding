# mqtt_tem_hum.py
from machine import Pin
import dht
import time

class Temperature_and_humidity_sensor:
    def __init__(self, pin_number):
        self.sensor = dht.DHT11(Pin(pin_number))

    def get_temperature_and_humidity(self):
        self.sensor.measure()
        time.sleep(1)
        temperature=round(self.sensor.temperature(), 2)
        humidity = round(self.sensor.humidity(), 2)
        return temperature, humidity




