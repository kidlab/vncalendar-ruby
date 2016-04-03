require 'test_helper'

class VncalendarTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Vncalendar::VERSION
  end

  def test_solar_to_lunar
    result = Vncalendar::Converter.solar_to_lunar(Date.new(2014, 9, 23), 0)
    assert_equal(true, result.is_a?(Vncalendar::LunarDate))
    assert_equal(30, result.day)
    assert_equal(8, result.month)
    assert_equal(2014, result.year)
    assert_equal(false, result.leap)
  end

  def test_solar_to_lunar_leap_month
    result = Vncalendar::Converter.solar_to_lunar(Date.new(2006, 9, 12), 7)
    assert_equal(true, result.is_a?(Vncalendar::LunarDate))
    assert_equal(20, result.day)
    assert_equal(7, result.month)
    assert_equal(2006, result.year)
    assert_equal(true, result.leap)

    result = Vncalendar::Converter.solar_to_lunar(Date.new(2012, 6, 12), 7)
    assert_equal(true, result.is_a?(Vncalendar::LunarDate))
    assert_equal(23, result.day)
    assert_equal(4, result.month)
    assert_equal(2012, result.year)
    assert_equal(true, result.leap)
  end

  def test_lunar_to_solar
    result = Vncalendar::Converter.lunar_to_solar(Date.new(2014, 8, 30), 0, 0)
    assert_equal(true, result.is_a?(Date))
    assert_equal(23, result.day)
    assert_equal(9, result.month)
    assert_equal(2014, result.year)
  end

  def test_lunar_to_solar_leap_month
    result = Vncalendar::Converter.lunar_to_solar(Date.new(2006, 7, 20), 7, 7)
    assert_equal(true, result.is_a?(Date))
    assert_equal(12, result.day)
    assert_equal(9, result.month)
    assert_equal(2006, result.year)

    result = Vncalendar::Converter.lunar_to_solar(Date.new(2012, 4, 23), 4, 7)
    assert_equal(true, result.is_a?(Date))
    assert_equal(12, result.day)
    assert_equal(6, result.month)
    assert_equal(2012, result.year)
  end
end
