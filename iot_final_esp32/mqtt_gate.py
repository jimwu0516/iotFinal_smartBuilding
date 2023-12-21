# mqtt_gate.py
from machine import Pin, PWM, SoftI2C
import time
import mfrc522
import network

class PeopleCounter:
    def __init__(self,max_people):
        self.max_people = max_people
        self.tag_states = {}
        self.total_people = 0
        self.too_many_people_published = False

        gpio_ss = 5
        gpio_sck = 18
        gpio_mosi = 23
        gpio_miso = 19
        gpio_rst = 32

        gpio_buzzer = 4
        self.buzzer = PWM(Pin(gpio_buzzer), freq=262, duty=0)

        self.rfid = mfrc522.MFRC522(gpio_sck, gpio_mosi, gpio_miso, gpio_rst, gpio_ss)

    def enter_sound(self):
        self.buzzer.duty(512)
        self.buzzer.freq(2217)
        time.sleep(0.03)
        self.buzzer.freq(2489)
        time.sleep(0.03)
        self.buzzer.freq(2959)
        time.sleep(0.3)
        self.buzzer.freq(1479)
        time.sleep(0.2)
        self.buzzer.duty(0)
        time.sleep(0.1)
        self.buzzer.duty(512)
        self.buzzer.freq(1479)
        time.sleep(0.2)
        self.buzzer.duty(0)

    def exit_sound(self):
        self.buzzer.duty(512)
        self.buzzer.freq(1479)
        time.sleep(0.2)
        self.buzzer.duty(0)

    def deny_enter_sound(self):
        self.buzzer.duty(512)
        self.buzzer.freq(2959)
        time.sleep(0.2)
        self.buzzer.duty(0)
        time.sleep(0.1)
        self.buzzer.duty(512)
        self.buzzer.freq(2959)
        time.sleep(0.2)
        self.buzzer.duty(0)

    def check_rfid(self):
        id = self.rfid.getCardValue()
        if id:
            tag_id = tuple(id)

            if tag_id in self.tag_states:
                if self.tag_states[tag_id] == "enter":
                    self.tag_states[tag_id] = "exit"
                    self.total_people -= 1
                    print("Tag ID:", tag_id)
                    print("Exit")
                    self.too_many_people_published = False
                    self.exit_sound()
                    if tag_id in self.tag_states:
                        del self.tag_states[tag_id]
            else:
                if self.total_people >= self.max_people:
                    self.deny_enter_sound()
                    time.sleep(0.7)
                else:
                    self.tag_states[tag_id] = "enter"
                    self.total_people += 1
                    print("Tag ID:", tag_id)
                    print("Enter")
                    self.enter_sound()

            print("Total People Inside:", self.total_people)

            time.sleep_ms(500)
        
        time.sleep_ms(500)
        
        if self.total_people >= self.max_people and not self.too_many_people_published:
            print("Too many people inside. Wait for someone to exit.")
            self.too_many_people_published = True
        
        return self.total_people


