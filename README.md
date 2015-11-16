```
npm browserify -g
npm install
browserify -t coffeeify script.coffee > bundle.js
```

docker/ipyserver 
docker run -d -p 80:8888 -v $PWD:/notebooks -e "USE_HTTP=1" ipython/scipyserver

pd.options.display.max_rows = 999
pd.options.display.max_columns =999


reference
https://en.wikipedia.org/wiki/Dot_distribution_map

get that data
wget -i urls.txt 

from
http://apps.who.int/gho/data/node.main.ASDRBYCOUNTRY?lang=en

population
http://apps.who.int/gho/data/view.main.POP2040ALL?lang=en


# tabs
- general, geometric zooming : http://stackoverflow.com/questions/12310024/fast-and-responsive-interactive-charts-graphs-svg-canvas-other
- canvas polyogns for sampling : http://bl.ocks.org/awoodruff/94dc6fc7038eba690f43