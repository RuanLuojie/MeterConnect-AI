!/**
 * Highstock JS v11.4.8 (2024-08-29)
 *
 * Money Flow Index indicator for Highcharts Stock
 *
 * (c) 2010-2024 Grzegorz Blachliński
 *
 * License: www.highcharts.com/license
 */function(e){"object"==typeof module&&module.exports?(e.default=e,module.exports=e):"function"==typeof define&&define.amd?define("highcharts/indicators/mfi",["highcharts","highcharts/modules/stock"],function(t){return e(t),e.Highcharts=t,e}):e("undefined"!=typeof Highcharts?Highcharts:void 0)}(function(e){"use strict";var t=e?e._modules:{};function s(t,s,i,o){t.hasOwnProperty(s)||(t[s]=o.apply(null,i),"function"==typeof CustomEvent&&e.win.dispatchEvent(new CustomEvent("HighchartsModuleLoaded",{detail:{path:s,module:t[s]}})))}s(t,"Stock/Indicators/MFI/MFIIndicator.js",[t["Core/Series/SeriesRegistry.js"],t["Core/Utilities.js"]],function(e,t){let{sma:s}=e.seriesTypes,{extend:i,merge:o,error:r,isArray:n}=t;function u(e){return e.reduce(function(e,t){return e+t})}function a(e){return(e[1]+e[2]+e[3])/3}class c extends s{getValues(e,t){let s=t.period,i=e.xData,o=e.yData,c=o?o.length:0,d=t.decimals,h=e.chart.get(t.volumeSeriesID),l=h&&h.yData,f=[],p=[],m=[],g=[],y=[],v,D,I,S,x,j,C=!1,F=1;if(!h){r("Series "+t.volumeSeriesID+" not found! Check `volumeSeriesID`.",!0,e.chart);return}if(!(i.length<=s)&&n(o[0])&&4===o[0].length&&l){for(v=a(o[F]);F<s+1;)D=v,C=(v=a(o[F]))>=D,I=v*l[F],g.push(C?I:0),y.push(C?0:I),F++;for(j=F-1;j<c;j++)j>F-1&&(g.shift(),y.shift(),D=v,C=(v=a(o[j]))>D,I=v*l[j],g.push(C?I:0),y.push(C?0:I)),S=u(y),x=parseFloat((100-100/(1+u(g)/S)).toFixed(d)),f.push([i[j],x]),p.push(i[j]),m.push(x);return{values:f,xData:p,yData:m}}}}return c.defaultOptions=o(s.defaultOptions,{params:{index:void 0,volumeSeriesID:"volume",decimals:4}}),i(c.prototype,{nameBase:"Money Flow Index"}),e.registerSeriesType("mfi",c),c}),s(t,"masters/indicators/mfi.src.js",[t["Core/Globals.js"]],function(e){return e})});