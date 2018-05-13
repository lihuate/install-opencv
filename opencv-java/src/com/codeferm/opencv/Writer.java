/*
 * Copyright (c) Steven P. Goldsmith. All rights reserved.
 *
 * Created by Steven P. Goldsmith on December 29, 2013
 * sgoldsmith@codeferm.com
 */
package com.codeferm.opencv;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.LogManager;
import java.util.logging.Logger;

import org.opencv.core.Core;
import org.opencv.core.Mat;
import org.opencv.core.Size;
import org.opencv.videoio.VideoCapture;
import org.opencv.videoio.VideoWriter;
import org.opencv.videoio.Videoio;

/**
 * Example of VideoWriter class.
 *
 * args[0] = source file or will default to "../resources/traffic.mp4" if no
 * args passed.
 *
 * @author sgoldsmith
 * @version 1.0.0
 * @since 1.0.0
 */
// This is demo code, not worried about magic numbers, etc.
@SuppressWarnings({ "checkstyle:magicnumber", "PMD.LawOfDemeter", "PMD.AvoidLiteralsInIfCondition",
        "PMD.AvoidInstantiatingObjectsInLoops", "PMD.AvoidUsingNativeCode", "PMD.AvoidFinalLocalVariable",
        "PMD.CommentSize", "PMD.AvoidPrintStackTrace", "PMD.UseProperClassLoader", "PMD.AvoidPrefixingMethodParameters",
        "PMD.DataflowAnomalyAnalysis" })
final class Writer {
    /**
     * Logger.
     */
    // Logger is not a constant
    @SuppressWarnings({ "checkstyle:constantname", "PMD.VariableNamingConventions" })
    private static final Logger logger = Logger.getLogger(Writer.class.getName());
    /* Load the OpenCV system library */
    static {
        System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
    }

    /**
     * Suppress default constructor for noninstantiability.
     */
    private Writer() {
        throw new AssertionError();
    }

    /**
     * Main method.
     *
     * args[0] = source file or will default to "../resources/traffic.mp4" if no
     * args passed.
     *
     * @param args
     *            Arguments passed.
     */
    public static void main(final String... args) {
        String url = null;
        final String outputFile = "../output/writer-java.avi";
        // Check how many arguments were passed in
        if (args.length == 0) {
            // If no arguments were passed then default to
            // ../resources/traffic.mp4
            url = "../resources/traffic.mp4";
        } else {
            url = args[0];
        }
        // Custom logging properties via class loader
        try {
            LogManager.getLogManager()
                    .readConfiguration(Writer.class.getClassLoader().getResourceAsStream("logging.properties"));
        } catch (SecurityException | IOException e) {
            e.printStackTrace();
        }
        logger.log(Level.INFO, String.format("OpenCV %s", Core.VERSION));
        logger.log(Level.INFO, String.format("Input file: %s", url));
        logger.log(Level.INFO, String.format("Output file: %s", outputFile));
        final VideoCapture videoCapture = new VideoCapture(url);
        final Size frameSize = new Size((int) videoCapture.get(Videoio.CAP_PROP_FRAME_WIDTH),
                (int) videoCapture.get(Videoio.CAP_PROP_FRAME_HEIGHT));
        logger.log(Level.INFO, String.format("Resolution: %s", frameSize));
        final FourCC fourCC = new FourCC("X264");
        final VideoWriter videoWriter = new VideoWriter(outputFile, fourCC.toInt(),
                videoCapture.get(Videoio.CAP_PROP_FPS), frameSize, true);
        final Mat mat = new Mat();
        int frames = 0;
        final long startTime = System.currentTimeMillis();
        while (videoCapture.read(mat)) {
            videoWriter.write(mat);
            frames++;
        }
        final long estimatedTime = System.currentTimeMillis() - startTime;
        final double seconds = (double) estimatedTime / 1000;
        logger.log(Level.INFO, String.format("%d frames", frames));
        logger.log(Level.INFO, String.format("%4.1f FPS, elapsed time: %4.2f seconds", frames / seconds, seconds));
        // Release native memory
        videoCapture.free();
        videoWriter.free();
        mat.free();
    }
}
