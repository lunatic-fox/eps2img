#!/bin/bash
set -e
shopt -s extglob

# inputs
input="$1"
output="$2"
format="$3"

outputFormats="jpeg|bmp|tiff|png|pdf|svg"

# Echo with foreground color
# $1 message; $2 red; $3 green; $4 blue
color() {
  echo -e "\033[38;2;$2;$3;$4m$1\033[0m"
}

error() {
  color "::  Error  :: $1" 255 0 0
  exit 1
}

# Change format
# $1 path; $2 extension
changeFmt() {
  local r=`echo $1 | sed -E 's/(.+\/)+(.+)\..+$/\1\2/'`
  echo "$r.$2"
}

removeFmt() {
  local r=`echo $1 | sed -E 's/(.+\/)+(.+)\..+$/\1\2/'`
  echo "${r}$2"
}

# Validates the $format input parameter
isValidFormat() {
  if [[ $1 == !($outputFormats) ]]; then
    error "Unknown format: \"$1\""
  fi
}

# Check if the `.eps` exists
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

if [[ $format == +(jpeg|tiff|png|svg) ]]; then toCairo=true; fi

if [[ $format == +(jpeg|tiff|png|pdf|svg) ]]; then
  device="pdfwrite"
  fmt=$format
  format="pdf"
  output=$(changeFmt $output "pdf")
else
  device="bmp16m"
  isRaster="-dGraphicsAlphaBits=4"
fi

gs -q -dBATCH -dNOPAUSE $isRaster -sDEVICE=$device -dEPSCrop -sOutputFile=$output $input

if [[ $toCairo ]]; then
  input=$output

  case $fmt in
    svg)
      output=$(changeFmt $input "svg")
      pdftocairo -svg $input $output;;
    +(png|tiff))
      output=$(removeFmt $input);
      pdftocairo -singlefile -$fmt -transp $input $output;;
    jpeg)
      output=$(removeFmt $input);
      pdftocairo -singlefile -$fmt -jpegopt quality=100,optimize=y $input $output;;
  esac

  wait

  if [[ $fmt == "jpeg" ]]; then mv "$output.jpg" "$output.jpeg"; fi
  if [[ $fmt == "tiff" ]]; then mv "$output.tif" "$output.tiff"; fi
  
  wait

  rm $input
fi

color ":: Success :: File \"$output\" created in the workflow!" 66 245 66
