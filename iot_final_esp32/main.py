# main.py
import time
import network
from umqtt.simple import MQTTClient
from machine import Pin, PWM
from mqtt_light import LightController
from mqtt_tem_hum import Temperature_and_humidity_sensor
from mqtt_gate import PeopleCounter
from mqtt_emergency_exit import EmergencyExitSensor
#from mqtt_emergency_state import EmergencyController

WIFI_SSID = "Suite21TPE424"
WIFI_PASSWORD = "0937885882"

wifi = network.WLAN(network.STA_IF)
wifi.active(True)
wifi.connect(WIFI_SSID, WIFI_PASSWORD)

while not wifi.isconnected():
    pass

print("Connected to WiFi")

# 連接到 MQTT broker
mqtt_client = MQTTClient("sensor", "test.mosquitto.org", port=1883)
mqtt_client.connect()
print("Connected to MQTT broker")



light_controller = LightController(led_pin=2, mqtt_broker="test.mosquitto.org", mqtt_port=1883, mqtt_topic="jim/ntub/light_control")
temperature_and_humidity_sensor = Temperature_and_humidity_sensor(33)
people_counter = PeopleCounter(5)
emergency_exit=EmergencyExitSensor(35)
#emergency_state = EmergencyController(gpio_buzzer=4, mqtt_broker="test.mosquitto.org", mqtt_port=1883, mqtt_topic="jim/ntub/emergency_state")


while True:
    try:
        light_controller.check_mqtt_messages()
        temperature, humidity = temperature_and_humidity_sensor.get_temperature_and_humidity()
        total_people = people_counter.check_rfid()
        emergency_status = emergency_exit.send_emergency_status()
        #emergency_state.check_mqtt_messages()
        
        
        print("溫度：{:d}°C，濕度：{:d}%".format(temperature, humidity))
        print(total_people)
        print(emergency_status)
        
        
        mqtt_client.publish("jim/ntub/total_people", str(total_people))
        mqtt_client.publish("jim/ntub/emergency_exit", str(emergency_status))
        mqtt_client.publish("jim/ntub/hum", "{:d}%".format(humidity))
        mqtt_client.publish("jim/ntub/tem", "{:d}°C".format(temperature))
        
        time.sleep(1)
            
    except OSError as e:
        mqtt_client.connect()
            
            
    




