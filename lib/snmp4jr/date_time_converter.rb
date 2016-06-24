module SNMP4JR
  # Utility class for converting SNMP DateTime octet strings into useful information.
  #
  # Example:
  #
  #   datetime = SnmpDateTimeConverter.new('07:e0:06:17:0d:18:01:00:2d:04:00')
  #
  #   datetime.to_s
  #   => "2016-6-23,13:24:01.0,-4:0"
  #
  #   datetime.to_time
  #   => 2016-06-23 13:24:01 -0400
  #
  #   datetime.to_time.to_i
  #   => 1466702641
  #
  # SNMP DateTime specification:
  #
  # DateAndTime ::= TEXTUAL-CONVENTION
  #     DISPLAY-HINT "2d-1d-1d,1d:1d:1d.1d,1a1d:1d"
  #     STATUS       current
  #     DESCRIPTION
  #             "A date-time specification.
  #
  #             field  octets  contents                  range
  #             -----  ------  --------                  -----
  #               1      1-2   year*                     0..65536
  #               2       3    month                     1..12
  #               3       4    day                       1..31
  #               4       5    hour                      0..23
  #               5       6    minutes                   0..59
  #               6       7    seconds                   0..60
  #                            (use 60 for leap-second)
  #               7       8    deci-seconds              0..9
  #               8       9    direction from UTC        '+' / '-'
  #               9      10    hours from UTC*           0..13
  #              10      11    minutes from UTC          0..59
  #
  #             * Notes:
  #             - the value of year is in network-byte order
  #             - daylight saving time in New Zealand is +13
  #
  #             For example, Tuesday May 26, 1992 at 1:30:15 PM EDT would be
  #             displayed as:
  #
  #                              1992-5-26,13:30:15.0,-4:0
  #
  #             Note that if only local time is known, then timezone
  #             information (fields 8-10) is not present."
  #     SYNTAX       OCTET STRING (SIZE (8 | 11))
  #
  class DateTimeConverter

    SPLIT_TOKEN   = ':'

    YEAR          = 0..1
    MONTH         = 2
    DAY           = 3
    HOUR          = 4
    MINUTES       = 5
    SECONDS       = 6
    DECI_SECONDS  = 7
    UTC_DIRECTION = 8
    UTC_HOURS     = 9
    UTC_MINUTES   = 10

    def initialize(string = '')
      @string = string
      parse
    end

    # 1992-5-26,13:30:15.0,-4:0
    def to_s
     [date, time, zone].join(',')
    end

    def to_time
      Time.new(@year, @month, @day, @hour, @minutes, @seconds, formatted_zone)
    end

    def to_i
      to_time.to_i
    end

    def date
      "#{@year}-#{@month}-#{@day}"
    end

    def time
      "#{padded(@hour)}:#{padded(@minutes)}:#{padded(@seconds)}.#{@deci_seconds}"
    end

    def zone
      "#{@utc_direction}#{@utc_hours}:#{@utc_minutes}"
    end

    def octets
      @octets ||= @string.split(SPLIT_TOKEN)
    end

    # "+HH:MM" or "-HH:MM" expected for ruby utc_offset
    def formatted_zone
      "#{@utc_direction}#{padded(@utc_hours)}:#{padded(@utc_minutes)}"
    end

    private

    def parse
      @year          = octets[YEAR].join.hex
      @month         = octets[MONTH].hex
      @day           = octets[DAY].hex
      @hour          = octets[HOUR].hex
      @minutes       = octets[MINUTES].hex
      @seconds       = octets[SECONDS].hex
      @deci_seconds  = octets[DECI_SECONDS].hex
      @utc_direction = octets[UTC_DIRECTION].hex.chr
      @utc_hours     = octets[UTC_HOURS].hex
      @utc_minutes   = octets[UTC_MINUTES].hex
    end

    def padded(input)
      sprintf '%02d', input
    end

  end
end
