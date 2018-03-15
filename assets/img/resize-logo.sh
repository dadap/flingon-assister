#!/bin/sh

# This script resizes the logo art to the various bitmap sizes needed.

iconsdir_ios=`dirname $0`/../../ios/Runner/Assets.xcassets/AppIcon.appiconset
launchdir_ios=`dirname $0`/../../ios/Runner/Assets.xcassets/LaunchImage.imageset
iconsdir_android=`dirname $0`/../../android/app/src/main/res

resize_ios() {
    size=$1
    scale=$2
    scaledsize=`echo "$size * $scale" | bc`

    convert -background '#313031' \
        `dirname $0`/logo.svg -resize ${scaledsize}x${scaledsize} \
        $iconsdir_ios/Icon-App-${size}x${size}@${scale}x.png
}

resize_ios_launch() {
    size=$1
    scale=$2

    convert -background none `dirname $0`/logo.svg -resize ${size}x${size} \
        $launchdir_ios/LaunchImage$scale.png
}

resize_android() {
    size=$1
    dpi=$2

    convert -background none `dirname $0`/logo.svg -resize ${size}x${size} \
        $iconsdir_android/mipmap-${dpi}/ic_launcher.png
}

resize_ios 1024 1
resize_ios 20 1
resize_ios 20 2
resize_ios 20 3
resize_ios 29 1
resize_ios 29 2
resize_ios 29 3
resize_ios 40 1
resize_ios 40 2
resize_ios 40 3
resize_ios 60 2
resize_ios 60 3
resize_ios 76 1
resize_ios 76 2
resize_ios 83.5 2

resize_ios_launch 256 ''
resize_ios_launch 512 @2x
resize_ios_launch 768 @3x

resize_android 48 mdpi
resize_android 72 hdpi
resize_android 96 xhdpi
resize_android 144 xxhdpi
resize_android 192 xxxhdpi
