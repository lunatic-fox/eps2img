#!/bin/bash
set -e
shopt -s extglob

# inputs
input="$1"
output="$2"
format="$3"

outputFormats="jpeg|bmp|tiff|png|pdf|svg|ps"

# Echo with foreground color
# $1 tag; $2 message; $3 red; $4 green; $5 blue
color() { echo -e "\033[38;2;0;0;0m\033[48;2;$3;$4;$5m  $1  \033[0m \033[38;2;$3;$4;$5m$2\033[0m"; }

error() {
  color "Error" "$1" 255 0 0
  exit 1
}

# Check if the `.eps` exists
if [[ ! -f $input ]]; then
  error "Parameter \"input\" does not exist in \"$input\""
fi

replace() { echo $1 | sed -E "s/$2/$3/"; }

# Change format
# $1 path; $2 extension
changeFmt() { echo "$(replace "$1" '(.+\/)+(.+)\..+$' '\1\2').$2"; }

rmFmt() { echo $(replace "$1" '(.+\/)+(.+)\..+$' '\1\2'); }

# Validates the $format input parameter
isValidFormat() { if [[ $1 == !($outputFormats) ]]; then error "Unknown format: \"$1\""; fi; }

isValidFormat $format

defaultFilename=$(replace $input '(.+\/)+(.+)\.eps$' '\2')

if [ -z $output ]; then
  output=$(replace $input '(.+)\.eps$' '\1')  

  if [[ $format == +($outputFormats) ]]; then endFormat=".$format"; fi

  output="$output$endFormat"
  color "Info" "Since \"output\" parameter is not defined, the converted file will be outputed to \"$output\"" 66 111 245
fi

case $output in
  +(*/))
    output="$output$defaultFilename.$format";;
  !(*/*.*)) 
    output="$output.$format";;
  *)
    defaultOutputFormat=$(replace $output '(.+\/)+.+\.(.+)$' '\2')
    isValidFormat $defaultOutputFormat
    format=$defaultOutputFormat;;
esac

if [[ $format == +(jpeg|tiff|png|svg|ps) ]]; then
  toCairo=true
  cks=$(echo -n "$input$output$format" | sha256sum | sed -E "s/^([a-fA-F0-9]+).*/\1/")
fi

if [[ $format == +(jpeg|tiff|png|pdf|svg|ps) ]]; then
  device="pdfwrite"
  fmt=$format
  format="pdf"
  output=$(changeFmt $output "pdf")
else
  device="bmp16m"
  isBMP="-dGraphicsAlphaBits=4"
fi

dirOutput=$(replace $output '(.+\/).+$' '\1')

if [[ ! -d $dirOutput ]]; then mkdir -p $dirOutput; fi
if [[ $toCairo ]]; then 
  output="$(replace $output '(.+\/).+$' '\1')_${cks}_$(replace $output '.+\/(.+)$' '\1')"
fi

gs $isBMP -sDEVICE=$device -dEPSCrop -o $output -q $input

if [[ $toCairo ]]; then
  input=$output
  rmTmp() { echo $(replace $1 "(.+\/)_${cks}_(.+)$" '\1\2'); }

  case $fmt in
    +(svg|ps))
      output=$(rmTmp $(changeFmt $input $fmt))
      pdftocairo -$fmt $input $output;;
    +(png|tiff))
      output=$(rmTmp $(rmFmt $input $fmt))
      pdftocairo -singlefile -$fmt -transp $input $output;;
    jpeg)
      output=$(rmTmp $(rmFmt $input $fmt))
      pdftocairo -singlefile -$fmt -jpegopt quality=100,optimize=y $input $output
      wait
      mv "$output.jpg" "$output.jpeg";;
  esac

  wait

  if [[ $fmt == "tiff" ]]; then mv "$output.tif" "$output.tiff"; fi
  if [[ $fmt == +(png|jpeg|tiff) ]]; then output="$output.$fmt"; fi
  
  wait

  rm $input
fi

color "Success" "File \"$output\" created in the workflow!" 66 245 66
