SLITCAMERA

Script to turn video into slit photo.
Requirements: ffmpeg or avconv and imagemagick.

Usage:

	-i, --input
		Input video file name.
		Required parameter.

	-o, --output
		Output video file name.
		Optional parameter.
		Default value: "slit-photo.png".

	-s, --slit-shift
		Slit shift in pixels by X-axis.
		Optional parameter.
		Default value: 0.

	-h, --help
		Show help information.
		Optional parameter.

Example:

	./slitcamera.sh --input=test.avi --output=test.png --slit-shift=100

Developed by Loparev Pavel 2016
