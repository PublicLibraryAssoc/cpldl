# frozen_string_literal: true

require 'rails_helper'

describe Admin::LessonsController do
  let(:org) { FactoryBot.create(:organization) }
  let(:admin) { FactoryBot.create(:user, :admin, organization: org) }
  let(:course) { FactoryBot.create(:course, organization: org) }
  let(:lesson1) { FactoryBot.create(:lesson, title: 'Lesson1', course: course, lesson_order: 1) }
  let(:lesson2) { FactoryBot.create(:lesson, title: 'Lesson2', course: course, lesson_order: 2) }

  before(:each) do
    @request.host = "#{org.subdomain}.test.host"
    sign_in admin
  end

  describe 'GET #edit' do
    it 'assigns the requested lesson as @lesson' do
      get :edit, params: { course_id: course.to_param, id: lesson1.id.to_param }
      expect(assigns(:lesson)).to eq(lesson1)
    end
  end

  describe 'GET #new' do
    it 'assigns a new lesson as @lesson' do
      get :new, params: { course_id: course.to_param }
      expect(assigns(:lesson)).to be_a_new(Lesson)
    end
  end

  describe 'POST #create' do
    let(:story_line) { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'BasicSearch1.zip'), 'application/zip') }

    let(:valid_attributes) do
      { duration: '01:20',
        title:  'Lesson your load man',
        seo_page_title:  'Seo | Beo | Meo ',
        meta_desc:  'Its good to Meta-Tate',
        summary:  'Sum-tings-smelly',
        is_assessment: false,
        story_line: story_line,
        pub_status: 'P' }
    end

    let(:assessment_attributes) do
      { duration: '01:20',
        title:  'I am an assessment',
        seo_page_title:  'See | Bee | Mee ',
        meta_desc:  'is this like inception',
        summary:  'Sum-tings-smelly',
        is_assessment: true,
        story_line: story_line,
        pub_status: 'P' }
    end

    let(:invalid_attributes) do
      { duration: '',
        title:  '',
        seo_page_title:  '',
        meta_desc:  '',
        summary:  '',
        is_assessment: '',
        story_line: nil,
        pub_status: nil }
    end

    context 'with valid params' do
      it 'creates a new lesson' do
        expect do
          post :create, params: { course_id: course.to_param, lesson: valid_attributes }
        end.to change(Lesson, :count).by(1)
      end

      it 'creates a new assessment' do
        expect do
          post :create, params: { course_id: course.to_param, lesson: assessment_attributes }
        end.to change(Lesson, :count).by(1)
      end

      it 'assigns a new assessment to the end of the course lessons' do
        FactoryBot.create(:lesson, course: course)
        post :create, params: { course_id: course.to_param, lesson: assessment_attributes }
        lesson = Lesson.last
        expect(lesson.lesson_order).to eq(2)
      end

      it 'does not create a second assessment' do
        post :create, params: { course_id: course.to_param, lesson: assessment_attributes }
        expect do
          post :create, params: { course_id: course.to_param, lesson: assessment_attributes, title: 'something different' }
        end.to_not change(Lesson, :count)
      end

      it 'assigns a new lesson as @lesson' do
        post :create, params: { course_id: course.to_param, lesson: valid_attributes }
        expect(assigns(:lesson)).to be_a(Lesson)
        expect(assigns(:lesson)).to be_persisted
      end

      it 'redirects to the admin edit view of the lesson' do
        post :create, params: { course_id: course.to_param, lesson: valid_attributes }
        expect(response).to redirect_to(edit_admin_course_lesson_path(course, 'lesson-your-load-man'))
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved lesson as @lesson' do
        post :create, params: { course_id: course.to_param, lesson: invalid_attributes }
        expect(assigns(:lesson)).to be_a_new(Lesson)
      end

      it "re-renders the 'new' template" do
        post :create, params: { course_id: course.to_param, lesson: invalid_attributes }
        expect(response).to render_template('new')
      end
    end
  end

  describe 'POST #update' do
    context 'with valid params' do
      it 'updates an existing Lesson' do
        update_params = { course_id: course.to_param, id: lesson1.to_param,
                          lesson: lesson1.attributes, commit: 'Save Lesson' }
        patch :update, params: update_params
        expect(response).to have_http_status(:redirect)
      end

      it 'updates with duration as a string' do
        @lesson_attributes = lesson1.attributes
        @lesson_attributes['duration'] = '1:00'
        update_params = { course_id: course.to_param, id: lesson1.to_param,
                          lesson: @lesson_attributes, commit: 'Save Lesson' }
        patch :update, params: update_params
        expect(response).to have_http_status(:redirect)
      end

      it 'propagates updates to child lessons' do
        org = create(:organization)
        child_course = create(:course, organization: org)
        lesson1_child = create(:lesson, course: child_course, parent: lesson1)
        update_params = { course_id: course.to_param, id: lesson1.to_param,
                          lesson: lesson1.attributes.merge(propagation_org_ids: [org.id], title: 'Test Lesson'),
                          commit: 'Save Lesson' }
        patch :update, params: update_params

        lesson1_child.reload
        expect(lesson1_child.title).to eq('Test Lesson')
      end
    end
  end

  describe 'POST #sort' do
    it 'should change course order' do
      order_params = { '0' => { id: lesson2.id, position: 1 }, '1' => { id: lesson1.id, position: 2 } }
      post :sort, params: { order: order_params }

      expect(lesson1.reload.lesson_order).to eq(2)
      expect(lesson2.reload.lesson_order).to eq(1)
    end
  end
end
