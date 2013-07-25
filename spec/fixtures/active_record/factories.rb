#
# Record creators
#

def create_record model, date, message = nil
  message ||= "#{model} on #{date}"
  record = model.factory message, date
  record.created_at = date if model.is_a?(Post)
  record.save
  record
end

def create_records_after date, model
  %w[1.day 2.days 1.week 1.month 1.year].map do |buffer|
    create_record model, date + eval(buffer), "#{model} #{buffer} after #{date}"
  end
end

def create_records_before date, model
  %w[1.day 2.days 1.week 1.month 1.year].map do |buffer|
    create_record model, date - eval(buffer), "#{model} #{buffer} before #{date}"
  end
end

def create_records_around date, model
  create_records_before(date, model) + create_records_after(date, model)
end

#
# Post creators
#

def create_post date
  create_record Post, date
end

def create_posts_before date
  create_records_before date, Post
end

def create_posts_after date
  create_records_after date, Post
end

def create_posts_around date
  create_records_around date, Post
end

#
# Event creators
#

def create_event date
  create_record Event, date
end

def create_events_before date
  create_records_before date, Event
end

def create_events_after date
  create_records_after date, Event
end

def create_events_around date
  create_records_around date, Event
end


def create_special_events
  Event.factory("Ryan's birthday!",             "#{Time.zone.now.year}-12-04".to_time)
  Event.factory("Ryan's birthday, last year!",  "#{Time.zone.now.year-1}-12-04".to_time)
  Event.factory("Dad's birthday!",              "#{Time.zone.now.year}-07-05".to_time)
  Event.factory("Mum's birthday!",              "#{Time.zone.now.year}-11-17".to_time)

  Event.create!(
    name: "NSA meeting",
    start_time: "#{Time.zone.now.year}-03-02".to_time,
    :public => false
  )
end
