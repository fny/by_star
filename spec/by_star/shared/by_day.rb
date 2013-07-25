require 'spec_helper'

shared_examples_for "by day" do

  describe "#by_day" do
    it "should be able to find a post for today" do
      posts = Array.new(2) { Post.factory "Today's post", now }
      create_posts_around now
      Post.by_day.should == posts
    end

    it "should be able to find a post by a given date in last year" do
      posts = Array.new(2) { Post.factory "This time, last year", 1.year.ago }
      create_posts_around 1.year.ago
      Post.by_day(:year => (Time.zone.now.year - 1)).all.should == posts
    end

    it "should be able to use an alternative field" do
      events = Array.new { Event.factory("Yesterday", 1.day.ago) }
      create_events_around 1.day.ago
      Event.by_day(1.day.ago, :field => "start_time").all.should  == events
    end

    it "should be able to use a date" do
      posts = Array.new(2) { Post.factory "Today's post", now }
      Post.by_day(Date.today).all.should == posts
    end

    it "should be able to use a standard date String" do
      posts = Array.new(2) { Post.factory "Today's post", now }
      create_posts_around now
      Post.by_day(Date.today.to_s).all.should == posts
    end
  end

  describe "#today" do
    it "should show the post for today" do
      posts = Array.new(2) { Post.factory("Today's post", now) }
      create_posts_around now
      Post.today.all.should == posts
    end

    it "should be able to use an alternative field" do
      events = Array.new(2) { Event.factory("Today", now) }
      create_events_around now
      Event.today(:field => "start_time").all.should == events
    end
  end

  describe "#yesterday" do
    it "should show the post for yesterday" do
      posts = Array.new(2) { Post.factory("Yesterday's post", 1.day.ago) }
      create_posts_around 1.day.ago
      Post.yesterday.all.should == posts
    end

    it "should be able to use an alternative field" do
      events = Array.new(2) { Event.factory("Yesterday", 1.day.ago) }
      create_events_around 1.day.ago
      Event.yesterday(:field => "start_time").all.should == events
    end
  end

  describe "#tomorrow" do
    it "should show the post for tomorrow" do
      posts = Array.new(2) { Post.factory("Tomorrow's post", 1.day.from_now) }
      create_posts_around 1.day.from_now
      Post.tomorrow.all.should == posts
    end

    it "should be able to use an alternative field" do
      events = Array.new(2) { Event.factory("T", 1.day.from_now) }
      create_events_around 1.day.from_now
      Event.tomorrow(:field => "start_time").all.should == events
    end
  end
end
