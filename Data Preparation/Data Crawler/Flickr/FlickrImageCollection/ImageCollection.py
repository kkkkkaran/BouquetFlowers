
"""
 AUTHOR : Min Xue
 PURPOSE : To collect bouquet of flowers images from Flickr
"""

import os
import sys
from datetime import date
from icrawler.builtin import FlickrImageCrawler

image_path = '/Users/xuemin/Desktop/FlickrImageCollection/result'
API_KEY = '13ef101ff4bac39647acb5531d8d0a3c'

FlowerBreedList = open('List1.txt','rt')

for nameList in FlowerBreedList:
    name = nameList.strip('\n')
    imageDir = image_path + '/' + name
    searchName = name
    flickr_crawler = FlickrImageCrawler(API_KEY, storage={'root_dir': imageDir})
    flickr_crawler.crawl(max_num = 500, tags = searchName, text = searchName)

print("Collection is done")
