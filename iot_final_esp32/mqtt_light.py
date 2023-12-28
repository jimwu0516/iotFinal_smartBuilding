# mqtt_light.py
from machine import Pin
from umqtt.simple import MQTTClient

class LightController:
    def __init__(self, led_pin, mqtt_broker, mqtt_port, mqtt_topic):
        self.led = Pin(led_pin, Pin.OUT)
        self.mqtt_topic = mqtt_topic
        self.client = MQTTClient("esp32_client", mqtt_broker, port=mqtt_port)
        self.client.set_callback(self.mqtt_callback)
        self.client.connect()
        self.client.subscribe(self.mqtt_topic)
        self.led.on()

    def mqtt_callback(self, topic, msg):
        message = msg.decode('utf-8')
        if message == "turn_on":
            self.led.on()
            print("let off")
        elif message == "turn_off":
            self.led.off()
            print("let on")

    def check_mqtt_messages(self):
        self.client.check_msg()

    def close_connection(self):
        self.client.disconnect()



