# frozen_string_literal: true

class CoursePropagationService

  def initialize(course:, attributes_to_propagate:)
    @course = course
    @attributes_to_propagate = attributes_to_propagate
  end

  def propagate_course_changes
    child_courses.each do |child|
      child.update(@attributes_to_propagate)
    end
  end

  private

  def child_courses
    Course.copied_from_course(@course)
  end
end
