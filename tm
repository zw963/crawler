#!/bin/sh

SCRIPT_DIRECTORY=$(dirname `which $0`)/bin
export SITE='天猫'

$SCRIPT_DIRECTORY/get_product_list
# $SCRIPT_DIRECTORY/get_product_detail
# $SCRIPT_DIRECTORY/get_picture_list
# $SCRIPT_DIRECTORY/get_picture_downloader
