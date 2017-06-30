# This class is responsible for creating a tee time based on the given
# options and the existing ValidTee times.
# If the TeeTime is valid then it will create a ValidTee otherwise
# it will create an InvalidTee.
class TeeTime
  def initialize(opts)
    @user = User.find_or_create_by(email: opts[:user_email])
    @club = Club.find_or_create_by(name: opts[:club_name])
    @number_time_slots = opts[:number_time_slots]
    @start_time = opts[:start_time]
    @end_time = opts[:end_time]

    @scheduled_tees = []

    @last_saved_user_tee = get_last_saved_user_tee
  end

  def schedule
    @number_time_slots.times do
      @scheduled_tees << find_time_slot
    end

    invalid_count = 0
    @scheduled_tees.each do |time|
      if time
        ValidTee.create(user: @user, club: @club, datetime: time)
      else
        invalid_count += 1
      end
    end

    if invalid_count > 0
      InvalidTee.create(user: @user,
                        club: @club,
                        number_time_slots: invalid_count,
                        start_date: @start_time,
                        end_date: @end_time)
    end
  end

  private

  # find a time between 9am or 5pm between start and end date
  # that factors existing tee times for the given user (3 hours apart)
  # and for given club (20 minutes apart)
  def find_time_slot
    time_slot = check_club_times(next_user_time)

    if valid_tee_time?(time_slot)
      time_slot
    else
      debugger
      go_to_next_day(time_slot)
    end
  end

  def go_to_next_day(datetime)
    new_date = datetime.change({hour: 9, minute: 0, second: 0}) + 1.days
    if (new_date + 3.hours) <=  @end_time
      new_date
    else
      false
    end
  end

  # tee time must be 3 hours before close (2pm), after 9am,
  # and 3 hours before end time
  def valid_tee_time?(datetime)
    before_5pm = (datetime.hour <= 13) || (datetime.hour <= 14 && datetime.min == 0)
    after_9am  = datetime.hour >= 9
    before_end_date = (datetime + 3.hours) <=  @end_time
    return before_5pm && after_9am && before_end_date
  end

  def next_user_time
    all_tees = (@last_saved_user_tee + @scheduled_tees).select { |x| x }
    all_tees.empty? ? @start_time : all_tees[-1] + 3.hours
  end

  def check_club_times(datetime)
    tees = @club.valid_tees.where(datetime: datetime)
    if tees.empty?
      datetime
    else
      new_date = datetime + 20.minutes
    end
  end

  def get_last_saved_user_tee
    @user.valid_tees.where(datetime: @start_time..@end_time)
      .order(datetime: :desc)
      .limit(1)
      .pluck(:datetime)
  end
end
