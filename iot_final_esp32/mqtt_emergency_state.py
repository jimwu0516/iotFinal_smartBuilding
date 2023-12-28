# mqtt_emergency_state.py
from machine import Pin, PWM
from umqtt.simple import MQTTClient
import time

class EmergencyController:
    def __init__(self, gpio_buzzer, mqtt_broker, mqtt_port, mqtt_topic):
        self.buzzer = PWM(Pin(gpio_buzzer), freq=262, duty=0)
        self.mqtt_topic = mqtt_topic
        self.client = MQTTClient("esp32_client", mqtt_broker, port=mqtt_port)
        self.client.set_callback(self.mqtt_callback)
        self.client.connect()
        self.client.subscribe(self.mqtt_topic)

    def mqtt_callback(self, topic, msg):
        message = msg.decode('utf-8')
        if message == "on":
            print("emergency")
            self.turn_on_sound()
        elif message == "off":
            print("off")
            self.turn_off_sound()

    def check_mqtt_messages(self):
        self.client.check_msg()

    def close_connection(self):
        self.client.disconnect()

    def turn_on_sound(self):
        self.buzzer.duty(512)
        self.buzzer.freq(2959)
        time.sleep(0.2)
        self.buzzer.duty(0)
        time.sleep(0.1)
        self.buzzer.duty(512)
        self.buzzer.freq(2959)
        time.sleep(0.2)
        self.buzzer.duty(0)

    def turn_off_sound(self):
        self.buzzer.duty(0)
        
    def close_connection(self):
        self.client.disconnect()

