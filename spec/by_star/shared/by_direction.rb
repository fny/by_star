require 'spec_helper'

shared_examples_for "by direction" do

  describe "#before" do

    it "should show the correct number of posts in the past", focus: true do
      posts_before = create_posts_before now
      # FIXME: Should not be counted as before
      # create_post now
      create_posts_after now
      Post.before.all.should match_array posts_before
    end

    it "is aliased as before_now" do
      posts_before = create_posts_before now
      Post.before_now.all.should match_array Post.before.all
    end

    it "should find for a given time" do
      posts = create_posts_before 2.days.ago
      # FIXME: Should not be counted as before
      # create_post 2.days.ago
      create_posts_after 2.days.ago
      Post.before(Time.zone.now - 2.days).all.should match_array posts
    end

    it "should find for a given date" do
      posts = create_posts_before 2.days.ago
      Post.factory("Two days ago", 2.days.ago)
      # FIXME: Should not be counted as before
      # create_post 2.days.ago
      create_posts_after 2.days.ago
      Post.before(Date.today - 2).should match_array posts
    end

    it "should find for a given string" do
      chronic_time = 'next Tuesday'
      next_tuesday = Chronic.parse(chronic_time)
      posts = create_posts_before next_tuesday
      create_posts_after next_tuesday
      Post.before(chronic_time).should match_array posts
    end

    it "raises an exception when Chronic can't parse" do
      lambda { Post.before(";aosdjbjisdabdgofbi").count }.should raise_error(ByStar::ParseError)
    end

    it "should be able to find all events before Ryan's birthday using a non-standard field" do
      ryans_birthday = "#{Time.zone.now.year}-12-04".to_time

      # Events before Ryan's birthday
      events_before_ryans_birthday = [
        Event.factory(
          "Ryan's birthday, last year!",  ryans_birthday - 1.year),
        Event.factory(
          "NSA meeting", "#{Time.zone.now.year}-03-02".to_time, :public => false),
        Event.factory(
          "Dad's birthday!", "#{Time.zone.now.year}-07-05".to_time),
        Event.factory(
          "Mum's birthday!", "#{Time.zone.now.year}-11-17".to_time)
      ]
      # Other events
      # FIXME: Should not be counted as before
      # Event.factory("Ryan's birthday!",          ryans_birthday)
      Event.factory("Ryan's birthday next year", ryans_birthday + 1.year)

      Event.before(
        ryans_birthday, :field => "start_time"
      ).all.should match_array events_before_ryans_birthday
    end
  end

  describe "#after" do
    it "should show the correct number of posts in the future" do
      posts = create_posts_after now
      # FIXME: Should not be counted as before
      # create_post now
      create_posts_before now
      Post.after.all.should match_array posts
    end

    it "should find for a given date" do
      posts = create_posts_after 2.days.ago
      # FIXME: Should not be counted as before
      # create_post 2.days.ago
      create_posts_before 2.days.ago
      Post.after(Date.today - 2).should match_array posts
    end

    it "should find for a given string" do
      chronic_time = 'next Tuesday'
      next_tuesday = Chronic.parse(chronic_time)
      posts = create_posts_after next_tuesday
      create_posts_before next_tuesday
      Post.after(chronic_time).should match_array posts
    end

    it "should be able to find all events after Dad's birthday using a non-standard field" do
      # Events after Dad's birthday
      events_after_dads_birthday = [
        Event.factory(
          "Ryan's birthday!",             "#{Time.zone.now.year}-12-04".to_time),
        Event.factory(
          "Mum's birthday!",              "#{Time.zone.now.year}-11-17".to_time)
      ]

      # Other events
      Event.create!(
        name: "NSA meeting",
        start_time: "#{Time.zone.now.year}-03-02".to_time,
        :public => false
      )
      Event.factory(
          "Ryan's birthday, last year!",  "#{Time.zone.now.year-1}-12-04".to_time)
      # FIXME: Should not be counted as after
      # Event.factory("Dad's birthday!", "#{Time.zone.now.year}-07-05".to_time)

      Event.after(
        Time.zone.local(Time.zone.now.year, 7, 5), :field => "start_time"
      ).all.should match_array events_after_dads_birthday
    end
  end

  describe "traversal" do
    before(:all) do
      # Posts
      @current_post   = Post.factory("Current Post", 1.day.ago).freeze
      @next_post      = Post.factory("Next Post", Date.today).freeze
      @previous_post  = Post.factory("Previous Post", 2.days.ago).freeze

      # Events
      @current_event  = Event.factory("Mum's birthday!", "#{Time.zone.now.year}-11-17").freeze
      @next_event     = Event.factory("Ryan's birthday!", "#{Time.zone.now.year}-12-04").freeze
      @previous_event = Event.factory("Dad's birthday!", "#{Time.zone.now.year}-07-05").freeze
    end

    describe "#previous" do
      it "can find the previous post" do
        @current_post.previous.text.should == @previous_post.text
      end

      it "takes the field option" do
        @current_event.previous(:field => "start_time").name.should == @previous_event.name
      end
    end

    describe "#next" do
      it "can find the next post" do
        @current_post.next.text.should == @next_post.text
      end

      it "takes the field option" do
        @current_event.next(:field => "start_time").name.should == @next_event.name
      end
    end
  end
end
