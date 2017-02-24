![Title](images/title.png)

If you are interested in compiling the latest version of OpenCV for ARM based SBCs or x86 computers then this project will show you how. You should be experienced with Linux, OpenCV and Python to make the most of this project. I have created a set of scripts that automate the install process. The scripts support Ubuntu 16.04, Debian GNU/Linux 8 (jessie) and probably other distributions. x86, x86_64, ARMV7 and ARMV8 are currently working. I'm trying to hardware optimize on the platforms I'm testing which are CHIP and Pine64 right now.

![Pedestrian detection](images/pedestrian-detect.png)

The image above is a screenshot of a video frame that has been processed by [motiondetect.py](https://github.com/sgjava/install-opencv/blob/master/python/codeferm/motiondetect.py). Motion is bounded by green boxes and pedestrians by blue boxes.

You have to optimize extensively on platforms with an incompatible VPU/GPU such as the Mali 400. The [CHIP](https://getchip.com/pages/chip) SBC only has one CPU core, but you can do real time object detection using techniques I'll describe later on. These methods will scale nicely on multi-core SBCs and x86 computers. The extra processing time on multi-core systems can be leveraged for milti-detection or other processing.

* [Provides](#provides)
* [Test Camera](#test-camera)
* [Download project](#download-project)
* [Install The Whole Enchilada](#install-the-whole-enchilada)
* [Install Java and Ant](#install-java-and-ant)
* [Install libjpeg-turbo](#install-libjpeg-turbo)
* [Install mjpg-streamer](#install-mjpg-streamer)
* [Install OpenCV](#install-opencv)
* [Motion Detection](#motion-detection)
    * [Boosting Performance](#boosting-performance)
* [Java](#java)    
* [References](#references)
* [FreeBSD License](#freebsd-license)

###Provides
* Latest Oracle JDK 8 and Apache Ant
    * FourCC class
    * CaptureUI Applet to view images/video since there's no imshow with the bindings
* Latest libjpeg-turbo optimized for SIMD
    * Patch to mute common warnings that will fill up the logs
* Latest mjpg-streamer (10/27/2013 last commit) optimized with libjpeg-turbo
* Latest OpenCV with opencv_contrib optimized for libjpeg-turbo
    * Patch memory leaks as I find them. Get more information [here](https://github.com/sgjava/opencvmem)
* Python application provides motion, pedestrian (HOG) and Haar Cascade detection
* Java, Python and C++ examples can be easily run from Eclipse.
    * Capture UI
    * Motion detection
    * People detection
    * Camera Calibration
    * Drawing

###Test Camera
If you plan on processing only video or image files then you can skip this section. Live video will allow you to create smart camera applications that react to a live video stream (versus a streaming only camera). You will need to select a USB camera that works under [Linux](http://elinux.org/RPi_USB_Webcams) and has the proper resolution.
* Add user to video group
    * `sudo usermod -a -G video username`
* Install uvcdynctrl v4l-utils
    * `sudo apt-get install uvcdynctrl v4l-utils`
* Reboot
    * `sudo reboot`
* Get camera information (using a cheap Kinobo Origami Webcam here for illustration)
    * `lsusb`
         * `Bus 003 Device 002: ID 1871:0142 Aveo Technology Corp.`
    * `uvcdynctrl -f`
         * `Pixel format: YUYV (YUYV 4:2:2; MIME type: video/x-raw-yuv)`

###Download project
* `sudo apt-get install git-core`
* `cd ~/`
* `git clone --depth 1 https://github.com/sgjava/install-opencv.git`

###Install The Whole Enchilada
This is probably the easiest way to install everything, but you can follow the individual steps below to build or rebuild individual components. There are values you can change in the individual scripts, so read them over. Skip the rest of the individual scripts below if you run this.
* `cd ~/install-opencv/scripts`
* Edit `config.sh` and make changes as needed
* `sudo nohup ./install.sh &`
    * Use `top` to monitor until build completes

###Install Java and Ant
* `cd ~/install-opencv/scripts`
* `sudo ./install-java.sh`
* `java -version`
* `ant -version`

###Install libjpeg-turbo
Patches jdhuff.c to remove "Invalid SOS parameters for sequential JPEG" warning and jdmarker.c to remove "Corrupt JPEG data: xx extraneous bytes before marker 0xd9" warning. These will fill up the logs if not muted.
* `cd ~/install-opencv/scripts`
* `sudo nohup ./install-libjpeg-turbo.sh &`
    * Use `top` to monitor until build completes

###Install mjpg-streamer
Sometimes all you need is a live video feed without further processing. This section will be what you are looking for. It also makes sense to move the UVC processing into a different Linux process or thread from the main CV code.

####WARNING
I'm running this on a test LAN and not securing mjpg-streamer. In production you will want to use a user and password with mjpg-streamer. You will also want to put it behind a secure proxy if you are accessing it from the Internet.

Change `whitepatch` in `install-mjpg-streamer.sh` to `True` if you get a white image. I had to set this to True for using MPJEG mode. In YUYV I set it to `False`. The default setting is `True`.

* `cd ~/install-opencv/scripts`
* `sudo sh install-mjpg-streamer.sh`
    * Runtime ~3 minutes
* `v4l2-ctl --list-formats`
    * Check Pixel Format for 'YUYV' and/or 'MJPG'
* To run mjpg-streamer with 'YUYV' only camera use
    * `mjpg_streamer -i "/usr/local/lib/input_uvc.so -y" -o "/usr/local/lib/output_http.so -w /usr/local/www"`
* To run mjpg-streamer with 'MJPG' use
    * `mjpg_streamer -i "/usr/local/lib/input_uvc.so" -o "/usr/local/lib/output_http.so -w /usr/local/www"`
* In your web browser or VLC player go to `http://yourhost:8080/?action=stream` and you should see the video stream.

###Install OpenCV
I have included a Java patch that is disabled by default. The patch will fix memory leaks and performance issues with Java. See [OpenCV Java memory management](https://github.com/sgjava/opencvmem) for details.
* `cd ~/install-opencv/scripts`
* `sudo rm nohup.out`
* `sudo nohup ./install-opencv.sh &`
    * Use `top` to monitor until build completes

###Motion Detection
This is a good first example into the foray that is Computer Vision. This is also a practical example that you can use as the basis for other CV projects. From experience I can tell you that you need to understand the usage scenario. Simple motion detection will work well with static backgrounds, but using it outside you have to deal with cars, tree branches blowing, sudden light changes, etc. This is why built in motion detection is mostly useless on security cameras for these types of scenarios. You can use ignore bitmaps and ROI (regions of interest) to improve results with dynamic backgrounds. For instance, I can ignore my palm tree, but trigger motion if you walk in my doorway.

####Boosting Performance
I see a lot of posts on the Internet about OpenCV performance on various ARM based SBCs being CPU intensive or slow frame capture, etc. Over time I learned the tricks of the trade and kicked it up a few notches from my own research. These techniques may not work for all usage scenarios or OpenCV functions. They do work well for security type applications.

Problem: Slow or inconsistent FPS using USB camera.

Solution: Use MJPEG compatible USB camera, mjpg-streamer and my [mjpegclient.py](https://github.com/sgjava/install-opencv/blob/master/python/codeferm/mjpegclient.py).

Problem: OpenCV functions max out the CPU resulting in low FPS.

Solution: Resize image before any processing. Check out [Pedestrian Detection OpenCV](http://www.pyimagesearch.com/2015/11/09/pedestrian-detection-opencv) as it covers reduction in detection time and improved detection accuracy. The pedestrian HOG detector was trained with 64 x 128 images, so a 320x240 image is fine for some scenarios. As you go up in resolution you get even better performance versus operating on the full sized image. This article also touches on non-maxima suppression which is basically removing overlapping rectangles from detection type functions.

Solution: Sample only some frames. Motion detection using the moving average algorithm works best at around 3 or 4 FPS. This works to our advantage since that is an ideal time to do other types of detection such as for pedestrians. This also works out well as your camera FPS goes higher. That means ~3 FPS are processed even at 30 FPS. You still have to consider video recording overhead since that's still 30 FPS.

Solution: Analyze only motion ROI (regions of interest). By analyzing only ROI you can cut down processing time tremendously. For instance, if only 10% of the frame has motion then the OpenCV function should run about 900% faster! This may not work where there's a large change frame after frame. Luckily this will not happen for most security type scenarios. If a region is too small for the detector it is not processed thus speeding things up even more.

The default [motiondetect.ini](https://github.com/sgjava/install-opencv/blob/master/python/config/motiondetect.ini) is configured to detect pedestrians from a local video file in the project. Try this first and make sure it works properly.
* `cd ~/install-opencv/python/codeferm`
* `python motiondetect.py`
* Video will record to ~/motion/test using camera name (default test), date for directory and time for file name
* This is handy for debugging issues or fine tuning using the same file over and over

This time we will run mjpg-streamer in background. Using `-b` did not work for me as a normal user, so I used `nohup`. Eventually mjpg-streamer will become a service, but this works for testing. To run example yourself use (this is 5 FPS example):
* `cd ~/install-opencv/python/codeferm`
* `nohup mjpg_streamer -i "/usr/local/lib/input_uvc.so -n -f 5 -r 640x480" -o "/usr/local/lib/output_http.so -w /usr/local/www" &`

### Java
To run Java programs in Eclipse you need add the OpenCV library.
* Window, Preferences, Java, Build Path, User Libraries, New..., OpenCV, OK
* Add External JARs..., ~/opencv/build/bin/opencv-320.jar
* Native library location, Edit..., External Folder..., ~/opencv/build/lib, OK
* Right click project, Properties, Java Build Path, Libraries, Add Library..., User Library, OpenCV, Finish, OK
* Import [Eclipse project](https://github.com/sgjava/install-opencv/tree/master/java)

To run compiled class (Canny for this example) from shell:
* `cd ~/install-opencv/java`
* `java -Djava.library.path=/home/<username>/opencv/build/lib -cp /home/<username>/opencv/build/bin/opencv-320.jar:bin com.codeferm.opencv.Canny`

#### Things to be aware of
* There are no bindings generated for OpenCV's GPU module.
* Missing constants generated via patch.
* There's no imshow equivalent, so check out [CaptureUI](https://github.com/sgjava/install-opencv/blob/master/opencv-java/src/com/codeferm/opencv/CaptureUI.java)
* Understand how memory management [works](https://github.com/sgjava/opencvmem)
* Make sure you call Mat.free() to free native memory
* The JNI code can modify variables with the final modifier. You need to be aware of the implications of this since it is not normal Java behavior.

![CaptureUI Java](images/captureui-java.png)
   
The Canny example is slightly faster in Java (3.08 seconds) compared to Python
(3.18 seconds). In general, there's not enough difference in processing over 900
frames to pick one set of bindings over another for performance reasons.
`-agentlib:hprof=cpu=samples` is used to profile.
```
OpenCV 3.2.0-dev
Input file: ../resources/traffic.mp4
Output file: ../output/canny-java.avi
Resolution: 480x360
921 frames
242.1 FPS, elapsed time: 3.80 seconds

CPU SAMPLES BEGIN (total = 310) Fri Jan  3 16:09:24 2014
rank   self  accum   count trace method
   1 40.32% 40.32%     125 300218 org.opencv.imgproc.Imgproc.Canny_0
   2 22.58% 62.90%      70 300220 org.opencv.highgui.VideoWriter.write_0
   3 10.00% 72.90%      31 300215 org.opencv.highgui.VideoCapture.read_0
   4  9.03% 81.94%      28 300219 org.opencv.core.Core.bitwise_and_0
   5  9.03% 90.97%      28 300221 org.opencv.imgproc.Imgproc.cvtColor_1
   6  5.81% 96.77%      18 300222 org.opencv.imgproc.Imgproc.GaussianBlur_2
   7  0.32% 97.10%       1 300016 sun.misc.Perf.createLong
   8  0.32% 97.42%       1 300077 java.util.zip.ZipFile.open
   9  0.32% 97.74%       1 300095 java.util.jar.JarVerifier.<init>
  10  0.32% 98.06%       1 300102 java.lang.ClassLoader$NativeLibrary.load
  11  0.32% 98.39%       1 300105 java.util.Arrays.copyOfRange
  12  0.32% 98.71%       1 300163 sun.nio.fs.UnixNativeDispatcher.init
  13  0.32% 99.03%       1 300212 sun.reflect.ReflectionFactory.newConstructorAccessor
  14  0.32% 99.35%       1 300214 org.opencv.highgui.VideoCapture.VideoCapture_1
  15  0.32% 99.68%       1 300216 java.util.Arrays.copyOfRange
  16  0.32% 100.00%       1 300217 com.codeferm.opencv.Canny.main
CPU SAMPLES END
```

###References
* [openCV 3.1.0 optimized for Raspberry Pi, with libjpeg-turbo 1.5.0 and NEON SIMD support](http://hopkinsdev.blogspot.com/2016/06/opencv-310-optimized-for-raspberry-pi.html)
* [script for easy build opencv for raspberry pi 2/3, beaglebone, cubietruck, banana pi and odroid c2 ](https://gist.github.com/lhelontra/e4357758e4d533bd415678bf11942c0a)
* [conflicting switches: -march=armv7-a -mcpu=cortex-a8 ](https://bugs.launchpad.net/gcc-linaro/+bug/662720)
* [How to build libjpeg-turbo with Neon(SIMP) on odroid with linux environment](http://stackoverflow.com/questions/41979004/how-to-build-libjpeg-turbo-with-neonsimp-on-odroid-with-linux-environment)

###FreeBSD License
Copyright (c) Steven P. Goldsmith

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
