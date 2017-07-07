require 'test_helper'

class TeeTimeTest < ActiveSupport::TestCase
  test "schedules 1 tee time 20 minutes before closing" do
    opts = {
      user_email: 'ghost@email.com',
      start_time: DateTime.parse('2017-09-01 16:40:00'),
      end_time: DateTime.parse('2017-09-01 22:40:00'),
      number_time_slots: 5,
      club_name: 'Club A'
    }

    assert_difference 'ValidTee.count', 1 do
      TeeTime.new(opts).schedule
    end
  end

  test "user cannot schedule more than one tee time at the same time" do
    opts_a = {
      user_email: 'ghost@email.com',
      start_time: DateTime.parse('2017-09-01 09:00:00'),
      end_time: DateTime.parse('2017-09-01 09:30:30'),
      number_time_slots: 1,
      club_name: 'Club A'
    }

    opts_b = {
      user_email: 'ghost@email.com',
      start_time: DateTime.parse('2017-09-01 09:00:00'),
      end_time: DateTime.parse('2017-09-01 09:30:30'),
      number_time_slots: 1,
      club_name: 'Club B'
    }

    valid_tee_count = ValidTee.count
    invalid_tee_count = InvalidTee.count

    TeeTime.new(opts_a).schedule
    TeeTime.new(opts_b).schedule

    assert valid_tee_count + 1, ValidTee.count
    assert invalid_tee_count + 1, InvalidTee.count
  end

  test "books inbetween two timeslots for the same user" do
    user = User.create email: "joseph"
    club = Club.create name: "Club A"
    ValidTee.create!(user: user, club: club, datetime: DateTime.parse('2017-09-01 09:00:00'))
    ValidTee.create!(user: user, club: club, datetime: DateTime.parse('2017-09-01 15:00:00'))

    opts = {
      user_email: "joseph",
      start_time: DateTime.parse('2017-09-01 09:00:00'),
      end_time: DateTime.parse('2017-09-01 19:30:30'),
      number_time_slots: 1,
      club_name: "Club A"
    }

    assert_difference 'ValidTee.count', 1 do
      TeeTime.new(opts).schedule
    end

    tee = ValidTee.last
    assert_equal tee.datetime, DateTime.parse('2017-09-01 12:00:00')
  end
end
