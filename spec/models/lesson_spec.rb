# == Schema Information
#
# Table name: lessons
#
#  id                      :integer          not null, primary key
#  lesson_order            :integer
#  title                   :string(90)
#  duration                :integer
#  course_id               :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  slug                    :string
#  summary                 :string(156)
#  story_line              :string(156)
#  seo_page_title          :string(90)
#  meta_desc               :string(156)
#  is_assessment           :boolean
#  story_line_file_name    :string
#  story_line_content_type :string
#  story_line_file_size    :integer
#  story_line_updated_at   :datetime
#  pub_status              :string
#  parent_lesson_id        :integer
#

require "rails_helper"

describe Lesson do

  context "validations" do

    before(:each) do
      @lesson = FactoryGirl.create(:lesson)
    end

    it "initially it is valid" do
      expect(@lesson).to be_valid
    end

  end

  context "scopes" do

    context ".published" do

      it "returns all published lessons" do
        @course = FactoryGirl.create(:course_with_lessons)
        expect(@course.lessons.published).to contain_exactly(@course.lessons.first, @course.lessons.second, @course.lessons.third)
      end

      it "returns all published lessons" do
        @course = FactoryGirl.create(:course_with_lessons)
        @course.lessons.second.update(pub_status: "D")
        expect(@course.lessons.published).to contain_exactly(@course.lessons.first, @course.lessons.third)
      end

      it "returns all published lessons" do
        @course = FactoryGirl.create(:course_with_lessons)
        @course.lessons.second.update(pub_status: "A")
        expect(@course.lessons.published).to contain_exactly(@course.lessons.first, @course.lessons.third)
      end

    end

  end

  context "#published_lesson_order" do

    it "returns the order of only published lessons" do
      @course = FactoryGirl.create(:course_with_lessons)
      @course.lessons.second.update(pub_status: "D")
      expect(@course.lessons.first.published_lesson_order).to eq 1
      expect(@course.lessons.second.published_lesson_order).to eq 0
      expect(@course.lessons.third.published_lesson_order).to eq 2
    end

  end

end
