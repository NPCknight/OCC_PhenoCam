OCC_method_20210617.m 为物候相机最优色彩合成方法（Optimal Color Composition，OCC）的实现代码，可以重建出物候相机逐日照片时序和GCC时间序列。

cell2csv.m，colorspace.m，DOY.m为OCC_method_20210617.m中调用的函数，其中cell2csv.m用于实现将cell储存为CSV文件；colorspace.m用于照片颜色模式的转换；DOY.m用于根据年份日期计算对应DOY。

test_data为用于检验代码的测试数据，下载自https://phenocam.sr.unh.edu/webcam/gallery/，为millhaft站点2018-5-18至5-21的照片。

注意：代码是从照片命名中获取照片拍摄时间的，该部分只是适用于从https://phenocam.sr.unh.edu/webcam/gallery/下载的照片，如果是其他来源的照片需要对获取拍摄时间部分的代码进行调整。