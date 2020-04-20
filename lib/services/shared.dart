import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'mapServices.dart';

SharedPreferences prefs;
bool caseReported;

class Shared {
	
	static Future<void> initShared() async {
  	prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey('caseReported')) 
     {
       prefs.setBool('caseReported', false);
       caseReported=false;
     } 
    if(!prefs.containsKey('uuid')) {
      var uuid = new Uuid();
      String uUID=uuid.v4();
      prefs.setString('uuid', uUID);
      MapService.buildMapCircles();
      print('First Time enter');
      print('UUID:$uUID');
    }
    else {
      caseReported=prefs.getBool('caseReported');
    }
    print('Shared Preferences Initialized!');
		return Future.value();
	}

	static Future<void> setMatchedCoordinates(dynamic coords) async {
    List<dynamic> previousMatchedCoords=await getMatchedCoordinates();
    if(previousMatchedCoords==null) {
      previousMatchedCoords=[];
    }
   List<dynamic> newList;
   if(previousMatchedCoords.isNotEmpty && coords.isNotEmpty) {
     newList=[...previousMatchedCoords, ...coords];
   }
   if(previousMatchedCoords.isEmpty && coords.isEmpty) {
     newList=[];
   }
   if(previousMatchedCoords.isEmpty) {
     newList=[...coords];
   }
   if(coords.isEmpty) {
     newList=[...previousMatchedCoords];
   }
		return prefs.setString('matchedCoords', json.encode(newList));
	}
	
	static Future<dynamic> getMatchedCoordinates() async {
    if(!prefs.containsKey('matchedCoords')) {
      print('No coordinates stored!');
      return Future.value([]);
    }
		return Future.value(json.decode(prefs.getString('matchedCoords')));
    //return Future.value();
	}

  static Future<bool> setCaseReported() async {
    caseReported=true;
    print('AOK-Set');
    return prefs.setBool('caseReported', true);
  }

  static isCaseReported() {
    return caseReported;
  }

  static getUuid() {
    return prefs.getString('uuid');
  }

  static Future<bool> setAffectedCitiesCircles(List<Map<String, dynamic>> circles) {
    print('Circle\'s data for cities stored locally!');
    return prefs.setString('affectedCitiesCircles', json.encode(circles));
  }

  static Set<Circle> getAffectedCitiesCircles() {
    Set<Circle> circles=Set();
    double radius=0;
    int color=0;
    List<dynamic> citiesData=json.decode(prefs.getString('affectedCitiesCircles'));
    for(int i=0;i<citiesData.length;i++) {
      if (citiesData[i]['confirmed'] < 50) {
        radius = 2500;
        color = 300;
      } else if (citiesData[i]['confirmed'] < 100) {
        radius = 5000;
        color = 400;
      } else if (citiesData[i]['confirmed'] < 200) {
        radius = 10000;
        color = 500;
      } else if (citiesData[i]['confirmed'] < 300) {
        radius = 20000;
        color = 600;
      } else if (citiesData[i]['confirmed'] < 500) {
        radius = 30000;
        color = 700;
      } else {
        radius = 50000;
        color = 900;
      }
      circles.add(Circle(
          circleId: CircleId(citiesData[i]['confirmed'].toString()),
          center: LatLng(citiesData[i]['latitude'], citiesData[i]['longitude']),
          radius: radius,
          strokeColor: Colors.red[color],
          strokeWidth: 5,
          fillColor: Colors.red[color]));
    }
    print('Retrieved and converted affected cities map circles!');
    return circles;
  }

  static Future<bool> setLastUpdatedStamp(DateTime datetime) {
    Map<String, dynamic> updateMap={
      'date': datetime.day.toString()+'-'+datetime.month.toString()+'-'+datetime.year.toString(),
      'time': datetime.hour.toString()+':'+datetime.minute.toString(),
    };
    print(updateMap);
    return prefs.setString('lastUpdatedStamp', json.encode(updateMap));
  }

  static getLastUpdatedStamp() {
    dynamic updateStamp=json.decode(prefs.getString('lastUpdatedStamp'));
    if(updateStamp==null) {
      DateTime datetime=DateTime.now();
      return ({
        'date': datetime.day.toString()+'-'+datetime.month.toString()+'-'+datetime.year.toString(),
        'time': datetime.hour.toString()+':'+datetime.minute.toString(),
      });
    }
    else {
      return updateStamp;
    }
  }
}

