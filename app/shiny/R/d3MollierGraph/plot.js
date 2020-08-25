// defining a margin and drawing the coordinates as well as the comfort zone
    
let coordinate_lines = svg.append("g");
let comfort_zone     = svg.append("g");
let plotted_points   = svg.append("g");

// die variable ch?nntsch s?sch em R definiere ond denn onder "options" wiiterg?a
let margin           = {top: 30,right: 20,left: 30,bottom: 30};
                        
drawHXCoordinates(coordinate_lines
                 ,width
                 ,height
                 ,margin
                 ,[options.graphHumAbsMin,options.graphHumAbsMax]
                 ,[options.graphTempMin,options.graphTempMax]
                 ,options.graphPressure);
                 
              
drawComfort(comfort_zone
           ,width
           ,height
           ,margin
           ,[options.graphHumAbsMin,options.graphHumAbsMax]
           ,[options.graphTempMin,options.graphTempMax]
           ,[options.cmfZoneTempMin,options.cmfZoneTempMax]
           ,[options.cmfZoneHumRelMin/100,options.cmfZoneHumRelMax/100]
           ,[options.cmfZoneHumAbsMin,options.cmfZoneHumAbsMax]
           ,options.graphPressure);

width -= margin.right+margin.left;
height -= margin.top+margin.bottom;
plotted_points.attr("transform","translate("+margin.left+","+margin.top+")");
plotted_points = plotted_points.append("svg").attr("width",width).attr("height",height);

x = d3.scaleLinear().range([0,width]).domain([options.graphHumAbsMin,options.graphHumAbsMax]);
y = d3.scaleLinear().range([height,0]).domain([options.graphTempMin,options.graphTempMax]);

let transdata = [];
data.forEach(function(d,i) {
  transdata[i] = get_x_y(d.temperature,d.humidity/100,options.graphPressure);
  transdata[i].z = d.season;
});

plotted_points.selectAll("circle")
              .data(transdata)
              .enter()
                .append("circle")
                .attr("cx",d => { return x(d.x); })
                .attr("cy",d => { return y(d.y); })
                .attr("r",3)
                .attr("fill",function(d){
                  if(d.z=="Winter"){return "#365c8d"}
                  else if(d.z=="Fall") {return "#440154"}
                  else if(d.z=="Summer") {return "#febc2b"}
                  else {return "#2db27d"}
                })
                .attr("opacity",0.4);

