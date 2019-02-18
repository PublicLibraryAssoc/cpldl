require "rails_helper"

describe MyCoursesController do
  let(:organization) { FactoryGirl.create(:organization) }
  let(:language) { FactoryGirl.create(:language) }
  let(:category) { FactoryGirl.create(:category, organization: organization) }
  let(:disabled_category) { FactoryGirl.create(:category, :disabled, organization: organization) }
  let(:course1) { FactoryGirl.create(:course, title: "Course 1", language: language, category: category, organization: organization) }
  let(:course2) { FactoryGirl.create(:course, title: "Course 2", language: language, organization: organization) }
  let(:course3) { FactoryGirl.create(:course, title: "Course 3", language: language, organization: organization) }
  let(:course4) { FactoryGirl.create(:course, title: "Course 4", language: language, category: disabled_category, organization: organization) }
  let(:user) { FactoryGirl.create(:user, organization: organization) }

  context "authenticated user" do

    before(:each) do
      request.host = "#{organization.subdomain}.example.com"
      sign_in user
    end

    describe "GET #index" do
      let!(:course_progress1) { FactoryGirl.create(:course_progress, user: user, course_id: course1.id, tracked: true) }
      let!(:course_progress2) { FactoryGirl.create(:course_progress, user: user, course_id: course2.id, tracked: false) }
      let!(:course_progress3) { FactoryGirl.create(:course_progress, user: user, course_id: course3.id, tracked: true) }
      let!(:course_progress4) { FactoryGirl.create(:course_progress, user: user, course_id: course4.id, tracked: true) }

      before(:each) do
        user.course_progresses << [course_progress1, course_progress2, course_progress3]
      end

      it "allows the user to view their tracked courses" do
        get :index
        expect(assigns(:courses)).to include(course1, course3, course4)
      end

      it "assigns @results if search params exist" do
        course1.update(description: "Mocha Java Scripta")
        get :index, { search: "java" }
        expect(assigns(:results)).to eq([course1])
      end

      it "assigns search results to @courses" do
        course1.update(description: "Mocha Java Scripta")
        get :index, { search: "java" }
        expect(assigns(:courses)).to eq([course1])
      end

      it "assigns categories" do
        get :index
        expect(assigns(:category_ids)).to eq([category.id])
      end

      it "assigns uncategorized courses including courses with a disabled category" do
        get :index
        expect(assigns(:uncategorized_courses)).to include(course3, course4)
      end
    end

  end

  context "non-authenticated user" do

    before(:each) do
      request.host = "#{organization.subdomain}.example.com"
    end

    describe "GET #index" do
      it "should redirect to login page" do
        get :index
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(user_session_path)
      end
    end

    describe "POST #create" do
      it "should redirect to login page" do
        get :index
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(user_session_path)
      end
    end

  end

end