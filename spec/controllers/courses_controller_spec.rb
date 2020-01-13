# frozen_string_literal: true

require 'rails_helper'

describe CoursesController do

  before(:each) do
    request.host = 'chipublib.example.com'
    @organization = create(:organization)
    @category1 = create(:category, organization: @organization)
    @category2 = create(:category, :disabled, organization: @organization)

    @course1 = create(:course, title: 'Course 1',
                               description: 'Mocha Java Scripta',
                               organization: @organization,
                               category: @category1)
    @course2 = create(:course, title: 'Course 2',
                               organization: @organization)
    @course3 = create(:course, title: 'Course 3',
                               description: 'Ruby on Rails',
                               organization: @organization)
    @disabled_category_course = create(:course, title: 'Disabled Category Course',
                                                description: 'Foo Bar Baz',
                                                organization: @organization,
                                                category: @category2)
  end

  describe 'GET #index' do
    it 'assigns all courses as @courses' do
      get :index
      expect(assigns(:courses)).to include(@course1, @course2, @course3, @disabled_category_course)
    end

    it 'assigns all courses as @courses with an empty params' do
      get :index, params: {}
      expect(assigns(:courses)).to include(@course1, @course2, @course3, @disabled_category_course)
    end

    it 'assigns search results to @courses' do
      get :index, params: { search: 'ruby' }
      expect(assigns(:courses)).to eq([@course3])
    end

    it 'responds to json' do
      get :index, format: :json
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #show' do
    it 'assigns the requested course (by id) as @course' do
      get :show, params: { id: @course2.to_param }
      expect(assigns(:course)).to eq(@course2)
    end

    it 'assigns the requested course (by friendly id) as @course' do
      get :show, params: { id: @course2.friendly_id }
      expect(assigns(:course)).to eq(@course2)
    end

    it 'allows the admin to change the title, and have the old title redirect to the new title' do
      old_url = @course1.friendly_id
      # @course1.slug = nil # Must set slug to nil for the friendly url to regenerate
      @course1.title = 'New Title'
      @course1.save

      get :show, params: { id: old_url }
      expect(assigns(:course)).to eq(@course1)
      expect(response).to have_http_status(:success)

      get :show, params: { id: @course1.friendly_id }
      expect(assigns(:course)).to eq(@course1)
    end

    it 'responds to json' do
      get :show, params: { id: @course1.to_param, format: :json }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #view_attachment' do
    context 'when logged in' do
      before(:each) do
        @user = create(:user)
        @attachment = create(:attachment)
        sign_in @user
      end

      it 'allows the user to view an uploaded file' do
        file = fixture_file_upload(Rails.root.join('spec', 'fixtures', 'testfile.pdf'), 'application/pdf')
        @course1.attachments.create(document: file, doc_type: 'post-course')
        get :view_attachment, params: { course_id: @course1, attachment_id: @course1.attachments.first.id }
        expect(response).to have_http_status(:success)
      end
    end

    context 'when logged out' do
      it 'should all view' do
        file = fixture_file_upload(Rails.root.join('spec', 'fixtures', 'testfile.pdf'), 'application/pdf')
        @course1.attachments.create(document: file, doc_type: 'post-course')
        get :view_attachment, params: { course_id: @course1, attachment_id: @course1.attachments.first.id }
        expect(response).to have_http_status(:success)
      end
    end
  end

end
