#!/bin/bash
set -e
shopt -s extglob

# inputs
input="$1"
output="$2"
format="$3"

outputFormats="jpeg|bmp|tiff|png|pdf"

# message, r, g, b
color() {
  coloredMsg="\033[38;2;$2;$3;$4m$1\033[0m"
}

error() {
  color "::  Error  :: $1" 255 0 0
  echo -e $coloredMsg
  exit 1
}

# validates the `format` input parameter
isValidFormat() {
  if [[ $1 == !($outputFormats) ]]; then
    error "Unknown format: \"$1\""
  fi
}

# check if the `.eps` exists
if [ ! -f $input ]; then
  error "Parameter \"input\" does not exist in \"$input\""
fi

isValidFormat $format

defaultFilename=`echo $input | sed -E 's/(.+\/)+(.+)\.eps$/\2/'`

if [ -z $output ]; then
  output=`echo $input | sed -E 's/(.+)\.eps$/\1/'`

  if [[ $format == +($outputFormats) ]]; then
    endFormat=".$format"
  fi

  output="${output}${endFormat}"
  color "::  Info  :: Since \"output\" parameter is not defined, the converted file will be outputed to \"$output\"" 221 158 255
  echo -e $coloredMsg
fi

case $output in
  +(*/))
    output="${output}${defaultFilename}.$format";;
  !(*/*.*)) 
    output="$output.$format";;
  *)
    defaultOutputFormat=`echo $output | sed -E 's/(.+\/)+.+\.(.+)$/\2/'`
    isValidFormat $defaultOutputFormat
    format=$defaultOutputFormat;;
esac

case $format in
  "jpeg") device=$format;;
   "bmp") device="bmp16m";;
  "tiff") device="tiff24nc";;
   "png") device="png16m";;
   "pdf") device="pdfwrite";;
esac

if [[ $format != "pdf" ]]; then
  isRaster="-dGraphicsAlphaBits=4"
fi

$(gs -q $isRaster -sDEVICE=$device -dEPSCrop -o $output $input)

color ":: Success :: File \"$output\" created in the workflow!" 66 245 66
echo -e $coloredMsg
