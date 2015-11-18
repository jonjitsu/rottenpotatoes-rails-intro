class Movie < ActiveRecord::Base
  def self.only_fields(movies, field)
    movies.map { |m| m.send(field) }.uniq
  end

  def self.all_ratings
    only_fields(self.all, :rating)
  end
end
