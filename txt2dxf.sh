#! /bin/bash

# Install required applications
# Ubuntu:
# apt-get install -y inkscape pstoedit
# Arch:
# pacman -S inkscape pstoedit

function svgToEps()
{
  if test $# -lt 1 ; then
    echo "You need to pass in a filename." ; return
  fi

  epsfile="${1%.*}.eps"

  echo "inkscape -f '$1' -E '$epsfile'"
  inkscape "$1" -o "$epsfile" --export-ignore-filters --export-ps-level=3
}

function bmpToSvg()
{
  if test $# -lt 1 ; then
    echo "You need to pass in a filename." ; return
  fi

  potrace --svg $1

}

function bmpToDxf()
{
  if test $# -lt 1 ; then
    echo "You need to pass in a filename." ; return
  fi

  base="${1%.*}"
  epsfile="${base}.eps"
  dxffile="${base}.dxf"
  bmpfile="${base}.bmp"
  svgfile="${base}.svg"

  bmpToSvg "$1"
  svgToEps "$svgfile"
  pstoedit -dt -f "dxf_s: -splineaspolyline -mm" "${epsfile}" "${dxffile}"
  rm "$epsfile"
  rm "$svgfile"
}


# Run the function
# bmpToDxf "$1"

input_text="$1"
bmpfile="$1.bmp"
echo -e "${input_text}\n42\n${input_text}" | ./ftext
bmpToDxf $(realpath ${bmpfile})
rm $bmpfile
