class PagesController < ApplicationController
  def home
    @valid_tees = ValidTee.all
    @invalid_tees = InvalidTee.all
  end


  def upload
    require 'CSV'

    arr_of_arr = CSV.read(params[:csv].path)
    header = arr_of_arr.shift

    arr_of_arr.map! do |row|
      opts = row_to_opts(row)

      # TeeTime is a plain old ruby object that creates a ValidTee
      # or InvalidTee based on the given options
      TeeTime.new(opts).schedule
    end

    redirect_to root_url
  end

  private

  # Converts a CSV row to a hash of options for TeeTime
  def row_to_opts(row)
    start_time = row[1] == row[2] ? DateTime.parse(row[2]) + 9.hours : DateTime.parse(row[1])
    end_time = row[1] == row[2] ? DateTime.parse(row[2]) + 17.hours : DateTime.parse(row[2])
    {
      user_email: row[0],
      start_time: start_time,
      end_time: end_time,
      number_time_slots: row[3].to_i,
      club_name: row[4]
    }
  end
end
