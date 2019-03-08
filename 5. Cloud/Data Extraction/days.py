import datetime

#Returns 2016-1-1
def new_year():
    return datetime.date(2016,1,1)

#Returns the date today
def today():
    return datetime.date.today()

#Returns a specific date
def day(y,m,d):
    return datetime.date(y,m,d)


#Returns a list of dates as strings from start to end inclusive
def get_dates(start, end):
    dts = []
    delta = end - start
    for d in range(delta.days + 1):
        dts.append(start + datetime.timedelta(days = d))
    return [str(d) for d in dts]
