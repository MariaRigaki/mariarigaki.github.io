---
title: 'Scoping it out!'
subtitle: 'Using an oscilloscope to perform side-channels'
date: 2019-07-29T13:16:05+02:00
authors:
  - me
tags:
  - side-channels
  - oscilloscope
aliases:
  - /post/summer-hacakathon-2019/
---

**TL;DR Using a Picoscope 2204A and its SDK to perform  timing side channel attacks against a weak password checker implementation running in an Arduino. Code, screenshots and lessons learned!**

Last weekend we held the bi-annual Stratosphere hackathon. It is a small tradition where twice a year the whole team gathers in a relatively remote place and we spend the weekend hacking and bonding. This time the hackathon was held at the beautiful Malá Úpa, in the mountains close to the border of Czech Republic and Poland.

{{< figure src="mala_upa.jpg" title="Our hackathon home" >}}
## The goal
For this year's event I decided that I wanted to work on something that I had not done before and step quite a lot out of my comfort zone. Ever since the Real World Crypto summer school that I attended this year in Croatia and the Side Channel Attacks (SCA) workshop, I've been meaning to work on side channels. In addition I had not really used an oscilloscope before and that was an opportunity to learn more and get over the fear and mystery of hardware.

Starting out, my goal for the hackathon was to learn how to use a USB based oscilloscope and use it in order to perform side channel attacks. The weapon of choice was a Picoscope 2204A [[1]](https://www.picotech.com/oscilloscope/2000/picoscope-2000-overview) which was chosen based on the following criteria: a) it is a USB scope so it is easy to carry and works with my laptop, b) it is relatively reliable and while it is the entry level product of the series, it still is quite powerfull and c) it has software that runs in all platforms and more specifically Linux. This was crucial since I did not want to fiddle around with Windows or scopes that did not offer a good software solution including SDKs. 


## Side Channel Attack (SCA)
Side channel attacks are attacks that take advantage of information leakage that is not directly related to the function being attacked. For example, in cryptography you might have a cryptographic function such a smart card or other software that performs communication encryption. A side channel is using information such as power analysis, timing, electromagentic emanations, sound, etc to reveal secret keys instead of attacking the cryptographic algorithm itself. 

## A timing side-channel
I started first with a simple kind of SCA which is a timing attack against an insecure password implementation. I found a nice blog explaining timing side channel attacks in Arduino [[2]](http://eax64.github.io/2015/04/10/timing-attack-on-arduino.html) and I used the arduino code provided there, as the vulnerable implementation to attack:
{{< figure src="arduino_code.png" title="Arduino code from [2]" >}}


The main idea is that you store a six digit password (or any length really) and you use the serial port to send a  candidate password to the Arduino. While the Arduino checks the password it turns on a LED that in essence corresponds to a digital pin set to ON. The password checking implementation looks at one digit at a time but it returns as soon as an incorrect digit is found. The fact that the response is not constant in time means that it leaks information about the validity of each digit, rendering the timing attack possible. 
Using the fact that the LED pin is turned on while the password check is perfomed, we can monitor the time that the PIN is on using the oscilloscope. The more digits that are correct, the longer the password checker takes and the longer the LED pin is on.

To illustrate the problem let's see how the Picoscope software looks like when the first 3 digits are correct:
{{< figure src="three.png" title="First three correct digits" >}}
and when all 6 digits are correct:
{{< figure src="six.png" title="All digits correct" >}}

## Using the Picoscope
The Picoscope is a USB oscilloscope that can be used for multiple purposes such as voltage measurement, spectrum analysis, serial channel decoding, etc. The interesting thing about USB scopes is that they come with powerful software that can perform advanced measurements and calculations which are usually quite expensive to get, or cost extra in bigger tabletop oscilloscopes.  Of course it all comes down to specifications such as sampling rates, bandwidth, number of channels and so on, but my impression so far is that you can get very good value for money with a good USB scope.

I do not intent to cover the Picoscope functions in detail in this blog post, but I do want to mention two functions that were important for this project:  **Triggers** and **automatic measurement** functions. 

As the scope runs, it continuously gathers data until you stop it. This results in viewing everything on screen in real time but usually we want to "freeze" the scope when something of interest happens so that we can see it.  A **trigger** allows us to tell the scope when to start (and stop) capturing data and present them on screen. Triggers can be _single_ (only triggers once) or _repeated_ (when we capturing periodic events) and they come with a lot of settings such as _rising edge_ or _falling edge_, etc. An example of a rising edge trigger is when we want the scope to start capturing when the voltage of a measurement goes from 0 to some higher value.

The other function that I used a lot in this project was the **measurement** functionality. Since we want to measure the time for which the LED pin is on we can use the _high pulse width_ type of measurement. The results appear as a line in the bottom of the window and it is visible in the previous two pictures.

## Using the Pico SDK to perform the attack
Since we can access the serial port we could always perform the attack programmatically, for example using pyserial. But where is the fun in that? :smile: Besides, I wanted to use the scope for the attack, since the fact that the serial port was used for input was just for illustration purposes. It could have been replaced just as easily with a bunch of buttons or some other way to provide input that is not directly measurable.

It was also a great opportunity to learn how to use the SDK that comes with the Picoscope. After looking at the site for documentation I got to the Github link where all the SDK software can be found [[3]](https://github.com/picotech). A good number of languages is supported (C/C++, C#, Python, VB .NET, LabVIEW, MATLAB). For each language and each specific driver there is example code that helps to get started. Although the code is very well documented and the programming guide explains quite a few details, the task was not problem free.

The first problem I faced was that I could not open the port and connect to the device. It turns out that there are two drivers for the 2000 series: the **ps2000** and the **ps2000a**. Although my device is called 2204A it actually did NOT use the **ps2000a** driver but the **ps2000** one. I found that out after going through some posts in the support forum that faced similar problems. Even though I knew now which example should be the correct one to try, I still could not connect to the device. It turned out that I needed to run the python script using **sudo** in order to open the connection!!!

The second problem was to reproduce the settings that were working with the picoscope using the python code. The most straight forward approach here was to try and understand the different API calls and how they correspond to the software settings and then plot the screens using matplotlib in order to see the captured data.
After fiddling quite a bit with the code I managed to produce something like the folllowing which is very close to what I could see in the picoscope software after providing the correct password:
{{< figure src="6_python.png" title="All digits correct using the SDK" >}}

### Code walkthrough
As a base I started with the Block code example that comes with the SDK.
As mentioned in the example, the code "*opens a 2000 driver device, sets up two channels and a trigger then collects a block of data. This data is then plotted as mV against time in ns.*"
Steps:

* Open connection: `ps2000_open_unit()`
* Define channels: `ps2000_set_channel()`
* Define triggers: `ps2000_set_trigger()`
* Get timebase information: `ps2000_get_timebase()` 
* Capture data: `ps2000_run_block()`
* Check if data collection is finished: `ps2000_ready()`
* Get the data from the scope: `ps2000_get_values()`
* Convert data from ADC to mV: `adc2mV()`
* Plot the data using matplotlib: `plt.plot()`
* Stop the scope: `ps2000_stop()`
* Close the scope: `ps2000_close_unit()`

Defining the trigger and the timebase were the most challenging parts for me, because the way some things are defined were not exactly similar to what I was seeing using the picoscope software. For example, the trigger threshold was set using ADC counts and not in voltage as it was on the software. The timebase was also tricky because it expects an integer value that is relative to the maximum timebase your device supports. After some calculations and a bit of trial and error, I managed to get to a point where my captured data corresponded to something I could use for the attack. The programming guide that explains the functions and their arguments in detail can be found here [[4]](https://www.picotech.com/download/manuals/picoscope-2000-series-programmers-guide.pdf).

The following changes/additions were required for the timing attack:

* Open the serial port using pyserial. 
* Send a password while data capture was running.
* Instead of plotting measure how many data points are above 490mV.
* Keep the maximum value and digit as a candidate digit.
* Repeat for all possible digits (0...9).
* Repeat for all six digits of the password.

The gist with all the code can be found here [[5]](https://gist.github.com/MariaRigaki/2d65a8a569cced23272beb7962d6654d) and a screenshot of the ouptut can be seen here:
{{< figure src="terminal.png" title="All digits correct" >}}

## Summary
I really enjoyed this project and it turned out that this was a great fit for the hackathon as I managed to pull it off within the 24 hour period that we had for this. Before I started out, I had very little experience using an oscilloscope and I only watched some videos in Youtube in order to try and learn the basics. Now, I feel much more comfortable and I am looking forward to explore more capabilities of the scope. Hopefully I will be able to use it to perform other types of side channels. Stay tuned and as always if you have any questions or comments feel free to contact me! 

## Links and References
[1] https://www.picotech.com/oscilloscope/2000/picoscope-2000-overview

[2] http://eax64.github.io/2015/04/10/timing-attack-on-arduino.html

[3] https://github.com/picotech

[4] https://www.picotech.com/download/manuals/picoscope-2000-series-programmers-guide.pdf

[5] https://gist.github.com/MariaRigaki/2d65a8a569cced23272beb7962d6654d
 


