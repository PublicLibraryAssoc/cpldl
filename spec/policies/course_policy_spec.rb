require 'rails_helper'

describe CoursePolicy, type: :policy do
  let(:user) { FactoryBot.create(:user) }
  let(:organization) { user.organization }
  let(:main_site) { FactoryBot.create(:default_organization) }
  let(:guest_user) { GuestUser.new(organization: organization) }

  let!(:everyone_course) { FactoryBot.create(:course, organization: organization) }
  let!(:authorized_user_course) { FactoryBot.create(:course, organization: organization, access_level: :authenticated_users) }
  let!(:other_subsite_course) { FactoryBot.create(:course) }
  let!(:draft_course) { FactoryBot.create(:draft_course, organization: organization) }
  let!(:archived_course) { FactoryBot.create(:archived_course, organization: organization) }

  subject { described_class }

  describe 'Scope' do
    context 'guest user' do
      let(:scope) { Pundit.policy_scope!(guest_user, Course) }

      it 'should only display public courses' do
        expect(scope).to contain_exactly(everyone_course)
      end
    end

    context 'subsite user' do
      let(:scope) { Pundit.policy_scope!(user, Course) }

      it 'should display public and authorized-user-only courses' do
        expect(scope).to contain_exactly(everyone_course, authorized_user_course)
      end
    end
  end

  permissions :show? do
    context 'guest user' do
      it 'denies access if course is only for authorized users' do
        expect(subject).to_not permit(guest_user, authorized_user_course)
      end

      it 'allows access if course is public' do
        expect(subject).to permit(guest_user, everyone_course)
      end

      it 'denies access for courses from another subsite' do
        expect(subject).to_not permit(guest_user, other_subsite_course)
      end

      it 'denies access for draft courses' do
        expect(subject).to_not permit(guest_user, draft_course)
      end

      it 'denies access for archived courses' do
        expect(subject).to_not permit(guest_user, archived_course)
      end
    end

    context 'authenticated user' do
      it 'allows access if course is public' do
        expect(subject).to permit(user, everyone_course)
      end

      it 'allows access if course is only for authorized users' do
        expect(subject).to permit(user, authorized_user_course)
      end

      it 'denies access for courses from another subsite' do
        expect(subject).to_not permit(user, other_subsite_course)
      end

      it 'denies access for draft courses' do
        expect(subject).to_not permit(user, draft_course)
      end

      it 'denies access for archived courses' do
        expect(subject).to_not permit(user, archived_course)
      end
    end
  end

  permissions :create? do
    pending "add some examples to (or delete) #{__FILE__}"
  end

  permissions :update? do
    pending "add some examples to (or delete) #{__FILE__}"
  end

  permissions :destroy? do
    pending "add some examples to (or delete) #{__FILE__}"
  end
end