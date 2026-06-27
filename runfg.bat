D:

cd D:\MATLAB\FlightGear 2020.3

SET FG_ROOT=D:\MATLAB\FlightGear 2020.3\data

START .\\bin\fgfs.exe --fdm=null --native-fdm=socket,in,30,localhost,5502,udp  --enable-terrasync  --aircraft=f15c --fog-fastest --disable-clouds --start-date-lat=2004:06:01:09:00:00 --disable-sound --in-air --airport=ZUUU --runway=20 --altitude=0 --heading=200 --offset-distance=0 --offset-azimuth=0  
