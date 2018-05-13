# == Schema Information
#
# Table name: organizations
#
#  id               :integer          not null, primary key
#  name             :string
#  subdomain        :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  branches         :boolean
#  accepts_programs :boolean
#

require "rails_helper"

RSpec.describe Organization, type: :model do
  before do
    @org = create(:organization)
    other_org = create(:organization, subdomain: "www")
    @user1 = create(:user, organization: @org)
    @user1.add_role("admin", @org)

    @user2 = create(:user, organization: @org)
    @user2.add_role("admin", @org)

    @user3 = create(:user, organization: @org)
    @user3.add_role("user", @org)

    @user4 = create(:user, organization: other_org)
    @user4.add_role("user", other_org)
  end

  it { should have_many(:cms_pages) }
  it { should have_many(:library_locations) }

  describe 'scopes' do
    describe 'using_lesson' do
      it 'includes only orgs using the passed lesson' do
        lesson_org = create(:organization)
        other_org = create(:organization)
        parent_lesson = create(:lesson)
        lesson = create(:lesson, parent_id: parent_lesson.id, course: create(:course))
        lesson_org.courses << lesson.course

        expect(Organization.using_lesson(parent_lesson.id)).to eq([lesson_org])
      end
    end
  end

  describe "#users_count" do
    it "returns the count of its users" do
      expect(@org.user_count).to eq(3)
    end
  end

  describe "#admin_user_emails" do
    it "returns emails of the admins" do
      expect(@org.admin_user_emails).to include(@user1.email)
      expect(@org.admin_user_emails).to include(@user2.email)
      expect(@org.admin_user_emails).not_to include(@user3.email)
      expect(@org.admin_user_emails).not_to include(@user4.email)
    end
  end

  describe '#base_site?' do
    it 'returns true if the org has the www subdomain' do
      subject.update(subdomain: 'www')
      expect(subject.base_site?).to eq(true)
    end

    it 'returns false if the org does not have the www subdomain' do
      expect(subject.base_site?).to eq(false)
    end
  end
end
