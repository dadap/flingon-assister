#!/bin/sh

# This script resizes the logo art to the various bitmap sizes needed.

iconsdir=`dirname $0`/../../ios/Runner/Assets.xcassets/AppIcon.appiconset

resize() {
    size=$1
    scale=$2
    scaledsize=`echo "$size * $scale" | bc`

    convert `dirname $0`/logo.svg -resize ${scaledsize}x${scaledsize} \
        $iconsdir/Icon-App-${size}x${size}@${scale}x.png
}

resize 1024 1
resize 20 1
resize 20 2
resize 20 3
resize 29 1
resize 29 2
resize 29 3
resize 40 1
resize 40 2
resize 40 3
resize 60 2
resize 60 3
resize 76 1
resize 76 2
resize 83.5 2
