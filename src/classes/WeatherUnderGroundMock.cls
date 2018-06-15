/*
Mock results for Weather Underground API call
*/	
@isTest
global class WeatherUnderGroundMock implements HttpCalloutMock {
  global HTTPResponse respond(HTTPRequest req) {
    HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
    String sample_response = '{' +
      '"response": {' +
        '"version": "0.1",' +
        '"termsofService": "http://www.wunderground.com/weather/api/d/terms.html",' +
        '"features": {' +
          '"forecast": 1' +
        '}' +
      '},' +
      '"forecast": {' +
        '"txt_forecast": {' +
          '"date": "2:00 PM PDT",' +
          '"forecastday": [{' +
            '"period": 0,' +
            '"icon": "partlycloudy",' +
            '"icon_url": "http://icons-ak.wxug.com/i/c/k/partlycloudy.gif",' +
            '"title": "Tuesday",' +
            '"fcttext": "Partly cloudy in the morning, then clear. High of 68F. Breezy. Winds from the West at 10 to 25 mph.",' +
            '"fcttext_metric": "Partly cloudy in the morning, then clear. High of 20C. Windy. Winds from the West at 20 to 35 km/h.",' +
            '"pop": "0"' +
            '}, {' +
            '"period": 7,' +
            '"icon": "partlycloudy",' +
            '"icon_url": "http://icons-ak.wxug.com/i/c/k/partlycloudy.gif",' +
            '"title": "Friday Night",' +
            '"fcttext": "Mostly cloudy. Fog overnight. Low of 52F. Winds from the West at 5 to 10 mph.",' +
            '"fcttext_metric": "Mostly cloudy. Fog overnight. Low of 11C. Winds from the West at 10 to 15 km/h.",' +
            '"pop": "0"' + 
          '}]' +
        '},' +
        '"simpleforecast": {' +
          '"forecastday": [{' +
            '"date": {' +
              '"epoch": "1340776800",' +
              '"pretty": "11:00 PM PDT on June 26, 2012",' +
              '"day": 26,' +
              '"month": 6,' +
              '"year": 2012,' +
              '"yday": 177,' +
              '"hour": 23,' +
              '"min": "00",' +
              '"sec": 0,' +
              '"isdst": "1",' +
              '"monthname": "June",' +
              '"weekday_short": "Tue",' +
              '"weekday": "Tuesday",' +
              '"ampm": "PM",' +
              '"tz_short": "PDT",' +
              '"tz_long": "America/Los_Angeles"' +
            '},' +
            '"period": 1,' +
            '"high": {' +
              '"fahrenheit": "68",' +
              '"celsius": "20"' +
            '},' +
            '"low": {' +
              '"fahrenheit": "50",' +
              '"celsius": "10"' +
            '},' +
            '"conditions": "Partly Cloudy",' +
            '"icon": "partlycloudy",' +
            '"icon_url": "http://icons-ak.wxug.com/i/c/k/partlycloudy.gif",' +
            '"skyicon": "mostlysunny",' +
            '"pop": 0,' +
            '"qpf_allday": {' +
              '"in": 0.00,' +
              '"mm": 0.0' +
            '},' +
            '"qpf_day": {' +
              '"in": 0.00,' +
              '"mm": 0.0' +
            '},' +
            '"qpf_night": {' +
              '"in": 0.00,' +
              '"mm": 0.0' +
            '},' +
            '"snow_allday": {' +
              '"in": 0,' +
              '"cm": 0' +
            '},' +
            '"snow_day": {' +
              '"in": 0,' +
              '"cm": 0' +
            '},' +
            '"snow_night": {' +
              '"in": 0,' +
              '"cm": 0' +
            '},' +
            '"maxwind": {' +
              '"mph": 21,' +
              '"kph": 34,' +
              '"dir": "West",' +
              '"degrees": 272' +
            '},' +
            '"avewind": {' +
              '"mph": 17,' +
              '"kph": 27,' +
              '"dir": "West",' +
              '"degrees": 272' +
            '},' +
            '"avehumidity": 72,' +
            '"maxhumidity": 94,' +
            '"minhumidity": 58' +
          '}, {' +
            '"date": {' +
              '"epoch": "1340863200",' +
              '"pretty": "11:00 PM PDT on June 27, 2012",' +
              '"day": 27,' +
              '"month": 6,' +
              '"year": 2012,' +
              '"yday": 178,' + 
              '"hour": 23,' +
              '"min": "00",' +
              '"sec": 0,' +
              '"isdst": "1",' +
              '"monthname": "June",' +
              '"weekday_short": "Wed",' +
              '"weekday": "Wednesday",' +
              '"ampm": "PM",' +
              '"tz_short": "PDT",' +
              '"tz_long": "America/Los_Angeles"' +
            '},' +
            '"period": 2,' +
            '"high": {' +
              '"fahrenheit": "72",' +
              '"celsius": "22"' +
            '},' +
            '"low": {' +
              '"fahrenheit": "54",' +
              '"celsius": "12"' +
            '},' +
            '"conditions": "Partly Cloudy",' +
            '"icon": "partlycloudy",' +
            '"icon_url": "http://icons-ak.wxug.com/i/c/k/partlycloudy.gif",' +
            '"skyicon": "mostlysunny",' +
            '"pop": 0,' +
            '"qpf_allday": {' +
              '"in": 0.00,' +
              '"mm": 0.0' +
            '},' +
            '"qpf_day": {' +
              '"in": 0.00,' +
              '"mm": 0.0' +
            '},' +
            '"qpf_night": {' +
              '"in": 0.00,' +
              '"mm": 0.0' +
            '},' +
            '"snow_allday": {' +
              '"in": 0,' +
              '"cm": 0' +
            '},' +
            '"snow_day": {' +
              '"in": 0,' +
              '"cm": 0' +
            '},' +
            '"snow_night": {' +
              '"in": 0,' +
              '"cm": 0' +
            '},' +
            '"maxwind": {' +
              '"mph": 11,' +
              '"kph": 18,' +
              '"dir": "WSW",' +
              '"degrees": 255' +
            '},' +
            '"avewind": {' +
              '"mph": 9,' +
              '"kph": 14,' +
              '"dir": "WSW",' +
              '"degrees": 252' +
            '},' +
            '"avehumidity": 70,' +
            '"maxhumidity": 84,' +
            '"minhumidity": 54' +
          '}]' +
        '}' +
      '}' +
    '}';
    res.setBody(sample_response);
    res.setStatusCode(200);
    return res;
  }
}