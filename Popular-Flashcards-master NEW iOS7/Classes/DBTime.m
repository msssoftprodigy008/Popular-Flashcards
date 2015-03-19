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


#import "DBTime.h"
#import "Util.h"

@interface DBTime ()

// The days in the SQLite database are stored as integer values with the semantics: days since 01.01.1970 (local time).
// The timestamps in the SQLite database are stored as integer values with the semantics: seconds since 01.01.1970 (GMT).

// prototypes
+ (NSInteger) secondsToDays: (NSTimeInterval) seconds;
+ (NSTimeInterval) daysToSeconds: (NSInteger) days;
+ (NSTimeInterval) hoursToSeconds: (NSInteger) hours;

@end

@implementation DBTime

//------------------------
// general time conversion

// @param seconds number of seconds
// @return corresponding number of days
+ (NSInteger) secondsToDays: (NSTimeInterval) seconds {
    return seconds / (24 * 60 * 60);   
}

// @param days number of days
// @return corresponding number of seconds
+ (NSTimeInterval) daysToSeconds: (NSInteger) days {
    return days * (24*60*60);
}    

// @param hours number of hours
// @return corresponding number of seconds
+ (NSTimeInterval) hoursToSeconds: (NSInteger) hours {
    return hours * (60*60);
}

//-----------------------------------
// Convert an iPhone date to a db day

// @return db day since 1970
+ (NSInteger) dateToDBDay: (NSDate*) aDate {
    NSTimeZone * timeZone = [NSTimeZone systemTimeZone];            // the current time zone
    NSInteger offset = [timeZone secondsFromGMTForDate: aDate];     // timezone correction (seconds)
    NSTimeInterval time = [aDate timeIntervalSince1970] + offset;   // seconds since 1970 (local time)
    return [self secondsToDays: time];                              // days since 1970
}    

// convert an iPhone date with offset [hours] to a db day.
// The offset is used to shift the day switch from midnight to another time.
+ (NSInteger) dateToDBDay: (NSDate*) aDate withOffset: (NSInteger) hours {
    return [self dateToDBDay: [aDate addTimeInterval: [self hoursToSeconds: -hours]]];
}

// ToDay as a db day
+ (NSInteger) Today {
    return [self dateToDBDay: [NSDate date]];
}

//---------------------------------------------------
// Convert a db day / timestamp to an iPhone date.

// Convert a db day to an iPhone date.
+ (NSDate*) dateFromDBDay:(NSInteger) dbDay {
    NSDate * aDate = [NSDate dateWithTimeIntervalSince1970: [self daysToSeconds: dbDay]];     // seconds since 1970 (local time)
    NSTimeZone * timeZone = [NSTimeZone systemTimeZone];          // the current time zone
    NSInteger offset = [timeZone secondsFromGMTForDate: aDate];   // timezone correction (seconds)
    return [aDate addTimeInterval: -offset];                      // GMT = local time - offset
}

// Convert a db day to a string (like dd.mm.yy as defined by the locale short date)
+ (NSString*) shortStringFromDBDay:(NSInteger) dbDay {
    return [Util shortStringFromDate: [self dateFromDBDay: dbDay]];
}    

// Convert a db timestamp to an iPhone date.
+ (NSDate*) dateFromDBTime: (NSInteger) dbTimestamp {
    return [NSDate dateWithTimeIntervalSince1970: dbTimestamp];
}

// Convert a db timestamp to a string (locale short time and date)
+ (NSString*) shortStringFromDBTime:(NSInteger) dbTimestamp {
    return [Util shortTimeStringFromDate: [self dateFromDBTime: dbTimestamp]];
}    

+(NSString*)smartDateString:(NSDate*)date
{
	NSDate *today = [NSDate date];
	
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	
	NSUInteger unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit;
	
	NSDateComponents *components = [gregorian components:unitFlags
												fromDate:date
												  toDate:today options:0];
	NSInteger months = [components month];
	NSInteger days = [components day];
	
	NSString *dateSting = [NSString stringWithString:@""];
	
	if(months==0 && days==0)
	{
		dateSting = [dateSting stringByAppendingString:@"Today"];
		return dateSting;
	}
	
	if(months==0 && days==1)
	{
		dateSting = [dateSting stringByAppendingString:@"Yesterday"];
		return dateSting;
	}
	
	NSInteger weeks = days/7;
	
	if(months!=0)
	{
		if(months==1)
			dateSting = [dateSting stringByAppendingString:@"1 month "];
		else
			dateSting = [dateSting stringByAppendingString:[NSString stringWithFormat:@"%d months ",months]];
	}
	
	if(weeks!=0)
	{
		if(weeks==1)
			dateSting = [dateSting stringByAppendingString:@"1 week "];
		else
			dateSting = [dateSting stringByAppendingString:[NSString stringWithFormat:@"%d weeks ",weeks]];
	}
	
	days = days%7;
	
	if(days!=0)
	{
		if(days==1)
			dateSting = [dateSting stringByAppendingString:@"1 day "];
		else
			dateSting = [dateSting stringByAppendingString:[NSString stringWithFormat:@"%d days ",days]];
	}
	
	dateSting = [dateSting stringByAppendingString:@"ago"];
	return dateSting;
}

+(NSString*)monthNameForNum:(NSInteger)monthNum
{
	switch (monthNum) {
		case 1:
			return @"January";
			break;
		case 2:
			return @"February";
			break;
		case 3:
			return @"March";
			break;
		case 4:
			return @"April";
			break;
		case 5:
			return @"May";
			break;
		case 6:
			return	@"June";
			break;
		case 7:
			return @"July";
			break;
		case 8:
			return @"August";
			break;
		case 9:
			return @"September";
			break;
		case 10:
			return @"October";
			break;
		case 11:
			return @"November";
			break;
		case 12:
			return @"December";
			break;
	
		default:
			return @"Unknown month";
			break;
	}
}

@end
