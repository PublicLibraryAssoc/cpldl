# frozen_string_literal: true

require 'feature_helper'

feature 'Admin user creates new course and lesson' do
  let(:org) { FactoryBot.create(:organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: org) }
  let!(:topic) { FactoryBot.create(:topic) }
  let!(:category) { FactoryBot.create(:category, organization: org) }
  let!(:disabled_category) { FactoryBot.create(:category, :disabled, organization: org) }
  let(:course) { FactoryBot.create(:course, organization: org) }
  let(:story_line) do
    Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'BasicSearch1.zip'), 'application/zip')
  end
  let(:new_category_name) { Faker::Lorem.word }

  def fill_basic_course_info
    fill_in :course_title, with: 'New Course Title'
    fill_in :course_contributor, with: 'Jane Doe'
    fill_in :course_summary, with: 'Summary for new course'
    fill_in :course_description, with: 'Description for new course'
    check 'Topic A'
    check 'Other Topic'
    fill_in :course_other_topic_text, with: 'Some New Topic'
    select('Desktop', from: 'course_format')
    select('English', from: 'course_language_id')
    select('Beginner', from: 'course_level')
    select('Published', from: 'course_pub_status')
  end

  before(:each) do
    switch_to_subdomain(org.subdomain)
    login_as admin
    visit new_admin_course_path
  end

  scenario 'creates course with new category' do
    expect(page).to have_content('Course Information')
    fill_basic_course_info
    select('Create new category', from: 'course_category_id')
    fill_in :course_category_attributes_name, with: new_category_name
    click_button 'Save Course'
    expect(page).to have_content('Course was successfully created.')
    expect(current_path).to eq(edit_admin_course_path(Course.last))
    expect(page).to have_select('course_category_id', selected: Course.last.category.name)
  end

  scenario 'creates new course with existing category' do
    fill_basic_course_info
    select(category.name, from: 'course_category_id')
    click_button 'Save Course'
    expect(page).to have_content('Course was successfully created.')
    expect(current_path).to eq(edit_admin_course_path(Course.last))
    expect(page).to have_select('course_category_id', selected: category.name)
  end

  scenario 'can see which categories are disabled' do
    expect(page).to have_select('course_category_id', with_options: [category.name.to_s, "#{disabled_category.name} (disabled)"])
  end

  scenario 'attempts to create duplicate category' do
    select('Create new category', from: 'course_category_id')
    fill_in :course_category_attributes_name, with: category.name
    click_button 'Save Course'
    expect(page).to have_content('Category Name is already in use by your organization.')
    expect(page).to have_select('course_category_id', selected: 'Create new category')
    expect(page).to have_selector(:css, ".field_with_errors #course_category_attributes_name[value='#{category.name}']")
  end

  scenario 'adds supplemental materials and post-course supplemental materials' do
    fill_basic_course_info
    attach_file 'Text copies of the course', Rails.root.join('spec', 'fixtures', 'Why_Use_a_Computer_1.pdf')
    attach_file 'Additional Resources (post-completion)', Rails.root.join('spec', 'fixtures', 'Why_Use_a_Computer_Worksheet.pdf')
    click_button 'Save Course'
    expect(page).to have_content('Course was successfully created.')
    expect(page).to have_content('Why_Use_a_Computer_1.pdf')
    expect(page).to have_content('Why_Use_a_Computer_Worksheet.pdf')
  end

  scenario 'adds a lesson' do
    visit edit_admin_course_path(course_id: course, id: course.id)
    click_button 'Save Course and Add Lessons'
    expect(current_path).to eq(new_admin_course_lesson_path(course))
    fill_in :lesson_title, with: 'New Lesson Title'
    fill_in :lesson_summary, with: 'Summary for new lesson'
    fill_in :lesson_duration, with: '05:15'
    attach_file 'Articulate Storyline Package', Rails.root.join('spec', 'fixtures', 'BasicSearch1.zip')
    select 'Published', from: 'Publication Status'
    click_button 'Save Lesson'
    expect(page).to have_content('Lesson was successfully created.')
    expect(current_path).to eq(edit_admin_course_lesson_path(course.to_param, Lesson.last.to_param))

    click_link 'Add Another Lesson'
    expect(current_path).to eq(new_admin_course_lesson_path(course.to_param))
  end

  scenario 'attempts to add two assessments' do
    FactoryBot.create(:lesson, course: course, is_assessment: true)
    visit edit_admin_course_path(course_id: course, id: course.id)
    click_button 'Save Course and Edit Lessons'
    click_link 'Add Another Lesson'
    expect(current_path).to eq(new_admin_course_lesson_path(course))
    page.find('#lesson_is_assessment_true').click
    click_button 'Save Lesson'

    expect(page).to have_content('There can only be one assessment for a Course.')
    expect(page).to have_content('If you are sure you want to replace it, please delete the existing one and try again.')
    expect(page).to have_content('Otherwise, please edit the existing assessment for this course.')
  end
end
