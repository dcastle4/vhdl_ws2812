# WS2812 RGB LED Controller and Serializer in VHDL

[image](doc/image.jpg?raw=true)

This is a WS2812 RGB LED controller and serializer written in VHDL for Digilent's Basys3 FPGA board. It was created by Bradford Jackson and I for the final project in CpE 3020 [VHDL Design with FPGAs] at Kennesaw State University in Fall 2019. 

The controller works by buffering the color data to be sent, which allows it to be manipulated and changed. This is used to allow the user to select the color type using the Up/Down buttons and the amount of colors by setting the four leftmost switches to any number in binary from zero to eight LEDs. The three rightmost switches allow the user to play with custom modes: the 13th switch (3rd from the left) allows the user to set custom colors for each individual LED; the 14th switch (2nd from the left) turns on a custom pattern that makes the active LEDs fade in color; the 15th switch (1st from the left) enables a preview mode, where only the first LED is active for cycling through colors.

The serializer works by taking any input color data and iterating through it to send it to the WS2812 LEDs. The WS2812's serial protocol interprets data in terms of the amount of time the signal is high or low in a 1200 nanosecond window. For example, in order to send a zero, you would set the signal high for 400 nanoseconds, and then low for 800 nanoseconds. Conversly, if you wanted to send a one, you would set the singal high for 800 nanoseconds, and then low for 400 nanoseconds. From here, the serializer iterates through every  bit of the input color data, determines the duty cycle/amount of time needed to hold the signal high depending on if its a one or zero, and then procedes to cycle through the appropriate amount of cycles for high or low. In our case, we used the Basys3's stock 100MHz clock, which has a 10 nanosecond period. With this in mind, we wrote the serializer to wait for 80 cycles (80 cycles times 10 nanoseconds each = 800 nanoseconds total) or 40 cycles to send the high voltage and then up to 120 cycles for the low voltage. 

In addition to these components, we also created a debouncing system to make the buttons work properly under synchronous control as well as a controller for the Basys3's seven segment display, adapted from an older version we made for lab but now with all characters/numbers (as close as we could represent them).
