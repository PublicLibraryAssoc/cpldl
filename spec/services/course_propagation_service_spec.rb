# frozen_string_literal: true

require 'rails_helper'

describe CoursePropagationService do
  let(:pla) { FactoryBot.create(:default_organization) }
  let(:course) { FactoryBot.create(:course_with_lessons, organization: pla) }
  let!(:child_course) { FactoryBot.create(:course, parent: course) }

  describe 'model attribute changes' do
    let(:new_attributes) do
      {
        title: 'New Course Title',
        contributor: 'New Contributor',
        summary: 'New Summary',
        description: 'New Description',
        notes: 'New Notes',
        language: @spanish,
        format: 'M',
        level: 'Advanced',
        seo_page_title: 'New SEO Title',
        meta_desc: 'New Meta Desc'
      }
    end

    subject { described_class.new(course: course, attributes_to_propagate: new_attributes) }

    it 'should update child course info' do
      subject.propagate_course_changes
      child_course.reload
      new_attributes.keys.each do |k|
        expect(child_course.send(k)).to eq(new_attributes[k])
      end
    end
  end

  describe 'attachment update' do
    let(:attachment) { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'testfile.pdf'), 'application/pdf') }
    let(:attachment_attributes) do
      {
        attachments_attributes: {
          '0' => {
            document: attachment,
            title: 'Test post-course attachment',
            doc_type: 'post-course',
            file_description: 'post-course attachment test'
          },
          '1' => {
            document: attachment,
            title: 'Test supplemental attachment',
            doc_type: 'supplemental',
            file_description: 'supplemental attachment test'
          }
        }
      }
    end

    subject { described_class.new(course: course, attributes_to_propagate: attachment_attributes) }

    it 'should update child attachments' do
      expect do
        subject.propagate_course_changes
      end.to change { child_course.attachments.count }.by(2)
    end

    it 'should add a post-course attachment' do
      expect do
        subject.propagate_course_changes
      end.to change { child_course.post_course_attachments.count }.by(1)
    end

    it 'should add a supplemental attachment' do
      expect do
        subject.propagate_course_changes
      end.to change { child_course.supplemental_attachments.count }.by(1)
    end
  end

  describe 'topic changes' do
    let!(:topic1) { FactoryBot.create(:topic) }
    let(:topic_attributes) do
      {
        topic_ids: [topic1.id],
        course_topics_attributes: [{ topic_attributes: { title: 'Some new topic' } }]
      }
    end

    subject { described_class.new(course: course, attributes_to_propagate: topic_attributes) }

    it 'should propagate topic changes' do
      expect do
        subject.propagate_course_changes
      end.to change { child_course.topics.count }.by(2)
    end

    it 'should create new custom topic' do
      expect do
        subject.propagate_course_changes
      end.to change(Topic, :count).by(1)
    end

    it 'should add existing topic to child course' do
      subject.propagate_course_changes
      expect(child_course.reload.topics).to include(topic1)
    end
  end

  it 'should not change child course category' do
  end

  it 'should not change child course access level' do
  end
end
