require 'date'
require_relative 'vncalendar/version'

module Vncalendar
  class LunarDate < Struct.new(:year, :month, :day, :leap)
  end

  class Converter
    class << self
      private

      # Return Julian date from Gregorian date (our regular date).
      def jd_from_date(date)
        a = (14 - date.month) / 12
        y = date.year + 4800 - a
        m = date.month + 12*a - 3
        jd = date.day + (153*m+2)/5 + 365*y + y/4 - y/100 + y/400 - 32045
        if jd < 2299161
          jd = date.day + (153*m+2)/5 + 365*y + y/4 - 32083
        end

        jd
      end

      # Return Gregorian date from Julian date.
      def jd_to_date(jd)
        if jd > 2299160
          # After 5/10/1582, Gregorian calendar
          a = jd + 32044
          b = ((4*a + 3) / 146097).to_i
          c = a - ((b*146097)/4).to_i
        else
          b = 0
          c = jd + 32082
        end

        d = ((4*c + 3) / 1461).to_i
        e = c - ((1461*d)/4).to_i
        m = ((5*e + 2) / 153).to_i
        day = e - ((153*m+2)/5).to_i + 1
        month = m + 3 - 12*(m/10).to_i
        year = b*100 + d - 4800 + (m/10).to_i

        Date.new(year, month, day)
      end

      def new_moon(ak)
        k = ak.to_f

        t = k / 1236.85 # Time in Julian centuries from 1900 January 0.5
        t2 = t * t
        t3 = t2 * t
        dr = Math::PI / 180
        jd1 = 2415020.75933 + 29.53058868*k + 0.0001178*t2 - 0.000000155*t3
        jd1 = jd1 + 0.00033*Math.sin((166.56+132.87*t-0.009173*t2)*dr)  # Mean new moon
        m = 359.2242 + 29.10535608*k - 0.0000333*t2 - 0.00000347*t3     # Sun's mean anomaly
        mPr = 306.0253 + 385.81691806*k + 0.0107306*t2 + 0.00001236*t3 # Moon's mean anomaly
        f = 21.2964 + 390.67050646*k - 0.0016528*t2 - 0.00000239*t3     # Moon's argument of latitude
        c1 = (0.1734-0.000393*t)*Math.sin(m*dr) + 0.0021*Math.sin(2*dr*m)
        c1 = c1 - 0.4068*Math.sin(mPr*dr) + 0.0161*Math.sin(dr*2*mPr)
        c1 = c1 - 0.0004*Math.sin(dr*3*mPr)
        c1 = c1 + 0.0104*Math.sin(dr*2*f) - 0.0051*Math.sin(dr*(m+mPr))
        c1 = c1 - 0.0074*Math.sin(dr*(m-mPr)) + 0.0004*Math.sin(dr*(2*f+m))
        c1 = c1 - 0.0004*Math.sin(dr*(2*f-m)) - 0.0006*Math.sin(dr*(2*f+mPr))
        c1 = c1 + 0.0010*Math.sin(dr*(2*f-mPr)) + 0.0005*Math.sin(dr*(2*mPr+m))

        if t < -11
          deltat = 0.001 + 0.000839*t + 0.0002261*t2 - 0.00000845*t3 - 0.000000081*t*t3
        else
          deltat = -0.000278 + 0.000265*t + 0.000262*t2
        end

        jd1 + c1 - deltat
      end

      def new_moon_day(k, utc_offset)
        (new_moon(k) + 0.5 + utc_offset.to_f/24).to_i
      end

      def sun_longitude(jdn)
        t = (jdn - 2451545.0) / 36525.0 # Time in Julian centuries from 2000-01-01 12:00:00 GMT
        t2 = t * t
        dr = Math::PI / 180 # degree to radian
        m = 357.52910 + 35999.05030*t - 0.0001559*t2 - 0.00000048*t*t2 # mean anomaly, degree
        l0 = 280.46645 + 36000.76983*t + 0.0003032*t2 # mean longitude, degree
        dl = (1.914600 - 0.004817*t - 0.000014*t2) * Math.sin(dr*m)
        dl = dl + (0.019993-0.000101*t)*Math.sin(dr*2*m) + 0.000290*Math.sin(dr*3*m)
        l = l0 + dl # true longitude, degree
        l = l * dr
        l = l - Math::PI*2*(l/(Math::PI*2)).to_i #Normalize to (0, 2*PI)
        l
      end

      def calc_sun_longitude(jd, utc_offset)
        (sun_longitude(jd.to_f - 0.5 - utc_offset.to_f/24)/Math::PI * 6).to_i
      end

      def lunar_month_11(year, utc_offset)
        off = jd_from_date(Date.new(year, 12, 31)) - 2415021
        k = (off.to_f / 29.530588853).to_i
        nm = new_moon_day(k, utc_offset)
        sun_long = calc_sun_longitude(nm, utc_offset) # sun longitude at local midnight

        if sun_long >= 9
          nm = new_moon_day(k-1, utc_offset)
        end

        nm
      end

      def leap_month_offset(a11, utc_offset)
        k = ((a11.to_f-2415021.076998695)/29.530588853 + 0.5).to_i
        last = 0
        i = 1 # We start with the month following lunar month 11
        arc = calc_sun_longitude(new_moon_day(k+i, utc_offset), utc_offset)

        while arc != last && i < 14
          last = arc
          i += 1
          arc = calc_sun_longitude(new_moon_day(k+i, utc_offset), utc_offset)
        end

        i - 1
      end
    end

    def self.solar_to_lunar(date, utc_offset = 0)
      day_number = jd_from_date(date)
      k = ((day_number.to_f - 2415021.076998695) / 29.530588853).to_i
      month_start = new_moon_day(k+1, utc_offset)

      if month_start > day_number
        month_start = new_moon_day(k, utc_offset)
      end

      b11 = a11 = lunar_month_11(date.year, utc_offset)

      if a11 >= month_start
        lunar_year = date.year
        a11 = lunar_month_11(date.year - 1, utc_offset)
      else
        lunar_year = date.year + 1
        b11 = lunar_month_11(date.year + 1, utc_offset)
      end

      lunar_day = day_number - month_start + 1
      diff = ((month_start - a11) / 29).to_i
      lunar_leap = false
      lunar_month = diff + 11

      if (b11 - a11) > 365
        leap_month_diff = leap_month_offset(a11, utc_offset)

        if diff >= leap_month_diff
          lunar_month = diff + 10

          if diff == leap_month_diff
            lunar_leap = true
          end
        end
      end

      if lunar_month > 12
        lunar_month = lunar_month - 12
      end

      if lunar_month >= 11 && diff < 4
        lunar_year -= 1
      end

      LunarDate.new(lunar_year, lunar_month, lunar_day, lunar_leap)
    end

    def self.lunar_to_solar(date, lunar_leap = 0, utc_offset = 0)
      if date.month < 11
        a11 = lunar_month_11(date.year - 1, utc_offset)
        b11 = lunar_month_11(date.year, utc_offset)
      else
        a11 = lunar_month_11(date.year, utc_offset)
        b11 = lunar_month_11(date.year + 1, utc_offset)
      end

      k = (0.5 + (a11 - 2415021.076998695) / 29.530588853).to_i
      off = date.month - 11

      if off < 0
        off += 12
      end

      if (b11 - a11) > 365
        leap_off = leap_month_offset(a11, utc_offset)
        leap_month = leap_off - 2

        if leap_month < 0
          leap_month += 12
        end

        if lunar_leap != 0 && date.month != lunar_leap
          return Date.new(0, 0, 0)
        elsif lunar_leap != 0 || off >= leap_off
          off += 1
        end
      end

      month_start = new_moon_day(k + off, utc_offset)
      jd_to_date(month_start + date.day - 1)
    end
  end
end
