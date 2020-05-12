# Sonar Image Segmentation via Fuzzy C-means Clustering

Author: Shuyue Jia and Ziyu Huo @ Human Sensor Laboratory, School of Automation Engineering, Northeast Electric Power University, Jilin, China.

Date: August of 2018

These are dozens of segmentation experiments on sonar images via Fuzzy Method.

---

<div>
  <div style="text-align:center">
      <img width=99%device-width src="https://github.com/SuperBruceJia/Fuzzy-C-Means-Clustering-Sonar-Image-Segmentation/raw/master/TEST34/Overall.png" alt="Project">
</div>

---

## Read the Original Shipwrecked Sonar Image

![](https://github.com/SuperBruceJia/Fuzzy-C-Means-Clustering-Sonar-Image-Segmentation/raw/master/TEST34/sonar_original.jpg)

## Gray the Image

![](https://github.com/SuperBruceJia/Fuzzy-C-Means-Clustering-Sonar-Image-Segmentation/raw/master/TEST34/Img_gray.png)

## Denoise the Image: DCT (Discrete Cosine Transform) Denoise

![](https://github.com/SuperBruceJia/Fuzzy-C-Means-Clustering-Sonar-Image-Segmentation/raw/master/TEST34/Img_Denoise.png)

## Edge Detection (Roberts Operator)

![](https://github.com/SuperBruceJia/Fuzzy-C-Means-Clustering-Sonar-Image-Segmentation/raw/master/TEST34/Img_Edge.png)

## Removing Shadow Boundaries

![](https://github.com/SuperBruceJia/Fuzzy-C-Means-Clustering-Sonar-Image-Segmentation/raw/master/TEST34/Removing_Shadow_Boundaries.png)

## Image Localization (Threshold)

![](https://github.com/SuperBruceJia/Fuzzy-C-Means-Clustering-Sonar-Image-Segmentation/raw/master/TEST34/Locate_Ship.png)

## Remove Ship Boundaries

![](https://github.com/SuperBruceJia/Fuzzy-C-Means-Clustering-Sonar-Image-Segmentation/raw/master/TEST34/Dilate_New_Img.png)

## Image Dilate White Pixel (Morphology Dilation)

![](https://github.com/SuperBruceJia/Fuzzy-C-Means-Clustering-Sonar-Image-Segmentation/raw/master/TEST34/Img_Dilate.png)

## Merge Denoise & Dilation Images

![](https://github.com/SuperBruceJia/Fuzzy-C-Means-Clustering-Sonar-Image-Segmentation/raw/master/TEST34/Img_Dilate_Final.png)

## 2-D Entropy Segamentation

![](https://github.com/SuperBruceJia/Fuzzy-C-Means-Clustering-Sonar-Image-Segmentation/raw/master/TEST34/Img_Segmentation.png)
