#!/bin/bash

# Help.
function help() {
  echo -e "SLITCAMERA\n"
  echo -e "Script to turn video into slit photo.\nRequirements: ffmpeg or avconv and imagemagick.\n"
  echo -e "Usage:\n"
  echo -e "\t-i, --input\n\t\tInput video file name.\n\t\tRequired parameter.\n"
  echo -e "\t-o, --output\n\t\tOutput video file name.\n\t\tOptional parameter.\n\t\tDefault value: \"slit-photo.png\".\n"
  echo -e "\t-s, --slit-shift\n\t\tSlit shift in pixels by X-axis.\n\t\tOptional parameter.\n\t\tDefault value: 0.\n"
  echo -e "\t-h, --help\n\t\tShow help information.\n\t\tOptional parameter.\n"
  echo -e "Example:\n"
  echo -e "\t./slitcamera.sh --input=test.avi --output=test.png --slit-shift=100\n"
  echo "Developed by Loparev Pavel 2016"
}

# Determine installed video converter
converter=''
ffmpeg -version >/dev/null 2>&1 && { converter='ffmpeg'; }
avconv -version >/dev/null 2>&1 && { converter='avconv'; }
if [ -z "$converter"]; then
  echo 'Please install ffmpeg or avconv.'
  exit 1
fi

# Init variables.
framesFolder="frames"
slitFramesFolder="$framesFolder/slitFrames"
slitShift=0
input=""
output="slit-photo.png"

for i in "$@"
do
  case $i in
      -i=*|--input=*)
        shift
        input="${i#*=}"
      ;;
      -o=*|--output=*)
        shift
        output="${i#*=}"
      ;;
      -s=*|--slit-shift=*)
        shift
        slitShift="${i#*=}"
      ;;
      -h|--help)
	help  # Call your function
	exit 0
      ;;
      *)
        echo "Unknown parameter: $1"
        exit 1
      ;;
  esac
done

if [ -n "$input" ]; then
  # Clear tmp folder if exists.
  rm -rf $framesFolder

  # Create tmp directiry.
  echo "Creating tmp directory..."
  mkdir $framesFolder

  # Extract frames from video file.
  echo "Getting frames from video..."
  eval "$converter -i $input $framesFolder/frame-%d.png"

  # Init frame variables.
  framesCount=$(ls $framesFolder -1 | wc -l)
  frameWidth=$(identify -format "%[fx:w]" $framesFolder/frame-1.png)
  frameHeight=$(identify -format "%[fx:h]" $framesFolder/frame-1.png)

  if [ $slitShift -gt $frameWidth ]; then
    slitShift=$(expr $frameWidth - 1)
  fi

  if [ $slitShift -lt 0 ]; then
    slitShift=0
  fi

  # Convert each of frames to slit frame (frame with width == 1px).
  echo "Getting slit frames..."
  mkdir $slitFramesFolder
  for ((i = 1; i <= $framesCount; i++));
  do
    echo -ne "Processing: $(($i * 100 / $framesCount)) %...\r"
    convert -crop 1x$frameHeight+$slitShift+0 $framesFolder/frame-$i.png $slitFramesFolder/slit-$i.png
  done

  # Implode slit frames into one photo.
  echo "Montaging slit photo..."
  montage $slitFramesFolder/slit-%d.png[1-$framesCount] -tile $(expr $framesCount)x1 -geometry +0+0 $output

  # Clear tmp directory.
  echo "Clearing tmp directory..."
  rm -rf $framesFolder

  echo "Done"
else
  echo "Input file is required"
  exit 1
fi
