/////////////////////////
// This file is part of the karatasi project.
//
// Copyright 2009 Christa Runge, Mathias Kussinger
//
// karatasi is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// karatasi is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with karatasi.  If not, see <http://www.gnu.org/licenses/>.
/////////////////////////

//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface DBTime : NSObject {

}

// The days in the SQLite database are stored as integer values with the semantics: days since 01.01.1970 (local time).
// The timestamps in the SQLite database are stored as integer values with the semantics: seconds since 01.01.1970 (GMT).

//-----------------------------------
// Convert an iPhone date to a db day
+ (NSInteger) dateToDBDay: (NSDate*) aDate;

// convert an iPhone date with offset [hours] to a db day
+ (NSInteger) dateToDBDay: (NSDate*) aDate withOffset: (NSInteger) hours;

// ToDay as a db day
+ (NSInteger) Today;

//---------------------------------------------------
// Convert a db day / timestamp to an iPhone date.

+ (NSDate*) dateFromDBDay:(NSInteger) dbDay;

// Convert a db day to a string (like dd.mm.yy as defined by the locale short date)
+ (NSString*) shortStringFromDBDay: (NSInteger) dbDay;

+ (NSDate*) dateFromDBTime: (NSInteger) dbTimestamp;

// Convert a db timestamp to a string (locale short time and date)
+ (NSString*) shortStringFromDBTime: (NSInteger) dbTimestamp;

+(NSString*)smartDateString:(NSDate*)date;

+(NSString*)monthNameForNum:(NSInteger)monthNum;




@end
